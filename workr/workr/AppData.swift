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
    private var baseUrl = "http://skurk.info:9877"
    private var testUrl = "http://192.168.1.88:9877"
    private var currentUserID = "d73720c4-4e34-4d81-b516-973915b68805"
    private var testing = true
    open let PhotoUrl = "http://ybphoto.s3-website.eu-central-1.amazonaws.com"
    
    override init(){
        super.init()
        
        if testing {
            baseUrl = testUrl
        }
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

//MARK: - Posts
extension AppData {
    func getPosts() -> Promise<[Post]> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return Alamofire.request("\(baseUrl)/posts", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseDecodable(Array<Post>.self, queue: .main, decoder: decoder)
    }
    
    func createPost(title: String, description: String) -> Promise<Post>{
        let parameters = [
            "Title": title,
            "Description": description,
            "CreatedByUserID": currentUserID,
            "CreatedDate": ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withFullTime)
            ] as [String : Any]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return Alamofire.request("\(baseUrl)/posts", method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseDecodable(Post.self, queue: DispatchQueue.main, decoder: decoder)
    }
}

extension AppData {
    func getUsers() -> Promise<[User]> {
        return Alamofire.request("\(baseUrl)/users", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseDecodable(Array<User>.self)
    }
}

extension AppData {
}

