//
//  PersonalInfoViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 10/21/25.
//

final class PersonalInfoViewModel {
    var currentLoginState: LoginStateInfo = {
        let currentLoginProvider = LoginProviderStore.shared.currentLoginProvider
        
        switch currentLoginProvider {
        case .kakao:
            return .kakao
        case .naver:
            return .naver
        case .apple:
            return .apple
        case .none:
            return .none
        }
    }()
}
