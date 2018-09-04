//
//  TagCollectionViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 21/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import SnapKit

class TagCollectionViewCell: UICollectionViewCell {
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            if newValue {
                self.alpha = 0.5
            } else {
                self.alpha = 1
            }
        }
    }
    
    lazy var tagBackground: UIView = {
        let view = UIView()

        view.backgroundColor = .lightGray
        
        view.layer.cornerRadius = 3.0
        
        return view
    }()
    
    lazy var tagLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.ultraLight)
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        self.addSubview(tagBackground)
        
        tagBackground.addSubview(tagLabel)
        
        tagBackground.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        tagLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tagBackground)
            make.left.equalTo(tagBackground).offset(8)
            make.right.equalTo(tagBackground).offset(-8)
        }
    }
}
