//
//  SearchViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()

//    private let searchBar = UISearchBar()
//    private let tableView = UITableView()
    private let selectedPlace = BehaviorRelay<Place?>(value: nil)
    
    private var results: [SearchItem] = []
    
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

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViewModel()
    }
    
    private func setupView() {
        view.backgroundColor = .background
        configureNavigationBar()
        configureView()
    }
    
    private func configureNavigationBar() {
        title = "검색"
        
        let backButton = UIButton(type: .system)
        backButton.setImage(.iconLeftArrow, for: .normal)
        backButton.tintColor = .grayScale9
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureView() {
        [searchTextField, illustrationImageView, tableView, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: PlaceTableViewCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        
        let middleGuide = UILayoutGuide()
        view.addLayoutGuide(middleGuide)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
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
    
    private func bindViewModel() {
        // 1) 입력 스트림: 검색어
        let searchText = searchTextField.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .share(replay: 1)
        
        // 2) ViewModel 변환
        let input = SearchViewModel.Input(
            searchText: searchText
        )
        let output = viewModel.transform(input: input)
        
        // 3) 결과 리스트 → 테이블 바인딩
        output.results
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: PlaceTableViewCell.identifier, cellType: PlaceTableViewCell.self)) { _, place, cell in
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
        
        // 5) 빈화면/리스트 표시 토글
        // - 검색어가 비어있으면 테이블 숨김, 일러스트 표시
        // - 검색어가 있고 결과가 비어있으면 일러스트 표시, 결과가 있으면 숨김
        let isQueryEmpty = searchText.map { $0.isEmpty }.distinctUntilChanged()
        let hasResults   = output.results.map { !$0.isEmpty }.distinctUntilChanged()
        
        isQueryEmpty
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isQueryEmpty, hasResults)
            .map { queryEmpty, hasResults in !(queryEmpty || !hasResults) == false ? true : false }
        // 위 식은 가독성이 떨어지니 아래로 해석하면:
        // illustrationVisible = queryEmpty || !hasResults
        // -> isHidden = !illustrationVisible
            .map { isHidden -> Bool in isHidden } // 그대로 사용
            .withLatestFrom(Observable.combineLatest(isQueryEmpty, hasResults)) { _, pair in
                let (queryEmpty, hasResults) = pair
                let illustrationVisible = queryEmpty || !hasResults
                return !illustrationVisible
            }
            .bind(to: illustrationImageView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController: UITableViewDataSource {
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
