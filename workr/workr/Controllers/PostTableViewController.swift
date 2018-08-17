//
//  PostTableViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class PostTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Int] = [0,1,2,3,4,5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appData.getUsers().done { (data) in
            print(data)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            print("HitIt")
        }
    }
}

extension PostTableViewController: UITableViewDelegate {
    
}

extension PostTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        
        return cell
    }
}
