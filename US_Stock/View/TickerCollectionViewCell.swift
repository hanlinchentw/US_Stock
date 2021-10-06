//
//  TickerCollectionViewCell.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/31.
//

import UIKit

class TickerCollectionViewCell: UICollectionViewCell {
    //MARK: - properties
    let symbolTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    let priceLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    let priceSubLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    let chartView = StockChartView(mode: .simple)
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .black
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - Configure View
extension TickerCollectionViewCell {
    func configure(){
        let stack = UIStackView(arrangedSubviews: [symbolTextLabel, priceLabel, priceSubLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = -2
        stack.alignment = .leading
        let horizontalStack = UIStackView(arrangedSubviews: [stack, chartView])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 4
        addSubview(horizontalStack)
        horizontalStack.anchor(top: self.topAnchor, left: self.leftAnchor,
                               right: self.rightAnchor, bottom: self.bottomAnchor,
                               topPadding: 16, leftPadding: 16,
                               rightPadding: 16, bottomPadding: 20)
    }
}

//MARK: - Chart data injection
extension TickerCollectionViewCell{
    func configureTickerCell(stock:Stock){
        self.symbolTextLabel.text = stock.symbol
        let viewModel = StockPageViewModel(dailyInfos: stock.intraInfo,
                                           stock: nil,
                                           displayTime: ChartDisplayTimeInterval.oneDay)
        self.priceLabel.text = "\(viewModel.currentPrice)"
        self.priceSubLabel.text = viewModel.risingPercenttage
        if let isRising = viewModel.isRising{
            self.priceSubLabel.textColor = isRising ? UIColor.systemRed : UIColor.systemGreen
        }
        chartView.updateChartData(with: viewModel)
    }
}
