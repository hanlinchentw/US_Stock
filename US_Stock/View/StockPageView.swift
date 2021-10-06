//
//  StockPageView.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/25.
//

import UIKit
import Charts
import Combine

enum ChartDisplayTimeInterval: Int {
    case oneDay = 0
    case oneWeek
    case oneMonth
    case threeMonth
    case halfYear
    case oneYear
    case threeYear
    case fiveYear
    case tenYear
    case all
    
    var dateFormatter: String {
        switch self {
        case .oneWeek, .oneMonth: return "d"
        case .threeMonth, .halfYear , .oneYear: return "MMM/d"
        case .threeYear, .fiveYear, .tenYear, .all: return "yyyy"
        case .oneDay: return "h:mm a"
        }
    }
}
class StockPageView : UIView {
    //MARK: - Properties
    private lazy var symbolTextLabel: UILabel = {
        let label = UILabel()
        label.text = "AAPL"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var nameTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Apple Inc."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var titleStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [symbolTextLabel, nameTextLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .lastBaseline
        return stack
    }()
    lazy var dismissButton : UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btnCancelGreySmall")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDismissButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private let currentValueTextLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let gainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGreen
        return label
    }()
    private lazy var priceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [currentValueTextLabel, gainLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .lastBaseline
        return stack
    }()
    lazy var addListButton : UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 24/2
        button.tintColor = .white
        button.setTitle("Add to WatchList", for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleAddButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var timeSegmentControl : UISegmentedControl = {
        let items = ["1D", "1W" , "1M", "3M", "6M", "1Y", "3Y", "5Y", "10Y", "20Y"]
        let sc = UISegmentedControl(items: items)
        sc.backgroundColor = UIColor(white: 0.09, alpha: 1)
        sc.selectedSegmentTintColor = .white
        sc.selectedSegmentIndex = 0
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .selected)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        sc.addTarget(self, action: #selector(segmentIndexDidChange(_:)), for: .valueChanged)
        return sc
    }()
    
    private lazy var chartView = StockChartView(mode: .complete)
    
    private let ohlcCollectionView : StockOhlcInfoCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = StockOhlcInfoCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = true
        return cv
    }()
    @Published var displayTimeInterval = ChartDisplayTimeInterval.oneDay
    //MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        viewSetUp()
        configureTitleSection()
        configurePriceSection()
        configureSegmentControl()
        configureChartView()
        configureOhlcInfoView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: -  UI method
    func configureTitle(with stock: Stock){
        self.nameTextLabel.text = stock.name
        self.symbolTextLabel.text = stock.symbol
        if stock.isAdded { addListButton.isHidden = true }
    }
    func configureValueText(with viewModel: StockPageViewModel){
        self.currentValueTextLabel.text = viewModel.currentPrice
        self.gainLabel.text = viewModel.risingPercenttage
        if let isRising = viewModel.isRising {
            self.gainLabel.textColor = isRising ? .systemRed : .systemGreen
        }
    }
    
    func configureOhlcSection(with viewModel: StockPageViewModel) {
        let dict = ["Open" : "\(viewModel.openValue.round(to: 2))",
                    "High" : "\(viewModel.highestValue.round(to: 2))",
                    "Low" : "\(viewModel.lowestValue.round(to: 2))",
                    "Volumn" : viewModel.lastDayVolumn] as [String : String]
        self.ohlcCollectionView.ohlcDictionary = dict
    }
    func showChartView(){
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .transitionCrossDissolve) {
            self.chartView.alpha = 1
            
        }
    }
    func hideChartView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve) {
            self.chartView.alpha = 0
        }
    }
}
//MARK: - Chart data inject
extension StockPageView {
    func inputChartData(with viewModel : StockPageViewModel) {
        self.chartView.updateChartData(with: viewModel)
    }
}
//MARK: - Selector
extension StockPageView {
    @objc func handleAddButtonTapped(){
        self.addListButton.isHidden = true
    }
    @objc func handleDismissButtonTapped() {
        
    }
    @objc func segmentIndexDidChange(_ segmentControl: UISegmentedControl) {
        guard let newTimeInterval = ChartDisplayTimeInterval(rawValue: segmentControl.selectedSegmentIndex) else { return }
        displayTimeInterval = newTimeInterval
        print("Value did change \(displayTimeInterval)")
    }
}
//MARK: - Auto layout
extension StockPageView {
    func viewSetUp(){
        backgroundColor = UIColor(white: 0.09, alpha: 1)
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    func configureTitleSection() {
        addSubview(titleStack)
        titleStack.anchor(top: self.topAnchor, left: self.leftAnchor, topPadding: 20, leftPadding: 16)
        
        addSubview(dismissButton)
        dismissButton.anchor(top: self.topAnchor, right: self.rightAnchor, topPadding: 8, rightPadding: 8)
        
        let dividerView = UIView()
        dividerView.backgroundColor = .darkGray
        addSubview(dividerView)
        dividerView.anchor(top: titleStack.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor,
                           topPadding: 12, leftPadding: 16, rightPadding: 16)
        dividerView.setDimension(height: 0.75)
    }
    func configurePriceSection(){
        addSubview(priceStack)
        priceStack.anchor(top: titleStack.bottomAnchor, left: self.leftAnchor, topPadding: 32, leftPadding: 16)
        
        addSubview(addListButton)
        addListButton.anchor(right: self.rightAnchor, rightPadding: 16)
        addListButton.centerY(inView: priceStack)
        addListButton.setDimension(width: 125, height: 24)
    }
    func configureSegmentControl(){
        addSubview(timeSegmentControl)
        timeSegmentControl.anchor(top: priceStack.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor,
                         topPadding: 24)
    }
    func configureChartView(){
        addSubview(chartView)
        chartView.anchor(top: timeSegmentControl.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor,
                         topPadding: 12, leftPadding: 16, rightPadding: 16)
        chartView.setDimension(height: 275)
        chartView.addGesture()
        
        let dividerView = UIView()
        dividerView.backgroundColor = .darkGray
        self.addSubview(dividerView)
        dividerView.anchor(top: chartView.bottomAnchor,left: leftAnchor, right: rightAnchor, topPadding: 4)
        dividerView.setDimension(height: 0.75)
    }
    
    func configureOhlcInfoView() {
        addSubview(ohlcCollectionView)
        ohlcCollectionView.anchor(top: chartView.bottomAnchor, left: self.leftAnchor, topPadding: 24)
        ohlcCollectionView.setDimension(width: 130*2, height: 24*3)
    }
}
