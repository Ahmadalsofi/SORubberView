//
//  CategoryRubberViewCell.swift
//  SORubberView_Example
//
//  Created by ahmad alsofi on 5/9/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SORubberView
class CategoryRubberViewCell: SORubberViewSection {

    @IBOutlet weak var iconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconCenterXConstraint: NSLayoutConstraint!

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    func setupCell(obj: AppModel) {
        nameLbl.text = obj.name
        iconImage.image = UIImage(named: obj.iconName)
    }
}
