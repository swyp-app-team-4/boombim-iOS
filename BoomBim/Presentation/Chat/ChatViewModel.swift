//
//  ChatViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import RxSwift
import RxCocoa
import CoreLocation

final class ChatViewModel {
    struct Input {
        let appear: Signal<Void>                 // viewDidAppear 등
        let refresh: Signal<Void>                // 당겨서 새로고침 or 상단 버튼
    }
    struct Output {
        let myCoordinate: Observable<Coordinate?>
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let voteList: Driver<[VoteItemResponse]>
        let myVoteList: Driver<[MyVoteItemResponse]>
    }

    private let loading = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    var goToQuestionView: (() -> Void)?
    
    func didTapFloating() {
        goToQuestionView?()
    }
    
    private let locationRepo: LocationRepositoryType
    
    init(locationRepo: LocationRepositoryType) {
        self.locationRepo = locationRepo
        print("self.locationRepo: \(locationRepo)")
    }

    func transform(_ input: Input) -> Output {
        // 1) 권한 요청(미결정이면)
        locationRepo.requestAuthorizationIfNeeded()
        // 1) 권한 스트림
        let authD: Driver<CLAuthorizationStatus> = locationRepo.authorization
            .asDriver(onErrorDriveWith: .empty())
        
        let isAuthorizedD: Driver<Bool> = authD
            .map { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse: return true
                default: return false
                }
            }
            .distinctUntilChanged()
        
        // 2) 권한이 허용된 "뒤에만" 프리워밍(캐시/메모리/원샷)
        isAuthorizedD
            .filter { $0 }
            .asObservable() 
            .take(1)
            .asObservable()
            .flatMapLatest { [locationRepo] _ in
                locationRepo.getCoordinate(ttl: 180)
                    .asObservable()
                    .materialize() // 오류를 삼키며 로그용으로만
            }
            .subscribe(onNext: { event in
                if case .error(let e) = event { print("⚠️ prewarm error:", e) }
            })
            .disposed(by: disposeBag)
        
        let myCoord = Observable
            .merge(locationRepo.coordinate)
            .share(replay: 1, scope: .whileConnected)
        
        let isLocationReady: Driver<Bool> = myCoord
            .map { $0 != nil }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
        
        // 1) 트리거를 Driver로 올림
        let appearD  = input.appear.asDriver(onErrorDriveWith: .empty())
        let refreshD = input.refresh.asDriver(onErrorDriveWith: .empty())
        let triggerD = Driver.merge(appearD, refreshD)
            .startWith(()) // 앱 진입 직후 한 번은 자동으로 시도하고 싶다면 유지
        
        let coordD: Driver<Coordinate> = myCoord
                .compactMap { $0 }
                .asDriver(onErrorDriveWith: .empty())
        
        // 트리거 + 최신 좌표로 API 호출
        let fetchParamD: Driver<Coordinate> = Driver
            .combineLatest(triggerD, coordD)
            .map { _, coord in coord }
        
        let shared: Driver<VoteListResponse> = fetchParamD
            .flatMapLatest { [weak self] coord -> Driver<VoteListResponse> in
                self?.loading.accept(true)
                let req = VoteListRequest(latitude: coord.latitude, longitude: coord.longitude)
                return VoteService.shared.fetchVoteList(req)
                    .asObservable()
                    .do(onError: { [weak self] err in
                        self?.errorRelay.accept(err.localizedDescription)
                        self?.loading.accept(false)
                    })
                    .catch { _ in .empty() }
                    .asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { [loading] _ in loading.accept(false) })

        let voteList = shared.map { response in
            response.voteResList.sorted { $0.createdAtDate > $1.createdAtDate }
        }
        
        let myVoteList = shared.map { response in
            response.myVoteResList.sorted { $0.createdAtDate > $1.createdAtDate }
        }

        return Output(
            myCoordinate: myCoord,
            isLoading: loading.asDriver(),
            error: errorRelay.asSignal(),
            voteList: voteList,
            myVoteList: myVoteList
        )
    }
}
