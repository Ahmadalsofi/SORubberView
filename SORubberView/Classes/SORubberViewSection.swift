//
//  SORubberViewSection.swift
//  SORubberView
//
//  Created by ahmad alsofi on 5/9/20.
//

import Foundation
open class SORubberViewSection: UIViewFromNib {
}

open class UIViewFromNib: UIView {
    var contentView: UIView!
    var nibName: String {
        return String(describing: type(of: self))
    }
    //MARK:
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        loadViewFromNib()
    }
    //MARK:
    public func loadViewFromNib() {
        contentView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as? UIView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }
}
