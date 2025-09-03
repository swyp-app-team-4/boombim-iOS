//
//  KeychainIDs.swift
//  BoomBim
//
//  Created by 조영현 on 8/27/25.
//

enum AppEnvironment {
    case dev, stage, prod

    static let current: AppEnvironment = {
        #if DEBUG
        return .dev
        #elseif STAGE
        return .stage
        #else
        return .prod
        #endif
    }()

    // suffix는 현재 빌드/실행 환경(dev, stage, prod)을 짧은 문자열로 표현한 값이에요.
    // 이 값을 Keychain의 account 이름 뒤에 붙여서 환경마다 저장소를 분리하려고 쓰는 겁니다.
    var suffix: String {
        switch self {
        case .dev: return "dev"
        case .stage: return "stage"
        case .prod: return "prod"
        }
    }
}

struct KeychainIDs {
    static func backendTokenPair(env: AppEnvironment) -> KeychainKey {
        .init(service: "com.boombim.auth",  account: "social_token_pair_\(env.suffix)")
    }
}
