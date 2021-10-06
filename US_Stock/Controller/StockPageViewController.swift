//
//  StockPageViewController.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/24.
//

import UIKit
import Combine
import CoreData
import MBProgressHUD

class StockPageViewController: UIViewController {
    //MARK: - Preperties
    var stock : Stock
    var tickerStocks = [Stock]() { didSet { self.tickerView.stocks = self.tickerStocks }}
    var recentInfos = [StockInfo]()
    var historicalInfos = [StockInfo]()
    
    var viewModels = [StockPageViewModel]()
    @Published var displayInfos: [StockInfo]?
    private var subscriber = Set<AnyCancellable>()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private lazy var tickerView : TickerDisplayCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = TickerDisplayCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        return cv
    }()
    private let containerView = StockPageView()
    
    let maximumHeight = UIScreen.main.bounds.height - 64
    let pageMinY  : CGFloat = 96
    //MARK: - Lifecycle
    init(stock: Stock) {
        self.stock = stock
        super.init(nibName: nil, bundle: nil)
        self.preloadIntraTimeSeries()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTickerView()
        configureContainerView()
        setUpPanGesture()
        observeDisplayTime()
        observeAddedState()
        observeDismissButton()
    }
}
//MARK: - API Service
extension StockPageViewController {
    func preloadDailyTimeSeries(completion: @escaping([StockInfo]) -> Void) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.containerView.hideChartView()
        self.fetchDailyTimeSeries(symbol: self.stock.symbol) { daily in
            self.historicalInfos = daily.getStockInfo()
            MBProgressHUD.hide(for: self.view, animated: true)
            self.containerView.showChartView()
            completion(daily.getStockInfo())
        }
    }
    func preloadIntraTimeSeries() {
        self.containerView.configureTitle(with: self.stock)
        if self.stock.intraInfo.isEmpty {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            fetchIntraTimeSeries(symbol: self.stock.symbol) { intra in
                let intraInfos = intra.getStockInfo()
                self.stock.intraInfo = intraInfos
                let viewModel = StockPageViewModel(dailyInfos: intraInfos, displayTime: .oneDay)
                self.containerView.inputChartData(with: viewModel)
                self.containerView.configureValueText(with: viewModel)
                self.containerView.configureOhlcSection(with: viewModel)
                self.updateSavedStock(stock: self.stock)
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }else{
            let viewModel = StockPageViewModel(dailyInfos: self.stock.intraInfo, displayTime: .oneDay)
            self.containerView.inputChartData(with: viewModel)
            self.containerView.configureValueText(with: viewModel)
            self.containerView.configureOhlcSection(with: viewModel)
        }
        
    }
    func fetchDailyTimeSeries(symbol: String, completion: ((Daily)->Void)? = nil ) {
        AlphaAPIService.shared
            .fetchDailyTimeSeriesPublisher(symbol: symbol)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("\(error.localizedDescription)")
                }
            } receiveValue: { daily in
                if let completion = completion{
                    completion(daily)
                }
            }.store(in: &subscriber )
    }
    func fetchIntraTimeSeries(symbol: String, completion: ((IntraDay)->Void)? = nil ) {
        AlphaAPIService.shared.fetchIntraTimeSeriesPublihser(symbol: symbol)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("\(error.localizedDescription)")
                }
            } receiveValue: { [weak self] intra in
                self?.stock.intraInfo = intra.getStockInfo()
                if let completion = completion {
                    completion(intra)
                }
            }.store(in: &subscriber)
    }
    
    func saveStockInEntity(stock: Stock) {
        let service = CoreDataService(context: self.context)
        service.saveToWatchList(stock: stock)
    }
    
    func updateSavedStock(stock: Stock) {
        let service = CoreDataService(context: self.context)
        service.updateSavedStockInEntity(stock: stock)
    }
}
//MARK: -  Observer
extension StockPageViewController {
    func observeDisplayTime() {
        self.containerView.$displayTimeInterval
            .sink { [weak self] chartTimeInterval in
                guard let self = self else { return }
                let rawValue = chartTimeInterval.rawValue
                if rawValue == 0 {
                    self.displayInfos = self.stock.intraInfo
                }else {
                    if self.historicalInfos.isEmpty {
                        self.preloadDailyTimeSeries() { infos in
                            self.displayInfos = infos
                        }
                    }else { self.displayInfos = self.historicalInfos }
                }
                guard let infos = self.displayInfos else { return }
                let viewModel = StockPageViewModel(dailyInfos: infos, displayTime: chartTimeInterval)
                self.containerView.inputChartData(with: viewModel)
            }.store(in: &subscriber)
    }
    func observeAddedState(){
        self.containerView.addListButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let stock = self?.stock else { return }
                self?.saveStockInEntity(stock: stock)
                self?.animateOut()
            }.store(in: &subscriber)
    }
    func observeDismissButton() {
        self.containerView.dismissButton
            .publisher(for: .touchUpInside)
            .sink {[weak self] _ in
                self?.animateOut()
            }.store(in: &subscriber)
    }
}
//MARK: - Auto layout
extension StockPageViewController {
    func configureTickerView(){
        view.addSubview(tickerView)
        tickerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        tickerView.setDimension(height: pageMinY)
    }
    func configureContainerView(){
        view.addSubview(containerView)
        containerView.anchor(top: tickerView.bottomAnchor, left: view.leftAnchor,
                             right: view.rightAnchor, bottom: view.bottomAnchor,
                             bottomPadding: -16)

    }
}

//MARK: - Animation & Pan gesture
extension StockPageViewController {
    func animateIn(){
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    func animateOut(){
        self.view.transform = .identity
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpPanGesture(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        self.containerView.addGestureRecognizer(panGesture)
        self.containerView.isUserInteractionEnabled = true
    }
    
    @objc
    func handlePanGesture(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: self.view)
        let y = self.view.frame.minY
        let newHeight = y + translation.y

        switch gesture.state {
        case .changed:
            UIView.animate(withDuration: 0.3) {
                self.tickerView.alpha  = 0
            }
            self.view.frame = CGRect(x: 0, y: newHeight, width: view.frame.width, height: view.frame.height)
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            
        case .ended:
            if newHeight > UIScreen.main.bounds.height/3 {
                animateOut()
            }else{
                UIView.animate(withDuration: 0.5) {
                    self.tickerView.alpha = 1
                }
                animateIn()
            }
        default:
            break
        }
    }
}
