//
//  SORubberStackView.swift
//  SORubberView
//
//  Created by ahmad alsofi on 5/9/20.
//

import UIKit
@available(iOS 9.0, *)
internal class SORubberStackView: UIStackView {
    var leadingNSLayoutConstraint: NSLayoutConstraint?
    var trailingNSLayoutConstraint: NSLayoutConstraint?
    var widthNSLayoutConstraint: NSLayoutConstraint?
    var heightNSLayoutConstraint: NSLayoutConstraint?
    init(axis: NSLayoutConstraint.Axis, height: CGFloat = 0, activeHeightConstraint: Bool = false, alignment: UIStackView.Alignment = .fill,distribution: UIStackView.Distribution) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.axis = axis
        self.spacing = 0
        self.alignment = alignment
        self.distribution = distribution
        self.heightAnchor.constraint(equalToConstant: height).isActive = activeHeightConstraint
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
