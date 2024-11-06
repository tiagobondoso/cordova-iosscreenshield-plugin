var exec = require('cordova/exec');

exports.protectWebView = function (success, error, shouldBlockScreenRecording, message, fontSize, fontColor) {
    exec(success, error, 'CDVScreenShield', 'protectWebView', [shouldBlockScreenRecording, message, fontSize, fontColor]);
};

/*exports.removeProtectionFromWebView = function (success, error) {
    exec(success, error, 'CDVScreenShield', 'removeProtectionFromWebView');
};*/