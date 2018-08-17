//
//  Rating.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

struct Rating {
    var ID: UUID
    var UserID: UUID
    var RatedByUserID: UUID
    var PostID: UUID
    var CreatedDate: Date
    var Score: Int
    var Text: String
}
