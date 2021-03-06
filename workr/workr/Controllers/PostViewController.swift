//
//  PostViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 20/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var offerButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bidsButton: UIButton!
    @IBOutlet weak var bidStackView: UIStackView!
    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBAction func contactDidTap(_ sender: Any) {
        
    }
    
    var chat: Chat?
    var post: Post?
    var images: Int = 10
    var tags = ["Tag1", "Looooooooooooong tag", "Tag 3", "Another long tag", "Even loooooooooooooooooonger tag"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    func initialize() {
        guard let post = post else {return}
        tagCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.isPagingEnabled = true
        collectionView.isHidden = post.PostImageIDs.count == 0
        
        editButton.isHidden = post.CreatedByUser?.ID != appData.currentUser.ID
        contactButton.isHidden = true
        offerButton.isHidden = post.CreatedByUser?.ID == appData.currentUser.ID //OR if post has any offer from you
        bidStackView.isHidden = post.PostBids.count == 0
        completeButton.isHidden = (post.PostBids.first { $0.Flags == 4}) == nil || post.CreatedByUser?.ID != appData.currentUser.ID
        
        bidsButton.setTitle("\(post.PostBids.count) bid(s)", for: .normal)
        
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.isHidden = post.PostTags.count == 0
        tagCollectionView.reloadData()
        
        let stringDate = post.CreatedDate.toString()
        
        titleLabel.text = post.Title
        createdByLabel.text = "\(post.CreatedByUser?.Name ?? ""), \(stringDate)"
        descriptionLabel.text = post.Description
        addressLabel.isHidden = (post.Address?.isEmptyOrWhitespace())!
        addressLabel.text = post.Address
        
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaceOffer" {
            guard let vc = segue.destination as? PlaceBidViewController else { return }
            vc.post = self.post
        }
        if segue.identifier == "ViewBids" {
            guard let vc = segue.destination as? BidsViewController else { return }
            vc.post = post
        }
        if segue.identifier == "ShowChat" {
            guard let nav = segue.destination as? UINavigationController, let vc = nav.childViewControllers[0] as? ChatViewController, let post = post else { return }
            vc.bid = post.PostBids.sorted(by: {$0.Price! > $1.Price!}).first{ $0.CreatedByUserID! == appData.currentUser.ID}
            vc.user1 = appData.currentUser
            vc.user2 = post.CreatedByUser
            vc.postId = post.ID
        }
        if segue.identifier == "Ratings" {
            guard let vc = segue.destination as? RatingsViewController else { return }
            vc.bid = post?.PostBids.first {$0.Flags == 4}
            vc.post = post
        }
    }
}

extension PostViewController: Loadable {
    func loadData() {
        guard let post = post else {return}
        appData.getChat(by: [
            "PostID" : post.ID.uuidString.lowercased(),
            "ChatParty2UserID": post.CreatedByUserID.uuidString.lowercased(),
            "ChatParty1UserID": appData.currentUser.ID.uuidString.lowercased()
            ]).done { (chats) in
                if chats.count > 0 {
                    self.chat = chats.first
                    self.contactButton.isHidden = false
                }
        }
    }
}

extension PostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            guard let post = post else { return 0 }
            return post.PostImageIDs.count
        } else {
            guard let post = post else { return 0 }
            return post.PostTags.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCell", for: indexPath) as! PostImageCollectionViewCell
            
            guard let postId = post?.ID, let imageId = post?.PostImageIDs[indexPath.row] else { return cell }
            
            cell.postImageView.downloadImage(from: postId, imageId: imageId)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCollectionViewCell
            
            guard let post = post else { return cell }
            cell.tagLabel.text = post.PostTags[indexPath.row].Name
            
            return cell
        }
        
    }
}

extension PostViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            let height = collectionView.frame.size.height
            let width = collectionView.frame.size.width - 40
            
            return CGSize(width: width, height: height)
        } else {
            guard let post = post else { return CGSize(width: 0, height: 0) }
            let tag = post.PostTags[indexPath.row].Name
            let height = collectionView.frame.size.height
            var width = (tag?.width(withConstraintedHeight: height, font: UIFont.systemFont(ofSize: 12)))! + 16
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView != self.collectionView {
            return
        }
        targetContentOffset.pointee = scrollView.contentOffset
        let pageWidth:Float = Float(self.view.bounds.width)
        let minSpace:Float = 10.0
        var mod = 0.0
        
        if velocity.x > 1 {
            mod = 0.5;
        } else if velocity.x < -1 {
            mod = -0.5;
        }
        
        var cellToSwipe:Double = Double(Float((scrollView.contentOffset.x))/Float((pageWidth+minSpace))) + Double(0.5) + mod
        if cellToSwipe < 0 {
            cellToSwipe = 0
        } else if cellToSwipe >= Double(self.images) {
            cellToSwipe = Double(self.images) - Double(1)
        }
        let indexPath:IndexPath = IndexPath(row: Int(cellToSwipe), section:0)
        self.collectionView.scrollToItem(at:indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
}
