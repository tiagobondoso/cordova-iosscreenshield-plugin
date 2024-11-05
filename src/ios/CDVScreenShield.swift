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
    private var secureView: SecureView? // Armazenando como variável de instância

    @objc(protectWebView:)
    func protectWebView(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            let shouldBlockScreenRecording = (command.arguments.first as? Bool) ?? false
            
            if let webView = self.webView as? WKWebView {
                // Verifica se secureView já existe, senão cria um novo
                if self.secureView == nil {
                    self.secureView = SecureField().secureContainer
                }

                guard let secureView = self.secureView else { return }
                
                // Add WKWebView to the secure container
                secureView.addSubview(webView)
                webView.pinEdges(to: secureView)
                
                // Add the secure container to the main Cordova view
                if let cordovaViewController = self.viewController {
                    cordovaViewController.view.addSubview(secureView)
                    secureView.pinEdges(to: cordovaViewController.view)
                }
                
                // Activate screen recording protection (video)
                if shouldBlockScreenRecording {
                    guard let message = command.arguments[1] as? String,
                          let fontSize = command.arguments[2] as? CGFloat,
                          let fontColor = command.arguments[3] as? String else {
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
            guard let webView = self.webView else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "WebView is nil")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            guard let secureView = self.secureView else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "SecureView is nil")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            // Remove WKWebView do container seguro e adiciona de volta à visão principal do Cordova
            if let cordovaViewController = self.viewController {
                secureView.removeFromSuperview()
                cordovaViewController.view.addSubview(webView as! UIView)
                (webView as! UIView).pinEdges(to: cordovaViewController.view)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No ViewController found")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            // Desativar a proteção contra gravação de tela
            ScreenShield.shared.deactivateProtection()

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
}

