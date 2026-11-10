# Signed AAB — draft instructions

No production key, APK/AAB or export preset is supplied. Confirm the final game/editor/toolchain and permanent package ID first. Match export templates exactly to the editor and recheck current Google Play target-API requirements; engine setup defaults alone may not satisfy the store.

After approval, configure a real Android preset and audit included font/license/config resources, portrait behavior, permissions, backup and architecture options. Create the upload key on your own computer outside Git using Android Studio/keytool with prompted passwords. Never paste secrets in chat or command arguments; securely back up the key and credentials. Keep `export_credentials.cfg`, keystores and passwords out of Git; use approved local secret configuration.

Export a non-debug signed AAB using the verified engine configuration. Verify package/version, certificate and SHA-256; test a standalone build. An AAB is uploaded, not directly installed like an APK. Later create the Play app record and configure Play App Signing when the developer account exists. Test-track upload and production each require separate approval. No automatic CI or publication is introduced.

References: https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html and https://developer.android.com/studio/publish/app-signing
