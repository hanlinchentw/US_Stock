//
//  SearchResultTableViewCell.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/26.
//

import UIKit

final class SearchResultTableViewCell: StockTableViewCell{
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpTitle()
        setUpPrice()
        overrideProperties()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Override Properties
extension SearchResultTableViewCell {
    func overrideProperties(){
        self.priceSubLabel.backgroundColor = .black
        self.priceSubLabel.font = UIFont.systemFont(ofSize: 14)
        self.priceSubLabel.textColor = UIColor.red
        
        self.typeLabel.font = UIFont.systemFont(ofSize: 16)
        self.typeLabel.textColor = .white
    }
    
    override func setUpTitle() {
        let titleStack = UIStackView(arrangedSubviews: [symbolTextLabel, nameTextLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 8
        titleStack.alignment = .leading
        
        addSubview(titleStack)
        
        titleStack.centerY(inView: self)
        titleStack.anchor(left: self.leftAnchor, right: self.centerXAnchor ,leftPadding: 20)
        
        addSubview(typeLabel)
        typeLabel.centerY(inView: self)
        typeLabel.anchor(left: titleStack.rightAnchor, rightPadding: 24)
    }
}
