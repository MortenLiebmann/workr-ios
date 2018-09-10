//
//  ProfileViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 30/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import PromiseKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func cancelDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutDidTap(_ sender: Any) {
        appData.logout().done { (success) in
            if success {
                self.performSegue(withIdentifier: "LogOut", sender: self)
            }
        }
    }
    
    @IBAction func unwindToProfile(_ segue: UIStoryboardSegue) {
        render()
    }

    var user: User!
    var ratings: [Rating] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadData()
        render()
    }
    
    func loadData() {
        firstly{
            appData.getRatings(for: user.ID)
            }.done { (ratings) in
                if ratings.count <= 0 {
                    return
                }
                
                self.ratings = ratings
                self.tableView.reloadData()
                
                let score = Double(ratings.compactMap({ (rating) -> Int? in
                    return rating.Score
                }).reduce(0, {x,y in x + y})) / Double(ratings.count).rounded(toPlaces: 1)
                
                self.ratingsLabel.text = String(score)
        }
    }
    
    func render() {
        guard let user = user else { return }
        
        logoutButton.isHidden = user.ID != appData.currentUser.ID
        nameLabel.text = user.Name
        profileImageView.downloadUserImage(from: user.ID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPicker" {
            guard let vc = segue.destination as? UploadProfileImageViewController else { return }
            vc.user = user
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! RatingTableViewCell
        
        cell.currentUser = appData.currentUser
        cell.rating = ratings[indexPath.row]
        cell.renderCell()
        
        return cell
    }
}
