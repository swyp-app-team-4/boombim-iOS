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
    
    // 선택된 장소 상태
    private let selectedPlace = BehaviorRelay<Place?>(value: nil)
    
    // MARK: - UI Components (기존 유지)
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconInfo
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
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.separatorStyle = .none
        tv.backgroundColor = .white
        return tv
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
    
    // MARK: - Init
    init(viewModel: SearchPlaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup UI
    private func setupView() {
        view.backgroundColor = .white
        configureNavigationBar()
        configureView()
    }
    
    private func configureNavigationBar() {
        title = "알리기"
        
        let backButton = UIButton(type: .system)
        backButton.setImage(.iconLeftArrow, for: .normal)
        backButton.tintColor = .grayScale9
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureView() {
        [titleImageView, titleLabel, searchTextField, illustrationImageView, tableView, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        
        let middleGuide = UILayoutGuide()
        view.addLayoutGuide(middleGuide)
        
        NSLayoutConstraint.activate([
            titleImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            titleImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleImageView.widthAnchor.constraint(equalToConstant: 24),
            titleImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: titleImageView.trailingAnchor, constant: 1),
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
    
    // MARK: - ViewModel binding (Rx 테이블 바인딩)
    private func bindViewModel() {
        // 1) 입력 스트림: 검색어
        let searchText = searchTextField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .share(replay: 1)
        
        // 2) ViewModel 변환
        let input = SearchPlaceViewModel.Input(
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
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { coord in
                print("내 좌표:", coord)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func setActions() {
        nextButton.rx.tap
            .withLatestFrom(selectedPlace.compactMap { $0 })
            .bind(onNext: { [weak self] place in
                self?.viewModel.didTapNextButton(place: place)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}
