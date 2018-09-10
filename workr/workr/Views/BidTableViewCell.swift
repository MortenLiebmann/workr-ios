//
//  BidTableViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 04/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

protocol Biddable {
    func bid(didTap cell: UITableViewCell)
    func bid(didAccept bid: Bid)
    func bid(didViewProfile bid: Bid)
    func bid(didReject bid: Bid)
    func bid(didContact bid: Bid)
}

class BidTableViewCell: UITableViewCell, UITableViewCellRenderable {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBAction func acceptDidTap(_ sender: Any) {
        delegate?.bid(didAccept: bid)
    }
    
    @IBAction func rejectDidTap(_ sender: Any) {
        delegate?.bid(didReject: bid)
    }
    
    @IBAction func chatDidTap(_ sender: Any) {
        delegate?.bid(didContact: bid)
    }
    
    @IBAction func viewProfileDidTap(_ sender: Any) {
        delegate?.bid(didViewProfile: bid)
    }
    
    var bid: Bid!
    var post: Post!
    var currentUser: User!
    var delegate: Biddable?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if post.CreatedByUserID != currentUser.ID {
            return
        }
        
        buttonStackView.isHidden = !selected
        delegate?.bid(didTap: self)
    }
    
    func renderCell() {
        nameLabel.text = bid.CreatedByUser?.Name
        createdLabel.text = bid.CreatedDate?.toString()
        priceLabel.text = bid.Value
        descriptionLabel.text = bid.Text
        
        avatar.downloadUserImage(from: bid.CreatedByUserID!)
    }
}
