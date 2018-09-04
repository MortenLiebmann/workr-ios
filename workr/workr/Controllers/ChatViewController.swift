//
//  ChatViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 27/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

struct chatModel {
    var message: String
    var outgoing: Bool
}

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func sendDidTap(_ sender: Any) {
        self.tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user1, CreatedDate: Date(), UpdatedDate: nil, Text: self.messageTextView.text, Flags: 0))
        let newRow = IndexPath(row: self.tableArray2.count - 1, section: 0)
        
        self.tableView.beginUpdates()
        tableView.insertRows(at: [newRow], with: UITableViewRowAnimation.bottom)
        self.tableView.endUpdates()
        
        tableView.scrollToRow(at: newRow, at: .bottom, animated: true)
        clearPlaceholder()
        updateTextViewHeight()
    }
    
    @IBAction func closeDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var user1: UUID = UUID()
    var user2: UUID = UUID()
    
    var tableArray2: [Message] = []
    var tableArray: [chatModel] = [chatModel(message: "This is a message\non multiple lines", outgoing: true), chatModel(message: "I forgot to say something", outgoing: true), chatModel(message: "Want to eat lunch?", outgoing: true), chatModel(message: "Yes, that sounds lovely.\n\n\nMeet me at starbucks at 9 PM", outgoing: false)]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user1, CreatedDate: Date(), UpdatedDate: nil, Text: "Hello", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user1, CreatedDate: Date(), UpdatedDate: nil, Text: "I would like to make an offer on this assignment", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user1, CreatedDate: Date(), UpdatedDate: nil, Text: "What is your expected rate for this type of work?", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user1, CreatedDate: Date(), UpdatedDate: nil, Text: "Best regards\n\nJohnny Reimar", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user2, CreatedDate: Date(), UpdatedDate: nil, Text: "Hi,\nThanks for reaching out.", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user2, CreatedDate: Date(), UpdatedDate: nil, Text: "I expect around 200 USD", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user1, CreatedDate: Date(), UpdatedDate: nil, Text: "I can do it for 250", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user2, CreatedDate: Date(), UpdatedDate: nil, Text: "What about 220", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user1, CreatedDate: Date(), UpdatedDate: nil, Text: "That is a deal\nWould you be so kind and then accept my offer?", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user2, CreatedDate: Date(), UpdatedDate: nil, Text: "Sure thing, done!", Flags: 0))
        tableArray2.append(Message(ID: UUID(), ChatID: UUID(), SentByUserID: user2, CreatedDate: Date(), UpdatedDate: nil, Text: "User 2 has accepted User 3's offer", Flags: 2))
        
        messageTextView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        messageTextView.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        messageTextView.delegate = self
        setPlaceholder()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableArray2[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatTableViewCell
        
        cell.messageLabel.text = data.Text
        cell.currentMessage = data
        
        if indexPath.row - 1 >= 0 {
            cell.previousMessage = tableArray2[indexPath.row - 1]
        }
        if indexPath.row + 1 < tableArray2.count {
            cell.nextMessage = tableArray2[indexPath.row + 1]
        }
        cell.primaryUser = user1
        cell.renderCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray2.count
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
