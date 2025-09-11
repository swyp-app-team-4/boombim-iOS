//
//  TermsModel.swift
//  BoomBim
//
//  Created by 조영현 on 9/11/25.
//

import Foundation

// MARK: - Model
struct TermsModel {
    enum Kind { case required, optional }
    
    let id: String
    let title: String
    let url: URL
    let kind: Kind
    var isChecked: Bool
}
