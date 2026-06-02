# Info.plist Configuration Guide

This file contains all the Info.plist entries you need for AppPod to work properly.

## Required for Apple Music (MusicKit)

Add this to request permission to access the user's Apple Music library:

```xml
<key>NSAppleMusicUsageDescription</key>
<string>AppPod needs access to your Apple Music library to display and play your music collection in a classic iPod interface.</string>
```

## Optional: For Spotify Integration

If you want to add Spotify support, include these entries:

### URL Scheme (for OAuth callback)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourdomain.apppod</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>apppod</string>
        </array>
    </dict>
</array>
```

### Query Schemes (to detect Spotify app)

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>spotify</string>
</array>
```

## How to Add These to Your Project

### Method 1: Using Xcode Property List Editor

1. In Xcode, select your `Info.plist` file
2. Right-click in the property list
3. Select "Add Row"
4. Enter the key name (e.g., `NSAppleMusicUsageDescription`)
5. Enter the value in the "Value" column

### Method 2: Editing Raw XML (if you have Info.plist as XML)

1. Open `Info.plist` as source code
2. Add the XML entries between the `<dict>` tags
3. Save the file

### Method 3: Using Info tab in Target Settings

1. Select your app target
2. Go to the "Info" tab
3. Under "Custom iOS Target Properties", click "+"
4. Add each key and its corresponding value

## Complete Example Info.plist

Here's what a complete Info.plist might look like with all AppPod-related entries:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing keys -->
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    
    <!-- AppPod Required: Apple Music Permission -->
    <key>NSAppleMusicUsageDescription</key>
    <string>AppPod needs access to your Apple Music library to display and play your music collection in a classic iPod interface.</string>
    
    <!-- AppPod Optional: Spotify URL Scheme -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.yourdomain.apppod</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>apppod</string>
            </array>
        </dict>
    </array>
    
    <!-- AppPod Optional: Spotify Query Schemes -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>spotify</string>
    </array>
    
    <!-- Your other existing keys continue here -->
</dict>
</plist>
```

## Verification

After adding these entries:

1. Clean build folder (Shift + Cmd + K)
2. Build and run the app
3. You should see the Apple Music permission dialog on first launch
4. Check that the permission appears in Settings > Privacy > Media & Apple Music

## Common Issues

### Permission dialog doesn't appear
- Make sure `NSAppleMusicUsageDescription` is correctly spelled
- The description string must not be empty
- Try deleting the app and reinstalling

### URL scheme conflicts
- Make sure your URL scheme (e.g., "apppod") is unique
- Check that no other apps use the same scheme
- The scheme should be lowercase with no special characters

### MusicKit not working
- Remember to add the MusicKit capability in Signing & Capabilities
- Verify you're signed in to Apple Music on the device
- Test on a physical device (simulator has limitations)
