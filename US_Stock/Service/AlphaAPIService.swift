
//  Created by 陳翰霖 on 2021/8/23.
//

import Foundation
import Combine

struct AlphaAPIService {
    enum APIServiceError: Error {
        case encoding
        case invalidResponse
        case badRequest
    }
    static let shared = AlphaAPIService()
    
    let API_KEYS = ["NUVA4XN9FXWQZ85M", "UAD52SAVHYQEY3AS", "NPXG3TJ9XUDYWX7U"]

    var API_KEY : String {
        return API_KEYS.randomElement() ?? ""
    }
    func createDataTaskPublisher<T: Decodable>(type: T.Type,url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap({ output in
//                print("API: response ", output.response)
//                print("API: Data", String(data: output.data, encoding: .utf8))
                guard let response = output.response as? HTTPURLResponse else { throw APIServiceError.invalidResponse }
                if response.statusCode >= 400 { throw APIServiceError.badRequest }
                return output.data
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .retry(3)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchSymbolPublisher(keyword: String) -> AnyPublisher<SearchResult, Error> {
        guard let keyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else
        { return Fail(error: APIServiceError.encoding).eraseToAnyPublisher() }
        let encondedURLString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keyword)&apikey=\(API_KEY)"
        guard let url = URL(string: encondedURLString) else{ return Fail(error: APIServiceError.encoding) .eraseToAnyPublisher()}
        return createDataTaskPublisher(type: SearchResult.self, url: url)
    }
    
    func fetchDailyTimeSeriesPublisher(symbol: String) -> AnyPublisher<Daily, Error> {
        guard let keyword = symbol.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else
        { return Fail(error: APIServiceError.encoding).eraseToAnyPublisher() }
        var encondedURLString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&outputsize=full&symbol=\(keyword)&apikey=\(API_KEY)"
        guard let url = URL(string: encondedURLString) else{return Fail(error: APIServiceError.badRequest).eraseToAnyPublisher()}
        return createDataTaskPublisher(type: Daily.self, url: url)
    }
    
    func fetchIntraTimeSeriesPublihser(symbol: String) -> AnyPublisher<IntraDay, Error> {
        guard let keyword = symbol.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else
        { return Fail(error: APIServiceError.encoding).eraseToAnyPublisher() }
        let encondedURLString = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(keyword)&outputsize=full&interval=5min&apikey=\(API_KEY)"
        guard let url = URL(string: encondedURLString) else{
            return Fail(error: APIServiceError.encoding).eraseToAnyPublisher() }
        return createDataTaskPublisher(type: IntraDay.self, url: url)
    }
}
