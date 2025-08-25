//
//  SearchPlaceViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/26/25.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

final class SearchPlaceViewController: BaseViewController {
    private let viewModel: SearchPlaceViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    private let currentLocationSubject = PublishSubject<CLLocationCoordinate2D>()
    
    private var places: [Place] = []
    private var selectedPlace: Place?
    
    // MARK: - UI Components
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconTime
        imageView.tintColor = .grayScale9
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "report.label.title.info".localized()
        label.font = Typography.Body03.medium.font
        label.textColor = .main
        label.numberOfLines = 1
        
        return label
    }()
    
    private let searchTextField = AppSearchTextField()
    
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
//        button.setTitleColor(.grayScale1, for: .normal)
//        button.backgroundColor = .main
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        return button
    }()
    
    init(viewModel: SearchPlaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocation()
        
        setupView()
        
        bindViewModel()
        
        bindAction()
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
        self.title = "알리기"
        
        let backButton = UIButton(type: .system)
        backButton.setImage(.iconLeftArrow, for: .normal)
        backButton.tintColor = .grayScale9
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureView() {
        [titleLabel, searchTextField, illustrationImageView, tableView, nextButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNonzeroMagnitude))
        
        let middleGuide = UILayoutGuide()
        view.addLayoutGuide(middleGuide)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
        let textInput = searchTextField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .share(replay: 1)

        textInput.bind(to: viewModel.query).disposed(by: disposeBag)

        textInput
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak tableView] hidden in
                guard let tableView = tableView else { return }
                UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve) {
                    tableView.isHidden = hidden
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.results
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.places = items
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 현재 위치 관련
        let input = SearchPlaceViewModel.Input(
            currentLocation: currentLocationSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.places
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places in
                guard let firstPlace = places.first else { return }
                
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Bind Action
    private func bindAction() {
        viewModel.bindSearch()
    }
    
    private func setActions() {
        nextButton.addTarget(self, action:  #selector(didTapNextButton), for: .touchUpInside)
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapNextButton() {
        guard let selectedPlace = selectedPlace else { return }
        print("selected Place : \(selectedPlace)")
        
        self.viewModel.didTapNextButton(place: selectedPlace)
    }
}

// MARK: 현재 위치 권한 설정 및 View Rect 값 확인
extension SearchPlaceViewController {
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

extension SearchPlaceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let place = places[index].name
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceTableViewCell.identifier, for: indexPath) as! PlaceTableViewCell
        
        cell.configure(title: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        searchTextField.text = places[index].name
        self.selectedPlace = places[index]
        
        nextButton.isEnabled = true
        nextButton.setTitleColor(.grayScale1, for: .normal)
        nextButton.backgroundColor = .main
    }
}
