//
//  StockTableViewCell.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/24.
//

import UIKit
import Combine
import Charts
class StockTableViewCell: UITableViewCell {
    //MARK: - Properties
    let symbolTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    let nameTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    let typeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        return label
    }()
    let chartView = StockChartView(mode: .simple)

    let priceLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    let priceSubLabel: PaddingLabel = {
        let label = PaddingLabel(withInsets: 3, 3, 8, 3)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .black
        label.textAlignment = .right
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .black
        self.selectionStyle = .none
        setUpTitle()
        setUpPrice()
        setUpChartView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitle(with stock: Stock){
        self.nameTextLabel.text = stock.name
        self.symbolTextLabel.text = stock.symbol
        self.typeLabel.text = stock.type
    }
    func injectChartData(with viewModel: StockPageViewModel) {
        self.chartView.updateChartData(with: viewModel)
    }
    func configureCurrentValue(with viewModel : StockPageViewModel) {
        self.priceLabel.text = viewModel.currentPrice
        self.priceSubLabel.text = viewModel.risingPercenttage
        if let isRising = viewModel.isRising {
            self.priceSubLabel.backgroundColor = isRising ? UIColor.systemRed : UIColor.systemGreen
        }
    }

}
extension StockTableViewCell{
    @objc func setUpTitle() {
        let symbolAndTypeStack = UIStackView(arrangedSubviews: [symbolTextLabel, typeLabel])
        symbolAndTypeStack.axis = .horizontal
        symbolAndTypeStack.spacing = 8
        symbolAndTypeStack.alignment = .top
        
        contentView.addSubview(symbolAndTypeStack)
        
        symbolAndTypeStack.centerY(inView: contentView, yConstant: -8)
        symbolAndTypeStack.anchor(left: contentView.leftAnchor, leftPadding: 20)
        
        contentView.addSubview(nameTextLabel)
        nameTextLabel.anchor(top: symbolAndTypeStack.bottomAnchor, left: symbolAndTypeStack.leftAnchor,
                             right: contentView.centerXAnchor)
    }
    func setUpPrice(){
         let priceStack = UIStackView(arrangedSubviews: [priceLabel, priceSubLabel])
         priceStack.axis = .vertical
         priceStack.spacing = 4
         priceStack.alignment = .trailing
         
        contentView.addSubview(priceStack)
        priceStack.centerY(inView: contentView)
        priceStack.anchor(right: contentView.rightAnchor, rightPadding: 8)
    }
    func setUpChartView(){
        contentView.addSubview(chartView)
        chartView.centerY(inView: contentView)
        chartView.anchor(top: topAnchor,left: contentView.centerXAnchor,right: priceLabel.leftAnchor ,bottom: contentView.bottomAnchor,
                         topPadding: 4, leftPadding: 8, rightPadding: 20,  bottomPadding: 4)
    }
}

extension StockTableViewCell {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if animated, editing {
            self.priceLabel.alpha = 0
            self.priceSubLabel.alpha = 0
            self.chartView.alpha = 0
        }else{
            self.priceLabel.alpha = 1
            self.priceSubLabel.alpha = 1
            self.chartView.alpha = 1
        }
    }
}
