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

extension String {
//    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
//        let attributes = [NSAttributedStringKey.font:self,]
//        let attString = NSAttributedString(string: string,attributes: attributes)
//        let framesetter = CTFramesetterCreateWithAttributedString(attString)
//        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: width, height: DBL_MAX), nil)
//    }    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
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

extension UIImageView {
    var appData:AppData {
        return (UIApplication.shared.delegate as! AppDelegate).appData
    }
    
    func downloadImage(from postId: UUID, imageId: UUID) {
        self.downloadImage(url: "postimages/\(postId)/\(imageId)", id: imageId) { (id, success) in
            print(success)
        }
    }
    
    func downloadImage(url: String, id: UUID, completion: @escaping (UUID, Bool) -> Void) {
        if let image = self.appData.imageCache[url] {
            completion(id, true)
            self.image = image
            return
        }
        
        self.appData.getImageFrom(url).done { (image) in
            DispatchQueue.main.async() {
                self.image = image
                self.appData.imageCache[url] = image
                completion(id, true)
            }
           
            } .catch { (error) in
                completion(id, false)
        }
    }
}

//extension Formatter {
//    static let iso8601: ISO8601DateFormatter = {
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        return formatter
//    }()
//}

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
