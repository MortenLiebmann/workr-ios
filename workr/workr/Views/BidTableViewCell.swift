//
//  BidTableViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 04/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class BidTableViewCell: UITableViewCell, UITableViewCellRenderable {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var bid: Bid!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func renderCell() {
        nameLabel.text = bid.CreatedByUser?.Name
        createdLabel.text = bid.CreatedDate?.toString()
        priceLabel.text = bid.Value
    }
}
