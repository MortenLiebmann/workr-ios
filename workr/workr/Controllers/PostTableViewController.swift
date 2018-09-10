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
    @IBOutlet weak var searchBar: UISearchBar!
    
    var posts: [Post] = []
    var tempPosts: [Post] = []
    var currentUser: User!
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        loadData()
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
        
        searchBar.delegate = self
       
        loadData()
       
    }
    
    func loadData() {
        appData.getPosts().done { (data) in
            self.posts = data.sorted{$0.CreatedDate > $1.CreatedDate}
            self.tempPosts = data.sorted{$0.CreatedDate > $1.CreatedDate}
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            }.catch { (error) in
                print(error)
        }
        
        appData.getCurrentUser().done { (user) in
            self.currentUser = user
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            guard let vc = segue.destination as? PostViewController else { return }
            guard let data = getData(from: tableView.indexPathForSelectedRow) else { return }
            vc.post = data
        }
        if segue.identifier == "AddPost" {
            guard let vc = segue.destination as? AddPostViewController else { return }
        }
        if segue.identifier == "ShowProfile" {
            guard let nav = segue.destination as? UINavigationController else { return }
            guard let vc = nav.childViewControllers[0] as? ProfileViewController else { return }
            guard let currentUser = currentUser else { return }
            vc.user = currentUser
        }
    }
    
    func getData(from indexPath: IndexPath?) -> Post? {
        guard let indexPath = indexPath else { return nil }
        return posts[indexPath.row]
    }
}

extension PostTableViewController: UITableViewDelegate {
    
}

extension PostTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        cell.post = posts[indexPath.row]
        cell.initialize()
        
        return cell
    }
}

extension PostTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.showsCancelButton = false
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        view.endEditing(true)
        searchBar.showsCancelButton = false
        posts = tempPosts
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        view.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        posts = tempPosts.filter { $0.match(searchBar.text)}
        tableView.reloadData()
    }
}
