//
//  Extensions.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

extension Double {
    func toString() -> String {
        return String(self)
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension DataRequest {
    private func decodableResponseSerializer<T: Decodable>(decoder: JSONDecoder?) -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            let jsonDecoder = decoder ?? JSONDecoder()
            
            return Result { try jsonDecoder.decode(T.self, from: data)}
        }
    }
    
    @discardableResult
    func responseDecodable<T: Decodable>(decoder: JSONDecoder? = nil, queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(decoder: decoder), completionHandler: completionHandler)
    }
}

extension String {
    func isEmptyOrWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        
        return (self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
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

extension Encodable {
    var dictionary: [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let json = try JSONSerialization.jsonObject(with: encoder.encode(self))
            return json as? [String : Any] ?? [:]
        } catch {
            print(error)
            return [:]
        }
    }
}

extension UIImageView {
    var appData:AppData {
        return (UIApplication.shared.delegate as! AppDelegate).appData
    }
    
    func downloadUserImage(from userId: UUID) {
        self.downloadImage(url: "userimages/\(userId.uuidString.lowercased())", id: userId) { (id, success) in
            print(success)
        }
    }
    
    func downloadImage(from postId: UUID, imageId: UUID) {
        self.downloadImage(url: "postimages/\(postId.uuidString.lowercased())/\(imageId.uuidString.lowercased())", id: imageId) { (id, success) in
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
