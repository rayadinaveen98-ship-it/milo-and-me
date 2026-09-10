// Portable server core: no child payloads, logs, or bundled credentials.
const enc = new TextEncoder();
const b64 = bytes => btoa(String.fromCharCode(...bytes)).replaceAll('+','-').replaceAll('/','_').replaceAll('=','');
const decode64 = text => Uint8Array.from(atob(text.replaceAll('-','+').replaceAll('_','/')), c => c.charCodeAt(0));
export const digest = async text => [...new Uint8Array(await crypto.subtle.digest('SHA-256', enc.encode(text)))].map(v => v.toString(16).padStart(2,'0')).join('');
export function verifyGoogle(purchase, {parentId, productId, products, now = Date.now()}) {
  if (!products.includes(productId) || purchase.externalAccountIdentifiers?.obfuscatedExternalAccountId !== parentId) throw new Error('Purchase owner or product mismatch');
  const line = purchase.lineItems?.find(l => l.productId === productId);
  const expiry = Date.parse(line?.expiryTime);
  if (!Number.isFinite(expiry)) throw new Error('Missing expiry');
  const active = ['SUBSCRIPTION_STATE_ACTIVE','SUBSCRIPTION_STATE_IN_GRACE_PERIOD','SUBSCRIPTION_STATE_CANCELED'].includes(purchase.subscriptionState) && expiry > now;
  return {product_id: productId, status: active ? 'active' : 'expired', expires_at: new Date(expiry).toISOString(), store: 'google'};
}
export async function seal(text, keyString) {
  const key = await crypto.subtle.importKey('raw', decode64(keyString), 'AES-GCM', false, ['encrypt']);
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const data = new Uint8Array(await crypto.subtle.encrypt({name:'AES-GCM', iv},key,enc.encode(text)));
  return `${b64(iv)}.${b64(data)}`;
}
export async function unseal(text, keyString) {
  const [iv, data] = text.split('.');
  const key = await crypto.subtle.importKey('raw', decode64(keyString), 'AES-GCM', false, ['decrypt']);
  return new TextDecoder().decode(await crypto.subtle.decrypt({name:'AES-GCM',iv:decode64(iv)},key,decode64(data)));
}
export async function googleAccessToken(account, fetcher = fetch) {
  const now = Math.floor(Date.now()/1000);
  const header = b64(enc.encode(JSON.stringify({alg:'RS256',typ:'JWT'})));
  const claims = b64(enc.encode(JSON.stringify({iss:account.client_email,scope:'https://www.googleapis.com/auth/androidpublisher',aud:'https://oauth2.googleapis.com/token',iat:now,exp:now+3600})));
  const pem = account.private_key.replace(/-----[^-]+-----/g,'').replace(/\s/g,'');
  const key = await crypto.subtle.importKey('pkcs8',decode64(pem),{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['sign']);
  const signature = b64(new Uint8Array(await crypto.subtle.sign('RSASSA-PKCS1-v1_5',key,enc.encode(`${header}.${claims}`))));
  const r = await fetcher('https://oauth2.googleapis.com/token',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({grant_type:'urn:ietf:params:oauth:grant-type:jwt-bearer',assertion:`${header}.${claims}.${signature}`})});
  if (!r.ok) throw new Error('Store authentication unavailable');
  const d = await r.json();
  if (typeof d.access_token !== 'string') throw new Error('Invalid store authentication');
  return d.access_token;
}
export function createParentHandler({env, fetcher = fetch, googleLookup}) {
  const base = env.SUPABASE_URL;
  const service = env.SUPABASE_SERVICE_ROLE_KEY;
  const headers = {'apikey': service, 'Authorization': `Bearer ${service}`, 'Content-Type':'application/json'};
  async function db(path, method='GET', body) {
    const r = await fetcher(`${base}/rest/v1/${path}`,{method,headers:{...headers,Prefer:'return=representation,resolution=merge-duplicates'},body:body === undefined ? undefined : JSON.stringify(body)});
    if (!r.ok) throw new Error('Database request failed');
    const text = await r.text(); return text ? JSON.parse(text) : null;
  }
  async function lookup(token) {
    if (googleLookup) return googleLookup(token);
    const bearer = await googleAccessToken(JSON.parse(env.GOOGLE_SERVICE_ACCOUNT_JSON),fetcher);
    const r = await fetcher(`https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(env.ANDROID_PACKAGE)}/purchases/subscriptionsv2/tokens/${encodeURIComponent(token)}`,{headers:{Authorization:`Bearer ${bearer}`}});
    if (!r.ok) throw new Error('Store verification unavailable');
    return r.json();
  }
  const products = [env.MILO_MONTHLY_PRODUCT,env.MILO_ANNUAL_PRODUCT].filter(Boolean);
  async function saveVerified(parentId, productId, token) {
    const result = verifyGoogle(await lookup(token),{parentId,productId,products});
    const hash = await digest(token);
    // A service-only SQL function locks the token hash and rejects cross-account
    // reassignment atomically. Receipt bytes are encrypted before database storage.
    await db('rpc/retain_verified_purchase','POST',{p_parent:parentId,p_hash:hash,p_cipher:await seal(token,env.PURCHASE_ENCRYPTION_KEY),p_product:productId,p_status:result.status,p_expiry:result.expires_at});
    return result;
  }
  return async request => {
    try {
      if (request.method !== 'POST') return Response.json({error:'POST required'},{status:405});
      const bearer = request.headers.get('Authorization') ?? '';
      if (!bearer.startsWith('Bearer ') || bearer.length > 16384) return Response.json({error:'Parent sign-in required'},{status:401});
      const userResponse = await fetcher(`${base}/auth/v1/user`,{headers:{apikey:env.SUPABASE_PUBLISHABLE_KEY,Authorization:bearer}});
      if (!userResponse.ok) return Response.json({error:'Parent sign-in required'},{status:401});
      const user = await userResponse.json();
      if (!user.id || !user.email_confirmed_at || user.is_anonymous === true) return Response.json({error:'Confirmed parent email required'},{status:403});
      // Claims are decoded only after the Auth server has verified the token.
      const claims = JSON.parse(new TextDecoder().decode(decode64(bearer.slice(7).split('.')[1])));
      if (claims.sub !== user.id || !claims.session_id || !await db('rpc/parent_session_valid','POST',{p_parent:user.id,p_session:claims.session_id})) return Response.json({error:'Parent session expired'},{status:401});
      const raw = await request.text();
      if (raw.length > 16384) return Response.json({error:'Request too large'},{status:413});
      const body = JSON.parse(raw), action = body.action;
      const allowed = {consent:['action','policy_version','accepted'],entitlement:['action'],verify_purchase:['action','product_id','purchase_token'],delete_account:['action','confirm']};
      if (!allowed[action] || Object.keys(body).some(k => !allowed[action].includes(k))) return Response.json({error:'Unsupported fields'},{status:400});
      if (action === 'consent') {
        if (body.policy_version !== '2026-09-v1' || body.accepted !== true) return Response.json({error:'Explicit current consent required'},{status:400});
        await db('parent_accounts','POST',{id:user.id});
        await db('consent_records?on_conflict=parent_id,policy_version','POST',{parent_id:user.id,policy_version:body.policy_version,verification_method:'confirmed-parent-email-and-declaration'});
        return Response.json({ok:true});
      }
      if (action === 'delete_account') {
        if (body.confirm !== true) return Response.json({error:'Confirmation required'},{status:400});
        const out = await fetcher(`${base}/auth/v1/logout?scope=global`,{method:'POST',headers:{apikey:env.SUPABASE_PUBLISHABLE_KEY,Authorization:bearer}});
        if (!out.ok) throw new Error('Session revocation failed');
        const deleted = await fetcher(`${base}/auth/v1/admin/users/${encodeURIComponent(user.id)}`,{method:'DELETE',headers});
        if (!deleted.ok) throw new Error('Account deletion failed');
        return Response.json({ok:true});
      }
      const consent = await db(`consent_records?parent_id=eq.${encodeURIComponent(user.id)}&policy_version=eq.2026-09-v1&revoked_at=is.null&select=id&limit=1`);
      if (!consent.length) return Response.json({error:'Current parent consent required'},{status:403});
      if (action === 'verify_purchase') {
        if (typeof body.purchase_token !== 'string' || body.purchase_token.length < 8 || body.purchase_token.length > 8192 || !products.includes(body.product_id)) return Response.json({error:'Invalid receipt'},{status:400});
        const verified = await saveVerified(user.id,body.product_id,body.purchase_token);
        verified.expires_at = new Date(Math.min(Date.parse(verified.expires_at),Date.now()+24*3600000)).toISOString();
        return Response.json(verified);
      }
      const tokens = await db(`purchase_tokens?parent_id=eq.${encodeURIComponent(user.id)}&select=ciphertext,product_id&order=verified_at.desc&limit=10`);
      const verified = [];
      for (const t of tokens) verified.push(await saveVerified(user.id,t.product_id,await unseal(t.ciphertext,env.PURCHASE_ENCRYPTION_KEY)));
      verified.sort((a,b) => (b.status === 'active') - (a.status === 'active') || Date.parse(b.expires_at) - Date.parse(a.expires_at));
      const e = verified[0] ?? null;
      // Bound offline access after a verified refresh; never invent a new term.
      if (e) e.expires_at = new Date(Math.min(Date.parse(e.expires_at),Date.now()+24*3600000)).toISOString();
      return Response.json({entitlement:e});
    } catch (_) {
      // Do not echo bearer tokens, email addresses or purchase receipts.
      return Response.json({error:'Parent service unavailable; local play is safe'},{status:503});
    }
  };
}
