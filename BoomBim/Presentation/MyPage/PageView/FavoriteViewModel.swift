//
//  FavoriteViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 9/6/25.
//

import RxSwift
import RxCocoa

final class FavoriteViewModel {
    struct Output {
        let items: Driver<[MyFavorite]>
    }
    
    let output: Output
    
    init(items: Driver<[MyFavorite]>) {
        self.output = .init(items: items)
    }
}
