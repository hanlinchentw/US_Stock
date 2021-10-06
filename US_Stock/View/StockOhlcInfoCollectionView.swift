//
//  StockOhlcInfoCollectionView.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/10/3.
//

import UIKit

private let ohlcIdentifier = "StockOhlcInfoCell"

class StockOhlcInfoCollectionView: UICollectionView {
    //MARK: - Properties
    private let titleStrings = ["Open", "High", "Low", "Volumn"]
    var ohlcDictionary = [String : String]() { didSet{ self.reloadData() }}
    //MARK: - Lifecycle
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .clear
        setupCollectionView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: - collection view set up
extension StockOhlcInfoCollectionView {
    func setupCollectionView(){
        self.register(StockOhlcCollectionViewCell.self, forCellWithReuseIdentifier: ohlcIdentifier)
        self.delegate = self
        self.dataSource = self
    }
}
//MARK: - Collectionview delegate/datasource
extension StockOhlcInfoCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ohlcDictionary.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ohlcIdentifier, for: indexPath)
            as! StockOhlcCollectionViewCell
        let key = self.titleStrings[indexPath.row]
        guard let value = ohlcDictionary[key] else { return cell}
        cell.configureTitleAndValue(with: key, value: value)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 24)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
