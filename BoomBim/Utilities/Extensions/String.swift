//
//  String.swift
//  BoomBim
//
//  Created by 조영현 on 8/14/25.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
