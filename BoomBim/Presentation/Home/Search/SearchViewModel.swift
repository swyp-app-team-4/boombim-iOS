//
//  SearchViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import RxSwift
import RxCocoa

final class SearchViewModel {
    let disposeBag = DisposeBag()
    
    let query = BehaviorRelay<String>(value: "")
    let results = BehaviorRelay<[Place]>(value: [])
    
    struct Input {
        let searchText: Observable<String>          // 검색어 변경 스트림
    }
    struct Output {
        let results: Observable<[Place]>
    }
    
    private let service: KakaoLocalService
    
    init(service: KakaoLocalService) {
        self.service = service
    }

    func transform(input: Input) -> Output {
        let results = input.searchText
            .skip(1)
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [service] query -> Observable<[Place]> in
                guard !query.isEmpty else { return .just([]) }
                return service.searchByKeyword(query: query)
                    .asObservable()
                    .catchAndReturn([])
            }
            .do(onNext: { [weak self] in self?.results.accept($0) }) // 기존 BehaviorRelay도 유지하고 싶으면
            .share(replay: 1, scope: .whileConnected)
        
        return Output(results: results)
    }
}

