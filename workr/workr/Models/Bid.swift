//
//  File.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 04/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

struct Bid: Codable {
    var ID: UUID?
    var PostID: UUID?
    var Text: String?
    var Flags: Int?
    var CreatedDate: Date?
    var CreatedByUserID: UUID?
    var CreatedByUser: User?
    var Price: Double?
}

extension Bid: CurrencyEnabled {
    var Value: String? {
        guard let price = Price as NSNumber? else { return nil }
        return formatter.string(from: price)
    }
}
