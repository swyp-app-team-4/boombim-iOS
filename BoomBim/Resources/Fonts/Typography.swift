//
//  Typography.swift
//  BoomBim
//
//  Created by 조영현 on 8/14/25.
//

import UIKit

struct TextStyle {
    let font: UIFont
    let lineHeight: CGFloat
}

enum Typography {

    enum Heading01 {
        private static let lh: CGFloat = 32
        static let semiBold = TextStyle(font: .pretendard(.semiBold, size: 24), lineHeight: lh)
        static let medium   = TextStyle(font: .pretendard(.medium,   size: 24), lineHeight: lh)
        static let regular  = TextStyle(font: .pretendard(.regular,  size: 24), lineHeight: lh)
    }

    enum Heading02 {
        private static let lh: CGFloat = 30
        static let semiBold = TextStyle(font: .pretendard(.semiBold, size: 22), lineHeight: lh)
        static let medium   = TextStyle(font: .pretendard(.medium,   size: 22), lineHeight: lh)
        static let regular  = TextStyle(font: .pretendard(.regular,  size: 22), lineHeight: lh)
    }

    enum Heading03 {
        private static let lh: CGFloat = 28
        static let semiBold = TextStyle(font: .pretendard(.semiBold, size: 20), lineHeight: lh)
        static let medium   = TextStyle(font: .pretendard(.medium,   size: 20), lineHeight: lh)
        static let regular  = TextStyle(font: .pretendard(.regular,  size: 20), lineHeight: lh)
    }

    enum Body01 {
        private static let lh: CGFloat = 24
        static let semiBold = TextStyle(font: .pretendard(.semiBold, size: 18), lineHeight: lh)
        static let medium   = TextStyle(font: .pretendard(.medium,   size: 18), lineHeight: lh)
        static let regular  = TextStyle(font: .pretendard(.regular,  size: 18), lineHeight: lh)
    }

    enum Body02 {
        private static let lh: CGFloat = 24
        static let semiBold = TextStyle(font: .pretendard(.semiBold, size: 16), lineHeight: lh)
        static let medium   = TextStyle(font: .pretendard(.medium,   size: 16), lineHeight: lh)
        static let regular  = TextStyle(font: .pretendard(.regular,  size: 16), lineHeight: lh)
    }

    enum Body03 {
        private static let lh: CGFloat = 22
        static let semiBold = TextStyle(font: .pretendard(.semiBold, size: 14), lineHeight: lh)
        static let medium   = TextStyle(font: .pretendard(.medium,   size: 14), lineHeight: lh)
        static let regular  = TextStyle(font: .pretendard(.regular,  size: 14), lineHeight: lh)
    }

    enum Caption {
        private static let lh: CGFloat = 18
        static let semiBold = TextStyle(font: .pretendard(.semiBold, size: 12), lineHeight: lh)
        static let medium   = TextStyle(font: .pretendard(.medium,   size: 12), lineHeight: lh)
        static let regular  = TextStyle(font: .pretendard(.regular,  size: 12), lineHeight: lh)
    }
}
