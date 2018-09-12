//
//  ChatTableViewCell.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 27/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class ChatTableViewCell: UITableViewCell, AppDataDelegate {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    override func layoutSubviews() {
        self.renderCell()
        self.selectionStyle = .none
    }
    
    var primaryUser: UUID!
    var viewColor: UIColor {
        get {
            if currentMessage?.Flags == 2 {
                return .darkGray
            } else if outgoing {
                return UIColor(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            } else {
                return UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
            }
        }
    }
    
    var previousMessage: Message?
    var currentMessage: Message?
    var nextMessage: Message?
    
    var outgoing: Bool {
        get {
            guard let currentMessage = currentMessage else { return false }
            
            if currentMessage.SentByUserID == appData.currentUser.ID {
                return true
            } else {
                return false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func renderCell() {
        guard let currentMessage = currentMessage else { return }
        messageView.backgroundColor = viewColor
        
        messageLabel.textColor = outgoing  ? .white : .darkGray
        messageLabel.textAlignment = outgoing ? .right : .left
        
        messageView.layer.cornerRadius = 10.0
        updateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        guard let currentMessage = currentMessage else { return }
        messageView.snp.remakeConstraints { (make) in
            if currentMessage.Flags == 2 {
                make.right.equalTo(self).offset(-8)
                make.left.equalTo(self).offset(8)
            } else if outgoing {
                make.right.equalTo(self).offset(-8)
                make.left.greaterThanOrEqualTo(self).offset(100)
            } else {
                make.right.lessThanOrEqualTo(self).offset(-100)
                make.left.equalTo(self).offset(8)
            }
            
            if currentMessage.Flags == 2 {
                make.top.equalTo(12)
                make.bottom.equalTo(-12)
            } else {
                if previousIsSameUser() {
                    make.top.equalTo(1)
                } else {
                    make.top.equalTo(8)
                }
                
                if nextIsSameUser() {
                    make.bottom.equalTo(-1)
                } else {
                    make.bottom.equalTo(-8)
                }
            }
        }
    }
    
    func previousIsSameUser() -> Bool {
        guard let currentMessage = currentMessage else { return false }
        guard let previousMessage = previousMessage else { return false}
        if previousMessage.SentByUserID == currentMessage.SentByUserID {
            return true
        } else {
            return false
        }
    }
    
    func nextIsSameUser() -> Bool {
        guard let currentMessage = currentMessage else { return false }
        guard let nextMessage = nextMessage else { return false}
        if nextMessage.SentByUserID == currentMessage.SentByUserID {
            return true
        } else {
            return false
        }
    }
}
