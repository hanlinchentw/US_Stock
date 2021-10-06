//
//  TickerDispalyCollecionView.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/31.
//

import UIKit

private let tickerIdentifier = "TickerViewCell"

class TickerDisplayCollectionView: UICollectionView {
    //MARK: - Properties
    var stocks = [Stock]() { didSet{ self.reloadData() }}
    //MARK: - Lifecycle
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setUpCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - View set up
extension TickerDisplayCollectionView {
    func setUpCollectionView(){
        self.register(TickerCollectionViewCell.self, forCellWithReuseIdentifier: tickerIdentifier)
        self.delegate = self
        self.dataSource = self
        self.showsHorizontalScrollIndicator = false
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            if let topPadding = window?.safeAreaInsets.top {
                self.contentInset = UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0)
            }
        }
    }
}
//MARK: - Collectionview delegate/datasource
extension TickerDisplayCollectionView:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stocks.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tickerIdentifier, for: indexPath)
            as! TickerCollectionViewCell
        let stock = self.stocks[indexPath.row]
        cell.configureTickerCell(stock: stock)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 96)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
