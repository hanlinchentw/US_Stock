//
//  DailyInfo.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/27.
//

import Foundation

struct StockInfo {
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volumn : Double
}
struct Daily: Decodable{
    let timeSeries : [String : OHLC]
    
    enum CodingKeys: String, CodingKey {
        case timeSeries = "Time Series (Daily)"
    }
    func getStockInfo() -> [StockInfo] {
        var infos = [StockInfo]()
        let sortedTimeSeries = timeSeries.sorted { $0.key < $1.key }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for (dateString, ohlc) in sortedTimeSeries {
            guard let date = formatter.date(from: dateString),
                  let open = Double(ohlc.open),
                  let high = Double(ohlc.high),
                  let low = Double(ohlc.low),
                  let close = Double(ohlc.close) ,
                  let volumn = Double(ohlc.volume) else { return []}
            let dailyInfo = StockInfo(date: date, open: open, high: high, low: low, close: close, volumn: volumn)
            infos.append(dailyInfo)
        }
        return infos
    }
}


struct Meta: Decodable {
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }
}

struct OHLC: Decodable {
    let open : String
    let high: String
    let low: String
    let close: String
    let volume : String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
    
}

