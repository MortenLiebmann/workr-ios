//
//  Chat.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

struct Chat: Codable {
    var ID: UUID
    var PostID: UUID
    var CreatedDate: Date
    var ChatParty1UserID: UUID
    var ChatParty2UserID: UUID
}
