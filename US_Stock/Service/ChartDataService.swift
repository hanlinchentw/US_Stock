//
//  ChartDataService.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/25.
//

import Foundation
import Charts

struct ChartDataService {
    
    static let shared = ChartDataService()
    
    func inputChartData(x: [String], y:[Double], fillColor: UIColor, canHighLight: Bool) -> LineChartDataSet {
        var dataEntries: [ChartDataEntry] = []
        for i in  (0..<y.count) {
            let entry = ChartDataEntry(x: Double(i), y: y[i])
            dataEntries.append(entry)
        }
        let dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.mode = .linear
        dataSet.colors = [fillColor]
        dataSet.lineWidth = 1.7
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.highlightEnabled = canHighLight
        dataSet.highlightColor = .white
        dataSet.highlightLineWidth = 1.5
        
        let gradientFill = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [fillColor.cgColor, UIColor.black.cgColor] as CFArray, locations: [0.7, 0])
        dataSet.fill = Fill.fillWithLinearGradient(gradientFill!, angle: 90)
        dataSet.drawFilledEnabled = true
        return dataSet
    }
}
