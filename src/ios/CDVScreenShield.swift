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

    // Guardar referência ao secureView
    private var secureView: UIView?

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
                
                // Ativar proteção contra gravação de tela e captura de tela
                if shouldBlockScreenRecording {
                    self.preventScreenCaptureAndRecording()
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
            if let secureView = self.secureView {
                // Remove WKWebView from the secure container and add it back to the main Cordova view
                if let cordovaViewController = self.viewController {
                    secureView.removeFromSuperview()
                    if let webView = self.webView as? UIView {
                        cordovaViewController.view.addSubview(webView)
                        webView.pinEdges(to: cordovaViewController.view)
                    }
                } else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "No ViewController found")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }
            }

            // Allow screen capture and recording again
            self.allowScreenCaptureAndRecording()

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }

    // Função para bloquear capturas de tela e gravação de tela
    private func preventScreenCaptureAndRecording() {
        // Impede captura de tela
        if #available(iOS 11.0, *) {
            UIScreen.main.isCaptured = true
        }

        // Impede gravação de tela
        if #available(iOS 11.0, *) {
            UIApplication.shared.isIdleTimerDisabled = true // Pode ajudar a impedir gravação de tela em alguns casos
        }

        // Outra abordagem pode envolver a utilização do método de proteção de vídeo da ScreenShield se necessário
        ScreenShield.shared.protectFromScreenRecording(message: "Screen Recording Disabled", fontSize: 14.0, fontColor: "#FF0000")
    }

    // Função para permitir captura de tela e gravação de tela
    private func allowScreenCaptureAndRecording() {
        // Permite captura de tela
        if #available(iOS 11.0, *) {
            UIScreen.main.isCaptured = false
        }

        // Permite gravação de tela
        if #available(iOS 11.0, *) {
            UIApplication.shared.isIdleTimerDisabled = false
        }

        // Desativa a proteção de gravação de tela
        ScreenShield.shared.deactivateProtection()
    }
}
