//
//  CDVScreenShield.swift
//  ScreenShield Plugin
//
//  Created by Andre Grillo on 12/07/2024.
//

import Foundation
import UIKit
import WebKit

@objc(CDVScreenShield) 
class CDVScreenShield: CDVPlugin {
    
    @objc(protectWebView:)
    func protectWebView(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            if let webView = self.webView as? WKWebView {
                ScreenShield.shared.protect(view: webView)
                ScreenShield.shared.protectFromScreenRecording()
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No WKWebView found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
}
