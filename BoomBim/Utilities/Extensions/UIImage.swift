//
//  UIImage.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
