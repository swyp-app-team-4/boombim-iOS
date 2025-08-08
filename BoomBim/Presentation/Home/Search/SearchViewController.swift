//
//  SearchViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/7/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    private let viewModel: SearchViewModel
    weak var coordinator: SearchCoordinator?
    
    private let disposeBag = DisposeBag()

    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    private var results: [SearchItem] = []

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "검색"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.bindSearch()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        searchBar.placeholder = "검색어를 입력하세요"
        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
    }
    
    private func bindViewModel() {
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)

        viewModel.results
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                self?.results = items
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
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
