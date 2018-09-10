//
//  BidsViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 04/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import PromiseKit

class BidsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var post: Post!
    var selectedBid: Bid!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChat" {
            guard let nav = segue.destination as? UINavigationController, let vc = nav.childViewControllers[0] as? ChatViewController else { return }
            vc.user1 = appData.currentUser
            vc.user2 = selectedBid?.CreatedByUser
            vc.postId = post?.ID
        }
        if segue.identifier == "ShowProfile" {
            guard let nav = segue.destination as? UINavigationController, let vc = nav.childViewControllers[0] as? ProfileViewController else { return }
            vc.user = selectedBid.CreatedByUser
        }
    }

}

extension BidsViewController: Biddable {
    func bid(didTap cell: UITableViewCell) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    func bid(didViewProfile bid: Bid) {
        selectedBid = bid
        
        self.performSegue(withIdentifier: "ShowProfile", sender: self)
    }
    func bid(didAccept bid: Bid) {
        updateBid(flag: 4, bid: bid)
    }
    
    func bid(didReject bid: Bid) {
        updateBid(flag: 2, bid: bid)
    }
    
    func bid(didContact bid: Bid) {
        selectedBid = bid
        
        self.performSegue(withIdentifier: "ShowChat", sender: self)
    }
    
    func updateBid(flag: Int, bid: Bid) {
        var bid1 = bid
        
        bid1.Flags = flag
        firstly {
            appData.updatePostBid(bidId: bid.ID!, bid: ["Flags": flag])
            }.done { (bid) in
                print(bid)
            }.catch { (error) in
                print(error)
        }
    }
}

extension BidsViewController: UITableViewDataSource {
    func loadRatings(for bid: Bid, cell: BidTableViewCell) {
        appData.getRatings(for: bid.CreatedByUserID!).done { (ratings) in
            let score = Double(ratings.compactMap({ (rating) -> Int? in
                return rating.Score
            }).reduce(0, {x,y in x + y})) / Double(ratings.count).rounded(toPlaces: 1)
            
            cell.ratingLabel.text = String(score)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.PostBids.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidCell", for: indexPath) as! BidTableViewCell
        
        cell.bid = post.PostBids[indexPath.row]
        cell.currentUser = appData.currentUser
        cell.delegate = self
        cell.post = post
        cell.renderCell()
        
        return cell
    }
}

extension BidsViewController: UITableViewDelegate {

}
