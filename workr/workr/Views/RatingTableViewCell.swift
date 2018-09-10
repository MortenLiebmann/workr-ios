//
//  RatingTableViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 08/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var rating: Rating!
    var currentUser: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func renderCell() {
        nameLabel.text = rating.RatedByUser?.Name
        createdLabel.text = rating.CreatedDate?.toString()
        ratingLabel.text = String(rating.Score!)
        descriptionLabel.text = rating.Text
        
        avatar.downloadUserImage(from: rating.RatedByUserID!)
    }
}
