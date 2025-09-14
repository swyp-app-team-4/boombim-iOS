//
//  FeedbackModel.swift
//  BoomBim
//
//  Created by 조영현 on 9/14/25.
//

enum WithdrawReason: CaseIterable {
    case notOftenUse
    case inconvenient
    case badService
    case newAccount
    case privacyConcern
    case other
    
    var title: String {
        switch self {
        case .notOftenUse:   return "자주 이용하지 않아요"
        case .inconvenient:  return "기능이 불편해요"
        case .badService:    return "서비스가 불편해요"
        case .newAccount:    return "신규 계정으로 가입할래요"
        case .privacyConcern:return "개인 정보가 우려돼요"
        case .other:         return "기타"
        }
    }
}
