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

struct KakaoCategoryResponse: Decodable {
    let documents: [KakaoPlace]
    let meta: KakaoMeta
}

struct KakaoPlace: Decodable {
    let id: String
    let place_name: String
    let address_name: String
    let road_address_name: String
    let distance: String
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
    
    // MARK: TEST Code 스타벅스 + 카페(CE7)만, rect로 검색
    func searchStarbucks(in rect: ViewportRect, size: Int = 15) -> Single<[Place]> {
        let url = NetworkDefine.apiKakao + NetworkDefine.Search.keyword
        let headers: HTTPHeaders = ["Authorization": "KakaoAK \(restApiKey)"]

        let rectParam = "\(rect.left),\(rect.bottom),\(rect.right),\(rect.top)"
        print("rect : \(rect.x), \(rect.y), \(rect.bottom), \(rect.left), \(rect.right), \(rect.top)")

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
                                  address: $0.road_address_name.isEmpty ? $0.address_name : $0.road_address_name,
                                  distance: Double($0.distance)
                            )
                        }
                        single(.success(places))
                    case .failure(let err):
                        single(.failure(err))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    // 1) 단일 코드용
    private func searchByCategory(code: String,
                                  x: Double, y: Double,
                                  radius: Int, size: Int) -> Single<[Place]> {
        
        let url = NetworkDefine.apiKakao + NetworkDefine.Search.category
        let headers: HTTPHeaders = ["Authorization": "KakaoAK \(restApiKey)"]
        let params: Parameters = [
            "category_group_code": code, // <-- 배열 금지! 단일 문자열
            "x": "\(x)", "y": "\(y)",
            "radius": radius,
            "size": size,               // category 검색: 보통 최대 15 권장
            "sort": "distance"          // distance 정렬하려면 x,y 필수
        ]
        
        return Single.create { single in
            let req = AF.request(url, method: .get, parameters: params, headers: headers)
                .validate()
                .responseDecodable(of: KakaoCategoryResponse.self) { res in
                    
                    debugPrint(res)
                    
                    switch res.result {
                    case .success(let dto):
                        let places = dto.documents.map { d in
                            Place(
                                id: d.id,
                                name: d.place_name,
                                coord: .init(latitude: Double(d.y) ?? 0,
                                             longitude: Double(d.x) ?? 0),
                                address: d.road_address_name.isEmpty ? d.address_name : d.road_address_name,
                                distance: Double(d.distance)
                            )
                        }
                        single(.success(places))
                    case .failure(let err):
                        single(.failure(err))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
    
    // 2) 여러 코드 병렬 호출 → 합치기 → 거리순 상위 N
    func searchNearbyAcrossCategories(x: Double, y: Double,
                                      radius: Int = 100,
                                      limit: Int = 5,
                                      sizePerCategory: Int = 3,
                                      codes: [String] = ["MT1","CS2","PS3","SC4","AC5","PK6",
                                                         "OL7","SW8","BK9","CT1","AG2","PO3",
                                                         "AT4","AD5","FD6","CE7","HP8","PM9"]) -> Single<[Place]> {
        
        let calls = codes.map { code in
            searchByCategory(code: code, x: x, y: y, radius: radius, size: sizePerCategory)
                .catchAndReturn([]) // 일부 실패 무시
        }
        

        // 여러 Single<[Place]> → Single<[[Place]]>로 합치기
        Single.zip(calls)
            .map { nestedArray in
                // [[Place]] → [Place]로 평탄화
                nestedArray.flatMap { $0 }
            }
            .subscribe(onSuccess: { places in
                print("=== Places 결과 ===")
                places.forEach { print($0) } // Place가 CustomStringConvertible 구현되어 있으면 보기 좋게 출력됨
            })
        
        // 핵심: Observable.zip로 바꾼 뒤 마지막에 asSingle()
            let zipped: Observable<[[Place]]> = Observable.zip(calls.map { $0.asObservable() })

            return zipped
                .map { (arrays: [[Place]]) -> [Place] in arrays.flatMap { $0 } }   // 합치기
                .map { (places: [Place]) -> [Place] in                              // 거리 오름차순 정렬
                    places.sorted { ($0.distance ?? Double(Int.max)) < ($1.distance ?? Double(Int.max)) }
                }
                .map { (sorted: [Place]) -> [Place] in Array(sorted.prefix(limit)) } // 상위 N개
                .asSingle()
    }
}
