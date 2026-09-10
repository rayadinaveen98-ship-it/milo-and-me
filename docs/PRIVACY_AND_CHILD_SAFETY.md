# Privacy and child safety

No ads, behavioural analytics, public chat, child accounts, unrestricted AI conversation, pressure to purchase, streak-loss or absence guilt. Child play stays useful offline. No camera, microphone, location, contacts or advertising identifier permission. Android automatic backup is disabled.

| Data | Storage and purpose | Deletion |
| --- | --- | --- |
| Nickname, Milo state, activity progress, drawings, memories | Private on-device SQLite; local play only | Parent local reset or app removal |
| PIN hash/salt and retry lockout | Platform secure storage; temporary parent gate | Replaced during setup; retained by local-profile reset |
| Optional adult auth tokens and bounded entitlement cache | Platform secure storage | Sign-out/account deletion clears local credentials |
| Optional adult email | Supabase Auth only when live services are configured and parent opts in | Parent cloud account deletion |
| Consent, entitlement, catalogue | Owner-scoped server records; server-only sensitive writes | Account records cascade on deletion |
| Purchase receipt token | Server-only AES-GCM ciphertext and unique hash | Cascades with parent account |
| Downloaded content/media | Validated on-device pack tables | Parent pack removal or local reset |

Default playtests enable no live account or billing. Test-store controls explicitly say simulation/no charge. Configured purchases occur only in parent controls and require server verification for both purchase and restore. Child routes never show purchase requests. Store subscriptions must be cancelled through Google Play separately from deleting the cloud account.

The parent PIN is a gate, not a claim of verified legal identity. Live account consent records the confirmed adult email plus explicit guardian declaration and policy version. Production operators must configure and review applicable store/privacy requirements before launch. No child voice or creations are uploaded; cloud backup is not enabled.

Science A is digital only; B uses optional seated observation; C uses adult-selected leaves or paper outlines. C requires a scoped 15-minute PIN permit revoked on background and screen exit. The adult stays throughout. No ingestion, heat, sharp tools, chemicals or electrical experiments. Real-world instructions come only from reviewed templates. No photos, location or proof is requested.

Local reset clears world, drawings, drafts, session, packs and media, and invalidates pending downloads. Cloud deletion revokes sessions before deleting the parent account and dependent records. It preserves on-device creations. No sensitive request bodies or tokens are echoed in server errors or logs.
