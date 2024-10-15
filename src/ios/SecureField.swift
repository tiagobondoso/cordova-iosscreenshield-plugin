//
//  SecureField.swift
//  
//
//  Created by Andre Grillo on 14/10/2024.
//


import UIKit

class SecureField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.isSecureTextEntry = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Secure container for preventing screenshots
    weak var secureContainer: UIView? {
        let secureView = self.subviews.filter({ subview in
            type(of: subview).description().contains("CanvasView")
        }).first
        secureView?.translatesAutoresizingMaskIntoConstraints = false
        secureView?.isUserInteractionEnabled = true // Enable interaction
        return secureView
    }
    
    override var canBecomeFirstResponder: Bool { false }
    override func becomeFirstResponder() -> Bool { false }
}

extension UIView {
    
    // Pin edges to a specific view (e.g., window or webView)
    func pinEdges(to superview: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }

    // Alternative pin method without parameters (in case it's needed elsewhere)
    func pinEdges() {
        guard let superview = self.superview else { return }
        pinEdges(to: superview)
    }
}
