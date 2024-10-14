//
//  ScreenShield.swift
//  ScreenShield Plugin
//
//  Created by Andre Grillo on 12/07/2024.
//

import UIKit

@objcMembers 
public class ScreenShield: NSObject {
    
    public static let shared = ScreenShield()
    private var blurView: UIVisualEffectView?
    private var recordingObservation: NSKeyValueObservation?
    
    public func protect(window: UIWindow) {
        DispatchQueue.main.async {
            window.makeSecure()
        }
    }
    
    public func protect(view: UIView) {
        DispatchQueue.main.async {
            view.makeSecure()
        }
    }
    
    public func protectFromScreenRecording() {
        recordingObservation = UIScreen.main.observe(\UIScreen.isCaptured, options: [.new]) { [weak self] screen, change in
            guard let self = self else { return }
            let isRecording = change.newValue ?? false
            print("✋ Screen is being captured: \(isRecording)")
            if isRecording {
                self.addBlurView()
            } else {
                self.removeBlurView()
            }
        }
    }
    
    private func addBlurView() {
        guard blurView == nil else { return }
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = UIScreen.main.bounds
        
        let label = UILabel()
        label.text = "Screen recording not allowed"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor)
        ])
        
        self.blurView = blurView
        UIApplication.shared.windows.first { $0.isKeyWindow }?.addSubview(blurView)
    }
    
    private func removeBlurView() {
        blurView?.removeFromSuperview()
        blurView = nil
    }
}

extension UIView {
    
    @objc func makeSecure() {
        DispatchQueue.main.async {
            let field = UITextField()
            field.isSecureTextEntry = true
            field.translatesAutoresizingMaskIntoConstraints = false
            field.isUserInteractionEnabled = false // Make it non-interactive
            field.backgroundColor = UIColor.white // Set background color to white to cover the view
            
            // MARK: TODO - Review - Create and configure the label
            let label = UILabel()
            label.text = "Screenshots are not allowed"
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.textColor = .black
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            
            // Add the secure text field to the view
            self.addSubview(field)
            NSLayoutConstraint.activate([
                field.topAnchor.constraint(equalTo: self.topAnchor),
                field.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                field.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                field.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            
            // Add the label to the secure text field
            field.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: field.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: field.centerYAnchor)
            ])
            
            self.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.first?.addSublayer(self.layer)
            
            // Debugging
            print("ℹ️ Secure text field frame after constraints: \(field.frame)")
            print("ℹ️ Secure text field superview: \(String(describing: field.superview))")
        }
    }
}
