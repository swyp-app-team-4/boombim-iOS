//
//  Int.swift
//  BoomBim
//
//  Created by 조영현 on 10/30/25.
//

import Foundation

extension Int {
    func asPeopleString(suffix: String = "명") -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "ko_KR")
        return (nf.string(from: NSNumber(value: self)) ?? "\(self)") + suffix
    }
}
