//
//  PlaceBidViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 04/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import PromiseKit

class PlaceBidViewController: UIViewController {
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBAction func offerDidTap(_ sender: Any) {
        appData.insertPostBid(text: self.messageTextView.text, price: price, postId: post.ID).done { (bid) in
            self.createMessage()
            } .catch { (error) in
                print(error)
        }
    }
    
    var chat: Chat!
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
        
        loadData()

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
    
    func createMessage() {
        if let chat = chat {
            insertMessage(chat: chat)
        } else {
            createChat().done { (chat) in
                self.insertMessage(chat: chat)
                }.catch { (error) in
                    print(error)
            }
        }
    }
    
    func insertMessage(chat: Chat) {
        guard let text = self.messageTextView.text, !text.isEmptyOrWhitespace() else { return }
        let parameters = Message(ID: nil, ChatID: chat.ID!, SentByUserID: appData.currentUser.ID, CreatedDate: nil, UpdatedDate: nil, Text: text, Flags: 4).dictionary
        appData.insertMessage(message: parameters).done { (message) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func createChat() -> Promise<Chat> {
        let parameters = Chat(ID: nil, PostID: post.ID, CreatedDate: nil, ChatParty1UserID: appData.currentUser.ID, ChatParty2UserID: post.CreatedByUserID).dictionary
        return appData.insertChat(chat: parameters)
    }
}

extension PlaceBidViewController: Loadable {
    func loadData() {
        guard let post = post else { return }
        appData.getChat(by: [
            "PostID" : post.ID.uuidString.lowercased(),
            "ChatParty1UserID": post.CreatedByUserID.uuidString.lowercased(),
            "ChatParty2UserID": appData.currentUser.ID.uuidString.lowercased()
            ]).done { (chats) in
                if chats.count > 0 {
                    self.chat = chats.first
                }
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
