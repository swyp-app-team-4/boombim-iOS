//
//  ProfileImageView.swift
//  BoomBim
//
//  Created by 조영현 on 8/22/25.
//

import UIKit
import Foundation
// import Nuke

final class ProfileImageView: UIView {
    /// 원 크기
    var avatarSize: CGFloat = 24 { didSet { setNeedsLayout() } }
    /// 겹치는 정도 (크면 더 많이 겹침)
    var overlap: CGFloat = 8  { didSet { setNeedsLayout() } }
    /// 최대 노출 개수 (요구: 3)
    var maxVisible: Int = 3   { didSet { setNeedsLayout() } }

    private var imageViews: [UIImageView] = []
    private var leadingConstraints: [NSLayoutConstraint] = []

    override var intrinsicContentSize: CGSize {
        let count = imageViews.count
        let width = count == 0 ? 0 :
            avatarSize + CGFloat(count - 1) * (avatarSize - overlap)
        return CGSize(width: width, height: avatarSize)
    }

    // 셀에서 호출
    func configure(with urls: [URL?]) {
        // 정리
        imageViews.forEach { $0.removeFromSuperview() }
        leadingConstraints.removeAll()
        imageViews.removeAll()
        
        let count = min(maxVisible, urls.count)
        guard count > 0 else { isHidden = true; return }
        isHidden = false
        
        for i in 0..<count {
            let iv = makeAvatarView()
            addSubview(iv)
            iv.translatesAutoresizingMaskIntoConstraints = false
            
            let leading = iv.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: CGFloat(i) * (avatarSize - overlap))
            leadingConstraints.append(leading)
            
            NSLayoutConstraint.activate([
                leading,
                iv.centerYAnchor.constraint(equalTo: centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: avatarSize),
                iv.heightAnchor.constraint(equalTo: iv.widthAnchor)
            ])
            
            // 오른쪽이 위로 오도록
            iv.layer.zPosition = CGFloat(Float(i))
            
            // ✅ placeholder 먼저 세팅
            iv.image = .iconEmptyProfile
            
            if let u = urls[i] {
                // Nuke 사용 시:
                // let opts = ImageLoadingOptions(placeholder: placeholderImage,
                //                                failureImage: placeholderImage,
                //                                transition: .fadeIn(duration: 0.2))
                // Nuke.loadImage(with: u, options: opts, into: iv)
                
                // 기본 URLSession 로더 사용 시:
//                iv.boundURL = u                      // 레이스컨디션 방지용 바인딩
//                loadWithURLSession(u, into: iv, placeholder: .iconEmptyProfile)
            } else {
                // ✅ URL이 없으면 기본 이미지 유지
                iv.image = .iconEmptyProfile
            }
            
            imageViews.append(iv)
        }
        
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageViews.forEach {
            $0.layer.cornerRadius = avatarSize / 2
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.white.cgColor
            $0.clipsToBounds = true
        }
    }
    
    private func makeAvatarView() -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray5
        return iv
    }

    // 간단 로더 (Nuke 없을 때)
    private func loadWithURLSession(_ url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { imageView.image = img }
        }.resume()
    }
}
