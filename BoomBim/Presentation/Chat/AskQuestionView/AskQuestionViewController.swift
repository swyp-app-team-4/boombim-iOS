//
//  AskQuestionViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

final class AskQuestionViewController: BaseViewController {
    private let viewModel: AskQuestionViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    private let currentLocationSubject = PublishSubject<CLLocationCoordinate2D>()
    
    private var results: [SearchItem] = []
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "chat.label.question.label".localized()
        label.font = Typography.Heading01.semiBold.font
        label.textColor = .grayScale10
        label.numberOfLines = 0
        
        return label
    }()
    
    private let locationSearchView = LocationSearchFieldView()

    // TODO: 추후 검토
    //    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.searchBarStyle = .minimal            // 기본 배경 제거
//        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
//        searchBar.isTranslucent = false
//        searchBar.backgroundColor = .grayScale1
//        
//        let textField = searchBar.searchTextField             // <- 진짜 텍스트필드
//        textField.attributedPlaceholder = NSAttributedString(
//            string: "약속된 장소를 검색해보세요.",
//            attributes: [.foregroundColor: UIColor.placeholder]
//        )
//        textField.font = Typography.Body03.medium.font
//        textField.backgroundColor = .grayScale1
//        textField.tintColor = .grayScale7
//        
//        textField.layer.cornerRadius = 10
//        textField.layer.borderWidth = 1
//        textField.layer.borderColor = UIColor.grayScale4.cgColor
//        textField.clipsToBounds = true
//        
//        textField.clearButtonMode = .whileEditing
//        textField.returnKeyType = .search
//        
//        textField.leftView?.tintColor = .grayScale8
//        textField.rightView?.tintColor = .grayScale8
//        
//        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .medium)
//        let base = UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg)!
//
//        // 원하는 색으로 “미리” 칠해서 넣기
//        let normal = base.withTintColor(.grayScale8, renderingMode: .alwaysOriginal)
//        let highlighted = base.withTintColor(.grayScale6, renderingMode: .alwaysOriginal)
//
//        searchBar.setImage(normal,     for: .clear, state: .normal)
//        searchBar.setImage(highlighted, for: .clear, state: .highlighted)
//        
//        return searchBar
//    }()
    
    private lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.grayScale4.cgColor
        button.clipsToBounds = true
        
        let image = UIImage.iconLocation
        button.setImage(image, for: .normal)
        button.tintColor = .grayScale8
        button.imageView?.contentMode = .scaleAspectFit
        
        button.contentEdgeInsets = UIEdgeInsets(top: 11.5, left: 11.5, bottom: 11.5, right: 11.5)
        
        return button
    }()
    
    private let illustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .illustrationAskQuestion
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("chat.button.next".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale7, for: .normal)
        button.backgroundColor = .grayScale4
//        button.setTitleColor(.grayScale1, for: .normal)
//        button.backgroundColor = .main
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    init(viewModel: AskQuestionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindAction()
        
        bindViewModel()
    }
    
    // MARK: Setup UI
    private func setupView() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        configureView()
    }
    
    private func configureNavigationBar() {
        self.title = "질문하기"
        
        let backButton = UIButton(type: .system)
        backButton.setImage(.iconLeftArrow, for: .normal)
        backButton.tintColor = .grayScale9
        backButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureView() {
        [titleLabel, locationSearchView, locationButton, illustrationImageView, tableView, nextButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        tableView.dataSource = self
        
        let middleGuide = UILayoutGuide()
        view.addLayoutGuide(middleGuide)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            locationButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationButton.heightAnchor.constraint(equalToConstant: 44),
            locationButton.widthAnchor.constraint(equalToConstant: 44),
            
            locationSearchView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            locationSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationSearchView.trailingAnchor.constraint(equalTo: locationButton.leadingAnchor, constant: -8),
            locationSearchView.heightAnchor.constraint(equalToConstant: 44),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            middleGuide.topAnchor.constraint(equalTo: locationSearchView.bottomAnchor),
            middleGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            middleGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            middleGuide.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            
            tableView.topAnchor.constraint(equalTo: locationSearchView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            
            illustrationImageView.centerXAnchor.constraint(equalTo: middleGuide.centerXAnchor),
            illustrationImageView.centerYAnchor.constraint(equalTo: middleGuide.centerYAnchor),
            illustrationImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 185),
            illustrationImageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 185)
        ])
    }
    
    // MARK: ViewModel binding
    private func bindViewModel() {
        // 검색 입력
        locationSearchView.rx.text.orEmpty
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        viewModel.results
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.results = items
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 현재 위치 관련
        let input = AskQuestionViewModel.Input(
            currentLocation: currentLocationSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.places
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places in
                guard let firstPlaceName = places.first?.name else { return }
                
                self?.locationSearchView.setText(firstPlaceName)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Bind Action
    private func bindAction() {
//        locationSearchView.onTapSearch = { [weak self] in
////            self?.viewModel.didTapSearch()
//        }
        
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
    }
    
    @objc private func didTapLocation() {
        self.setLocation()
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

// MARK: 현재 위치 권한 설정 및 View Rect 값 확인
extension AskQuestionViewController {
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

extension AskQuestionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = results[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.address
        return cell
    }
}
