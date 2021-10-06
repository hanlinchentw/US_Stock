//
//  SearchResultTableViewController.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/26.
//

import UIKit

private let resultCell = "SearchResultCell"

class SearchResultTableViewController : UITableViewController {
    //MARK: - Properties
    var searchResults : SearchResult? { didSet{ tableView.reloadData() }}
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    //MARK: - Core data
    func checkIfStockIsInEntity(stock: Stock, completion: @escaping(Bool)->Void) {
        let service = CoreDataService(context: self.context)
        service.checkIfStockIsInStockEntity(symbol: stock.symbol, name: stock.name) { isExisted in
            completion(isExisted)
        }
    }
}

//MARK: - View Set UP
extension SearchResultTableViewController {
    func setUpTableView(){
        tableView.backgroundColor = .black
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: resultCell)
        tableView.rowHeight = 70
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(white: 1, alpha: 0.3)
        
    }
}
//MARK: - UITableViewDelegate, UITableViewDatasource
extension SearchResultTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.bestMatches.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: resultCell, for: indexPath) as! SearchResultTableViewCell
        guard let result = searchResults?.bestMatches else { return cell}
        cell.configureTitle(with: result[indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let result = searchResults?.bestMatches else { return }
        var stock = result[indexPath.row]
        self.checkIfStockIsInEntity(stock: stock) { isExisted in
            stock.isAdded = isExisted
            let page = StockPageViewController(stock: stock)
            page.modalPresentationStyle = .overFullScreen
            self.present(page, animated: true, completion: nil)
        }
    }
}
