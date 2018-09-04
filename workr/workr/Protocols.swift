//
//  Protocols.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation

protocol AppDataError: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

protocol UITableViewCellRenderable {
    func renderCell()
}

protocol CurrencyEnabled {
    var formatter: NumberFormatter { get }
    var Value: String? { get }
}

extension CurrencyEnabled {
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "da_DK")
        formatter.currencySymbol = "DKK"
        formatter.alwaysShowsDecimalSeparator = true
        formatter.allowsFloats = true
        
        return formatter
        
    }
}
