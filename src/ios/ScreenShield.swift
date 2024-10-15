//
//  ScreenShield.swift
//  ScreenShield Plugin
//
//  Created by Andre Grillo on 12/07/2024.
//

import UIKit

@objcMembers public class ScreenShield: NSObject {

    public static let shared = ScreenShield()
    private var blurView: UIVisualEffectView?
    private var recordingObservation: NSKeyValueObservation?

    // Protect the app's main window from screenshots
    public func protect(window: UIWindow) {
        DispatchQueue.main.async {
            guard let secureView = SecureField().secureContainer else { return }
            window.addSubview(secureView)
            secureView.pinEdges(to: window)
        }
    }

    // Protect a specific view (e.g., WKWebView) from screenshots
    public func protect(view: UIView) {
        DispatchQueue.main.async {
            guard let secureView = SecureField().secureContainer else { return }
            view.addSubview(secureView)
            secureView.pinEdges(to: view)
        }
    }

    // Detect screen recording and overlay a blur when active
    public func protectFromScreenRecording() {
        recordingObservation = UIScreen.main.observe(\.isCaptured, options: [.new]) { [weak self] screen, change in
            guard let self = self else { return }
            let isRecording = change.newValue ?? false
            print("Screen is being captured: \(isRecording)")
            if isRecording {
                self.addBlurView()  // Add blur when recording starts
            } else {
                self.removeBlurView()  // Remove blur when recording stops
            }
        }
    }

    // Add a blur effect when screen recording is active
    private func addBlurView() {
        guard blurView == nil else { return }
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView?.frame = UIScreen.main.bounds

        // Add a label to indicate screen recording is not allowed
        let label = UILabel()
        label.text = "Screen recording not allowed"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        blurView?.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: blurView!.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: blurView!.contentView.centerYAnchor)
        ])

        // Add the blur view to the key window
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(blurView!)
        }
    }

    // Remove the blur effect after screen recording stops
    private func removeBlurView() {
        blurView?.removeFromSuperview()
        blurView = nil
    }
}
