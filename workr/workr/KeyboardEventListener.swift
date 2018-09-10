//
//  KeyboardEventListener.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 05/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardEventDelegate {
    func keyboardDidHide(duration: TimeInterval, animationCurve: UIViewAnimationOptions)
    func keyboardDidShow(height: CGFloat, frame: CGRect, duration: TimeInterval, animationCurve: UIViewAnimationOptions)
}

class KeyboardEventListener {
    var delegate: KeyboardEventDelegate!
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    deinit {
        removeObserver()
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.delegate.keyboardDidHide(duration: duration, animationCurve: animationCurve)
            } else {
                if let frameHeight = endFrame?.size.height {
                    self.delegate.keyboardDidShow(height: frameHeight, frame: endFrame!, duration: duration, animationCurve: animationCurve)
                }
            }
        }
    }
}
