//
//  IntradayInfo.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/29.
//

import Foundation

struct IntraDay: Decodable{
    let timeSeries : [String : OHLC]
    
    enum CodingKeys: String, CodingKey {
        case timeSeries = "Time Series (5min)"
    }
    
    func getStockInfo() -> [StockInfo] {
        var infos = [StockInfo]()
        let sortedTimeSeries = timeSeries.sorted { $0.key < $1.key }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let lastDate = self.getLastRefreshDate()
        let openTimeString = getTimeString(from: lastDate, times: "09:30:00")
        let closeTimeString = getTimeString(from: lastDate, times: "16:00:00")
        
        if let openTime = formatter.date(from: openTimeString), let closeTime = formatter.date(from: closeTimeString) {
            for (dateString, ohlc) in sortedTimeSeries {
                guard let date = formatter.date(from: dateString),
                      let open = Double(ohlc.open),
                      let high = Double(ohlc.high),
                      let low = Double(ohlc.low),
                      let close = Double(ohlc.close),
                      let volumn  = Double (ohlc.volume) else { return [] }
                if date < openTime { continue }
                let dailyInfo = StockInfo(date: date, open: open, high: high, low: low, close: close, volumn: volumn)
                infos.append(dailyInfo)
                if date >= closeTime { break }
            }
        }
        return infos
    }
    func getLastRefreshDate() -> Date {
        let sortedTimeSeries = timeSeries.sorted { $0.key < $1.key }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let lastDateString = sortedTimeSeries.last?.key,
              let lastDate = formatter.date(from: lastDateString) else { return Date() }
        return lastDate
    }
    func getTimeString(from day: Date, times: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd "
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dayString = formatter.string(from: day)
        let timeString = dayString + times
        return timeString
    }
}
