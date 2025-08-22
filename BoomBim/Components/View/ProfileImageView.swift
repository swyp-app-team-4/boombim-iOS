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
        // 1) 기존 정리
        imageViews.forEach { $0.removeFromSuperview() }
        leadingConstraints.removeAll()
        imageViews.removeAll()

        // 2) 개수 제한
        let count = min(maxVisible, urls.count)
        guard count > 0 else { isHidden = true; return }
        isHidden = false

        // 3) 생성
        for i in 0..<count {
            let iv = makeAvatarView()
            addSubview(iv)
            iv.translatesAutoresizingMaskIntoConstraints = false

            let leading = iv.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: CGFloat(i) * (avatarSize - overlap)
            )
            leadingConstraints.append(leading)

            NSLayoutConstraint.activate([
                leading,
                iv.centerYAnchor.constraint(equalTo: centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: avatarSize),
                iv.heightAnchor.constraint(equalTo: iv.widthAnchor)
            ])

            // 최신(오른쪽)이 위로 오도록
            iv.layer.zPosition = CGFloat(Float(i))

            // 이미지 로딩
            if let u = urls[i] {
                // Nuke 사용 시:
                // Nuke.loadImage(with: u, options: .init(transition: .fadeIn(duration: 0.2)), into: iv)
                loadWithURLSession(u, into: iv) // 기본 로더
            } else {
                iv.backgroundColor = .systemGray4
            }

            imageViews.append(iv)
        }

        // 컨텐츠 폭 계산을 위해
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 원형 + 테두리
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
