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

    override func viewDidLoad() {
        super.viewDidLoad()
        

        priceTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
