//
//  Message.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

struct Message: Codable {
    var ID: UUID
    var ChatID: UUID
    var SentByUserID: UUID
    var CreatedDate: Date
    var UpdatedDate: Date?
    var Text: String
    var Flags: Int
}
