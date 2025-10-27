//
//  KoreanOnlyTextField.swift
//  BoomBim
//
//  Created by 조영현 on 10/2/25.
//

import UIKit

final class KoreanOnlyTextField: InsetTextField {

    /// 허용 최대 글자 수 (완성형 기준)
    var maxLength: Int = 20

    private let koreanOnlyRegex = try! NSRegularExpression(pattern: "[^0-9A-Za-z가-힣ㄱ-ㅎㅏ-ㅣ]")

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    @objc private func editingChanged() {
        // 조합(한글 입력 중)일 때는 건드리지 않음
        guard markedTextRange == nil else { return }

        let t = text ?? ""
        let filtered = koreanOnlyRegex.stringByReplacingMatches(
            in: t, options: [], range: NSRange(location: 0, length: (t as NSString).length), withTemplate: ""
        )

        let trimmed = String(filtered.prefix(maxLength))
        if trimmed != t { text = trimmed }
    }
}
