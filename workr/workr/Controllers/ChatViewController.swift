//
//  ChatViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 27/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import PromiseKit

struct chatModel {
    var message: String
    var outgoing: Bool
}

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBAction func sendDidTap(_ sender: Any) {
        createMessage()
    }
    
    @IBAction func closeDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var user1: User!
    var user2: User!
    var chat: Chat!
    var timer: Timer!
    var postId: UUID!
    var keyboardListener: KeyboardEventListener!
    var messages: [Message] = []
    override func viewDidLoad() {
        super.viewDidLoad()
     
        keyboardListener = KeyboardEventListener()
        keyboardListener.delegate = self
        getChat()
        
        messageTextView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        messageTextView.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        messageTextView.delegate = self
        
        profileImageView.downloadUserImage(from: user2.ID)
        nameLabel.text = user2.Name
        
        setPlaceholder()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func getChat() {
        firstly {
            appData.getChat(by: [
                "PostID" : postId.uuidString.lowercased(),
                "ChatParty1UserID": user1.ID.uuidString.lowercased(),
                "ChatParty2UserID": user2.ID.uuidString.lowercased()
                ])
            }.done { (chats) in
                if chats.count > 0 {
                    self.chat = chats.first
                }
                
                guard let chat = self.chat else { return }
                
                self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_) in
                    self.loadData()
                })
                self.loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createMessage() {
        if let chat = chat {
            insertMessage(chat: chat)
        } else {
            createChat().done { (chat) in
                self.insertMessage(chat: chat)
            }
        }
    }
    
    func insertMessage(chat: Chat) {
        guard let text = self.messageTextView.text, !text.isEmptyOrWhitespace() else { return }
        let parameters = Message(ID: nil, ChatID: chat.ID!, SentByUserID: appData.currentUser.ID, CreatedDate: nil, UpdatedDate: nil, Text: text, Flags: nil).dictionary
        appData.insertMessage(message: parameters).done { (message) in
            self.messages.append(message)
            
            let index = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.beginUpdates()
            
            self.tableView.insertRows(at: [index], with: .automatic)
            
            self.tableView.endUpdates()
            
            self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
            
            self.clearPlaceholder()
            self.updateTextViewHeight()
        }
    }
    
    func createChat() -> Promise<Chat> {
        let parameters = Chat(ID: nil, PostID: postId, CreatedDate: nil, ChatParty1UserID: user1.ID, ChatParty2UserID: user2.ID).dictionary
        return appData.insertChat(chat: parameters)
    }
}

extension ChatViewController: Loadable {
    func loadData() {
        guard let user1 = user1, let user2 = user2, let postId = postId else { return }
        
        if let chat = chat {
            self.appData.getMessages(chatId: chat.ID!).done({ (messages) in
                if self.messages.count != messages.count {
                    self.messages = messages
                    self.tableView.reloadData()
                }
            })
        }
    }
}

extension ChatViewController: KeyboardEventDelegate {
    func keyboardDidHide(duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        bottomConstraint.constant = 0.0
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutSubviews()
        }
    }
    
    func keyboardDidShow(height: CGFloat, frame: CGRect, duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        var tabBarHeight: CGFloat = 0.0
        
        if let tabbar = self.tabBarController?.tabBar {
            tabBarHeight = tabbar.frame.height
        }
        
        self.bottomConstraint?.constant = height - tabBarHeight
        UIView.animate(withDuration: duration) {
            self.view.layoutSubviews()
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatTableViewCell
        
        cell.messageLabel.text = data.Text
        cell.currentMessage = data
        
        if indexPath.row - 1 >= 0 {
            cell.previousMessage = messages[indexPath.row - 1]
        }
        if indexPath.row + 1 < messages.count {
            cell.nextMessage = messages[indexPath.row + 1]
        }
        cell.primaryUser = user2.ID
        
        cell.renderCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}

extension ChatViewController: UITableViewDelegate {
    
}

extension ChatViewController: UITextViewDelegate {
    func setPlaceholder() {
        updateText(textView: messageTextView, text: "Enter comment")
        messageTextView.textColor = UIColor.lightGray
    }
    
    func clearPlaceholder() {
        updateText(textView: messageTextView, text: "")
        messageTextView.textColor = UIColor.darkGray
    }
    
    func isPlaceholder() -> Bool {
        return messageTextView.textColor == .lightGray
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
        updateText(textView: textView, text: textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            setPlaceholder()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isPlaceholder() {
            clearPlaceholder()
        }
    }
    
    func updateTextViewHeight() {
        messageTextViewHeightConstraint.constant = min(120, messageTextView.contentSize.height + 4)
    }
    
    func updateText(textView: UITextView, text: String) {
        let attributeString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.headIndent = 8
        style.firstLineHeadIndent = 8
        style.tailIndent = -8
        
        
        attributeString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSMakeRange(0, text.count))
        attributeString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, text.count))
        textView.attributedText = attributeString
    }
}
