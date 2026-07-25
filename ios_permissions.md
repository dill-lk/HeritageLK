# iOS Permissions

Add these keys to `ios/Runner/Info.plist`:

```xml
<!-- Camera permission for heritage scanning -->
<key>NSCameraUsageDescription</key>
<string>HeritageLK needs camera access to scan and identify heritage sites, plants, and wildlife.</string>

<!-- Photo library permission for evidence uploads -->
<key>NSPhotoLibraryUsageDescription</key>
<string>HeritageLK needs photo library access to upload images for damage reports and archive contributions.</string>

<!-- Location permission for GPS heritage detection -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>HeritageLK needs your location to detect nearby heritage sites and complete GPS-based quests.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>HeritageLK uses your location to show nearby heritage sites and verify quest completion.</string>

<!-- Microphone (for future audio contributions) -->
<key>NSMicrophoneUsageDescription</key>
<string>HeritageLK may need microphone access for audio archive contributions.</string>
```

Example placement in Info.plist:

```xml
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>HeritageLK</string>
    <!-- ... other existing keys ... -->

    <!-- Camera permission for heritage scanning -->
    <key>NSCameraUsageDescription</key>
    <string>HeritageLK needs camera access to scan and identify heritage sites, plants, and wildlife.</string>

    <!-- Photo library permission for evidence uploads -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>HeritageLK needs photo library access to upload images for damage reports and archive contributions.</string>

    <!-- Location permission for GPS heritage detection -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>HeritageLK needs your location to detect nearby heritage sites and complete GPS-based quests.</string>

    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>HeritageLK uses your location to show nearby heritage sites and verify quest completion.</string>
</dict>
```
