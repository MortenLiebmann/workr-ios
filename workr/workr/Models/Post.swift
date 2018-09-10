//
//  Post.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

struct Post: Codable {
    var ID: UUID
    var Title: String
    var CreatedByUserID: UUID
    var CreatedDate: Date
    var Description: String
    var Address: String?
    var JobEndDate: Date?
//    var PostFlags: Int
    var PostTags: [Tag]
    var PostBids: [Bid]
    var PostImageIDs: [UUID]
    var CreatedByUser: User?
}

extension Post: Matchable {
    typealias T = String?
    
    func match(_ input: String?) -> Bool {
        guard let text = input, !text.isEmptyOrWhitespace() else { return true }
        
        if self.Title.lowercased().contains(text.lowercased())
            || (self.PostTags.first { $0.Name!.lowercased().contains(text.lowercased())} ) != nil
            || CreatedByUser!.Name.lowercased().contains(text.lowercased()) {
            return true
        }
        
        return false
    }
}
