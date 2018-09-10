//
//  PlaceBidViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 04/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class PlaceBidViewController: UIViewController {
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBAction func offerDidTap(_ sender: Any) {
        appData.insertPostBid(text: self.messageTextView.text, price: price, postId: post.ID).done { (bid) in
            print(bid)
            self.dismiss(animated: true, completion: nil)
            } .catch { (error) in
                print(error)
        }
    }
    
    var post: Post!
    var price: Double!
    var formatter: NumberFormatter = NumberFormatter()
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "da_DK")
        formatter.currencySymbol = "DKK"
        formatter.alwaysShowsDecimalSeparator = true
        formatter.allowsFloats = true
        
        return formatter
    }()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)

        priceTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if self.isEditing {
            self.view.endEditing(true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension PlaceBidViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let value = textField.text, !value.isEmptyOrWhitespace() else { return }
        guard let price = formatter.number(from: value) else { return }
        
        self.price = Double(price)
        
        textField.text = currencyFormatter.string(from: price)
    }
}
