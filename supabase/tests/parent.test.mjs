import test from 'node:test';
import assert from 'node:assert/strict';
import {verifyGoogle,seal,unseal,createParentHandler} from '../functions/_shared/parent.mjs';
const parentId='00000000-0000-0000-0000-000000000001';
const config={parentId,productId:'monthly',products:['monthly','annual'],now:1000};
const purchase={subscriptionState:'SUBSCRIPTION_STATE_ACTIVE',externalAccountIdentifiers:{obfuscatedExternalAccountId:parentId},lineItems:[{productId:'monthly',expiryTime:new Date(5000).toISOString()}]};
test('Receipt owner, product, expiry and state are authoritative',()=>{
 assert.equal(verifyGoogle(purchase,config).status,'active');
 assert.throws(()=>verifyGoogle(purchase,{...config,parentId:'other'}));
 assert.throws(()=>verifyGoogle(purchase,{...config,productId:'annual'}));
 assert.equal(verifyGoogle(purchase,{...config,now:5000}).status,'expired');
 assert.equal(verifyGoogle({...purchase,subscriptionState:'SUBSCRIPTION_STATE_REVOKED'},config).status,'expired');
 assert.equal(verifyGoogle({...purchase,subscriptionState:'SUBSCRIPTION_STATE_CANCELED'},config).status,'active');
});
test('Stored purchase tokens are authenticated ciphertext',async()=>{
 const key=Buffer.alloc(32,7).toString('base64');
 const ciphertext=await seal('private-purchase-token',key);
 assert.equal(await unseal(ciphertext,key),'private-purchase-token');
 await assert.rejects(()=>unseal(ciphertext,Buffer.alloc(32,8).toString('base64')));
 assert.ok(!ciphertext.includes('private-purchase-token'));
});
function fixture({session=true, user=true}={}) {
 const calls=[];
 const fetcher=async(url,init)=>{
  calls.push({url,init});
  if(url.endsWith('/auth/v1/user')) return Response.json(user?{id:parentId,email_confirmed_at:'2026-01-01'}:{},{status:user?200:401});
  if(url.includes('parent_session_valid')) return Response.json(session);
  return Response.json([]);
 };
 const handler=createParentHandler({env:{SUPABASE_URL:'https://fixture.test',SUPABASE_SERVICE_ROLE_KEY:'server-test',SUPABASE_PUBLISHABLE_KEY:'public-test'},fetcher});
 const jwt=`a.${Buffer.from(JSON.stringify({sub:parentId,session_id:'fixture'})).toString('base64url')}.b`;
 return {calls,send:body=>handler(new Request('https://fixture.test/parent',{method:'POST',headers:{Authorization:`Bearer ${jwt}`},body:JSON.stringify(body)}))};
}
test('Expired server sessions cannot write even with a formerly valid JWT',async()=>{ const f=fixture({session:false}); assert.equal((await f.send({action:'consent',policy_version:'2026-09-v1',accepted:true})).status,401); assert.equal(f.calls.length,2); });
test('Unknown child fields and unconfirmed consent are rejected',async()=>{ const f=fixture(); assert.equal((await f.send({action:'consent',policy_version:'2026-09-v1',accepted:true,nickname:'child'})).status,400); assert.equal((await f.send({action:'consent',policy_version:'old',accepted:true})).status,400); });
test('Consent account identity is derived from the verified server user',async()=>{const f=fixture();assert.equal((await f.send({action:'consent',policy_version:'2026-09-v1',accepted:true})).status,200);const account=f.calls.find(c=>c.url.endsWith('/parent_accounts'));assert.equal(JSON.parse(account.init.body).id,parentId);});
test('Purchase endpoint verifies Google, binds ownership, encrypts and stores through atomic RPC',async()=>{
 const calls=[];
 const env={SUPABASE_URL:'https://fixture.test',SUPABASE_SERVICE_ROLE_KEY:'server-test',SUPABASE_PUBLISHABLE_KEY:'public-test',MILO_MONTHLY_PRODUCT:'monthly',MILO_ANNUAL_PRODUCT:'annual',PURCHASE_ENCRYPTION_KEY:Buffer.alloc(32,4).toString('base64')};
 const jwt=`a.${Buffer.from(JSON.stringify({sub:parentId,session_id:'fixture'})).toString('base64url')}.b`;
 const fetcher=async(url,init)=>{calls.push({url,init});if(url.endsWith('/auth/v1/user'))return Response.json({id:parentId,email_confirmed_at:'2026-01-01'});if(url.includes('parent_session_valid'))return Response.json(true);if(url.includes('consent_records?'))return Response.json([{id:'consent'}]);return Response.json(null);};
 let owner=parentId;
 const handler=createParentHandler({env,fetcher,googleLookup:async()=>({...purchase,externalAccountIdentifiers:{obfuscatedExternalAccountId:owner},lineItems:[{productId:'monthly',expiryTime:new Date(Date.now()+30*86400000).toISOString()}]})});
 const send=()=>handler(new Request('https://fixture.test/parent',{method:'POST',headers:{Authorization:`Bearer ${jwt}`},body:JSON.stringify({action:'verify_purchase',product_id:'monthly',purchase_token:'private-receipt-token'})}));
 const r=await send();assert.equal(r.status,200);const data=await r.json();assert.equal(data.status,'active');assert.ok(Date.parse(data.expires_at)<=Date.now()+86400000);
 const stored=JSON.parse(calls.find(c=>c.url.endsWith('retain_verified_purchase')).init.body);assert.equal(stored.p_parent,parentId);assert.equal(await unseal(stored.p_cipher,env.PURCHASE_ENCRYPTION_KEY),'private-receipt-token');assert.equal(stored.p_hash.length,64);
 calls.length=0;owner='another-parent';assert.equal((await send()).status,503);assert.equal(calls.filter(c=>c.url.endsWith('retain_verified_purchase')).length,0);
});
