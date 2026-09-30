# Calculator Incognito

Android package: `com.calculator.prod`.

## Local Android setup

Flutter 3.44.1 / Dart 3.12.1, Java 17, Android SDK 36, NDK 28.2.13676358,
Gradle 8.14, AGP 8.13.2. Run `flutter pub get` before building.

Local signing files: `android/upload-keystore.jks` and `android/key.properties`.
Both are ignored by Git. Keep BOTH in a secure off-device backup. Do not
regenerate the key after submitting its certificate to Play.

Local Photo Math configuration: `config/local.json`; use `config/local.example.json`
as a template on a new machine. This value is ignored by Git.

```sh
flutter analyze
flutter test
FLUTTER_BIN=/absolute/path/to/flutter ./tool/build_android_release.sh
```

For local runs also pass `--dart-define-from-file=config/local.json`.
This keeps the API key out of new source commits; it DOES NOT conceal it from
the compiled app or remove it from Git history. Rotate the previously embedded
key and move authenticated Photo Math requests behind an owned backend to secure it.

## Play upload recovery

The new upload key alias is `upload`. Submit ONLY its public PEM certificate via
Play Console > Protected with Play > Manage Play app signing > Request upload key
reset. Wait for Google's activation time before uploading. Do not use Upgrade key.

Builds are for local verification until the listing's highest version code is known.
Confirm the package name, then choose a higher unused version code for the update:

```sh
./tool/build_android_release.sh --build-number=NEXT_UNUSED_CODE --build-name=RELEASE_VERSION
```

Test on the internal track before production rollout.

## External services to verify before publishing

- Firebase project access, Firestore rules and the public URL document.
- Receipt validation endpoints on `thebluebamboo.in`: server source and credentials
  are not in this repository.
- Play subscription `ad_free_099`, active base plan and license testers.
- AdMob account/ad units and Photo Math key/quota.
- Billing uses library 8 through Android plugin 0.5.0, pinned before its AGP 9
  migration. iOS retains StoreKit 1 receipt mode and needs separate device testing.

https://support.google.com/googleplay/android-developer/answer/9842756
https://docs.flutter.dev/deployment/android
