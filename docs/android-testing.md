# Android testing — preparation, not a completed export

Checked editor: standard Godot 4.6.3 stable, GDScript, Compatibility renderer. No native Android APK/AAB has been exported or installed in this task. Do not use Expo Go.

1. Test with F5 on your computer first. Install export templates matching the exact Godot editor version.
2. Install/verify the JDK and Android SDK packages required by your chosen engine. Godot 4.6 docs recommend JDK 17 and document the engine-specific SDK/NDK/CMake requirements. Do not assume paths or that another app’s toolchain matches.
3. Set Java SDK Path and Android SDK Path in Godot Editor Settings → Export → Android. Select and approve a permanent package ID before publication; none is configured by this source-only preview.
4. After export configuration is approved, add an Android preset marked Runnable. Audit permissions, orientation, renderer, versioning and included files. Include the bundled font and OFL text plus JSON config and notices; inspect the actual export rather than assuming every non-resource document was bundled.
5. For your debug phone install, enable Developer options/USB debugging and authorize your computer. Godot’s one-click deploy can install/run a debug build. Test touch controls on an actual device; no emulator is necessary.
6. For Wi-Fi, use Android’s supported Wireless debugging pairing flow on the same network: pair with `adb pair IP:PAIRING_PORT`, then connect if needed using the device’s debugging IP/port (which may differ from the pairing port). Check `adb devices` before Godot deployment. Pairing and device setup have not been performed here.
7. Test clean install, both languages, largest relevant display settings, gestures versus touch-button input, all difficulties, backgrounding during play/countdown, process restart, score retention, reset cancellation/confirmation, narrow layouts and heat/memory/frame pacing.
8. Reopen the standalone installed build in airplane mode and verify all gameplay/art/menus without computer connection. Native permissions and network behavior must be audited on that exact artifact.

Godot 4.6 engine setup requirements are not a promise of satisfying the latest Play target-API policy. Recheck release-time Play requirements and choose a supported engine/export configuration before signing/submitting.

Official references:
- https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html
- https://docs.godotengine.org/en/stable/tutorials/export/one-click_deploy.html
