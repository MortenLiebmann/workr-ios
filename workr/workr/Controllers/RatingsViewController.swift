//
//  RatingsViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 07/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class RatingsViewController: UIViewController, AppDataDelegate {
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        ratingTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillAppear() {
        self.isEditing = true
    }
    
    @objc func keyboardWillDisappear() {
        self.isEditing = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if self.isEditing {
            self.view.endEditing(true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
