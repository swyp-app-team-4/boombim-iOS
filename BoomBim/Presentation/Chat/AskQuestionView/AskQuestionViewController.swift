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
    
//    private let currentLocationSubject = PublishSubject<CLLocationCoordinate2D>()
    
    private var places: [Place] = []
    private let selectedPlace = BehaviorRelay<Place?>(value: nil)
    private let userLocation = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "chat.label.question.label".localized()
        label.font = Typography.Heading01.semiBold.font
        label.textColor = .grayScale10
        label.numberOfLines = 0
        
        return label
    }()
    
//    private let locationSearchView = LocationSearchFieldView()
    private let searchTextField = AppSearchTextField()
    
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
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("chat.button.next".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale7, for: .normal)
        button.backgroundColor = .grayScale4
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
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
        
//        setLocation()
        
        setupView()
        
        bindViewModel()
        
//        bindAction()
        setActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        [titleLabel, /*locationSearchView*/searchTextField, locationButton, illustrationImageView, tableView, nextButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNonzeroMagnitude))
        
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
            
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: locationButton.leadingAnchor, constant: -8),
            searchTextField.heightAnchor.constraint(equalToConstant: 44),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            middleGuide.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            middleGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            middleGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            middleGuide.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            
            illustrationImageView.centerXAnchor.constraint(equalTo: middleGuide.centerXAnchor),
            illustrationImageView.centerYAnchor.constraint(equalTo: middleGuide.centerYAnchor),
            illustrationImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 185),
            illustrationImageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 185)
        ])
    }
    
    // MARK: ViewModel binding
    private func bindViewModel() {
        let searchText = searchTextField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .share(replay: 1)
        
        // 2) ViewModel 변환
        let input = AskQuestionViewModel.Input(
            searchText: searchText
        )
        
        let output = viewModel.transform(input: input)
        
        // 3) 결과 리스트 → 테이블 바인딩
        output.results
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: PlaceTableViewCell.identifier,
                cellType: PlaceTableViewCell.self
            )) { _, place, cell in
                cell.configure(title: place.name) // 여러분의 셀 API에 맞게 조정
            }
            .disposed(by: disposeBag)
        
        // 4) 셀 선택 처리 (선택 상태/버튼 상태)
        tableView.rx.modelSelected(Place.self)
            .bind(to: selectedPlace)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        let selection = selectedPlace
            .map { (enabled: $0 != nil, name: $0?.name) }
            .share(replay: 1)
        
        selection
            .map(\.name)                     // String?
            .distinctUntilChanged { $0 == $1 }
            .observe(on: MainScheduler.instance)
            .bind(to: searchTextField.rx.text)
            .disposed(by: disposeBag)
        
        selection
            .map(\.enabled)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] enabled in
                guard let self else { return }
                self.nextButton.isEnabled = enabled
                self.nextButton.setTitleColor(enabled ? .grayScale1 : .grayScale7, for: .normal)
                self.nextButton.backgroundColor = enabled ? .main : .grayScale4
            })
            .disposed(by: disposeBag)
        
        let isQueryEmpty = searchText.map { $0.isEmpty }.distinctUntilChanged()
        let hasResults   = output.results.map { !$0.isEmpty }.distinctUntilChanged()
        
        isQueryEmpty
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isQueryEmpty, hasResults)
            .map { queryEmpty, hasResults in !(queryEmpty || !hasResults) == false ? true : false }
            .map { isHidden -> Bool in isHidden } // 그대로 사용
            .withLatestFrom(Observable.combineLatest(isQueryEmpty, hasResults)) { _, pair in
                let (queryEmpty, hasResults) = pair
                let illustrationVisible = queryEmpty || !hasResults
                return !illustrationVisible
            }
            .bind(to: illustrationImageView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 6) (옵션) 내 좌표 로그/배지 등
        output.myCoordinate
            .compactMap { $0 }
            .subscribe(onNext: { coord in
                print("내 좌표:", coord)
                self.userLocation.accept(coord)
            })
            .disposed(by: disposeBag)

        output.places
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places in
                guard let firstPlace = places.first else { return }
            })
            .disposed(by: disposeBag)
    }
    
    private func setActions() {
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
//        nextButton.addTarget(self, action:  #selector(didTapNextButton), for: .touchUpInside)
        
        let placeAndLocation = Observable.combineLatest(
            selectedPlace.compactMap { $0 },                 // Place
            userLocation.compactMap { $0 }                   // CLLocationCoordinate2D
        )
        
        nextButton.rx.tap
            .withLatestFrom(placeAndLocation)
            .bind(onNext: { [weak self] place, userLocation in
                self?.viewModel.didTapNextButton(place: place, userLocation: userLocation)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func didTapLocation() {
//        self.setLocation()
        print("didTapLocation")
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}
