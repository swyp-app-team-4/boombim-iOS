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
}
