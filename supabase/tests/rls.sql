\set ON_ERROR_STOP on
insert into auth.users values ('00000000-0000-0000-0000-000000000001'),('00000000-0000-0000-0000-000000000002');
insert into auth.sessions values ('00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000001');
insert into public.parent_accounts(id) select id from auth.users;
insert into public.consent_records(parent_id,policy_version,verification_method) select id,'2026-09-v1','fixture' from auth.users;
insert into public.entitlements(parent_id,product_id,status,expires_at,store) select id,'monthly','active',now()+interval '1 day','google' from auth.users;
insert into public.content_packs values ('visible','Visible',1,1,'https://example.com/a',repeat('a',64),'free',true),('hidden','Hidden',1,1,'https://example.com/b',repeat('b',64),'premium',false);
set role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',false);
do $$begin
 if (select count(*) from public.parent_accounts)<>1 then raise exception 'Parent isolation failed'; end if;
 if (select count(*) from public.consent_records)<>1 then raise exception 'Consent isolation failed'; end if;
 if (select count(*) from public.entitlements)<>1 then raise exception 'Entitlement isolation failed'; end if;
 if (select count(*) from public.content_packs)<>1 then raise exception 'Unpublished pack leaked'; end if;
 begin update public.entitlements set status='revoked'; raise exception 'Client entitlement write allowed'; exception when insufficient_privilege then null; end;
 begin select count(*) from public.purchase_tokens; raise exception 'Receipt leaked'; exception when insufficient_privilege then null; end;
 begin perform public.parent_session_valid('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001'); raise exception 'Client session RPC allowed'; exception when insufficient_privilege then null; end;
end$$;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000002',false);
do $$begin if (select id from public.parent_accounts)<>'00000000-0000-0000-0000-000000000002'::uuid then raise exception 'Other parent visible'; end if; end$$;
reset role;
set role service_role;
do $$begin
 if not public.parent_session_valid('00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000003') then raise exception 'Valid session rejected'; end if;
 if public.parent_session_valid('00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003') then raise exception 'Session owner mismatch accepted'; end if;
end$$;
select public.retain_verified_purchase('00000000-0000-0000-0000-000000000001',repeat('c',64),'encrypted-fixture','monthly','active',now()+interval '1 day');
do $$begin
 begin
 perform public.retain_verified_purchase('00000000-0000-0000-0000-000000000002',repeat('c',64),'different','monthly','active',now()+interval '1 day');
 raise exception 'Cross-account claim succeeded';
 exception when raise_exception then if sqlerrm <> 'Receipt already belongs to another account' then raise; end if;
 end;
end$$;
reset role;
delete from auth.users where id='00000000-0000-0000-0000-000000000001';
do $$begin if exists(select 1 from public.purchase_tokens) then raise exception 'Delete left receipt behind'; end if; end$$;
