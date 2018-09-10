//
//  AssetCollectionViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 21/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import SnapKit

class AssetCollectionViewCell: UICollectionViewCell {
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
    
    lazy var assetImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var checkedView: UIView = {
        let view = UIView()
        let checkedImage = UIImageView(image: UIImage(named: "Star"))
        checkedImage.tintColor = .white
        
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5)
        
        view.addSubview(checkedImage)
        checkedImage.snp.makeConstraints({ (make) in
            make.height.width.equalTo(36)
            make.centerX.centerY.equalTo(view)
        })
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        self.addSubview(assetImage)
        self.addSubview(checkedView)
        
        assetImage.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        checkedView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}
