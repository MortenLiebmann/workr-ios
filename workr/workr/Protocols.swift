//
//  Protocols.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 17/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import Foundation
import UIKit

protocol Renderable {
    func render()
}

protocol AppDataDelegate {
     var appData: AppData { get }
}

extension AppDataDelegate {
    var appData:AppData {
        return (UIApplication.shared.delegate as! AppDelegate).appData
    }
}

protocol Loadable: AppDataDelegate {
    func loadData()
}

protocol Matchable {
    associatedtype T
    func match(_ input: T) -> Bool
}

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
