//
//  Extensions.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/23.
//

import UIKit
import Charts

extension UIView  {
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil,
                topPadding: CGFloat = 0, leftPadding : CGFloat = 0,
                rightPadding: CGFloat = 0, bottomPadding:CGFloat = 0){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftPadding).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -rightPadding).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }
    }
    func setDimension(width: CGFloat? = nil, height:CGFloat? = nil){
        self.translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    func centerX(inView view: UIView, xConstant : CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: xConstant).isActive = true
    }
    func centerY(inView view: UIView, yConstant : CGFloat = 0){
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant).isActive = true
    }
}
extension UIViewController{
   
    func setTitleView() -> UIView {
        //Get navigation Bar Height and Width
                let navigationBarHeight = Int(self.navigationController!.navigationBar.frame.height)
                let navigationBarWidth = Int(self.navigationController!.navigationBar.frame.width)

                //Set Font size and weight for Title and Subtitle
                let titleFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
                let subTitleFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)

                //Title label
                let titleLabel = UILabel(frame: CGRect(x: 12, y: 0, width: 0, height: 0))
                titleLabel.backgroundColor = UIColor.clear
                titleLabel.textColor = UIColor.white
                titleLabel.font = titleFont
                titleLabel.text = "Stocks"
                titleLabel.sizeToFit()

                //SubTitle label
                let subtitleLabel = UILabel(frame: CGRect(x: 12, y: 16, width: 0, height: 0))
                subtitleLabel.backgroundColor = UIColor.clear
                subtitleLabel.textColor = UIColor.gray
                subtitleLabel.font = subTitleFont
                subtitleLabel.text = getTodayDateString()
                subtitleLabel.sizeToFit()

                //Add Title and Subtitle to View
                let titleView = UIView(frame: CGRect(x: 0, y: 0, width: navigationBarWidth, height: navigationBarHeight))
                titleView.addSubview(titleLabel)
                titleView.addSubview(subtitleLabel)

                return titleView
    }
    func getTodayDateString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
extension UISearchController {
    open override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let presentingVC = self.presentingViewController {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.view.frame = presentingVC.view.frame
                }
            }
        }
}
extension UISearchBar {
    func setTextFieldColor(_ color: UIColor){
        for subview in self.subviews{
            for subSubview in subview.subviews {
                if let textField = subSubview as? UITextField {
                    textField.backgroundColor = color
                    print("DEBUG: Search bar color changed.")
                    break
                }
            }
        }
    }
}

extension Double {
    func round(to places: Int) -> Double{
        let mutiplier = pow(10, Double(places))
        return (self * mutiplier).rounded() / mutiplier
    }
    func formatPoints()  -> String {
        let thousandNum = self/1000
        let millionNum = self/1000000
        if self >= 1000 && self < 1000000 {
            if floor(thousandNum) == thousandNum{ return "\(Int(thousandNum)) k" }
            return "\(thousandNum.round(to: 3)) k"
        }else if self >= 1000000 {
            if floor(millionNum) == millionNum{ return "\(Int(millionNum)) M" }
            return "\(millionNum.round(to: 2)) M"
        }else{ return "\(self)" }
    }
}

extension String {
    func turnIntoDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let date = formatter.date(from: self) else { fatalError() }
        return date
    }
}

extension NSSet {
    func unzipNSSetToStockInfos() -> [StockInfo]{
        guard let ohlcArray = self.allObjects as? [IntraSeries] else { return [] }
        var stockInfos = [StockInfo]()
        for ohlc in ohlcArray {
            guard let date = ohlc.date?.turnIntoDate()  else { return [] }
            let stockInfo = StockInfo(date: date,
                                      open: ohlc.open,
                                      high: ohlc.high,
                                      low: ohlc.low,
                                      close: ohlc.close,
                                      volumn: ohlc.volumn)
            stockInfos.append(stockInfo)
        }
        stockInfos.sort {$0.date < $1.date}
        return stockInfos
    }
}
