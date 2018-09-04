//
//  ProfileViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 30/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
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

    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    func render() {
        guard let user = user else { return }
        
        nameLabel.text = user.Name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
