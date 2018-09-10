//
//  RatingsViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 07/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class RatingsViewController: UIViewController {
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBAction func confirmDidTap(_ sender: Any) {
        confirm()
    }
    
    var post: Post!
    var bid: Bid!
    
    private var score: Int {
        get {
            guard let ratingString = ratingTextField.text, let ratingValue = formatter.number(from: ratingString) as? Int else { return 1 }
            var value = min(ratingValue, 5)
            value = max(value, 1)
            return value
        }
    }
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.allowsFloats = false
        formatter.alwaysShowsDecimalSeparator = false
        
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func confirm() {
        let rating = Rating(ID: nil,
                            UserID: bid.CreatedByUserID,
                            RatedByUserID: post.CreatedByUserID,
                            RatedByUser: nil,
                            PostID: post.ID,
                            CreatedDate: Date(),
                            Score: score,
                            Text: self.messageTextView.text).dictionary
        
        self.appData.insertRating(rating: rating).done { (rating) in
            print(rating)
            }.catch { (error) in
                print(error)
        }
    }
}

extension RatingsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        ratingTextField.text = formatter.string(from: score as NSNumber)
    }
}
