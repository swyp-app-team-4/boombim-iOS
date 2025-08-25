//
//  CongestionReportViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

final class CongestionReportViewController: BaseViewController {
    private let viewModel: CongestionReportViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    private let currentLocationSubject = PublishSubject<CLLocationCoordinate2D>()
    
    // MARK: - UI Components
    private let timeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconTime
        imageView.tintColor = .grayScale9
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let timeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .left
        label.text = "report.label.title.time".localized()
        label.sizeToFit()
        
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .left
        label.text = AppDateFormatter.koChatDateTime.string(from: Date())
        
        return label
    }()
    
    private let locationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconPin
        imageView.tintColor = .grayScale9
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .left
        label.text = "report.label.title.location".localized()
        label.sizeToFit()
        
        return label
    }()
    
    private let locationTextField: AppSearchTextField = {
        let textField = AppSearchTextField()
        textField.tapOnly = true
        
        return textField
    }()
    
    private let voteContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let voteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconVote
        imageView.tintColor = .grayScale9
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let voteTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .left
        label.text = "report.label.title.vote".localized()
        label.sizeToFit()
        
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let relaxedButton = makeButton(off: .buttonLargeUnselectedRelaxed, on: .buttonLargeSelectedRelaxed, disable: .buttonLargeDefaultRelaxed)
    private let normalButton  = makeButton(off: .buttonLargeUnselectedNormal, on: .buttonLargeSelectedNormal, disable: .buttonLargeDefaultNormal)
    private let busyButton   = makeButton(off: .buttonLargeUnselectedBusy, on: .buttonLargeSelectedBusy, disable: .buttonLargeDefaultBusy)
    private let crowdedButton = makeButton(off: .buttonLargeUnselectedCrowded, on: .buttonLargeSelectedCrowded, disable: .buttonLargeDefaultCrowded)
    
    private lazy var buttons: [UIButton] = [relaxedButton, normalButton, busyButton, crowdedButton]
    
    private static func makeButton(off: UIImage, on: UIImage, disable: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(disable, for: .disabled)
        button.setImage(off, for: .normal)
        button.setImage(on,  for: .selected)
        button.setImage(on,  for: [.selected, .highlighted])
        
        return button
    }
    
    private lazy var descriptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale4.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = Typography.Body03.medium.font
        
        return textView
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "report.label.placeholder".localized()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale7
        
        return label
    }()
    
    private let descriptionCount: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale7
        
        return label
    }()
    
    init(viewModel: CongestionReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindAction()
        setActions()
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        
        configureTime()
        configureLocation()
        configureVote()
        configureTextView()
    }
    
    private func configureNavigationBar() {
        self.title = "알리기"
        
        let backButton = UIButton(type: .system)
        backButton.setImage(.iconLeftArrow, for: .normal)
        backButton.tintColor = .grayScale9
        backButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureTime() {
        timeContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeContainerView)
        
        [timeImageView, timeTitleLabel, timeLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            timeContainerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            timeContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeContainerView.heightAnchor.constraint(equalToConstant: 24),
            
            timeImageView.centerYAnchor.constraint(equalTo: timeContainerView.centerYAnchor),
            timeImageView.leadingAnchor.constraint(equalTo: timeContainerView.leadingAnchor),
            timeImageView.widthAnchor.constraint(equalToConstant: 18),
            timeImageView.heightAnchor.constraint(equalToConstant: 18),
            
            timeTitleLabel.topAnchor.constraint(equalTo: timeContainerView.topAnchor),
            timeTitleLabel.bottomAnchor.constraint(equalTo: timeContainerView.bottomAnchor),
            timeTitleLabel.leadingAnchor.constraint(equalTo: timeImageView.trailingAnchor, constant: 4),
            
            timeLabel.topAnchor.constraint(equalTo: timeContainerView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: timeContainerView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: timeTitleLabel.trailingAnchor, constant: 10)
        ])
    }
    
    private func configureLocation() {
        locationContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationContainerView)
        
        [locationImageView, locationTitleLabel, locationTextField].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            locationContainerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            locationContainerView.topAnchor.constraint(equalTo: timeContainerView.bottomAnchor, constant: 18),
            locationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            locationImageView.centerYAnchor.constraint(equalTo: locationTitleLabel.centerYAnchor),
            locationImageView.leadingAnchor.constraint(equalTo: locationContainerView.leadingAnchor),
            locationImageView.widthAnchor.constraint(equalToConstant: 18),
            locationImageView.heightAnchor.constraint(equalToConstant: 18),
            
            locationTitleLabel.topAnchor.constraint(equalTo: locationContainerView.topAnchor),
            locationTitleLabel.leadingAnchor.constraint(equalTo: timeImageView.trailingAnchor, constant: 4),
            
            locationTextField.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 10),
            locationTextField.bottomAnchor.constraint(equalTo: locationContainerView.bottomAnchor),
            locationTextField.leadingAnchor.constraint(equalTo: locationContainerView.leadingAnchor),
            locationTextField.trailingAnchor.constraint(equalTo: locationContainerView.trailingAnchor),
        ])
    }
    
    private func configureVote() {
        voteContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voteContainerView)
        
        buttons.forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
        
        [voteImageView, voteTitleLabel, buttonStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            voteContainerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            voteContainerView.topAnchor.constraint(equalTo: locationContainerView.bottomAnchor, constant: 18),
            voteContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            voteContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            voteContainerView.heightAnchor.constraint(equalToConstant: 128),
            
            voteImageView.centerYAnchor.constraint(equalTo: voteTitleLabel.centerYAnchor),
            voteImageView.leadingAnchor.constraint(equalTo: voteContainerView.leadingAnchor),
            voteImageView.widthAnchor.constraint(equalToConstant: 18),
            voteImageView.heightAnchor.constraint(equalToConstant: 18),
            
            voteTitleLabel.topAnchor.constraint(equalTo: voteContainerView.topAnchor),
            voteTitleLabel.leadingAnchor.constraint(equalTo: voteImageView.trailingAnchor, constant: 4),
            
            buttonStackView.topAnchor.constraint(equalTo: voteTitleLabel.bottomAnchor, constant: 10),
            buttonStackView.bottomAnchor.constraint(equalTo: voteContainerView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: voteContainerView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: voteContainerView.trailingAnchor),
        ])
        
        buttonSetting()
    }
    
    private func buttonSetting() {
        buttons.forEach { button in
            button.isEnabled = false
        }
    }
    
    private func configureTextView() {
        descriptionContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionContainerView)
        
        [descriptionTextView, descriptionPlaceholder, descriptionCount].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            descriptionContainerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            descriptionContainerView.topAnchor.constraint(equalTo: voteContainerView.bottomAnchor, constant: 18),
            descriptionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionContainerView.heightAnchor.constraint(equalToConstant: 165),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 12),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionCount.topAnchor, constant: 4),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -16),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 12),
            descriptionPlaceholder.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            
            descriptionCount.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: -12),
            descriptionCount.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -16),
        ])
        
        descriptionTextView.delegate = self
    }
    
    // MARK: Bind Action
    private func bindAction() {
        
    }
    
    private func setActions() {
        didTapLocation()
    }
    
    private func didTapLocation() {
        locationTextField.onTap = { [weak self] in
            self?.viewModel.didTapSearch()
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

extension CongestionReportViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
        updateCounter()
    }
    
    private func updateCounter() {
        descriptionCount.text = "\(descriptionTextView.text.count)/\(500)자"
    }
}
