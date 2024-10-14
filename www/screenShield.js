var exec = require('cordova/exec');

exports.protectWebView = function (success, error) {
    exec(success, error, 'CDVScreenShield', 'protectWebView');
};
