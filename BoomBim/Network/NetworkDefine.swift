//
//  NetworkDefine.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

enum NetworkDefine {
    static let API_HOST = "https://api.boombim.p-e.kr/"
    
    enum Auth {
        enum AuthType: String {
            case naver = "naver"
            case kakao = "kakao"
            case apple = "apple"
        }
        
        static let login = "api/oauth2/login/"
    }
}
