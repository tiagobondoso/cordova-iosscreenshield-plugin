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
            let shouldBlockScreenRecording = (command.arguments.first as? Bool) ?? false
            if let webView = self.webView as? WKWebView {
                guard let secureView = SecureField().secureContainer else { return }
                
                // Add WKWebView to the secure container
                secureView.addSubview(webView)
                webView.pinEdges()  // Pin web view to the secure container
                
                // Add the secure container to the main Cordova view
                if let cordovaViewController = self.viewController {
                    cordovaViewController.view.addSubview(secureView)
                    secureView.pinEdges()
                }
                
                // Activate screen recording protection
                if shouldBlockScreenRecording {
                    ScreenShield.shared.protectFromScreenRecording()
                }
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No WKWebView found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
}
