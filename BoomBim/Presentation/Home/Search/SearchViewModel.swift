//
//  SearchViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import RxSwift
import RxCocoa

final class SearchViewModel {
    let query = BehaviorRelay<String>(value: "")
    let results = PublishRelay<[SearchItem]>()
    let disposeBag = DisposeBag()

    func bindSearch() {
        query
            .skip(1)
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] query in
                self?.search(query: query)
            })
            .disposed(by: disposeBag)
    }

    private func search(query: String) {
        NaverSearchService.shared.search(query: query) { [weak self] result in
            switch result {
            case .success(let items):
                self?.results.accept(items)
            case .failure(let error):
                print("Search error: \(error.localizedDescription)")
            }
        }
    }
}

