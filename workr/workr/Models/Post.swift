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
    var PostImageIDs: [UUID]
    var CreatedByUser: User?
}
