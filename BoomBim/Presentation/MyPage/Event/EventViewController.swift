//
//  EventViewController.swift
//  BoomBim
//
//  Created by 조영현 on 11/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class EventViewController: BaseViewController {
    private let viewModel: EventViewModel
    private let disposeBag = DisposeBag()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        imageView.isUserInteractionEnabled = true
        
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
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private let eventInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 18, left: 8, bottom: 18, right: 8)
        stackView.spacing = 8
        
        stackView.backgroundColor = .background
        stackView.layer.cornerRadius = 14
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.eventSroke.cgColor
        stackView.layer.masksToBounds = true
        
        return stackView
    }()
    
    private let ticketStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.setText("획득한 응모권", style: Typography.Body03.medium)
        label.textColor = .grayScale9
        
        return label
    }()
    
    private let ticketValueLabel: UILabel = {
        let label = UILabel()
        label.setText("0 장", style: Typography.Body02.semiBold)
        label.textColor = .grayScale9
        
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .eventDivider
        
        return view
    }()
    
    private let pointStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 5
        
        return stackView
    }()
    
    private let pointTitleLabel: UILabel = {
        let label = UILabel()
        label.setText("현재 포인트", style: Typography.Body03.medium)
        label.textColor = .grayScale9
        
        return label
    }()
    
    private let pointValueLabel: UILabel = {
        let label = UILabel()
        label.setText("0 point", style: Typography.Body02.semiBold)
        label.textColor = .grayScale9
        
        return label
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
        bind()
        setActions()
    }
    
    private func setupView() {
        view.backgroundColor = .background
     
        configureScrollView()
        configureButton()
        configureEventInfoStackView()
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
    
    private func configureButton() {
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        giftImageView.addSubview(purchaseButton)
        
        noticeButton.translatesAutoresizingMaskIntoConstraints = false
        partImageView.addSubview(noticeButton)
        
        NSLayoutConstraint.activate([
            purchaseButton.centerXAnchor.constraint(equalTo: giftImageView.centerXAnchor),
            purchaseButton.bottomAnchor.constraint(equalTo: giftImageView.bottomAnchor, constant: -52),
            
            noticeButton.centerXAnchor.constraint(equalTo: partImageView.centerXAnchor),
            noticeButton.bottomAnchor.constraint(equalTo: partImageView.bottomAnchor, constant: -52)
        ])
    }
    
    private func configureEventInfoStackView(){
        [ticketTitleLabel, ticketValueLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            ticketStackView.addArrangedSubview(label)
        }
        
        [pointTitleLabel, pointValueLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            pointStackView.addArrangedSubview(label)
        }
        
        [ticketStackView, dividerView, pointStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            eventInfoStackView.addArrangedSubview(view)
        }
        
        eventInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        partImageView.addSubview(eventInfoStackView)
        
        NSLayoutConstraint.activate([
            eventInfoStackView.centerXAnchor.constraint(equalTo: partImageView.centerXAnchor),
            eventInfoStackView.bottomAnchor.constraint(equalTo: noticeButton.topAnchor, constant: -16),
            eventInfoStackView.leadingAnchor.constraint(equalTo: partImageView.leadingAnchor, constant: 16),
            eventInfoStackView.trailingAnchor.constraint(equalTo: partImageView.trailingAnchor, constant: -16),
            
            dividerView.heightAnchor.constraint(equalToConstant: 40),
            dividerView.widthAnchor.constraint(equalToConstant: 1)
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
    
    private func setEventInfo(ticket: Int, point: Int) {
        ticketValueLabel.setText("\(ticket) 장", style: Typography.Body02.semiBold)
        pointValueLabel.setText("\(point) point", style: Typography.Body02.semiBold)
    }
    
    // MARK: - bind
    private func bind() {
        let appear = rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .asSignal(onErrorSignalWith: .empty())
        
        let input = EventViewModel.Input(
            appear: appear,
            purchaseTap: purchaseButton.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .emit(onNext: { [weak self] msg in
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)
        
        output.event
            .drive(onNext: { [weak self] p in
                guard let self else { return }
                
                print("p : \(p)")
                setEventInfo(ticket: p.currentTicket, point: p.memberPoint)
            })
            .disposed(by: disposeBag)
        
        output.completed
            .emit(with: self) { vc, ticketCount in
                print("응모 완료")
                AppDialogController.showOK(
                    on: self,
                    title: "\(ticketCount)번째 응모권 구매 완료",
                    message: "응모권이 많을 수록 당첨에 유리해요",
                    onOK: {
                        self.dismiss(animated: true)
                    })
            }
            .disposed(by: disposeBag)
        
        output.purchaseFail
            .emit(with: self) { vc, code in
                print("응모 실패 : \(code)")
                
                if code == -1003 {
                    AppDialogController.showOK(
                        on: self,
                        title: "포인트가 부족해요",
                        message: "혼잡도를 알리고 포인트를 모아보세요",
                        okTitle: "혼잡도 알리고 10p 받기",
                        onOK: {
                            self.dismiss(animated: true)
                        })
                } else {
                    AppDialogController.showOK(
                        on: self,
                        title: "내일 다시 도전해 보세요!",
                        message: "하루에 최대 5개의 응모권을 구매할 수 있어요",
                        onOK: {
                            self.dismiss(animated: true)
                        })
                }
            }
    }
    
    // MARK: - Actions
    private func setActions() {
        noticeButton.addTarget(self, action: #selector(didTapNoticeButton), for: .touchUpInside)
    }
    
    @objc private func didTapNoticeButton() {
        print("didTapNoticeButton")
        viewModel.goToCongestionReportView?()
    }
}
