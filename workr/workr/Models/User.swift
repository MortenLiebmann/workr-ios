//
//  User.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

struct User: Codable {
    var ID: UUID
    var Name: String
    var Email: String
    var Address: String?
    var Business: String?
    var Phone: String?
    var Company: String?
    var AccountFlags: Int
}
