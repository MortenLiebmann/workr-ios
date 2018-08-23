//
//  TestImageViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 23/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class TestImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        appData.getImageFrom("postimages/3463a8fa-f055-481b-a970-f241b5a8567a/1dfad231-a102-436b-8e21-f8d5e1df3137")
//        imageView.downloadImage(url: "postimages/3463a8fa-f055-481b-a970-f241b5a8567a/1dfad231-a102-436b-8e21-f8d5e1df3137", id: "1dfad231-a102-436b-8e21-f8d5e1df3137") { (id, success) in
//            print(success)
//        }
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

}
