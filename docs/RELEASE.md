# Android release preparation

GitHub Actions is the authoritative build environment. Analysis, all Flutter tests and debug APK generation pass; see `STATUS.md` for the green run and artifact. Store release and installed-device acceptance are separate gates.

1. Run `tool/build.ps1` or `tool/build.sh`, or push to a GitHub repository with the included workflow. Fix dependency/analysis/test/build failures before claiming the slice works.
2. Run `dart format lib test` when editing Dart and retain intentional dependency updates. `pubspec.lock` and the official Gradle wrapper are committed. Pin CI actions to audited commit SHAs before production use.
3. Install the debug APK on a representative phone and tablet. Complete setup, art, a puzzle and a story; close/reopen and verify the pet’s memory, artwork, draft, story resume and settings.
4. Run TalkBack, large-text and reduced-motion checks. Observe a supervised child using environmental navigation. Profile drawing, memory growth and animation on mid-range Android hardware.
5. Use the current store requirements to select the final target SDK and distribution settings. Check Android’s native-library page-size requirements using the actual packaged libraries. This source has not passed those release checks.
6. Create and securely retain the production signing key outside the repository. Supply `android/key.properties` locally with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. The file and keystore are ignored by Git. The release configuration never substitutes a debug signing key.
7. Once signing is configured and all gates pass, run `flutter build apk --release` and `flutter build appbundle --release`. Verify the signing certificate and install/upgrade path.
8. Finish the privacy policy, publisher/contact identity, territory-specific child/privacy review, store family/kids disclosures and purchase configuration. The local parent checkbox is not a claim of verified regulatory consent.
9. Produce screenshots from the actual application, not a recreated mockup. Included icons are original temporary shape assets; confirm the final brand name before submission.

## External configuration still needed

- A dedicated Supabase project if hosted features are desired; project URL and publishable key alone do not implement parent auth or legal consent.
- A trusted object-storage origin/catalogue and appropriate authorization for premium downloads.
- Google Play / Apple developer accounts, products, receipt-verification services and production signing identities.
- Final recorded narration and any Rive production assets.

The `.env.example` file documents future backend inputs; the offline bootstrap does not consume it. There are no runtime LLM/API fees or active paid services in the source milestone. No production infrastructure was created.
