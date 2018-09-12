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
import SwiftyJSON

open class AppData: NSObject {
    struct CustomError: AppDataError {
        var title: String?
        var code: Int
        var errorDescription: String? { return _description }
        var failureReason: String? { return _description }
        
        private var _description: String
        
        init(title: String?, description: String, code: Int) {
            self.title = title ?? "Error"
            self._description = description
            self.code = code
        }
    }
    
    private var credentials: String? {
        get {
            return UserDefaults.standard.string(forKey: "Credentials")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Credentials")
        }
    }
    
    open var imageCache: [String: UIImage] = [:]
    private var ratingsCache: [UUID: [Rating]] = [:]
    private var defaults = UserDefaults.standard
    private var baseUrl = "http://skurk.info:9877"
    private var testUrl = "http://192.168.1.88:9877"
    private var mobileUrl = "http://10.0.0.37:9877"
    private var currentUserID = "5b6f0164-9798-407d-a38f-e4640bdbd8de"
    var currentUser: User!
    private var testing = false
    
    override init(){
        super.init()
        
        if testing {
            baseUrl = testUrl
        }
//        baseUrl = mobileUrl
    }
    
    var decoder: JSONDecoder {
        get {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }
    }
    
    public func getImageFrom(_ url: String) -> Promise<UIImage> {
        return Promise<UIImage> { promise in
            Alamofire.request("\(baseUrl)/\(url)",
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                headers: ["Content-Type": "image/png"]).responseImage { (response) in
                if let image = response.result.value {
                    promise.fulfill(image)
                } else {
                    promise.reject(CustomError(title: nil, description: "No image", code: 400))
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
    
    func getFirstUser() -> Promise<User?> {
        return firstly {
            Alamofire.request("\(baseUrl)/users").responseDecodable(Array<User>.self, queue: .main, decoder: decoder)
            }.map({ (users) -> User? in
                guard let user = users.first else { return nil }
                self.currentUser = user
                return user
            })
    }
    
    func getUrl(from stub: String) -> URL? {
        return URL(string: "\(baseUrl)/\(stub)")
    }
    
    func clearCache() {
        imageCache = [:]
        ratingsCache = [:]
    }
    
    func generateHeader() -> HTTPHeaders? {
        guard let credentials = self.credentials else { return nil}
        
        return [
            "Authorization": "Basic \(credentials)"
        ]
    }
}

//MARK: - Posts
extension AppData {
    func getPosts() -> Promise<[Post]> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return Alamofire.request("\(baseUrl)/posts",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: nil).responseDecodable(Array<Post>.self, queue: .main, decoder: decoder)
    }
    
    func createPost(title: String, description: String, tags: [[String: String]], address: String?) -> Promise<Post> {
        let parameters = [
            "Title": title,
            "Description": description,
            "CreatedByUserID": currentUser.ID.uuidString.lowercased(),
            "PostTags": tags,
            "CreatedDate": ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withFullTime),
            "Address": address ?? ""
            ] as [String : Any]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return Promise<Post> {seal in
            Alamofire.request("\(baseUrl)/posts",
                method: .put,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: self.decoder, queue: .main){ (response: DataResponse<Post>) in
                    if let post = response.value {
                        seal.fulfill(post)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
            }
        }
    }
}

//MARK: - Users
extension AppData {
    func getCurrentUser() -> Promise<User> {
        return Promise<User> {seal in
            if let user = currentUser {
                seal.fulfill(user)
            } else {
                getFirstUser().done({ (user) in
                    if let user = user {
                        seal.fulfill(user)
                    } else {
                         seal.reject(CustomError(title: nil, description: "No users", code: 400))
                    }
                })
            }
        }
    }
    
    func getUsers() -> Promise<[User]> {
        return Alamofire.request("\(baseUrl)/users",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: nil).responseDecodable(Array<User>.self)
    }
    
    func login() -> Promise<User> {
        return Promise<User> {seal in
            if let credentials = self.credentials {
                self.login(with: credentials).done({ (user) in
                    seal.fulfill(user)
                })
            } else {
                seal.reject(CustomError(title: nil, description: "Not logged in", code: 1000))
            }
        }
    }
    
    func logout() -> Promise<Bool> {
        return Promise<Bool> {seal in
            self.credentials = nil
            seal.fulfill(true)
        }
    }
    
    func login(username: String, password: String) -> Promise<User> {
        let cred = "\(username):\(password)".data(using: String.Encoding.utf8)?.base64EncodedString()
        
        return login(with: cred!)
    }
    
    private func login(with credentials: String) -> Promise<User> {
        let headers = [
            "Authorization": "Basic \(credentials)"
            
        ]
        return Promise<User> {seal in
            firstly{
                Alamofire.request("\(baseUrl)/auth",
                    method: .get, parameters: nil,
                    encoding: URLEncoding.default,
                    headers: headers).responseData()
                }.get({ (data, response) in
                    if data.count == 0 {
                        seal.reject(CustomError(title: "Error", description: "Incorrect username or password", code: 500))
                        return
                    }
                    
                    let json = try JSON.init(data: data)
                    if response.response?.statusCode == 200 {
                        let user = try self.decoder.decode(User.self, from: json.rawData())
                        self.currentUser = user
                        self.credentials = credentials
                        seal.fulfill(user)
                    } else if let message = json["ErrorMessage"].string {
                        seal.reject(CustomError(title: "Server error", description: message, code: 500))
                    }
                }).catch({ (error) in
                    seal.reject(error)
                })
        }
    }
    
    func registerUser(name: String, email: String, password: String) -> Promise<User> {
        let parameters = [
            "Name": name,
            "Email": email
        ]
        
        let header = [
            "Password": password
        ]
        
        return Promise<User> {seal in
            firstly{
                Alamofire.request("\(baseUrl)/register",
                    method: .put,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                    headers: header).responseData()
                }.get({ (data, response) in
                    let json = try JSON.init(data: data)
                    if response.response?.statusCode == 200 {
                        seal.fulfill(try self.decoder.decode(User.self, from: json.rawData()))
                    } else if let message = json["ErrorMessage"].string {
                        seal.reject(CustomError(title: "Server error", description: message, code: 500))
                    }
                }).catch({ (error) in
                    seal.reject(error)
                })
        }
    }
}

//MARK: - Tags
extension AppData {
    func getTags() -> Promise<[Tag]> {
        return Alamofire.request("\(baseUrl)/posttags",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: nil).responseDecodable(Array<Tag>.self, queue: .main, decoder: decoder)
    }
}

//MARK: - Chats
extension AppData {
    func insertChat(chat: [String : Any]) -> Promise<Chat> {
        return Promise<Chat> {seal in
            Alamofire.request("\(baseUrl)/chats",
                method: .put,
                parameters: chat,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: decoder, queue: .main, completionHandler: { (response: DataResponse<Chat>) in
                    if let chat = response.value {
                        seal.fulfill(chat)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
                }) 
        }
    }
    
    func getChat(by parameters: [String: Any]) -> Promise<[Chat]> {
        return Promise<[Chat]> { seal in
            Alamofire.request("\(baseUrl)/chats",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: decoder, queue: .main){ (response: DataResponse<[Chat]>) in
                    if let chats = response.value {
                        seal.fulfill(chats)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
            }
        }
    }
    
    func getMessages(chatId: UUID) -> Promise<[Message]> {
        let parameters = [
            "ChatID": chatId.uuidString.lowercased()
        ]
        return Promise<[Message]> { seal in
            Alamofire.request("\(baseUrl)/messages",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: decoder, queue: .main) { (response: DataResponse<[Message]>) in
                    if let messages = response.value {
                        seal.fulfill(messages)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
            }
        }
    }
 
    func insertMessage(message: [String: Any]) -> Promise<Message> {
        return Promise<Message> { seal in
            Alamofire.request("\(baseUrl)/messages",
                method: .put,
                parameters: message,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: decoder, queue: .main){ (response: DataResponse<Message>) in
                    if let message = response.value {
                        seal.fulfill(message)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
            }
        }
    }
}

//MARK: - Ratings
extension AppData {
    func getRatings(for userId: UUID) -> Promise<[Rating]> {
        let parameters = [
            "UserID": userId.uuidString.lowercased()
        ]
        return Promise<[Rating]> {seal in
            if let ratings = ratingsCache[userId] {
                seal.fulfill(ratings)
                return
            }
            
            Alamofire.request("\(baseUrl)/ratings",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: decoder, queue: .main){ (response: DataResponse<[Rating]>) in
                    if let ratings = response.value {
                        self.ratingsCache[userId] = ratings
                        seal.fulfill(ratings)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
            }
        }
    }
    
    func insertRating(rating: [String : Any]) -> Promise<Rating> {
        return Promise<Rating> {seal in
            Alamofire.request("\(baseUrl)/ratings",
                method: .put,
                parameters: rating,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: decoder, queue: .main){ (response: DataResponse<Rating>) in
                    if let rating = response.value {
                        seal.fulfill(rating)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
            }
        }
    }
}

//MARK: - Bids
extension AppData {
    func insertPostBid(text: String, price: Double, postId: UUID) -> Promise<Bid> {
        let parameters = [
            "Text": text,
            "CreatedByUserID": currentUser.ID.uuidString.lowercased(),
            "PostID": postId.uuidString,
            "Price": price.toString()
        ]
        
        return Alamofire.request("\(baseUrl)/postbids",
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: generateHeader())
            .responseDecodable(Bid.self, queue: .main, decoder: decoder)
    }
    
    func updatePostBid(bidId: UUID, bid: [String: Any]) -> Promise<Bid> {
        return Promise<Bid> {seal in
            Alamofire.request("\(baseUrl)/postbids/\(bidId.uuidString.lowercased())",
                method: .patch,
                parameters: bid,
                encoding: JSONEncoding.default,
                headers: generateHeader())
                .responseDecodable(decoder: decoder, queue: .main){ (response: DataResponse<Bid>) in
                    if let bid = response.value {
                        seal.fulfill(bid)
                    } else if let error = response.error {
                        seal.reject(error)
                    }
            }
        }
    }
}

//MARK: - Image upload
extension AppData {
    func uploadResourceImage(userId: UUID, image: UIImage) -> Promise<UserImage> {
        return Promise<UserImage> { seal in
            if let data = UIImageJPEGRepresentation(image, 0.1) {
                Alamofire.upload(multipartFormData: { (multipart) in
                    multipart.append(data, withName: "file", mimeType: "image/png")
                },
                                 usingThreshold: 2500000,
                                 to: "\(baseUrl)/userimages/\(userId.uuidString.lowercased())",
                    method: .put,
                    headers: generateHeader()){ (result) in
                        switch result {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                let decoder = JSONDecoder()
                                
                                do {
                                    let responseImage = try decoder.decode(UserImage.self, from: response.data!)
                                    seal.fulfill(responseImage)
                                } catch {
                                    
                                }
                            }
                        case .failure(let error):
                            seal.reject(error)
                        }
                }
            }
        }
    }
    
    func uploadImages(postId: UUID, images: [UIImage]) -> Promise<[PostImage]> {
        return Promise<[PostImage]> {promise in
            var returnData: [PostImage] = []
            
            for image in images {
                if let data = UIImageJPEGRepresentation(image, 0.05) {
                    Alamofire.upload(multipartFormData: { (multipart) in
                        multipart.append(data, withName: "file", fileName: "tis", mimeType: "image/png")
                    }, usingThreshold: 2500000, to: "\(baseUrl)/postimages/\(postId.uuidString.lowercased())", method: .put, headers: generateHeader(), encodingCompletion: { (result) in
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

