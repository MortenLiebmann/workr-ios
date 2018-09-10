//
//  CameraCollectionViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 05/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class CameraCollectionViewCell: UICollectionViewCell {
    lazy var checkedView: UIView = {
        let view = UIView()
        let checkedImage = UIImageView(image: UIImage(named: "Camera"))
        checkedImage.tintColor = .white
        
        view.backgroundColor = .darkGray
        
        view.addSubview(checkedImage)
        checkedImage.snp.makeConstraints({ (make) in
            make.height.width.equalTo(36)
            make.centerX.centerY.equalTo(view)
        })
        
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        self.addSubview(checkedView)
        checkedView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}
