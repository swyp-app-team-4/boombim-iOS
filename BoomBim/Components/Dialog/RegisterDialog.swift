//
//  RegisterDialog.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import UIKit

final class RegisterDialogController: UIViewController {
    private let nickname: String
    init(nickname: String) {
        self.nickname = nickname
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder: NSCoder) { fatalError() }

    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return v
    }()
    private let card = UIView()
    private let titleLabel = UILabel()
    private let imageView = UIImageView(image: UIImage(named: "celebration")) // 폭죽 이미지
    private let okButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dimView)
        dimView.frame = view.bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        card.backgroundColor = .white
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = Typography.Body01.medium.font
        titleLabel.textColor = .grayScale7
        titleLabel.text = "\(nickname)의\n혼잡도 질문이 올라갔어요!"

        imageView.image = .illustrationCongratulation
        imageView.contentMode = .scaleAspectFit

        okButton.setTitle("확인", for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.backgroundColor = UIColor.systemOrange
        okButton.layer.cornerRadius = 12
        okButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, imageView, okButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -30),

            imageView.heightAnchor.constraint(equalToConstant: 114),
            okButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func dismissSelf() { dismiss(animated: true) }
}
