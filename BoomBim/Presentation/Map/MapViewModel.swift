//
//  MapViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import RxSwift
import RxCocoa

final class MapViewModel {
    struct Input {
        let cameraRect: Observable<ViewportRect>
        let zoomLevel: Observable<Int> // 옵션: 너무 먼 줌에서는 요청 안 함
    }
    struct Output {
        let places: Observable<[Place]>
    }

    private let service: KakaoLocalService
    init(service: KakaoLocalService) {
        self.service = service
    }

    func transform(input: Input) -> Output {
        let rectWhenZoomOK = Observable
            .combineLatest(input.cameraRect, input.zoomLevel.startWith(14))
            .filter { _, zoom in zoom >= 11 } // 줌 레벨 11 이상인 경우, 단 현재는 zoom Level 14로 고정
            .map { rect, _ in rect }
            .distinctUntilChanged { a, b in
                // 카메라 움직임 조절
                func round6(_ d: Double) -> Double { (d * 1e6).rounded() / 1e6 }
                return round6(a.left) == round6(b.left)
                    && round6(a.right) == round6(b.right)
                    && round6(a.top) == round6(b.top)
                    && round6(a.bottom) == round6(b.bottom)
            }
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)

        let places = rectWhenZoomOK
            .flatMapLatest { [service] rect in
                service.searchStarbucks(in: rect).asObservable()
                    .catchAndReturn([]) // 실패 시 조용히 빈값
            }
            .share(replay: 1, scope: .whileConnected)

        return Output(places: places)
    }
}
