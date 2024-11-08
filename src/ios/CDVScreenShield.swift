//
//  CDVScreenShield.swift
//  ScreenShield Plugin
//
//  Created by Andre Grillo on 12/07/2024.
//

import Foundation
import UIKit
import WebKit

class CDVScreenShield: CDVPlugin {
    private var secureView: UIView? // Variável de instância global

    @objc(protectWebView:)
    func protectWebView(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            let shouldBlockScreenRecording = (command.arguments.first as? Bool) ?? false
            if let webView = self.webView as? WKWebView {
                self.secureView = SecureField().secureContainer else { return }
                
                // Add WKWebView to the secure container
                self.secureView.addSubview(webView)
                webView.pinEdges(to: self.secureView)
                
                // Add the secure container to the main Cordova view
                if let cordovaViewController = self.viewController {
                    cordovaViewController.view.addSubview(self.secureView)
                    //secureView.pinEdges()
                    self.secureView.pinEdges(to: cordovaViewController.view)
                }
                
                // Activate screen recording protection (video)
                if shouldBlockScreenRecording {
                    guard let message = command.arguments[1] as? String, let fontSize = command.arguments[2] as? CGFloat, let fontColor = command.arguments[3] as? String else {
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Missing input parameters")
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                        return
                    }
                    ScreenShield.shared.protectFromScreenRecording(message: message, fontSize: fontSize, fontColor: fontColor)
                }
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No WKWebView found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }

    @objc(removeProtectionFromWebView:)
    func removeProtectionFromWebView(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            guard let secureView = self.secureView else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No secure container found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            secureView.removeFromSuperview()

            if let cordovaViewController = self.viewController, let webView = self.webView as? UIView {
                cordovaViewController.view.addSubview(webView)
                webView.pinEdges(to: cordovaViewController.view)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No ViewController found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            ScreenShield.shared.deactivateProtection()

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
}
