//
//  StockOhlcCollectionViewCell.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/10/3.
//

import UIKit

class StockOhlcCollectionViewCell : UICollectionViewCell {
    //MARK: - Properties
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "Open"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private let valueLabel : UILabel = {
        let label = UILabel()
        label.text = "145.0"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    var isWidthCaluculated : Bool = false
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//MARK: -
extension StockOhlcCollectionViewCell {
    func configureTitleAndValue(with title: String, value: String) {
        self.titleLabel.text = title
        self.valueLabel.text = value
    }
}
//MARK: - Auto layout
extension StockOhlcCollectionViewCell {
    func configure() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.spacing = 8
        stack.axis = .horizontal
        self.addSubview(stack)
        stack.anchor(left: leftAnchor, right: rightAnchor, leftPadding: 16, rightPadding: 8)
        stack.centerY(inView: self)
    }  
}
