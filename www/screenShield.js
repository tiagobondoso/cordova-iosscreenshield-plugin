var exec = require('cordova/exec');

exports.protectWebView = function (success, error, shouldBlockScreenRecording) {
    exec(success, error, 'CDVScreenShield', 'protectWebView', [shouldBlockScreenRecording]);
};