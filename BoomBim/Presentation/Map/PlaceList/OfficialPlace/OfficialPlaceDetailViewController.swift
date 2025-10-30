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
        button.imageView?.contentMode = .center
        
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
        label.font = Typography.Body01.semiBold.font
        label.textColor = .grayScale10
        
        return label
    }()
    
    private let subTitleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 4
        
        return stackView
    }()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .iconRecycleTime.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .grayScale9
        
        return imageView
    }()
    
    private let updateLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale9
        
        return label
    }()
    
    private let bulletImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = .iconBullet
        
        return imageView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Caption.regular.font
        label.textColor = .grayScale8
        
        return label
    }()
    
    private let subTitleSpacerView: UIView = {
        let view = UIView()
        
        return view
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
    
    private lazy var estimatedPeopleContatiner: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale1
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale3.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private let estimatedPeopleStackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 18
        return s
    }()
    
    // UI
    private let estimatedPeopleTitleLabel: UILabel = {
        let label = UILabel()
        label.setText("추정 인구수", style: Typography.Body01.semiBold)
        label.textColor = .grayScale9
        
        return label
    }()
    
    private let grayPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayPanel
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let minMaxStackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fill
        s.spacing = 8
        
        return s
    }()
    
    // 행(왼쪽 라벨/오른쪽 값) 공통
    private static func makeRow() -> UIStackView {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.distribution = .fill
        
        return s
    }
    
    private let maxRow = makeRow()
    private let minRow = makeRow()
    
    private let maxTitleLabel: UILabel = {
        let label = UILabel()
        label.setText("실시간 최대", style: Typography.Body03.regular)
        label.textColor = .grayScale9
        label.textAlignment = .left
        
        return label
    }()
    
    private let minTitleLabel: UILabel = {
        let label = UILabel()
        label.setText("실시간 최소", style: Typography.Body03.regular)
        label.textColor = .grayScale9
        label.textAlignment = .left
        
        return label
    }()
    
    private let maxValueLabel: UILabel = {
        let l = UILabel()
        l.font = Typography.Body01.medium.font
        l.textColor = .grayScale9
        l.textAlignment = .right
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return l
    }()
    
    private let minValueLabel: UILabel = {
        let l = UILabel()
        l.font = Typography.Body01.medium.font
        l.textColor = .grayScale9
        l.textAlignment = .right
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return l
    }()
    
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
        configureEstimatedPeople()
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
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 34),
            favoriteButton.heightAnchor.constraint(equalToConstant: 34),
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
        [timeImageView, updateLabel, bulletImageView, addressLabel, subTitleSpacerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            subTitleStackView.addArrangedSubview($0)
        }
        
        subTitleStackView.setCustomSpacing(7, after: timeImageView)
        
        [titleLabel, subTitleStackView].forEach { label in
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
        }
    }
    
    private func configureEstimatedPeople() {
        [maxTitleLabel, maxValueLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            maxRow.addArrangedSubview(label)
        }
        
        [minTitleLabel, minValueLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            minRow.addArrangedSubview(label)
        }
        
        [maxRow, minRow].forEach { stackView in
            stackView.translatesAutoresizingMaskIntoConstraints = false
            minMaxStackView.addArrangedSubview(stackView)
        }
        
        minMaxStackView.translatesAutoresizingMaskIntoConstraints = false
        grayPanelView.addSubview(minMaxStackView)
        
        [estimatedPeopleTitleLabel, grayPanelView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            estimatedPeopleStackView.addArrangedSubview($0)
        }
        
        estimatedPeopleStackView.translatesAutoresizingMaskIntoConstraints = false
        estimatedPeopleContatiner.addSubview(estimatedPeopleStackView)
        
        estimatedPeopleContatiner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(estimatedPeopleContatiner)
        
        NSLayoutConstraint.activate([
            estimatedPeopleContatiner.topAnchor.constraint(equalTo: chartContatiner.bottomAnchor, constant: 18),
            estimatedPeopleContatiner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            estimatedPeopleContatiner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            estimatedPeopleStackView.topAnchor.constraint(equalTo: estimatedPeopleContatiner.topAnchor, constant: 18),
            estimatedPeopleStackView.bottomAnchor.constraint(equalTo: estimatedPeopleContatiner.bottomAnchor, constant: -18),
            estimatedPeopleStackView.leadingAnchor.constraint(equalTo: estimatedPeopleContatiner.leadingAnchor, constant: 16),
            estimatedPeopleStackView.trailingAnchor.constraint(equalTo: estimatedPeopleContatiner.trailingAnchor, constant: -16),
            
            minMaxStackView.topAnchor.constraint(equalTo: grayPanelView.topAnchor, constant: 12),
            minMaxStackView.bottomAnchor.constraint(equalTo: grayPanelView.bottomAnchor, constant: -12),
            minMaxStackView.leadingAnchor.constraint(equalTo: grayPanelView.leadingAnchor, constant: 14),
            minMaxStackView.trailingAnchor.constraint(equalTo: grayPanelView.trailingAnchor, constant: -14),
        ])
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
            peopleContatiner.topAnchor.constraint(equalTo: estimatedPeopleContatiner.bottomAnchor, constant: 18),
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
        titleLabel.setText(data.officialPlaceName, style: Typography.Body01.semiBold)
        
        let updateText = DateHelper.displayString(from: data.observedAt)
        updateLabel.setText(updateText, style: Typography.Caption.regular)
        addressLabel.setText(data.legalDong, style: Typography.Caption.regular)
        
        congestionImageView.image = CongestionLevel(ko: data.congestionLevelName)?.badge
        placeImageView.setImage(from: data.imageUrl)
        
        let forecasts: [HourPoint] = data.forecasts.compactMap { f in
            guard let hour  = DateHelper.getHour(from: f.forecastTime),
                  let level = CongestionLevel(ko: f.congestionLevelName) else {
                return nil              // 이 항목만 제외
            }
            return HourPoint(hour: hour, level: level)
        }

        updateChart(data: forecasts)
        
        let currentForecast = data.forecasts.first
        let maxPeople: String = currentForecast?.forecastPopulationMax.asPeopleString() ?? "0명"
        let minPeople: String = currentForecast?.forecastPopulationMin.asPeopleString() ?? "0명"
        
        maxValueLabel.setText(maxPeople, style: Typography.Body01.medium)
        minValueLabel.setText(minPeople, style: Typography.Body01.medium)
        
        let manPercent = data.demographics.filter{ $0.category == DemographicCategory.gender }.filter { $0.subCategory == GenderCategory.MALE.rawValue }.first?.rate ?? 0
        let womanPercent = data.demographics.filter{ $0.category == DemographicCategory.gender }.filter { $0.subCategory == GenderCategory.FEMALE.rawValue }.first?.rate ?? 0
        
        let residePercent = data.demographics.filter{ $0.category == DemographicCategory.residency }.filter { $0.subCategory == ResidencyCategory.RESIDENT.rawValue }.first?.rate ?? 0
        let nonresidePercent = data.demographics.filter{ $0.category == DemographicCategory.residency }.filter { $0.subCategory == ResidencyCategory.NON_RESIDENT.rawValue }.first?.rate ?? 0
        
        let ageRateArray: [Double] = ageRatesArrayOrdered(data: data.demographics)
        
        peopleGaugeView.update(manPercent: manPercent, womanPercent: womanPercent)
        liveGaugeView.update(residePercent: residePercent, nonresidePercent: nonresidePercent)
        
        setAgeStackView(percent: ageRateArray)
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
