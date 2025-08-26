//
//  MapViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class MapViewModel {
    struct Input {
        let cameraRect: Observable<ViewportRect>
        let zoomLevel: Observable<Int>
    }
    struct Output {
        let places: Observable<[Place]>
        let officialPlace: Observable<OfficialPlace>
    }

    private(set) var currentCoordinate: CLLocationCoordinate2D?

    // ✅ 추가: 현재 위치 스트림(옵셔널 허용)
    private let memberCoordSubject = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)

    private let service: KakaoLocalService
    private let officialService: OfficialPlaceServiceType

    init(service: KakaoLocalService,
         officialService: OfficialPlaceServiceType) {
        self.service = service
        self.officialService = officialService
    }

    func setCurrentCoordinate(_ coord: CLLocationCoordinate2D) {
        currentCoordinate = coord
        memberCoordSubject.onNext(coord)   // ✅ 최신 위치를 스트림으로도 흘림
    }
    
    func transform(input: Input) -> Output {
           // 기존 로직 유지
           let rectWhenZoomOK = Observable
               .combineLatest(input.cameraRect, input.zoomLevel.startWith(14))
               .filter { _, zoom in zoom >= 11 }
               .map { rect, _ in rect }
               .distinctUntilChanged { a, b in
                   func round6(_ d: Double) -> Double { (d * 1e6).rounded() / 1e6 }
                   return round6(a.left) == round6(b.left)
                       && round6(a.right) == round6(b.right)
                       && round6(a.top) == round6(b.top)
                       && round6(a.bottom) == round6(b.bottom)
               }
               .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
               .share(replay: 1, scope: .whileConnected)

           // A) 카메라 이동이 트리거: 그 시점의 최신 위치를 묶음
           let rectWithMember_byCamera = rectWhenZoomOK
               .withLatestFrom(memberCoordSubject.startWith(currentCoordinate)) { rect, member in
                   (rect, member)  // (ViewportRect, CLLocationCoordinate2D?)
               }

           // 필요에 따라 A만 쓰거나, A+B를 merge해서 둘 다 트리거
           let trigger = Observable.merge(rectWithMember_byCamera)
               .share(replay: 1, scope: .whileConnected)

           // 기존 Kakao 검색 (member를 쓰고 싶으면 서명 확장)
           let places = rectWhenZoomOK
               .flatMapLatest { [service] rect in
                   service.searchStarbucks(in: rect).asObservable()
                       .catchAndReturn([])
               }
               .share(replay: 1, scope: .whileConnected)

           // ✅ 공식 장소 API: member가 없으면 뷰포트 중심을 대체값으로 사용
           let officialPlace = trigger
               .flatMapLatest { [officialService] (rect, memberOpt) in
                   let member = memberOpt ?? rect.centerCoord
                   return officialService.fetchOfficialPlace(
                       topLeft: rect.topLeftCoord,
                       bottomRight: rect.bottomRightCoord,
                       member: member
                   )
                   .asObservable()
                   .catch { _ in .empty() }
               }
               .share(replay: 1, scope: .whileConnected)

           return Output(places: places, officialPlace: officialPlace)
       }
   }
