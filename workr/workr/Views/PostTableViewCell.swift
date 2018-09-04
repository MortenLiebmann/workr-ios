//
//  PostTableViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    //MARK: - Location
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    //MARK: - End date
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var endDateLabel: UILabel!
    
    //MARK: - Description
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: - Created by
    @IBOutlet weak var createdByLabel: UILabel!
    
    //MARK: - Title
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var noImagesView: UIView!
    @IBOutlet weak var numberOfImages: UILabel!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initialize() {
        locationLabel.text = post.Address
        titleLabel.text = post.Title
        
        locationView.isHidden = (post.Address?.isEmptyOrWhitespace())!
        
        if post.PostImageIDs.count > 0 {
            postImageView.downloadImage(from: post.ID, imageId: post.PostImageIDs[0])
            numberOfImages.text = String(post.PostImageIDs.count)
            noImagesView.isHidden = true
        } else {
            noImagesView.isHidden = false
        }
        
        if let endDate = post.JobEndDate {
            endDateLabel.text = endDate.toString()
            endDateView.isHidden = false
        } else {
            endDateLabel.text = nil
            endDateView.isHidden = true
        }
        
        descriptionLabel.text = post.Description
        createdByLabel.text = post.CreatedByUser?.Name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
