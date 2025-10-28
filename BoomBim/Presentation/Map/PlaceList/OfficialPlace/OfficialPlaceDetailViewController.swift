//
//  OfficialPlaceDetailViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/1/25.
//

import UIKit
import SwiftUI

import RxSwift
import RxCocoa

enum FavoriteAction {
    case add(RegisterFavoritePlaceRequest)
    case remove(RemoveFavoritePlaceRequest)   // 서버 규격에 맞춰 정의
}

final class OfficialPlaceDetailViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let placeIdRelay    = BehaviorRelay<Int?>(value: nil)
    private let placeTypeRelay  = BehaviorRelay<FavoritePlaceType>(value: .OFFICIAL_PLACE)
    let favoriteState           = BehaviorRelay<Bool>(value: false)    // 현재 선택상태
    let favoriteLoading         = BehaviorRelay<Bool>(value: false)    // 로딩시 버튼잠금
    private let favoriteIdRelay = BehaviorRelay<Int?>(value: nil)      // 삭제가 favoriteId 기준이면 사용
    
    private let favoriteTapRelay = PublishRelay<Void>()
    var favoriteActionRequested: Signal<FavoriteAction> {
        favoriteTapRelay
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance) // 중복탭 방지(옵션)
            .withLatestFrom(Observable.combineLatest(
                favoriteState.asObservable(),
                placeIdRelay.compactMap { $0 },
                placeTypeRelay.asObservable(),
                favoriteIdRelay.asObservable()
            ))
            .map { isFav, placeId, placeType, favoriteId in
                if isFav {
                    // 현재가 '즐겨찾기 중'이면 → 삭제 요청
                    return .remove(RemoveFavoritePlaceRequest(placeType: placeType, placeId: placeId))
                } else {
                    // 현재가 '미즐겨찾기'면 → 추가 요청
                    return .add(RegisterFavoritePlaceRequest(placeType: placeType, placeId: placeId))
                }
            }
            .asSignal(onErrorSignalWith: .empty())
    }
    
    // SwiftUI Chart용 viewModel
    private let chartViewModel = ChartViewModel()
    
    let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let viewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        label.textAlignment = .center
        label.text = "place.detail.label.title".localized()
        
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(.iconUnselectedFavorite, for: .normal)
        button.setImage(.iconSelectedFavorite, for: .selected)
        button.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let congestionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var placeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconEmptyProfile
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let spacingView: UIView = {
        let view = UIView()
        view.backgroundColor = .viewDivider
        
        return view
    }()
    
    private lazy var chartContatiner: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale3.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private var chartHost: UIHostingController<CongestionChartView>?
    
    private lazy var peopleContatiner: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale3.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private let peopleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 18
        
        return stackView
    }()
    
    private let peopleTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body01.semiBold.font
        label.textColor = .grayScale9
        label.text = "place.detail.label.title.people".localized()
        
        return label
    }()
    
    private let peopleGaugeView = PeopleGaugeView()
    private let liveGaugeView = LiveGaugeView()
    
    private lazy var ageContatiner: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale3.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private let ageTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body01.semiBold.font
        label.textColor = .grayScale9
        label.text = "place.detail.label.title.age".localized()
        
        return label
    }()
    
    private let ageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var firstAgeStackView = makeRow()
    private lazy var secondAgeStackView = makeRow()
    
    private func makeRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        return stackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()
    }
    
    private func bind() {
        favoriteButton.rx.tap
            .do(onNext: { print("favoriteButton tap!") })
            .bind(to: favoriteTapRelay)
            .disposed(by: disposeBag)
        
        // 상태 반영
        favoriteState
            .bind(to: favoriteButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        favoriteLoading
            .map { !$0 }
            .bind(to: favoriteButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func setFavoriteSelected(_ selected: Bool) { favoriteState.accept(selected) }
    func setFavoriteLoading(_ loading: Bool)   { favoriteLoading.accept(loading) }
    func setFavoriteId(_ id: Int?)             { favoriteIdRelay.accept(id) }
    
    private func setupView() {
        view.backgroundColor = .background
        
        configureScrollView()
        configureTitle()
        configureText()
        configurePlaceInfo()
        
        configureChart()
        
        configurePeople()
        configureAge()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // contentView는 contentLayoutGuide에 4변 고정
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // 가로 폭 고정: 가로 스크롤 방지 & 오토레이아웃 높이 계산 가능
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func configureTitle() {
        [viewTitleLabel, favoriteButton].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            viewTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            viewTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewTitleLabel.heightAnchor.constraint(equalToConstant: 46),
            
            favoriteButton.centerYAnchor.constraint(equalTo: viewTitleLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func configurePlaceInfo() {
        [textStackView, congestionImageView, placeImageView, spacingView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: viewTitleLabel.bottomAnchor, constant: 16),
            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            congestionImageView.centerYAnchor.constraint(equalTo: textStackView.centerYAnchor),
            congestionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            placeImageView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 14),
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            placeImageView.heightAnchor.constraint(equalToConstant: 105),
            
            spacingView.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: 30),
            spacingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacingView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func configureText() {
        [titleLabel, addressLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            textStackView.addArrangedSubview(label)
        }
    }
    
    private func configureChart() {
        let chartView = CongestionChartView(viewModel: chartViewModel)
        let host = UIHostingController(rootView: chartView)
        host.view.backgroundColor = .grayScale1
        
        self.addChild(host)
        
        host.view.translatesAutoresizingMaskIntoConstraints = false
        chartContatiner.addSubview(host.view)
        
        chartContatiner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chartContatiner)
        
        NSLayoutConstraint.activate([
            chartContatiner.topAnchor.constraint(equalTo: spacingView.bottomAnchor, constant: 16),
            chartContatiner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartContatiner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            host.view.topAnchor.constraint(equalTo: chartContatiner.topAnchor, constant: 20),
            host.view.bottomAnchor.constraint(equalTo: chartContatiner.bottomAnchor, constant: -20),
            host.view.leadingAnchor.constraint(equalTo: chartContatiner.leadingAnchor, constant: 16),
            host.view.trailingAnchor.constraint(equalTo: chartContatiner.trailingAnchor, constant: -16),
        ])
        
        host.didMove(toParent: self)
        chartHost = host
    }
    
    func updateChart(data: [HourPoint]) {
        DispatchQueue.main.async {
            self.chartViewModel.data = data
            self.chartViewModel.selectedHour = 16 // 현재 시간
        }
    }
    
    private func configurePeople() {
        [peopleTitleLabel, peopleGaugeView, liveGaugeView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            peopleStackView.addArrangedSubview(view)
        }
        
        peopleStackView.translatesAutoresizingMaskIntoConstraints = false
        peopleContatiner.addSubview(peopleStackView)
        
        peopleContatiner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(peopleContatiner)
        
        NSLayoutConstraint.activate([
            peopleContatiner.topAnchor.constraint(equalTo: chartContatiner.bottomAnchor, constant: 18),
            peopleContatiner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            peopleContatiner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            peopleStackView.topAnchor.constraint(equalTo: peopleContatiner.topAnchor, constant: 18),
            peopleStackView.bottomAnchor.constraint(equalTo: peopleContatiner.bottomAnchor, constant: -18),
            peopleStackView.leadingAnchor.constraint(equalTo: peopleContatiner.leadingAnchor, constant: 16),
            peopleStackView.trailingAnchor.constraint(equalTo: peopleContatiner.trailingAnchor, constant: -16),
            
            peopleGaugeView.heightAnchor.constraint(equalToConstant: 80),
            liveGaugeView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func configureAge() {
        [firstAgeStackView, secondAgeStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            ageStackView.addArrangedSubview(view)
        }
        
        [ageTitleLabel, ageStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            ageContatiner.addSubview(view)
        }
        
        ageContatiner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageContatiner)
        
        NSLayoutConstraint.activate([
            ageContatiner.topAnchor.constraint(equalTo: peopleContatiner.bottomAnchor, constant: 18),
            ageContatiner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ageContatiner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ageContatiner.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            
            ageTitleLabel.topAnchor.constraint(equalTo: ageContatiner.topAnchor, constant: 18),
            ageTitleLabel.leadingAnchor.constraint(equalTo: ageContatiner.leadingAnchor, constant: 16),
            
            ageStackView.topAnchor.constraint(equalTo: ageTitleLabel.bottomAnchor, constant: 18),
            ageStackView.bottomAnchor.constraint(equalTo: ageContatiner.bottomAnchor, constant: -18),
            ageStackView.leadingAnchor.constraint(equalTo: ageContatiner.leadingAnchor, constant: 16),
            ageStackView.trailingAnchor.constraint(equalTo: ageContatiner.trailingAnchor, constant: -16)
        ])
    }
    
    private func clearAgeStacks() {
        [firstAgeStackView, secondAgeStackView].forEach { stack in
            stack.arrangedSubviews.forEach { v in
                stack.removeArrangedSubview(v) // 스택 관계 제거
                v.removeFromSuperview()        // 실제 뷰 계층에서 제거
            }
        }
    }
    
    private func setAgeStackView(percent: [Double]) {
        clearAgeStacks()
        
        let titles = ["10대 미만", "10대", "20대", "30대", "40대", "50대", "60대", "70대"]
        for (i, title) in titles.enumerated() {
            let tile = AgeTileView()
            tile.configure(percentText: "\(percent[i])%", title: title)
            print("i:\(i), \(title): \(percent[i])%")
            (i < 4 ? firstAgeStackView : secondAgeStackView).addArrangedSubview(tile)
        }
    }
    
    func configure(data: OfficialPlaceDetailInfo) {
        placeIdRelay.accept(data.officialPlaceId)
        placeTypeRelay.accept(.OFFICIAL_PLACE)
        favoriteState.accept(data.isFavorite)
        
        favoriteButton.isSelected = data.isFavorite
        titleLabel.text = data.officialPlaceName
        addressLabel.text = data.legalDong
        congestionImageView.image = CongestionLevel(ko: data.congestionLevelName)?.badge
        placeImageView.setImage(from: data.imageUrl)
        
        let manPercent = data.demographics.filter{ $0.category == DemographicCategory.gender }.filter { $0.subCategory == GenderCategory.MALE.rawValue }.first?.rate ?? 0
        let womanPercent = data.demographics.filter{ $0.category == DemographicCategory.gender }.filter { $0.subCategory == GenderCategory.FEMALE.rawValue }.first?.rate ?? 0
        
        let residePercent = data.demographics.filter{ $0.category == DemographicCategory.residency }.filter { $0.subCategory == ResidencyCategory.RESIDENT.rawValue }.first?.rate ?? 0
        let nonresidePercent = data.demographics.filter{ $0.category == DemographicCategory.residency }.filter { $0.subCategory == ResidencyCategory.NON_RESIDENT.rawValue }.first?.rate ?? 0
        
        let ageRateArray: [Double] = ageRatesArrayOrdered(data: data.demographics)
        
        peopleGaugeView.update(manPercent: manPercent, womanPercent: womanPercent)
        liveGaugeView.update(residePercent: residePercent, nonresidePercent: nonresidePercent)
        
        setAgeStackView(percent: ageRateArray)
        
        let sample: [HourPoint] = [
            .init(hour: 6, level: .relaxed, value: 1),
            .init(hour: 7, level: .relaxed, value: 12),
            .init(hour: 8, level: .crowded, value: 59),
            .init(hour: 9, level: .relaxed, value: 10),
            .init(hour: 10, level: .relaxed, value: 15),
            .init(hour: 11, level: .busy, value: 30),
            .init(hour: 12, level: .crowded, value: 68),
            .init(hour: 13, level: .crowded, value: 74),
            .init(hour: 14, level: .crowded, value: 79),
            .init(hour: 15, level: .busy, value: 36),
            .init(hour: 16, level: .normal, value: 28),
            .init(hour: 17, level: .normal, value: 21),
            .init(hour: 18, level: .normal, value: 20),
            .init(hour: 19, level: .relaxed, value: 10),
            .init(hour: 20, level: .crowded, value: 58),
            .init(hour: 21, level: .crowded, value: 60),
            .init(hour: 22, level: .relaxed, value: 3),
            .init(hour: 23, level: .relaxed, value: 1),
            .init(hour: 24, level: .relaxed, value: 1),
        ]
        
        updateChart(data: sample)
    }
    
    func ageRatesDict(data: [Demographic]) -> [AgeCategory: Double] {
        let ages = data.filter { $0.category == DemographicCategory.ageGroup }
        var map: [AgeCategory: Double] = [:]
        for a in ages {
            if let band = AgeCategory(rawValue: a.subCategory) {
                map[band] = a.rate
            }
        }
        return map
    }
    
    /// AGE_GROUP을 0s~70s 순서 배열(Double)로. 누락은 0.
    func ageRatesArrayOrdered(data: [Demographic]) -> [Double] {
        let map = ageRatesDict(data: data)
        return AgeCategory.allCases.map { map[$0] ?? 0 }
    }
}
