\!\[OutSystems\](https://www.outsystems.com/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Flogo.202c3251.svg&w=256&q=75)

# cordova-iosscreenshield-plugin

`cordova-iosscreenshield-plugin` is a Cordova plugin designed to protect your app from screen capture and recording on iOS devices. This plugin ensures that sensitive information displayed in your app is safeguarded by applying security measures such as preventing screenshots, screen recording, and displaying custom messages to the user.

## Features

- Prevents screenshots and screen recording on iOS devices.
- Automatically displays a custom blur effect and message when screen recording is detected.
- Applies security measures to WebViews, ensuring content is protected from unauthorized capture.

## Installation

To install the plugin, use the following command:

```bash
cordova plugin add com-outsystems-experts-screenshield
```

## Usage

After installing the plugin, you can call the `protectWebView` method to protect your app's WebView from being captured or recorded.

### Example:

```javascript
screenshield.protectWebView(
  function() {
    console.log('WebView is now protected');
  },
  function(error) {
    console.error('Error protecting WebView:', error);
  }
);
```

This method will activate screen shield protection on the WebView component of your application, blocking any attempts to take screenshots or record the screen.

## iOS Specific Configuration

Ensure that your `config.xml` file includes the following entries:

```xml
<feature name="CDVScreenShield">
    <param name="ios-package" value="CDVScreenShield" />
    <param name="onload" value="true" />
</feature>
```

The plugin also requires Swift support for iOS, which is automatically enabled through the hooks provided.

## Technical Details

The plugin uses `WKWebView` for protection and detects screen recording by monitoring the `isCaptured` property of `UIScreen`. When screen capture is detected, a blur effect with a custom message is applied over the screen to hide sensitive content.

It also includes security measures for `UIView`, making it resistant to screenshots by overlaying a secure text field that prevents the view's content from being captured.

## License

This plugin is distributed under the MIT license. See the `LICENSE` file for more details.

## Author

**André Grillo**

- Email: andre.grillo@outsystems.com
- GitHub: \[André Grillo\](https://github.com/andregrillo)

---

This plugin was created for OutSystems to enhance the security of mobile applications by preventing screen capture and recording.