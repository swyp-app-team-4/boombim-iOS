//
//  Service.swift
//  BoomBim
//
//  Created by 조영현 on 8/29/25.
//

import RxSwift
import RxCocoa
import Alamofire
import Foundation

class Service {
    func request<T: Decodable, B: Encodable>(_ url: String, method: HTTPMethod, header: HTTPHeaders, body: B) -> Single<T> {
        
        return Single.create { single in
            let req = AF.request(url, method: method, parameters: body, encoder: JSONParameterEncoder.default, headers: header)
                .validate()
                .responseDecodable(of: T.self) { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let value): single(.success(value))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    // 서버가 바디 없는 2xx만 주는 엔드포인트용
    func requestVoid<B: Encodable>(_ url: String, method: HTTPMethod, header: HTTPHeaders, body: B) -> Single<Void> {
        return Single.create { single in
            let req = AF.request(url,
                                 method: method,
                                 parameters: body,
                                 encoder: JSONParameterEncoder.default,
                                 headers: header)
                .validate()
                .response { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success: single(.success(()))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    func requestMultipartFormData<T: Decodable>(_ url: String, data: Data, fileName: String, method: HTTPMethod, header: HTTPHeaders) -> Single<T> {
        return Single.create { single in
            let req = AF.upload(
                multipartFormData: { form in
                    print("form : \(form)")
                    print("data : \(data)")
                    debugPrint(form)
                    return form.append(data, withName: "multipartFile", fileName: fileName, mimeType: "image/jpeg")},
                to: url,
                method: method,
                headers: header)
                .validate()
                .responseString { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let pathString):
                        single(.success(pathString as! T))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create { req.cancel() }
        }
    }
    
    func requestGet<T: Decodable>(_ url: String, method: HTTPMethod, header: HTTPHeaders) -> Single<T> {
        
        return Single.create { single in
            let req = AF.request(url, method: method, headers: header)
                .validate()
                .responseDecodable(of: T.self) { resp in
                    debugPrint(resp)
                    switch resp.result {
                    case .success(let value): single(.success(value))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
}
