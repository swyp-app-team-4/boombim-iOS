//
//  FcmService.swift
//  BoomBim
//
//  Created by 조영현 on 8/21/25.
//

import Foundation
import RxSwift
import Alamofire

final class FcmService {
  static let shared = FcmService()
    init() {}
    
    func registerFcmToken(userToken: String, token: String) -> Observable<Result<FcmTokenResponse, Error>> {
        return Observable.create { observer in
            let url = NetworkDefine.apiHost + NetworkDefine.Fcm.token
            
            var headers:HTTPHeaders = ["Content-Type": "application/json"]
            headers["Accept"] = "application/json"
            
            headers["Authorization"] = "Bearer \(userToken)"
            
            let params: [String: Any] = [
                "token": token,
                "deviceType": "IOS"
            ]
            
            print("params: \(params)")
            
            CommonRequest.shared.request(
                url: url,
                method: .post,
                parameters: params,
                headers: headers,
                encoding: JSONEncoding.default,
                responseType: FcmTokenResponse.self
            ) { result in
                
                debugPrint(result)
                
                switch result {
                    case .success(let token):
                        observer.onNext(.success(token))
                        
                    case .failure(let error):
                        observer.onError(error)
                    }

                    observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func fetchAlarm(userToken: String) -> Observable<Result<AlarmItem, Error>> {
        return Observable.create { observer in
            let url = NetworkDefine.apiHost + NetworkDefine.Fcm.alarm
            
            var headers:HTTPHeaders = ["Content-Type": "application/json"]
            headers["Accept"] = "application/json"
            
            headers["Authorization"] = "Bearer \(userToken)"
            
            
            CommonRequest.shared.request(
                url: url,
                method: .get,
                headers: headers,
                encoding: JSONEncoding.default,
                responseType: AlarmItem.self
            ) { result in
                
                debugPrint(result)
                
                switch result {
                    case .success(let alarm):
                        observer.onNext(.success(alarm))
                        
                    case .failure(let error):
                        observer.onError(error)
                    }

                    observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
