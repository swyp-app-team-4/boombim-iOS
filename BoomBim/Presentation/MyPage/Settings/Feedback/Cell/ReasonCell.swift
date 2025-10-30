//
//  ReasonCell.swift
//  BoomBim
//
//  Created by 조영현 on 9/14/25.
//

import UIKit

final class ReasonCell: UITableViewCell {
    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 6
        return v
    }()

    private let checkView = UIImageView()
    private let titleLabel = UILabel()

    private let textView: UITextView = {
        let v = UITextView()
        v.font = Typography.Body03.regular.font
        v.textColor = .grayScale9
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.grayScale4.cgColor
        v.backgroundColor = .grayScale1
        v.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        v.isScrollEnabled = false                        // 셀프사이징 안정화
        return v
    }()

    private let placeholder: UILabel = {
        let l = UILabel()
        l.font = Typography.Body03.regular.font          // 기존 유지
        l.textColor = .grayScale7
        l.text = "자유롭게 작성해주세요."
        return l
    }()

    private var onChange: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .background

        checkView.contentMode = .scaleAspectFit
        checkView.tintColor = .main

        titleLabel.font = Typography.Body02.regular.font // 기존 유지
        titleLabel.textColor = .grayScale10

        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholder)

        let top = UIStackView(arrangedSubviews: [checkView, titleLabel])
        top.axis = .horizontal
        top.spacing = 12
        top.alignment = .center
        top.distribution = .fill
        top.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(top)
        stackView.addArrangedSubview(textView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            checkView.widthAnchor.constraint(equalToConstant: 34),   // 기존 유지
            checkView.heightAnchor.constraint(equalToConstant: 34),

            // TextView 기본 높이 (표시될 때)
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),

            placeholder.topAnchor.constraint(equalTo: textView.topAnchor, constant: 16),
            placeholder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 20),

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 58)
        ])

        selectionStyle = .none
        // 최초엔 숨김
        textView.isHidden = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.isHidden = true
        textView.text = nil
        placeholder.isHidden = false
        onChange = nil
    }

    func configure(title: String,
                   checked: Bool,
                   showTextView: Bool,
                   initialText: String?,
                   onChange: ((String) -> Void)?) {
        titleLabel.text = title
        checkView.image = checked ? .buttonChecked : .buttonUnchecked

        textView.isHidden = !showTextView
        textView.text = initialText ?? ""
        placeholder.isHidden = !(initialText ?? "").isEmpty
        self.onChange = onChange
    }

    func beginEditing() { textView.becomeFirstResponder() }
}

extension ReasonCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
        onChange?(textView.text)
    }
}
