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
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let relaxedButton = makeButton(off: .buttonUnselectedRelaxed, on: .buttonSelectedRelaxed)
    private let normalButton  = makeButton(off: .buttonUnselectedNormal,  on: .buttonSelectedNormal)
    private let busyButton   = makeButton(off: .buttonUnselectedBusy,  on: .buttonSelectedBusy)
    private let crowdedButton = makeButton(off: .buttonUnselectedCrowded,   on: .buttonSelectedCrowded)
    
    private lazy var buttons: [UIButton] = [relaxedButton, normalButton, busyButton, crowdedButton]
    
    private static func makeButton(off: UIImage, on: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(off, for: .normal)
        button.setImage(on,  for: .selected)
        button.setImage(on,  for: [.selected, .highlighted])
        
        return button
    }
    
    init(viewModel: CongestionReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        setupUI()
        
        bindAction()
        setActions()
        
        setLocation()
    }
    
    // MARK: ViewModel binding
    private func bindViewModel() {
        let input = CongestionReportViewModel.Input(
            currentLocation: currentLocationSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.places
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places in
                guard let firstPlaceName = places.first?.name else { return }
                
                
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        
        configureTime()
        configureLocation()
        configureVote()
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
            button.isSelected = true // 처음에 모두가 선택되어 on 된 상태 유지
        }
    }
    
    // MARK: Bind Action
    private func bindAction() {
        
    }
    
    private func setActions() {
        didTapLocation()
    }
    
    private func didTapLocation() {
        locationTextField.onTap = { [weak self] in
            print("화면 이동")
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: 현재 위치 권한 설정 및 View Rect 값 확인
extension CongestionReportViewController {
    private func setLocation() {
        if locationManager.authorization.value == .notDetermined { // 권한 설정이 안된 경우 권한 요청
            locationManager.requestWhenInUseAuthorization()
        }
        
        // 권한 상태 스트림에서 '최종 상태(허용/거부)'만 대기 → 1회 처리
        locationManager.authorization
            .asObservable()
            .startWith(locationManager.authorization.value) // 현재 상태 먼저 흘려보내기
            .distinctUntilChanged()
            .filter { status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways, .denied, .restricted:
                    return true // 최종 상태만 통과
                default:
                    return false // .notDetermined은 대기
                }
            }
            .take(1) // 허용 or 거부 중 첫 결과 한 번만
            .flatMapLatest { [weak self] status -> Observable<CLLocationCoordinate2D> in
                guard let self else { return .empty() }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    return locationManager.requestOneShotLocation(timeout: 5)
                        .asObservable()
                        .map {
                            print("위도 : \($0.coordinate.latitude), 경도 : \($0.coordinate.longitude)")
                            return $0.coordinate
                        }
                case .denied, .restricted:
                    self.showLocationDeniedAlert()
                    return .empty()
                default:
                    return .empty()
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coord in
                print("coord : \(coord)")
                self?.viewModel.setCurrentCoordinate(coord)
                self?.currentLocationSubject.onNext(coord)
            })
            .disposed(by: disposeBag)
    }
    
    /** 위치 접근 안내 Alert */
    private func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "위치 접근이 꺼져 있어요",
            message: "현재 위치를 기반으로 검색하려면 설정 > 앱 > 위치에서 허용해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}
