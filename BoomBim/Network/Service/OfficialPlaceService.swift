//
//  OfficialPlaceService.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import Alamofire
import RxSwift
import CoreLocation

protocol OfficialPlaceServiceType {
    func fetchOfficialPlace(topLeft: CLLocationCoordinate2D,
                            bottomRight: CLLocationCoordinate2D,
                            member: CLLocationCoordinate2D) -> Single<OfficialPlace>
}

final class OfficialPlaceService: OfficialPlaceServiceType {
    private let session: Session

    init(session: Session = .default) { self.session = session }

    func fetchOfficialPlace(topLeft: CLLocationCoordinate2D,
                            bottomRight: CLLocationCoordinate2D,
                            member: CLLocationCoordinate2D) -> Single<OfficialPlace> {

        let body = OfficialPlacesRequest(
            topLeft: .init(latitude: topLeft.latitude, longitude: topLeft.longitude),
            bottomRight: .init(latitude: bottomRight.latitude, longitude: bottomRight.longitude),
            memberCoordinate: .init(latitude: member.latitude, longitude: member.longitude)
        )

        let url = NetworkDefine.apiHost + NetworkDefine.Place.officialPlace

        var headers: HTTPHeaders = ["Content-Type": "application/json"]
        headers["Accept"] = "application/json"
        if let token = TokenManager.shared.currentAccessToken(), token.isEmpty == false {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }

        return Single.create { single in
            let req = self.session.request(url,
                                           method: .post,
                                           parameters: body,
                                           encoder: JSONParameterEncoder.default,
                                           headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: APIResponse<OfficialPlaceDTO>.self) { res in
                    debugPrint(res)
                    switch res.result {
                    case .success(let api):
                        do {
                            let place = try api.data.toDomain()
                            single(.success(place))
                        } catch {
                            single(.failure(error))
                        }
                    case .failure(let error):
                        single(.failure(error))
                    }
                }

            return Disposables.create { req.cancel() }
        }
    }
}
