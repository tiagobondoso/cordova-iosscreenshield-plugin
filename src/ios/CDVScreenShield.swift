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
                if self.secureView == nil {
                    self.secureView = SecureField().secureContainer
                }

                guard let secureView = self.secureView else { return }

                secureView.addSubview(webView)
                webView.pinEdges(to: secureView)

                if let cordovaViewController = self.viewController {
                    cordovaViewController.view.addSubview(secureView)
                    secureView.pinEdges(to: cordovaViewController.view)
                }

                // Código para ativar a proteção...

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
