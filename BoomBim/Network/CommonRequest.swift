//
//  CommonRequest.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import Foundation
import Alamofire

final class CommonRequest {
    static let shared = CommonRequest()

    private init() {}

//    func request<T: Decodable>(
//        url: String,
//        method: HTTPMethod = .get,
//        parameters: [String: Any]? = nil,
//        headers: HTTPHeaders? = nil,
//        encoding: ParameterEncoding = JSONEncoding.default,
//        responseType: T.Type,
//        completion: @escaping (Result<T, Error>) -> Void
//    ) {
//        guard let reachability = NetworkReachabilityManager(), reachability.isReachable else {
//            completion(.failure(NetworkError.disconnected))
//            return
//        }
//
//        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
//            .validate()
//            .responseDecodable(of: T.self) { response in
//                debugPrint(response)
//
//                switch response.result {
//                case .success(let data):
//                    completion(.success(data))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            }
//    }
    
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let reachability = NetworkReachabilityManager(), reachability.isReachable else {
            completion(.failure(NetworkError.disconnected))
            return
        }

        AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .validate(statusCode: 200..<600) // 모든 상태코드 수신
            .responseData { response in
                debugPrint(response)

                switch response.result {
                case .success(let data):
                    let statusCode = response.response?.statusCode ?? 500
                    if 200..<300 ~= statusCode {
                        do {
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            completion(.success(decoded))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        do {
                            let serverError = try JSONDecoder().decode(ServerErrorResponse.self, from: data)
                            let error = NSError(domain: "Server", code: serverError.code ?? -1, userInfo: [
                                NSLocalizedDescriptionKey: serverError.message ?? "알 수 없는 서버 오류"
                            ])
                            completion(.failure(error))
                        } catch {
                            // 서버 에러 응답 디코딩도 실패하면 일반 에러로 처리
                            completion(.failure(error))
                        }
                    }

                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

}
