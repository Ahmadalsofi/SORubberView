//
//  HelpfulExtension.swift
//  SORubberView
//
//  Created by ahmad alsofi on 5/9/20.
//

import UIKit
@available(iOS 9.0, *)
extension UIView {
    internal func soDrawConstraint(from view: UIView) {
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
}
@available(iOS 9.0, *)
extension UIStackView {
   internal func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
