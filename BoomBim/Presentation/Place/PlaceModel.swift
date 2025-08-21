//
//  PlaceModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/19/25.
//

import Foundation
import UIKit

struct PlaceItem: Hashable {
    let id = UUID()
    let image: UIImage
    let name: String
    let detail: String
    let congestion: String
}
