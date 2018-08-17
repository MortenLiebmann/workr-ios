//
//  AppData.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PromiseKit

open class AppData: NSObject {
    open var imageCache: [String: Data] = [:]
    private var defaults = UserDefaults.standard
    private var baseUrl = "http://192.168.1.88:9877"
    open let PhotoUrl = "http://ybphoto.s3-website.eu-central-1.amazonaws.com"
    
    override init(){
        super.init()
    }
    
    public func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func clearCache() {
        imageCache = [:]
    }
    
    func generateHeader() -> HTTPHeaders? {
        guard let token = self.defaults.string(forKey: "token") else { return nil}
        
        return [
            "Authorization": "Bearer \(token)"
        ]
    }
}

extension AppData {
    func getPosts() -> Promise<[Post]> {
        return Alamofire.request("\(baseUrl)/posts", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseDecodable(Array<Post>.self)
    }
    
    func getUsers() -> Promise<[User]> {
        return Alamofire.request("\(baseUrl)/users", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseDecodable(Array<User>.self)
    }
}

extension AppData {
}

extension AppData {
}

