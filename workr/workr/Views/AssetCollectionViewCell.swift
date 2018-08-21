//
//  AssetCollectionViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 21/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var checkedView: UIView!
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            if newValue {
                checkedView.isHidden = false
            } else {
                checkedView.isHidden = true
            }
        }
    }
}
