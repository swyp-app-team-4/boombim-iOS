//
//  EventViewController.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import UIKit

final class EventViewController: BaseViewController {
    private let viewModel: EventViewModel
    
    private let scrollView = UIScrollView()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .eventHeader202511
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        
        return imageView
    }()
    
    private let giftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .eventGift202511
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        
        return imageView
    }()
    
    private let purchaseButton: UIButton = {
        let button = UIButton()
        button.setImage(.eventButtonPurchase, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let partImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .eventPart202511
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        
        return imageView
    }()
    
    private let noticeButton: UIButton = {
        let button = UIButton()
        button.setImage(.eventButtonNotice, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let cautionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .eventCaution202511
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        
        return imageView
    }()
    
    init(viewModel: EventViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.title = "이벤트"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .background
     
        configureScrollView()
        configureStackView()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureStackView() {
        [headerImageView, giftImageView, partImageView, cautionImageView].forEach { imageView in
            imageView.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(imageView)
            
            addAspectRatioConstraint(imageView)
            imageView.setContentCompressionResistancePriority(.required, for: .vertical)
            imageView.setContentHuggingPriority(.required, for: .vertical)
        }
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor), // navigation Bar height
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // 가로를 화면 폭에 고정
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func addAspectRatioConstraint(_ imageView: UIImageView) {
        guard let img = imageView.image, img.size.width > 0 else { return }
        let multiplier = img.size.height / img.size.width
        imageView.heightAnchor.constraint(
            equalTo: imageView.widthAnchor,
            multiplier: multiplier
        ).isActive = true
    }
}
