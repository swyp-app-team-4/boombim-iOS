//
//  KakaoLocalService.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import Alamofire
import RxSwift
import CoreLocation

// Kakao Local 응답 DTO
struct KakaoKeywordResponse: Decodable {
    let documents: [KakaoPlace]
    let meta: KakaoMeta
}

struct KakaoPlace: Decodable {
    let id: String
    let place_name: String
    let address_name: String
    let road_address_name: String
    let x: String // longitude
    let y: String // latitude
}

struct KakaoMeta: Decodable {
    let total_count: Int
    let pageable_count: Int
    let is_end: Bool
}

final class KakaoLocalService {
    private let restApiKey: String
    
    init() {
        if let kakaoNativeAppKey = Bundle.main.object(forInfoDictionaryKey: "KakaoRestApiKey") as? String {
            print("kakao REST API key 설정 완료")
            self.restApiKey = kakaoNativeAppKey
        } else {
            print("kakao native app key missing")
            self.restApiKey = ""
        }
    }
    
    // 사용자의 위치 x,y 좌표로 카테고리 검사를 진행해서 반경 100m에 포함된 목록 중 가장 가까운 것을 표시

    // MARK: TEST Code 스타벅스 + 카페(CE7)만, rect로 검색
    func searchStarbucks(in rect: ViewportRect, size: Int = 15) -> Single<[Place]> {
        let url = "https://dapi.kakao.com/v2/local/search/keyword.json"
        let headers: HTTPHeaders = ["Authorization": "KakaoAK \(restApiKey)"]

        // rect는 "left,bottom,right,top"
        let rectParam = "\(rect.left),\(rect.bottom),\(rect.right),\(rect.top)"
        
        print("rect : \(rect.x), \(rect.y), \(rect.bottom),\(rect.left),\(rect.right),\(rect.top)")

        let params: Parameters = [
            "query": "스타벅스",
            "category_group_code": "CE7", // 카페
            "x": rect.x,
            "y": rect.y,
            "rect": rectParam,
            "page": 1,
            "size": size,                 // 1~45
            "sort": "distance"            // 거리순(뷰포트 내)
        ]

        return Single.create { single in
            let req = AF.request(url, method: .get, parameters: params, headers: headers)
                .validate()
                .responseDecodable(of: KakaoKeywordResponse.self) { res in
                    
                    debugPrint(res)
                    
                    switch res.result {
                    case .success(let dto):
                        let places: [Place] = dto.documents.map {
                            Place(id: $0.id,
                                  name: $0.place_name,
                                  coord: CLLocationCoordinate2D(latitude: Double($0.y) ?? 0,
                                                                longitude: Double($0.x) ?? 0),
                                  address: $0.road_address_name.isEmpty ? $0.address_name : $0.road_address_name)
                        }
                        single(.success(places))
                    case .failure(let err):
                        single(.failure(err))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
}
