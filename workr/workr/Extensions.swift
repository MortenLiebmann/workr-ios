//
//  Extensions.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var appData:AppData {
        return (UIApplication.shared.delegate as! AppDelegate).appData
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
            clipsToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: Double {
        get {
            return Double(layer.borderWidth)
        }
        
        set {
            layer.borderWidth = CGFloat(newValue)
        }
    }
}

extension Date {
    func toString(dateStyle: DateFormatter.Style? = .long, timeStyle: DateFormatter.Style? = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle!
        formatter.timeStyle = timeStyle!
        
        return formatter.string(from: self)
    }
}

@IBDesignable
class BorderView: UIView { }

@IBDesignable
class BorderButton: UIButton { }

@IBDesignable
class BorderTextField: UITextField { }
