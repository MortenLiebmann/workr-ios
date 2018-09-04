//
//  TagCollectionView.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 30/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class TagCollectionView: UICollectionView {
    var tags: [Tag] = []
    
    override func numberOfItems(inSection section: Int) -> Int {
        return tags.count
    }
}
