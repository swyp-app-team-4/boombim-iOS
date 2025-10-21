//
//  PersonalInfoModel.swift
//  BoomBim
//
//  Created by 조영현 on 10/21/25.
//

import Foundation
import UIKit

enum LoginStateInfo {
    case kakao
    case naver
    case apple
    case none
    
    var title: String {
        switch self {
        case .kakao:
            return "카카오"
        case .naver:
            return "네이버"
        case .apple:
            return "애플"
        case .none:
            return "로그인이 되어있지 않습니다"
        }
    }
    
    var image: UIImage {
        switch self {
            case .kakao:
            return UIImage.iconCircleKakao
        case .naver:
            return UIImage.iconCircleNaver
        case .apple:
            return UIImage.iconCircleApple
        case .none:
            return UIImage.iconCircleApple
        }
    }
}
