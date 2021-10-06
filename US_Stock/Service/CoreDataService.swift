//
//  CoreDataService.swift
//  US_Stock
//
//  Created by 陳翰霖 on 2021/8/26.
//

import Foundation
import CoreData

struct CoreDataService {
    let context: NSManagedObjectContext
    
    func saveToWatchList(stock: Stock){
        let stockEntity = NSEntityDescription.entity(forEntityName: "SavedStock", in: context)
        var stockObject = NSManagedObject(entity: stockEntity!, insertInto: context) as! SavedStock
        stockObject.name = stock.name
        stockObject.symbol = stock.symbol
        stockObject.type = stock.type
        if !stock.intraInfo.isEmpty {
            print("DEBUG: Save time series ... ")
            stockObject = stockAddToTimeSeries(stock:  stockObject, ohlc: stock.intraInfo)
        }
        do {
            try context.save()
        }catch{
            fatalError(error.localizedDescription)
        }
    }

    func fetchStock(symbol: String, completion: @escaping(SavedStock) -> Void){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedStock")
        let predicate = NSPredicate(format: "symbol == %@", symbol)
        request.predicate = predicate
        do{
            let results = try context.fetch(request) as! [SavedStock]
            if !results.isEmpty {
                let savedStock = results[0]
                completion(savedStock)
            }
        }catch{
            print("Core: Failed to update data in SavedStock")
        }
    }
    func fetchIntraSeries(belongTo stock: SavedStock, completion: @escaping(IntraSeries) -> Void){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "IntraSeries")
        let predicate = NSPredicate(format: "belongStock.symbol == %@", stock.symbol ?? "")
        request.predicate = predicate
        do{
            let results = try context.fetch(request) as! [IntraSeries]
            if !results.isEmpty {
                let intraSeries = results[0]
                completion(intraSeries)
            }
        }catch{
            print("Core: Failed to update data in SavedStock")
        }
    }
    func deleteStock(stock: Stock) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "SavedStock")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "symbol == %@", stock.symbol)
        do{
            let result = try context.fetch(request)
            for object in result {
                guard let object = object as? SavedStock else { return }
                self.deleteIntraSeries(belongTo: object)
                context.delete(object)
                try context.save()
            }
        }catch{
            print("Debug: Failed to delete stock \(error.localizedDescription)")
        }
    }
    func deleteIntraSeries(belongTo stock: SavedStock) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "IntraSeries")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "belongStock.symbol == %@", stock.symbol ?? "")
        do{
            let result = try context.fetch(request)
            for object in result {
                context.delete(object)
                try context.save()
            }
        }catch{
            print("Debug: Failed to delete stock \(error.localizedDescription)")
        }
    }
    func fetchSavedStocks(completion: @escaping([Stock])->Void){
        var stocks = [Stock]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedStock")
        do {
            let object = try context.fetch(request) as! [SavedStock]
            for stock in object {
                guard let name = stock.name,
                      let symbol = stock.symbol,
                      let type = stock.type,
                      let timeSeriesNSSet = stock.timeSeries else { return }
                var stock = Stock(name: name, symbol: symbol, type: type, isAdded: true)
                let timeSeries =  timeSeriesNSSet.unzipNSSetToStockInfos()
                stock.intraInfo = timeSeries
                stock.lastRefreshDate = timeSeries.last?.date
                stocks.append(stock)
            }
            completion(stocks)
        }catch{
            print("DEBUG: Failed to fetch stock in entity. \(error.localizedDescription)")
        }
    }
    func checkIfDataShouldUpdate(lastDate: Date) -> Bool{
        let cal = Calendar.current
        let refreshDate = cal.date(byAdding: .day , value: 1, to: lastDate) ?? lastDate
        let now = Date()
        let shouldUpdate = now > refreshDate
        return shouldUpdate
    }
    func checkIfStockIsInStockEntity(symbol: String, name: String, completion: @escaping(Bool)->Void){
        let request = NSFetchRequest<NSManagedObject>(entityName: "SavedStock")
        request.returnsObjectsAsFaults = false
        let symbolPredicate = NSPredicate(format: "symbol == %@", symbol)
        let namePredicate = NSPredicate(format: "name == %@", name)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [symbolPredicate, namePredicate])
        request.predicate = compoundPredicate
        do{
            let object = try context.fetch(request)
            let isSelected = (object.count >= 1)
            completion(isSelected)
        }catch{
            print("Debug: Failed to read data in core data model ... \(error.localizedDescription)")
        }
    }
    
    func updateSavedStockInEntity(stock: Stock) {
        self.fetchStock(symbol: stock.symbol) { savedStock in
            self.deleteIntraSeries(belongTo: savedStock)
            let _ = self.stockAddToTimeSeries(stock: savedStock, ohlc: stock.intraInfo)
            do{
                try context.save()
            }catch{
                print("Core: Failed to update stock in entity ... ")
            }
        }
    }
    
    func clearEntity(_ context: NSManagedObjectContext, entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        }catch{
            print("Core: Failed to delete all ... ")
        }
    }
}
//MARK: - Data preprocess
extension CoreDataService {
    func stockAddToTimeSeries(stock: SavedStock, ohlc: [StockInfo]) -> SavedStock {
        let intraSeries = self.createIntraSeries(stock: stock, ohlc: ohlc)
        for intra in intraSeries {
            stock.addToTimeSeries(intra)
        }
        return stock
    }
    
    func createIntraSeries(stock: SavedStock, ohlc: [StockInfo]) -> [IntraSeries] {
        var intraSeries = [IntraSeries]()
        for stockInfo in ohlc {
            let ohlcObject = IntraSeries(context: context)
            ohlcObject.open = stockInfo.open
            ohlcObject.low = stockInfo.low
            ohlcObject.high = stockInfo.high
            ohlcObject.close = stockInfo.close
            ohlcObject.date = "\(stockInfo.date)"
            ohlcObject.volumn = stockInfo.volumn
            ohlcObject.belongStock = stock
            intraSeries.append(ohlcObject)
        }
        return intraSeries
    }

}
