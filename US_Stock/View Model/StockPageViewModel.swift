//
//  StockCellViewModel.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/24.
//

import Foundation

struct StockPageViewModel {
    let dailyInfos : [StockInfo]
    var stock: Stock?
    let displayTime: ChartDisplayTimeInterval
    
    var latestData : StockInfo? {
        return dailyInfos.last
    }
    var lastDayVolumn : String {
        let volumnArray = dailyInfos.compactMap{$0.volumn}
        return volumnArray.reduce(0) { $0 + $1 }.formatPoints()
    }
    var openValue: Double {
        return dailyInfos.first?.open ?? 0.0
    }
    var highestValue: Double {
        return dailyInfos.map{ $0.close }.max() ?? 0.0
    }
    var lowestValue: Double {
        return dailyInfos.map{ $0.close }.min() ?? 0.0
    }
    var closeValue: Double {
        return latestData?.close ?? 0.0
    }
    var priceDiff : Double? {
        guard let latestData = latestData,
              let firstData = dailyInfos.first else { return nil }
        
        return (latestData.close - firstData.open)
    }
    var risingPercenttage: String {
        guard let latestData = latestData,
              let priceDiff = priceDiff else { return String() }
        let percent = (priceDiff/latestData.open * 100).round(to: 2)
        let sign = isRising! ? "+" : ""
        return "\(sign)\(percent) %"
    }
    var isRising: Bool? {
        guard let diff = priceDiff else { return nil }
        return diff > 0
    }
  
    var currentPrice : String {
        guard let lastData = dailyInfos.last else { return String() }
        return "\(lastData.close)"
    }
    
    var trimedDailyInfos: [StockInfo] {
        guard let latestDate = latestData?.date else { return [] }
        let endDate = getTargetDate(from: latestDate, in: displayTime)
        let dataBetweenTwoDate = self.dailyInfos.filter{ $0.date > endDate }
        var infos = [StockInfo]()
        switch displayTime {
        case .all, .tenYear:
            for (index, data) in dataBetweenTwoDate.enumerated() {
                if index % 15 == 0 { infos.append(data) }
            }
            return infos
        case .fiveYear, .threeYear:
            for (index, data) in dataBetweenTwoDate.enumerated() {
                if index % 4 == 0 { infos.append(data) }
            }
            return infos
        default:
            return dataBetweenTwoDate
        }
    }
    var chartDataX: [String] {
        let rawXData = trimedDailyInfos.map {"\($0.date)"}
        return chartXDateFormatTransformer(displayTime, xData: rawXData)
    }
    var chartDataY: [Double] {
        return trimedDailyInfos.map{$0.close}
    }
    var averagePrice: Double {
        return chartDataY.reduce(0.0){
            return $0 + $1/Double(chartDataY.count)
        }
    }
    
    func chartXDateFormatTransformer(_ interval: ChartDisplayTimeInterval, xData: [String])  -> [String] {
        var newData = [String]()
        for originalDate in xData {
            if let convertString = convertDateStringFormat(dateString: originalDate,
                                           fromDateFormat: "yyyy-MM-dd HH:mm:ss Z",
                                           toDateFormat: interval.dateFormatter){
                newData.append(convertString)
            }
        }
        return newData
    }
    func convertDateStringFormat(dateString: String, fromDateFormat: String, toDateFormat: String) -> String? {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = fromDateFormat
        fromDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let fromDateObject = fromDateFormatter.date(from: dateString) {
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = toDateFormat
            toDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let newDateString = toDateFormatter.string(from: fromDateObject)
            return newDateString
        }
        return nil
    }
    
    func getTargetDate(from intialDate: Date, in interval: ChartDisplayTimeInterval) -> Date {
        let cal = Calendar.current
        var targetDate = Date()
        switch interval {
        case .oneDay:
            targetDate = cal.date(byAdding: .minute, value: -390, to: intialDate) ?? Date()
        case .oneWeek:
            targetDate = cal.date(byAdding: .day, value: -7, to: intialDate) ?? Date()
        case .oneMonth:
            targetDate = cal.date(byAdding: .month, value: -1, to: intialDate) ?? Date()
        case .threeMonth:
            targetDate = cal.date(byAdding: .month, value: -3, to: intialDate) ?? Date()
        case .halfYear:
            targetDate = cal.date(byAdding: .month, value: -6, to: intialDate) ?? Date()
        case .oneYear:
            targetDate = cal.date(byAdding: .year, value: -1, to: intialDate) ?? Date()
        case .threeYear:
            targetDate = cal.date(byAdding: .year, value: -3, to: intialDate) ?? Date()
        case .fiveYear:
            targetDate = cal.date(byAdding: .year, value: -5, to: intialDate) ?? Date()
        case .tenYear:
            targetDate = cal.date(byAdding: .year, value: -10, to: intialDate) ?? Date()
        case .all:
            targetDate = cal.date(byAdding: .year, value: -50, to: intialDate) ?? Date()
        }
        let year = cal.component(.year, from: targetDate)
        let month = cal.component(.month, from: targetDate)
        let day = cal.component(.day, from: targetDate)
        let reformatDate = DateComponents(calendar: cal, year:year, month: month, day: day).date
        return reformatDate ?? Date()
    }
}
