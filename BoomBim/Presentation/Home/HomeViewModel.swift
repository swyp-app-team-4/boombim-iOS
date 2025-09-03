//
//  HomeViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {
    var goToCongestionReportView: (() -> Void)?
    var goToSearchView: (() -> Void)?
    var goToNotificationView: (() -> Void)?
    var goToPlaceView: ((FavoritePlaceItem) -> Void)?
    
    func didTapFloating() {
        goToCongestionReportView?()
    }
    
    func didTapSearch() {
        goToSearchView?()
    }
    
    func didTapNotification() {
        goToNotificationView?()
    }
    
    func didSelectPlace(_ place: FavoritePlaceItem) {
        goToPlaceView?(place)
    }
    private let disposeBag = DisposeBag()
    
    struct Input {
        let appear: Observable<Void>        // 최초 1회
//        let pullToRefresh: Signal<Void>     // 당겨서 새로고침
//        let retryTap: Signal<Void>          // 에러 후 재시도 버튼
    }
    
    struct Output {
        let regionNewsItems: Driver<[RegionItem]>
        let isLoading: Driver<Bool>
        let isRegionNewsEmpty: Driver<Bool>
        let isEmpty: Driver<Bool>
        let errorMessage: Signal<String>
    }
    
    func transform(_ input: Input) -> Output {
        // 1) 트리거: 첫 진입 1회 + 당겨서새로고침 + 재시도
        let trigger = Observable.merge(
            input.appear.take(1)//,
//            input.pullToRefresh.asObservable(),
//            input.retryTap.asObservable()
        )
            .share()
        
        // 2) 로딩/에러 상태
        let loading = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()
        
        // 3) 데이터 요청
        let response = trigger
            .flatMapLatest {  _ -> Observable<Event<[RegionNewsResponse]>> in
                PlaceService.shared.getRegionNews()
                    .asObservable()
                    .do(onSubscribe: { loading.accept(true) })
                    .materialize()
            }
            .do(onNext: { _ in loading.accept(false) },
                onError: { _ in loading.accept(false) })
            .share()
        
        // 4) 성공/실패 분기
        let values = response.compactMap { $0.element }
        let errors = response.compactMap { $0.error }
        
        errors
            .map { $0.localizedDescription }
            .bind(to: errorRelay)
            .disposed(by: disposeBag)
        
        // 5) UI 아이템 매핑
        let regionNewsItems = values
            .map { list in
                list.map(Self.makeItem(_:))
            }
            .asDriver(onErrorJustReturn: [])
        
        let isRegionNewsEmpty = regionNewsItems.map { $0.isEmpty }
        
        return Output(
            regionNewsItems: regionNewsItems,
            isLoading: loading.asDriver(),
            isRegionNewsEmpty: isRegionNewsEmpty,
            isEmpty: isRegionNewsEmpty,
            errorMessage: errorRelay.asSignal()
        )
    }
    
    private static func makeItem(_ r: RegionNewsResponse) -> RegionItem {
        let title = "\(r.area) · \(r.posName)"
        let timeRange: String
        if let s = parse("yyyy-MM-dd'T'HH:mm:ss", r.startTime),
           let e = parse("yyyy-MM-dd'T'HH:mm:ss", r.endTime) {
            let f = DateFormatter()
            f.locale = Locale(identifier: "ko_KR")
            f.timeZone = TimeZone(identifier: "Asia/Seoul")
            f.dateFormat = "HH:mm"
            timeRange = "\(f.string(from: s))–\(f.string(from: e))"
        } else {
            timeRange = "\(r.startTime) ~ \(r.endTime)"
        }
        
        let desc = "\(timeRange) · \(r.peopleCnt)명"
        return RegionItem(iconImage: .iconTaegeuk,
                          organization: r.area,
                          title: r.posName,
                          description: desc)
    }
    
    private static func parse(_ format: String, _ str: String) -> Date? {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = format
        return df.date(from: str)
    }
}
