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
import AlamofireImage
import PromiseKit

open class AppData: NSObject {
    open var imageCache: [String: UIImage] = [:]
    private var defaults = UserDefaults.standard
    private var baseUrl = "http://skurk.info:9877"
    private var testUrl = "http://192.168.1.88:9877"
    private var currentUserID = "d73720c4-4e34-4d81-b516-973915b68805"
    private var testing = true
    open let PhotoUrl = "http://ybphoto.s3-website.eu-central-1.amazonaws.com"
    
    enum AppDataError: Error {
        case NotImplemented
    }
    
    override init(){
        super.init()
        
        if testing {
            baseUrl = testUrl
        }
    }
    
    public func getImageFrom(_ url: String) -> Promise<UIImage> {
        return Promise<UIImage> { promise in
            Alamofire.request("\(baseUrl)/\(url)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Content-Type": "image/png"]).responseImage { (response) in
                if let image = response.result.value {
                    promise.fulfill(image)
                } else {
                    promise.reject(AppDataError.NotImplemented)
                }
            }
        }
    }
    
    public func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        do {
            try URLSession.shared.dataTask(with: URLRequest(url: url, method: HTTPMethod(rawValue: "VIEW")!)) { data, response, error in
                completion(data, response, error)
                }.resume()
        } catch var error {
            print(error)
        }
    }
    
    func getUrl(from stub: String) -> URL? {
        return URL(string: "\(baseUrl)/\(stub)")
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
    func uploadImages(postId: UUID, images: [UIImage]) -> Promise<[PostImage]> {
        return Promise<[PostImage]> {promise in
            var returnData: [PostImage] = []
            
            for image in images {
                if let data = UIImageJPEGRepresentation(image, 0.05) {
                    Alamofire.upload(multipartFormData: { (multipart) in
                        multipart.append(data, withName: "file", fileName: "tis", mimeType: "image/png")
                    }, usingThreshold: 2500000, to: "\(baseUrl)/postimages/\(postId)", method: .put, headers: nil, encodingCompletion: { (result) in
                        switch result {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                let decoder = JSONDecoder()
                                
                                do {
                                    let responseImage = try decoder.decode(PostImage.self, from: response.data!)
                                    returnData.append(responseImage)
                                    
                                    if returnData.count >= images.count {
                                        promise.fulfill(returnData)
                                    }
                                } catch {
                                    
                                }
                            }
                        case .failure(let error):
                            promise.reject(error)
                            
                        }
                    })
                }
            }
        }
      
    }
}

