//
//  NaverSearchService.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import Foundation
import Alamofire

final class NaverSearchService {
    static let shared = NaverSearchService()

    private let clientId: String
    private let clientSecret: String
    
    init() {
        if let clientIdValue = Bundle.main.object(forInfoDictionaryKey: "NidClientID") as? String,
           let clientSecretValue = Bundle.main.object(forInfoDictionaryKey: "NidClientSecret") as? String {
            self.clientId = clientIdValue
            self.clientSecret = clientSecretValue
        } else {
            print("cliendt id, secret missing")
            
            self.clientId = ""
            self.clientSecret = ""
        }
    }

    func search(query: String, completion: @escaping (Result<[SearchItem], Error>) -> Void) {
        let url = "https://openapi.naver.com/v1/search/local.json"
        let parameters: [String: String] = [
            "query": query,
            "display": "10",
            "start": "1",
            "sort": "random"
        ]

        let headers: HTTPHeaders = [
            "X-Naver-Client-Id": clientId,
            "X-Naver-Client-Secret": clientSecret
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   headers: headers)
        .validate()
        .responseDecodable(of: SearchResponse.self) { response in
            
            debugPrint(response)
            
            switch response.result {
            case .success(let data):
                completion(.success(data.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
