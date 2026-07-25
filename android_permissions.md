# Android Permissions

Add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Camera permission for heritage scanning -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />

<!-- Location permission for GPS heritage detection -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Internet for API calls -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Network state for connectivity checks -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Place these ABOVE the `<application>` tag but INSIDE the `<manifest>` tag.

Example location in the manifest:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.heritagelk.app">

    <!-- Put permissions here -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="HeritageLK"
        ...>
```
