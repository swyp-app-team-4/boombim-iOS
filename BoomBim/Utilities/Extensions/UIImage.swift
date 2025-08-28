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
    
    /// 업로드용 데이터 생성 (리사이즈 + JPEG 압축)
    /// - Parameters:
    ///   - maxBytes: 목표 최대 용량(바이트). 예: 900_000 ≈ 0.9MB
    ///   - maxDimension: 긴 변 기준 최대 픽셀. 예: 1080 (필요시 1280/1440)
    ///   - minQuality: JPEG 최소 품질(0.0~1.0)
    ///   - initialQuality: 시작 품질(기본 0.9)
    /// - Returns: JPEG Data (용량 제한 내), 실패 시 nil
    func preparedForUpload(maxBytes: Int = 900_000,
                           maxDimension: CGFloat = 1080,
                           minQuality: CGFloat = 0.35,
                           initialQuality: CGFloat = 0.9) -> Data? {

        // 1) 해상도 축소 (긴 변 기준)
        let resized = resizedToFit(maxDimension: maxDimension)

        // 2) 우선 높은 품질로 시도
        guard var best = resized.jpegData(compressionQuality: initialQuality) else { return nil }
        if best.count <= maxBytes { return best }

        // 3) JPEG 품질 이진 탐색
        var lo = minQuality
        var hi = initialQuality
        for _ in 0..<6 { // 6~7회면 충분
            let mid = (lo + hi) / 2
            guard let d = resized.jpegData(compressionQuality: mid) else { break }
            if d.count > maxBytes {
                hi = mid
            } else {
                best = d
                lo = mid
            }
        }
        if best.count <= maxBytes { return best }

        // 4) 그래도 크면 해상도를 더 낮춰서 한 번 더 시도
        let smaller = resized.resizedToFit(maxDimension: maxDimension * 0.75)
        return smaller.jpegData(compressionQuality: max(lo, minQuality))
    }

    /// 긴 변이 `maxDimension`을 넘으면 비율 유지 리사이즈
    func resizedToFit(maxDimension: CGFloat) -> UIImage {
        let w = size.width, h = size.height
        let maxSide = max(w, h)
        guard maxSide > maxDimension, maxSide > 0 else { return self }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: w * scale, height: h * scale)

        // UIGraphicsImageRenderer는 이미지 방향을 올바르게 반영합니다.
        let renderer = UIGraphicsImageRenderer(size: newSize, format: UIGraphicsImageRendererFormat.default())
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// 업로드 페이로드 편의 생성자 (파일명/타입 포함)
    /// - Returns: (data, fileName, mimeType)
    func uploadPayload(maxBytes: Int = 900_000,
                       maxDimension: CGFloat = 1080,
                       baseName: String = "profile") -> (data: Data, fileName: String, mimeType: String)? {
        guard let data = preparedForUpload(maxBytes: maxBytes, maxDimension: maxDimension) else { return nil }
        return (data, "\(baseName).jpg", "image/jpeg")
    }
}
