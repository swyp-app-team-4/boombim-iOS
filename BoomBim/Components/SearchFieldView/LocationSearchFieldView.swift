//
//  LocationSearchFieldView.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import RxSwift
import RxCocoa

final class LocationSearchFieldView: UIView {

    fileprivate let textField: UITextField = {
        let textField = UITextField()
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "약속된 장소를 검색해보세요.",
            attributes: [.foregroundColor: UIColor.placeholder]
        )
        textField.font = Typography.Body03.medium.font
        textField.backgroundColor = .grayScale1
        textField.tintColor = .grayScale7
        
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.grayScale4.cgColor
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        
        textField.setIcon(UIImage(systemName: "magnifyingglass") ?? .iconProfile)
        
        return textField
    }()

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

        // 3) 레이아웃
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 전체 뷰 탭해도 검색 열리게
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSearch))
        addGestureRecognizer(tap)
    }

    /** 외부에서 텍스트 세팅 */
    func setText(_ text: String?) {
        textField.textColor = .grayScale9
        textField.text = text
    }

    @objc private func openSearch() {
        onTapSearch?()
    }
}

extension LocationSearchFieldView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool { // 편집 시작을 가로채서 지도 화면으로
        onTapSearch?()
        return false // 키보드 열지 않음, 지도 화면으로 전환
    }
}

extension Reactive where Base: LocationSearchFieldView {
    /// UISearchBar처럼 쓰는 text ControlProperty
    var text: ControlProperty<String?> {
        let source = base.textField.rx.text
        let sink = Binder(base) { view, value in
            view.textField.text = value
        }
        return ControlProperty(values: source, valueSink: sink)
    }

    /// Return(검색) 눌렀을 때
    var returnTap: ControlEvent<Void> {
        base.textField.rx.controlEvent(.editingDidEndOnExit)
    }
}
