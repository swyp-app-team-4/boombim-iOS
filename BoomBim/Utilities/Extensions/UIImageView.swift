//
//  UIImageView.swift
//  BoomBim
//
//  Created by 조영현 on 8/28/25.
//

import UIKit
import Nuke
import NukeExtensions

public enum RemoteImage {
    public static let profilePlaceholder = UIImage.iconEmptyProfile
}

extension UIImageView {

    func setImage(from urlString: String?, placeholder: UIImage? = RemoteImage.profilePlaceholder, resizeToViewBounds: Bool = true
    ) {
        self.image = placeholder

        guard var s = urlString, s.isEmpty == false else { return }

        // 1) 공백/한글 인코딩
        if let encoded = s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            s = encoded
        }
        
        s = upgradingToHTTPS(s)

        guard let url = URL(string: s) else {
            print("[Nuke] Invalid URL: \(urlString ?? "nil")")
            return
        }

        // 2) 요청 생성 (다운샘플 권장)
        var request = ImageRequest(url: url)

        if resizeToViewBounds, self.bounds.size != .zero {
            request.processors = [
                ImageProcessors.Resize(
                    size: self.bounds.size,
                    contentMode: .aspectFill,
                    crop: true,
                    upscale: false
                )
            ]
        }

        // 3) 옵션
        var options = ImageLoadingOptions(
            placeholder: placeholder,
            transition: .fadeIn(duration: 0.2), failureImage: placeholder
        )

        // 4) 로드 + 로깅
        NukeExtensions.loadImage(with: request, options: options, into: self) { result in
            switch result {
            case .success(let response):
                // 성공하지만 뷰 크기 0에서 시작했다면, 다음 레이아웃 이후 다시 리사이즈 로딩 가능
                // print("[Nuke] Loaded: \(response.urlResponse?.statusCode ?? -1)")
                // self.contentMode = .scaleAspectFill
                self.clipsToBounds = true
            case .failure(let error):
                print("[Nuke] Load failed: \(error)")
                if let urlError = (error as NSError).userInfo[NSUnderlyingErrorKey] as? URLError {
                    print("[Nuke] Underlying URLError: \(urlError)")
                }
            }
        }
    }
    
    private func upgradingToHTTPS(_ urlString: String) -> String {
        guard urlString.hasPrefix("http://") else { return urlString }
        // 특정 도메인만 엄격히 바꾸고 싶다면 contains("k.kakaocdn.net") 검사 추가
        return "https://" + urlString.dropFirst("http://".count)
    }
}
