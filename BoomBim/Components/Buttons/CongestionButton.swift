//
//  CongestionButton.swift
//  BoomBim
//
//  Created by 조영현 on 10/30/25.
//

import UIKit

struct CongestionButtonStyle {
    let disabledImage: UIImage
    let disabledLayerColor: UIColor
    let disabledBackgroundColor: UIColor
    
    let normalImage: UIImage
    let normalLayerColor: UIColor
    let normalBackgroundColor: UIColor
    
    let selectedImage: UIImage
    let selectedLayerColor: UIColor
    let selectedBackgroundColor: UIColor
    
    let text: String
    
    // 선택: 타이틀 컬러를 직접 지정하고 싶으면 추가
    var normalTitleColor: UIColor = .grayScale7
    var selectedTitleColor: UIColor = .grayScale7
    var disabledTitleColor: UIColor = .grayScale7
    
    // 선택: 모서리/보더/인셋/간격
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 1
    //    var contentInsets: NSDirectionalEdgeInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12)
    //    var imagePadding: CGFloat = 6
    //    var imagePlacement: NSDirectionalRectEdge = .leading
}

final class CongestionButton: UIButton {
    
    private let style: CongestionButtonStyle
    
    // MARK: - Init
    init(style: CongestionButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup
    private func setup() {
        // 접근성(라벨은 상태와 상관없이 공통 텍스트)
        accessibilityLabel = style.text
        
        var config = UIButton.Configuration.plain() // filled도 가능
        //            config.contentInsets = style.contentInsets
        config.imagePadding = 2
        config.imagePlacement = .top
        // 기본 타이틀 지정(상태별로 색만 바꿔줌)
        var titleAttr = AttributedString(style.text)
        titleAttr.font = .systemFont(ofSize: 15, weight: .semibold)
        config.attributedTitle = titleAttr
        self.configuration = config
        
        // 상태가 바뀔 때마다 이 핸들러가 호출되어 외형을 갱신
        self.configurationUpdateHandler = { [weak self] button in
            guard let self, var c = button.configuration else { return }
            self.applyStyle(&c, for: button.state)
            button.configuration = c
            
            // layer (corner/border)는 configuration이 아니라 view layer에 반영
            self.layer.cornerRadius = self.style.cornerRadius
            self.layer.borderWidth = self.style.borderWidth
            self.layer.borderColor = self.borderColor(for: button.state).cgColor
            self.layer.masksToBounds = true
        }
        
        // 초기 갱신
        setNeedsUpdateConfiguration()
    }
    
    // MARK: - iOS 15+ 상태별 적용
    @available(iOS 15.0, *)
    private func applyStyle(_ config: inout UIButton.Configuration, for state: UIControl.State) {
        let (bg, img, titleColor): (UIColor, UIImage, UIColor)
        
        if !isEnabled {
            bg = style.disabledBackgroundColor
            img = style.disabledImage
            titleColor = style.disabledTitleColor
        } else if isSelected {
            bg = style.selectedBackgroundColor
            img = style.selectedImage
            titleColor = style.selectedTitleColor
        } else {
            bg = style.normalBackgroundColor
            img = style.normalImage
            titleColor = style.normalTitleColor
        }
        
        // 배경색
        if config.background == nil { config.background = .clear() }
        config.baseBackgroundColor = bg
        
        // 타이틀 색
        if var attr = config.attributedTitle {
            attr.foregroundColor = titleColor
            config.attributedTitle = attr
        }
        
        // 이미지
        config.image = img
        // contentInsets, imagePadding 등은 setup에서 한 번만 설정
    }
    
    private func borderColor(for state: UIControl.State) -> UIColor {
        if !isEnabled { return style.disabledLayerColor }
        if isSelected { return style.selectedLayerColor }
        return style.normalLayerColor
    }
}

// MARK: - Utilities
private extension UIImage {
    static func solidColor(_ color: UIColor, size: CGSize = .init(width: 2, height: 2)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }
}
