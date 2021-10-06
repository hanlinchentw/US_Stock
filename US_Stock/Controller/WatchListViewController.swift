//
//  WatchListViewController.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/23.
//

import UIKit
import Combine
import CoreData

private let stockCellIdentifier = "StockCell"

class WatchListViewController: UITableViewController {
    //MARK: - Properties
    var stocks = [Stock]()
    private lazy var searchVC : UISearchController = {
        let sc = UISearchController(searchResultsController: resultVC)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = true
        sc.hidesNavigationBarDuringPresentation = true
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        sc.searchBar.sizeToFit()
        return sc
    }()
    private lazy var resultVC = SearchResultTableViewController()
    
    private lazy var blackView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return view
    }()
    
    @Published private var searchQuery = String()
    
    private var subscribers = Set<AnyCancellable>()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)[0])
        fetchSavedStock()
        configureNavBar()
        configureTableView()
        observeSearchQuery()
        observeEntityChange()
    }
    @objc
    func handleEditButtonTapped(){
        print("Editing... \(!tableView.isEditing)")
        self.tableView.setEditing(!tableView.isEditing, animated: true)
    }
}
//MARK: - API
extension WatchListViewController {
    func fetchSavedStock(){
        let service = CoreDataService(context: context)
        service.fetchSavedStocks { [weak self] stocks in
            self?.stocks = stocks
            for (index, stock) in stocks.enumerated() {
                if stock.intraInfo.isEmpty ||
                    service.checkIfDataShouldUpdate(lastDate: stock.lastRefreshDate ?? Date() )  {
                    print("Watch: Fetching \(stock.symbol) Intra...")
                    self?.fetchIntraInfo(symbol: stock.symbol, completion: { (intra, error) in
                        if let intra = intra{
                            self?.stocks[index].intraInfo = intra.getStockInfo()
                            DispatchQueue.main.async { self?.tableView.reloadData() }
                            if let stock = self?.stocks[index] {
                                self?.updateSavedStock(stock: stock)
                            }
                        }
                    })
                }
                DispatchQueue.main.async { self?.tableView.reloadData() }
            }
        }
    }
    func fetchIntraInfo(symbol: String, completion: @escaping(IntraDay?, Error?) -> Void){
        AlphaAPIService.shared
            .fetchIntraTimeSeriesPublihser(symbol: symbol)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("DEBUG: Failed to decode data ... \(error)")
                }
            } receiveValue: { intra in
                completion(intra, nil)
            }.store(in: &subscribers)
    }
    private func performSearch(query: String) {
        AlphaAPIService.shared.fetchSymbolPublisher(keyword: query)
            .sink { completion in
                switch completion{
                case .failure(let error): print("Failed to fetch symbol publisher .. \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] results in
                self?.resultVC.searchResults = results
            }.store(in: &subscribers)
    }
    
    func updateSavedStock(stock: Stock) {
        let service = CoreDataService(context: self.context)
        service.updateSavedStockInEntity(stock: stock)
    }
}
//MARK: - Observe
extension WatchListViewController {
    func observeEntityChange(){
        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { notification in
                if let objects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
                    for object in objects {
                        guard let object = object as? SavedStock,
                              let name = object.name ,
                              let symbol = object.symbol,
                              let type = object.type,
                              let timeSeries = object.timeSeries else { continue }
                        var stock = Stock(name: name, symbol: symbol, type: type)
                        let stockInfo = timeSeries.unzipNSSetToStockInfos()
                        stock.intraInfo = stockInfo
                        stock.isAdded = true
                        print(stock)
                        self.stocks.append(stock)
                        DispatchQueue.main.async { self.tableView.reloadData() }
                    }
                }else if let object = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
                    print(object)
                }
            }.store(in: &subscribers)
    }
    private func observeSearchQuery(){
        self.$searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard !query.isEmpty else { return }
                self?.performSearch(query: query)
            }.store(in: &subscribers)
    }
}
//MARK: - Set up view
extension WatchListViewController {
    func configureNavBar(){
        navigationItem.searchController = searchVC
        navigationItem.titleView = setTitleView()
        let editBarItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEditButtonTapped))
        navigationItem.rightBarButtonItem = editBarItem
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
    }
    func configureTableView(){
        self.tableView.register(StockTableViewCell.self, forCellReuseIdentifier: stockCellIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.rowHeight = 70
        self.tableView.allowsSelection = true
        self.tableView.backgroundColor = .black
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(white: 1, alpha: 0.3)
    }
}
//MARK: - UISearchControllerDelegate, UISearchResultsUpdating
extension WatchListViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else { return }
        self.searchQuery = query
    }
    func willPresentSearchController(_ searchController: UISearchController) {
        navigationController?.navigationBar.isTranslucent = true
        blackView.frame = UIScreen.main.bounds
        self.view.addSubview(blackView)
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationController?.navigationBar.isTranslucent = false
        self.blackView.removeFromSuperview()
    }
}
//MARK: -TableViewDelegate / DataSource
extension WatchListViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: stockCellIdentifier, for: indexPath) as! StockTableViewCell
        let stock = self.stocks[indexPath.row]
        cell.configureTitle(with: stock)
        let viewModel = StockPageViewModel(dailyInfos: stock.intraInfo, stock: nil, displayTime: ChartDisplayTimeInterval.oneDay)
        cell.injectChartData(with: viewModel)
        cell.configureCurrentValue(with: viewModel)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = self.stocks[indexPath.row]
        let page = StockPageViewController(stock: stock)
        page.tickerStocks = self.stocks
        page.stock.isAdded = true
        page.modalPresentationStyle = .overFullScreen
        self.present(page, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("Deleting")
        if editingStyle == .delete {
            let service = CoreDataService(context: self.context)
            service.deleteStock(stock: self.stocks[indexPath.row])
            self.stocks.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

}
