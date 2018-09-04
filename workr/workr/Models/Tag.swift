//
//  Tag.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

struct jsonTag : Codable{
    var Name: String
}

struct Tag: Codable {
    var ID: UUID?
    var Name: String?
    var Flags: Int?
    var CreatedDate: Date
}
