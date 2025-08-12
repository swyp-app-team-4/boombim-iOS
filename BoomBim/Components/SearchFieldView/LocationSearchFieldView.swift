//
//  LocationSearchFieldView.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit

final class LocationSearchFieldView: UIView, UITextFieldDelegate {

    let textField = UITextField()

    var onTapSearch: (() -> Void)?   // 탭 시 지도 열기

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // 2) 검색 입력창
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: "검색",
            attributes: [.foregroundColor: UIColor.systemGray3]
        )
        textField.font = .systemFont(ofSize: 16)
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 16
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search

        // 좌측 돋보기 아이콘
        let left = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        left.tintColor = .systemGray3
        left.contentMode = .center
        left.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        textField.leftView = left
        textField.leftViewMode = .always

        // 3) 레이아웃
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 56),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 전체 뷰 탭해도 검색 열리게
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSearch))
        addGestureRecognizer(tap)
    }

    /** 외부에서 텍스트 세팅 */
    func setText(_ text: String?) {
        textField.text = text
    }

    // 편집 시작을 가로채서 지도 화면으로
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        onTapSearch?()
        return false // 키보드 열지 않음, 지도 화면으로 전환
    }

    @objc private func openSearch() {
        onTapSearch?()
    }
}
