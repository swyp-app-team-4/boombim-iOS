//
//  NetworkDefine.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

enum NetworkDefine {
    static let apiHost = "https://api.boombim.p-e.kr/"
    static let apiKakao = "https://dapi.kakao.com/"
    
    enum Auth {
        enum AuthType: String {
            case naver = "naver"
            case kakao = "kakao"
            case apple = "apple"
        }
        
        static let login = "api/oauth2/login/"
    }
    
    enum Search {
        static let keyword = "v2/local/search/keyword.json"
        static let category = "v2/local/search/category.json"
    }
}
