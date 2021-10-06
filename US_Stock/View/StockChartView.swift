//
//  StockChartView.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/28.
//

import UIKit
import Charts

enum StockChartMode {
    case simple
    case complete
}

class StockChartView: LineChartView {
    //MARK: - Properties
    let mode: StockChartMode
    var xAxisLabels = [String]()
    weak var axisFormatDelegate : IAxisValueFormatter?
    
    private let valueLabel : PaddingLabel = {
        let valueLabel = PaddingLabel(withInsets: 8, 8, 12, 12)
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        return valueLabel
    }()
    
    
    //MARK: - Lifecycle
    init(mode: StockChartMode) {
        self.mode = mode
        super.init(frame: .zero)
        axisFormatDelegate = self
        self.configureChart(with: mode)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Data inject
    func updateChartData(with viewModel : StockPageViewModel) {
        self.xAxisLabels = viewModel.chartDataX
        var fillColor = UIColor.black
        if let isRising = viewModel.isRising {
            fillColor = isRising ? UIColor.systemRed : UIColor.systemGreen
        }
        let x = viewModel.chartDataX
        let y = viewModel.chartDataY
        let dataSet = ChartDataService.shared.inputChartData(x: x,
                                                             y: y,
                                                             fillColor: fillColor,
                                                             canHighLight: self.mode == .complete)
        let chartData = LineChartData(dataSet: dataSet)
        
        self.data = chartData
    }
    //MARK: - Gesture
    func addGesture() {
        if self.mode == .complete {
            let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(chartTapped))
            tapGesture.minimumPressDuration = 0.05
            self.addGestureRecognizer(tapGesture)
        }
    }
    //MARK: - Seletors
    @objc func chartTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            // show
            let position = sender.location(in: self)
            guard let highlight = self.getHighlightByTouchPoint(position) else { return }
            highlightValue(highlight)
            self.showHighlightValue(highlight, postion: position)
        } else {
            // hide
            self.hideValueLabel()
            highlightValue(nil)
        }
    }
}
//MARK: - HighLight animation
extension StockChartView {
    func showHighlightValue(_ highlight : Highlight, postion: CGPoint) {
        let x = highlight.x
        let xValue = self.xAxisLabels[Int(x)]
        let yValue = highlight.y
        valueLabel.text = "\(xValue) - \(yValue)"
        self.addSubview(valueLabel)
        valueLabel.anchor(top: self.topAnchor, left: self.leftAnchor, topPadding: 8, leftPadding: 8)
        print(yValue)
    }
    func hideValueLabel() {
        valueLabel.removeFromSuperview()
    }
}
//MARK: - IAxisValueFormatter
extension StockChartView: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return self.xAxisLabels[Int(value)]
    }
}
//MARK: - Chart set up
extension StockChartView {
    func configureChart(with mode: StockChartMode){
        noDataText = "N/A"
        noDataTextColor = .white
        legend.enabled = false
        self.doubleTapToZoomEnabled = false
        
        if mode == .simple {
            xAxis.enabled = false
            leftAxis.enabled = false
            rightAxis.enabled = false
            return
        }else{
            xAxis.avoidFirstLastClippingEnabled = true
            xAxis.labelTextColor = .white
            xAxis.labelPosition = .bottom
            xAxis.gridColor = .lightGray
            xAxis.gridLineWidth = 0.3
            xAxis.axisLineColor = .darkGray
            xAxis.axisLineWidth = 0.1
            xAxis.valueFormatter = axisFormatDelegate
            xAxis.setLabelCount(5, force: true)
            
            rightAxis.labelTextColor = .white
            rightAxis.labelPosition = .outsideChart
            rightAxis.axisLineColor = .lightGray
            rightAxis.axisLineWidth = 0.1
            
            leftAxis.drawAxisLineEnabled = false
            leftAxis.drawLabelsEnabled = false
        }
    }
}
