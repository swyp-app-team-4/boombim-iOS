//
//  CongestionReportViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class CongestionReportViewModel {

    struct Input {
        let postTap: Signal<Void>
        let levelSelect: Signal<Int>          // 0~3 (서버가 1~4면 내부에서 +1)
        let message: Driver<String>           // 설명 텍스트(최대 500자)
        let place: Driver<Place?>             // 선택된 장소
        let aiTap: Signal<Void>
    }

    struct Output {
        let postEnabled: Driver<Bool>         // 버튼 활성화
        let loading: Driver<Bool>
        let error: Signal<String>
        let completed: Signal<Void>
        let aiText: Signal<String>
    }

    // 외부에서 이미 사용 중인 바인딩
//    let selectedPlace: Driver<Place?>         // VC에서 표시용으로 쓰던 스트림
    var selectedPlace: Driver<Place?> { _currentSelectedPlace.asDriver() }
    var currentSelectedPlace: Place? { _currentSelectedPlace.value }

    private let _currentSelectedPlace = BehaviorRelay<Place?>(value: nil)
    private let selectedLevelRelay = BehaviorRelay<Int?>(value: nil) // 0~3 저장
    
    private let _registerPlaceId = BehaviorRelay<Int?>(value: nil)
    private let _registerPlaceName = BehaviorRelay<String?>(value: nil)
    
    private let aiTextRelay = PublishRelay<String>()

    private let disposeBag = DisposeBag()
    
    var goToMapPickerView: ((CLLocationCoordinate2D) -> Void)?
    var goToSearchPlaceView: (() -> Void)?
    var backToHome: (() -> Void)?

//    // DI 필요한 경우 주입하세요
//    init(selectedPlace: Driver<Place?>) {
//        self.selectedPlace = selectedPlace
//
//        // 내부 상태에 최신 place 반영 (post 시 샘플링 용도)
//        selectedPlace
//            .drive(_currentSelectedPlace)
//            .disposed(by: disposeBag)
//    }
    private let service: KakaoLocalService
    
    init(service: KakaoLocalService) {
        self.service = service
    }
    
    // Coordinator가 호출할 setter
    func setSelectedPlace(place: Place, id: Int) {
        _currentSelectedPlace.accept(place)
        _registerPlaceId.accept(id)
        _registerPlaceName.accept(place.name)
    }

    func transform(input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<String>()
        let completedRelay = PublishRelay<Void>()

        // 최신 level 보관
        input.levelSelect
            .emit(onNext: { [weak self] level in
                self?.selectedLevelRelay.accept(level)
            })
            .disposed(by: disposeBag)

        // post 버튼 enable 조건: place 존재 && level 선택됨
        let postEnabled = Driver
            .combineLatest(input.place.map { $0 != nil },
                           selectedLevelRelay.asDriver())
            .map { hasPlace, levelOpt in hasPlace && (levelOpt != nil) }
            .distinctUntilChanged()

        // postTap → (place, level, message) 스냅샷
        input.postTap
            .asObservable()
            .withLatestFrom(Observable.combineLatest(
                _currentSelectedPlace.asObservable(),
                _registerPlaceId.asObservable(),
                selectedLevelRelay.asObservable(),
                input.message.asObservable()
            ))
            .flatMapLatest { [weak self] (placeOpt, placeId, levelOpt, message) -> Observable<Event<ReportData>> in
                guard let self else { return .empty() }

                guard let place = placeOpt else {
                    errorRelay.accept("장소를 선택해 주세요.")
                    return .empty()
                }
                guard let id = placeId else {
                    errorRelay.accept("장소를 등록해 주세요.")
                    return .empty()
                }
                guard let level0to3 = levelOpt else {
                    errorRelay.accept("혼잡도를 선택해 주세요.")
                    return .empty()
                }

                // 서버 ID 매핑(예: 1~4)
                let levelId = level0to3 + 1

                let body = PostPlaceRequest(
                    memberPlaceId: id,
                    congestionLevelId: levelId,
                    congestionMessage: message,
                    latitude: place.coord.latitude,
                    longitude: place.coord.longitude
                )

                loadingRelay.accept(true)
                return PlaceService.shared.postReport(body: body)
                    .map { $0.data }                 // ReportData(memberPlaceId 등)
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { event in
                switch event {
                case .next(_):
                    loadingRelay.accept(false)
                    completedRelay.accept(())
                case .error(let err):
                    loadingRelay.accept(false)
                    errorRelay.accept(err.localizedDescription)
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        input.aiTap
            .asObservable()
            .withLatestFrom(Observable.combineLatest(
                _registerPlaceName.asObservable(),
                selectedLevelRelay.asObservable(),
                input.message.asObservable()
            ))
            .flatMapLatest { [weak self] (placeName, levelOpt, message) -> Observable<Event<AiMessageData>> in
                guard let self else { return .empty() }

                guard let place = placeName else {
                    errorRelay.accept("장소를 등록해 주세요.")
                    return .empty()
                }
                guard let level = levelOpt else {
                    errorRelay.accept("혼잡도를 선택해 주세요.")
                    return .empty()
                }
                
                let body = AiMessageRequest(
                    memberPlaceName: place,
                    congestionLevelName: CongestionLevel.init(index: level)?.description ?? "보통",
                    congestionMessage: message
                )

                loadingRelay.accept(true)
                return PlaceService.shared.requestAi(body: body)
                    .map { $0.data }
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { event in
                switch event {
                case .next(let data):
                    loadingRelay.accept(false)
                    self.aiTextRelay.accept(data.generatedCongestionMessage)
                case .error(let err):
                    loadingRelay.accept(false)
                    errorRelay.accept(err.localizedDescription)
                case .completed:
                    break
                }
            })
            .disposed(by: disposeBag)

        return Output(
            postEnabled: postEnabled,
            loading: loadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            completed: completedRelay.asSignal(),
            aiText: aiTextRelay.asSignal()
        )
    }

    // 라우팅/완료 후 닫기 등
    func didTapPost() {
        print("didTapPost")
        backToHome?()
    }
    
    // MARK: Action
    func didTapSearch() {
        print("didTapSearch")
        goToSearchPlaceView?()
    }
    
    func didTapExit() {
        print("didTapExit")
        backToHome?()
    }
}
