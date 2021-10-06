//
//  Stock.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/24.
//

import Foundation

struct SearchResult: Decodable {
    let bestMatches : [Stock]
}

struct Stock : Decodable{
    let name: String
    let symbol: String
    let type: String
    
    var isAdded: Bool = false
    var intraInfo = [StockInfo]()
    var lastRefreshDate: Date?
    
    enum CodingKeys : String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
    }
}
