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
    
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initialize() {
        guard let post = post else { return }
        locationLabel.text = post.Address
        titleLabel.text = post.Title
        tagsCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCell")
        
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        tagsView.isHidden = post.PostTags.count == 0
        tagsCollectionView.reloadData()
        
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

extension PostTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let post = post else { return CGSize(width: 0, height: 0) }
        let tag = post.PostTags[indexPath.row].Name
        let height = collectionView.frame.size.height
        var width = (tag?.width(withConstraintedHeight: height, font: UIFont.systemFont(ofSize: 12)))! + 16
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension PostTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.PostTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCollectionViewCell
        
        guard let post = post else { return cell }
        cell.tagLabel.text = post.PostTags[indexPath.row].Name
        
        return cell
    }
}
