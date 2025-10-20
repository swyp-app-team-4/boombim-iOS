//
//  UIFont.swift
//  BoomBim
//
//  Created by 조영현 on 8/14/25.
//

import UIKit

extension UIFont {
    
    public enum PretendardType: String {
        case semiBold = "-SemiBold"
        case medium = "-Medium"
        case regular = "-Regular"
    }

    static func pretendard(_ type: PretendardType, size: CGFloat = UIFont.systemFontSize) -> UIFont {
        return UIFont(name: "Pretendard\(type.rawValue)", size: size)!
    }
    
    static func taebaek(size: CGFloat = UIFont.systemFontSize) -> UIFont {
        return UIFont(name: "TAEBAEK-font", size: size)!
    }
    
    public enum NotoSansType: String {
        case semiBold = "-SemiBold"
    }
    
    static func notoSans(_ type: NotoSansType, size: CGFloat = UIFont.systemFontSize) -> UIFont {
        return UIFont(name: "NotoSansKR\(type.rawValue)", size: size)!
    }
}
