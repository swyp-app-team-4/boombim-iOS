//
//  QuestionChatViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/29/25.
//

import RxSwift
import RxCocoa

final class QuestionChatViewModel {
    
    let items: Driver<[VoteItemResponse]>
    
    init(items: Driver<[VoteItemResponse]>) {
        self.items = items
    }
}
