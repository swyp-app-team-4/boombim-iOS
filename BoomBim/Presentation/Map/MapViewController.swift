//
//  MapViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import UIKit
import KakaoMapsSDK
import CoreLocation
import RxSwift
import RxCocoa
import FloatingPanel

final class MapViewController: BaseViewController, FloatingPanelControllerDelegate {

    // MARK: - DI
    private let viewModel: MapViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Kakao Map
    private var mapContainer: KMViewContainer!
    private var mapController: KMController!
    private var kakaoMap: KakaoMap!
    private var overlay: MapOverlayManager!
    
    private let mapReady = PublishRelay<Void>()
    private let modeRelay = BehaviorRelay<OverlayGroup>(value: .realtime)
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Rx (카메라 이벤트 파이프)
    private let cameraRectSubject = PublishSubject<ViewportRect>()
    private let zoomLevelSubject  = PublishSubject<Int>()
    
    // id ↔︎ Place 매핑(POI 탭 시 detail로 전환하기 위해
    private var placeIndex: [String: UserPlaceItem] = [:]
    // VC 내 프로퍼티 (공식 장소 인덱스)
    private var officialIndex: [String: OfficialPlaceItem] = [:]
    
    // 1) POI 탭 이벤트를 담을 Relay
    private let userPoiTapRelay = PublishRelay<Int>()
    private let officialPoiTapRelay = PublishRelay<Int>()

    // MARK: - UI
    private lazy var floatingPanel: FloatingPanelController = {
        let f = FloatingPanelController()
        f.surfaceView.grabberHandle.isHidden = false
        f.isRemovalInteractionEnabled = false
        f.delegate = self
        return f
    }()
    
    private weak var trackedScrollView: UIScrollView? // floating Panel 내부 scrollView
    
    private var officialPlaceListViewController: OfficialPlaceListViewController?
    private var officialPlaceDetailViewController: OfficialPlaceDetailViewController?
    
    private var userPlaceDetailViewController: UserPlaceDetailViewController?
    private var userPlaceListViewController: UserPlaceListViewController?
    
    private let searchTextField: AppSearchTextField = {
        let textField = AppSearchTextField()
        textField.tapOnly = true
        return textField
    }()

    private let buttonsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(.buttonUnselectedFavorite, for: .normal)
        button.setImage(.buttonSelectedFavorite,  for: .selected)
        return button
    }()

    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayScale6
        return view
    }()

    private lazy var publicButton: UIButton = {
        let button = UIButton()
        button.setTitle("map.button.public".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body03.regular.font
        button.setTitleColor(.grayScale8, for: .normal)
        button.setTitleColor(.grayScale9, for: .selected)
        button.backgroundColor = .grayScale1
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.grayScale6.cgColor
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        return button
    }()

    private lazy var realtimeButton: UIButton = {
        let button = UIButton()
        button.setTitle("map.button.realtime".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body03.regular.font
        button.setTitleColor(.grayScale8, for: .normal)
        button.setTitleColor(.grayScale9, for: .selected)
        button.backgroundColor = .grayScale1
        button.layer.cornerRadius = 17
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.grayScale6.cgColor
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        return button
    }()

    private let currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(.buttonCurrentLocation, for: .normal)
        return button
    }()

    private let zoomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let zoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(.buttonZoomIn, for: .normal)
        return button
    }()

    private let zoomOutButton: UIButton = {
        let button = UIButton()
        button.setImage(.buttonZoomOut, for: .normal)
        return button
    }()

    // MARK: - Init
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureIndicator()
        setupMapContainer()
        setupBottomSheet()
        
        buildUI()
        
        setupMapEngine()
        
        bindUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapController?.activateEngine()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 오토레이아웃으로 배치하므로 별도 프레임 조정 불필요
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapController?.pauseEngine()
    }

    // MARK: - Build UI
    private func setupBottomSheet() {
        // 탭바 위까지만 보이도록 레이아웃
        let tabBarH = tabBarController?.tabBar.frame.height ?? 49
        floatingPanel.layout = AboveTabBarLayout(tabBarHeight: tabBarH)
        
        // 첫 컨텐트는 비워두거나 "peek 카드"
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .clear
        floatingPanel.set(contentViewController: placeholder)
        
        
        // 둥근 모서리(상단 좌/우만)
        floatingPanel.surfaceView.layer.cornerRadius = 20
        floatingPanel.surfaceView.clipsToBounds = true
        
        // 부모에 장착
        floatingPanel.addPanel(toParent: self) // 제약조건 자동
        floatingPanel.move(to: .tip, animated: false)
    }
    
    private func setupMapContainer() {
        mapContainer = KMViewContainer()
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainer)
        NSLayoutConstraint.activate([
            mapContainer.topAnchor.constraint(equalTo: view.topAnchor),
            mapContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func buildUI() {
        // 검색창 - 현재는 기능 구현이 되지 않아 비활성화
//        view.addSubview(searchTextField)
//        searchTextField.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
//            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            searchTextField.heightAnchor.constraint(equalToConstant: 44)
//        ])

        // 버튼 컨테이너(즐겨찾기 | 구분선 | [공식, 실시간])
        view.addSubview(buttonsContainer)
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
//            buttonsContainer.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            buttonsContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 34)
        ])

        // 내부 구성
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        let segmentStack = UIStackView(arrangedSubviews: [publicButton, realtimeButton])
        segmentStack.axis = .horizontal
        segmentStack.spacing = 8
        segmentStack.translatesAutoresizingMaskIntoConstraints = false

        buttonsContainer.addSubview(favoriteButton)
        buttonsContainer.addSubview(dividerView)
        buttonsContainer.addSubview(segmentStack)

        NSLayoutConstraint.activate([
            favoriteButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 34),
            favoriteButton.heightAnchor.constraint(equalToConstant: 34),

            dividerView.leadingAnchor.constraint(equalTo: favoriteButton.trailingAnchor, constant: 10),
            dividerView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            dividerView.widthAnchor.constraint(equalToConstant: 2),
            dividerView.heightAnchor.constraint(equalToConstant: 15),

            segmentStack.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor, constant: 4),
            segmentStack.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            segmentStack.trailingAnchor.constraint(lessThanOrEqualTo: buttonsContainer.trailingAnchor),
            segmentStack.heightAnchor.constraint(equalToConstant: 34)
        ])

        // 현재 위치 버튼
        view.addSubview(currentLocationButton)
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            currentLocationButton.bottomAnchor.constraint(equalTo: floatingPanel.surfaceView.topAnchor, constant: -16),
            currentLocationButton.widthAnchor.constraint(equalToConstant: 40),
            currentLocationButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // 줌 스택(현재 위치 버튼 위쪽에 세로 배치)
        zoomStackView.addArrangedSubview(zoomInButton)
        zoomStackView.addArrangedSubview(zoomOutButton)
        view.addSubview(zoomStackView)
        zoomStackView.translatesAutoresizingMaskIntoConstraints = false
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            zoomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            zoomStackView.bottomAnchor.constraint(equalTo: floatingPanel.surfaceView.topAnchor, constant: -70),

            zoomInButton.widthAnchor.constraint(equalToConstant: 40),
            zoomInButton.heightAnchor.constraint(equalToConstant: 40),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 40),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // 맵이 맨 뒤로
        view.sendSubviewToBack(mapContainer)
    }

    // MARK: - Map Engine
    private func setupMapEngine() {
        mapController = KMController(viewContainer: mapContainer)
        mapController.delegate = self
        mapController.prepareEngine()
    }

    // MARK: - Bindings
    private func bindUI() {
        // 검색창 탭(편집 없이 탭만) → 검색 화면 이동(코디네이터로 라우팅)
        let searchTap = UITapGestureRecognizer(target: nil, action: nil)
        searchTextField.addGestureRecognizer(searchTap)
        searchTap.rx.event
            .bind(onNext: { [weak self] _ in
                self?.openSearch()
            })
            .disposed(by: disposeBag)

        // 토글 버튼 상태 관리 (공식/실시간은 택1)
        publicButton.rx.tap
            .bind(onNext: { [weak self] in self?.selectMode(.official) })
            .disposed(by: disposeBag)
        realtimeButton.rx.tap
            .bind(onNext: { [weak self] in self?.selectMode(.realtime) })
            .disposed(by: disposeBag)

        // 즐겨찾기 토글(보이기/숨기기)
        favoriteButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                favoriteButton.isSelected.toggle()
                if favoriteButton.isSelected {
                    overlay.show(.favorite)
                } else {
                    overlay.hide(.favorite)
                }
//                kakaoMap?.commit()
            })
            .disposed(by: disposeBag)

        // 현재 위치
        currentLocationButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.didTapCurrentLocation()
            })
            .disposed(by: disposeBag)

        // 줌 인/아웃 (SDK 버전에 맞춰 필요 시 교체)
        zoomInButton.rx.tap
            .bind(onNext: { [weak self] in self?.applyZoom(delta: +1) })
            .disposed(by: disposeBag)

        zoomOutButton.rx.tap
            .bind(onNext: { [weak self] in self?.applyZoom(delta: -1) })
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        // ViewModel 입력
        let input = MapViewModel.Input(
            cameraRect: cameraRectSubject.asObservable(),
            zoomLevel:  zoomLevelSubject.asObservable(),
            didTapMyLocation: currentLocationButton.rx.tap.asObservable(), // 사용하는 경우
            officialPoiTap: officialPoiTapRelay.asSignal(),
            userPoiTap: userPoiTapRelay.asSignal()
        )
        let output = viewModel.transform(input: input)

        // places → 실시간 그룹 POI
        output.places
            .withLatestFrom(modeRelay) { entries, mode in (entries, mode) }
            .filter { $0.1 == .realtime }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] entries, _ in
                guard let self, let _ = self.kakaoMap else { return }
                let visual = self.visual(for: .realtime)

                // ✅ PLACE만 추출
                let onlyPlaces: [UserPlaceItem] = entries.compactMap {
                    if case let UserPlaceEntry.place(p) = $0 { return p }
                    else { return nil }
                }
                
                let onlyCluster: [ClusterItem] = entries.compactMap {
                    if case let UserPlaceEntry.cluster(c) = $0 { return c }
                    else { return nil }
                }

                // ✅ 인덱스도 PLACE만으로
                self.placeIndex = Dictionary(uniqueKeysWithValues: onlyPlaces.map {
                    (String($0.memberPlaceId), $0)
                })

                // ✅ POI도 PLACE만으로
                let items: [POIItem] = onlyPlaces.map {
                    .init(
                        id: String($0.memberPlaceId),
                        point: MapPoint(
                            longitude: $0.coordinate.longitude,
                            latitude:  $0.coordinate.latitude
                        ),
                        styleKey: self.styleKey(for: $0)
                    )
                }
                
                let clusterItems: [POIClusterItem] = onlyCluster.map {
                    .init(
                        point: MapPoint(
                            longitude: $0.coordinate.longitude,
                            latitude:  $0.coordinate.latitude
                        ),
                        itemCount: $0.clusterSize,
                        styleKey: "congestion.relaxed" // TODO: 각 클러스터링마다 가장 큰 값을 정해야함.
                    )
                }

                self.overlay.setPOIs(
                    for: .realtime,
                    items: items,
                    visual: visual,
                    iconProvider: self.iconForStyleKey,
                    onTapID: { [weak self] group, id in
                        guard let self else { return }
                        guard group == .realtime,
                              self.placeIndex[id] != nil else { return }
                        self.userPoiTapRelay.accept(Int(id) ?? 0)
                    }
                )
                
                self.overlay.setPOIs(
                    for: .realtime,
                    items: clusterItems,
                    visual: visual,
                    iconProvider: self.iconForStyleKey, // TODO: 각 클러스터링마다 가장 큰 값에 따라 이미지 변경
                )

                // ✅ 패널 표시는 PLACE 여부 기반
                if onlyPlaces.isEmpty {
                    self.floatingPanel.move(to: .tip, animated: true)
                } else {
                    self.showUserListPanel(with: onlyPlaces)
                }
            })
            .disposed(by: disposeBag)

        // officialPlace → 폴리곤/센터
        output.officialPlace
            .withLatestFrom(modeRelay) { official, mode in (official, mode) }
            .filter { $0.1 == .official }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] official, _ in
                guard let self else { return }
                let visual = self.visual(for: .official)

                self.officialIndex = Dictionary(uniqueKeysWithValues: official.map { (String($0.officialPlaceId), $0) })
                
                let items: [POIItem] = official.map {
                    .init(
                        id: String($0.officialPlaceId),
                        point: MapPoint(longitude: $0.coordinate.longitude,latitude:  $0.coordinate.latitude),
                        styleKey: self.styleKey(for: $0)
                    )
                }
                
                self.overlay.setPOIs(
                    for: .official,
                    items: items,
                    visual: visual,
                    iconProvider: self.iconForStyleKey,
                    onTapID: { [weak self] group, id in
                        guard let self else { return }
                        guard group == .official, let model = self.officialIndex[id] else { return }
                        
                        self.officialPoiTapRelay.accept(Int(id) ?? 0)
                    })
                
                // 결과가 있으면 목록 패널을 .half로 띄움, 없으면 .tip
                if official.isEmpty {
                    self.floatingPanel.move(to: .tip, animated: true)
                } else {
                    self.showOfficialListPanel(with: official) // 아래 함수
                }
            })
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                favoriteButton.isSelected.toggle()
                
                if favoriteButton.isSelected {
                    self.overlay.show(.favorite)
                } else {
                    self.overlay.hide(.favorite)
                }
            })
            .disposed(by: disposeBag)
        
        output.myCoordinate
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coord in
                print("현재 위치 coord: \(coord)")
                self?.moveCamera(to: coord, level: 14)
            })
            .disposed(by: disposeBag)
        
        let coordStream = output.myCoordinate
            .compactMap { $0 }
            .share(replay: 1, scope: .whileConnected)
        
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 3) 상세 도착 → 패널 업데이트
        output.officialPlaceDetail
            .emit(onNext: { [weak self] info in
                self?.showOfficialDetailPanel(with: info)
            })
            .disposed(by: disposeBag)
        
        output.userPlaceDetail
            .emit(onNext: { [weak self] info in
                self?.showUserDetailPanel(with: info)
            })
            .disposed(by: disposeBag)
        
        output.error
            .emit(onNext: { [weak self] msg in
                
                self?.presentAlert(title: "오류", message: msg)
            })
            .disposed(by: disposeBag)
        
        mapReady
            .withLatestFrom(coordStream)
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coord in
                print("현재 위치 확인 후 이제는 이동해야지 coord: \(coord)")
                self?.moveCamera(to: coord, level: 14)
            })
            .disposed(by: disposeBag)
    }
    
    private func styleKey(for p: OfficialPlaceItem) -> String {
        // 혼잡도명/브랜드/카테고리 등 원하는 규칙으로 키 생성
        let key = p.congestionLevelName.lowercased()
        switch key {
        case "relaxed", "여유":     return "congestion.relaxed"
        case "normal",  "보통":     return "congestion.normal"
        case "busy",    "약간 붐빔":     return "congestion.busy"
        case "crowded", "붐빔": return "congestion.crowded"
        default:                    return "congestion.default"
        }
    }
    
    private func styleKey(for p: UserPlaceItem) -> String {
        // 혼잡도명/브랜드/카테고리 등 원하는 규칙으로 키 생성
        let key = p.congestionLevelName.lowercased()
        switch key {
        case "relaxed", "여유":     return "congestion.relaxed"
        case "normal",  "보통":     return "congestion.normal"
        case "busy",    "약간 붐빔":     return "congestion.busy"
        case "crowded", "붐빔": return "congestion.crowded"
        default:                    return "congestion.default"
        }
    }

    private func iconForStyleKey(_ key: String) -> UIImage {
        switch key {
        case "congestion.relaxed": return .iconGreenMapPoi
        case "congestion.normal":  return .iconBlueMapPoi
        case "congestion.busy":    return .iconYellowMapPoi
        case "congestion.crowded": return .iconRedMapPoi
        default:                   return .iconGreenMapPoi
        }
    }

    // MARK: - Mode / Visual
    private func selectMode(_ group: OverlayGroup) {
        // 버튼 선택 상태/스타일 변경
        publicButton.isSelected   = (group == .official)
        publicButton.layer.borderColor   = (publicButton.isSelected ? UIColor.grayScale7 : .grayScale6).cgColor
        publicButton.backgroundColor   = publicButton.isSelected ? UIColor.grayScale4 : .grayScale1
        
        realtimeButton.isSelected = (group == .realtime)
        realtimeButton.layer.borderColor = (realtimeButton.isSelected ? UIColor.grayScale7 : .grayScale6).cgColor
        realtimeButton.backgroundColor = realtimeButton.isSelected ? UIColor.grayScale4 : .grayScale1

        // 오버레이 표시 모드
        modeRelay.accept(group)
        overlay.showOnly(group)
//        kakaoMap?.commit()
    }

    private func visual(for group: OverlayGroup, level: Int = 1) -> GroupVisual {
        switch group {
        case .official:
            return .init(
                icon: .iconPublicMapPoi,
                fill: UIColor.systemBlue.withAlphaComponent(0.2),
                stroke: .systemBlue,
                zPOI: 3000, zShape: 2500
            )
        case .favorite:
            return .init(
                icon: .iconFavoriteStar,
                fill: UIColor.systemGreen.withAlphaComponent(0.2),
                stroke: .systemGreen,
                zPOI: 2200, zShape: 1800
            )
        case .realtime:
            return .init(
                icon: .iconRedMapPoi,
                fill: UIColor.systemOrange.withAlphaComponent(0.2),
                stroke: .systemOrange,
                zPOI: 2400, zShape: 1900
            )
        }
    }

    // MARK: - Actions
    private func openSearch() {
        // 코디네이터 라우팅 지점
        viewModel.didTapSearch()
    }

    private func didTapCurrentLocation() {
        // ViewModel에서 myCoordinate를 방출한다면 VC에서는 카메라만 옮기는 식으로 분리.
        // 혹은 Repository를 직접 써서 바로 옮겨도 됩니다(선호 구조에 맞게 선택).
        // 여기서는 ViewModel 입력으로 보내는 버전(이미 bindViewModel input에 주입)이라 별도 처리 불필요.
    }

    private func applyZoom(delta: Int) {
        guard let map = kakaoMap else { return }

        // 현재/허용 범위
        let current = map.zoomLevel
        let minL = map.cameraMinLevel
        let maxL = map.cameraMaxLevel

        // 타겟 레벨 계산 (범위 클램핑)
        let target = max(minL, min(maxL, current + delta))

        // 1) 줌만 변경하는 CameraUpdate 생성
        let cu = CameraUpdate.make(zoomLevel: target, mapView: map)

        // 2a) 애니메이션으로 적용 (콜백에서 필요 시 스트림 발사)
        map.animateCamera(cameraUpdate: cu,
                          options: CameraAnimationOptions(autoElevation: false,
                                                          consecutive: false,
                                                          durationInMillis: 250)) { [weak self] in
            guard let self else { return }
            // 여기서 직접 이벤트 쏘고 싶으면 사용 (중복되면 생략)
            let rect = self.currentViewportRect()
//            self.cameraRectSubject.onNext(rect)
//            self.zoomLevelSubject.onNext(target)
        }

        // 2b) 즉시 이동하고 싶으면 아래 한 줄로 대체:
        // map.moveCamera(cu)
    }


    // 현재 뷰포트 계산(델리게이트/헬퍼에서 재사용)
    private func currentViewportRect() -> ViewportRect {
        let size = mapContainer.bounds.size
        let m = kakaoMap.margins
        let topLeft = CGPoint(x: m.left, y: m.top)
        let bottomRight = CGPoint(x: size.width - m.right, y: size.height - m.bottom)
        let centerX = (topLeft.x + bottomRight.x) * 0.5
        let centerY = (topLeft.y + bottomRight.y) * 0.5

        let ne = kakaoMap.getPosition(CGPoint(x: bottomRight.x, y: topLeft.y))     // 오른쪽 위
        let sw = kakaoMap.getPosition(CGPoint(x: topLeft.x,     y: bottomRight.y)) // 왼쪽 아래

        return ViewportRect(
            x: centerX,
            y: centerY,
            left:   sw.wgsCoord.longitude,
            bottom: sw.wgsCoord.latitude,
            right:  ne.wgsCoord.longitude,
            top:    ne.wgsCoord.latitude
        )
    }
    
    // MARK: Floating Panel
    private var listBindingsBag = DisposeBag()  // 리스트 전용 bag
    private var didBindOfficialListActions = false
    private var officialDetailBindingsBag = DisposeBag()
    private var didBindOfficialDetailActions = false
    private var didBindUserListActions = false
    private var userDetailBindingsBag = DisposeBag()
    private var didBindUserDetailActions = false

    private func showOfficialListPanel(with places: [OfficialPlaceItem]) {
        if officialPlaceListViewController == nil {
            officialPlaceListViewController = OfficialPlaceListViewController()
            listBindingsBag = DisposeBag()
            if didBindOfficialListActions == false {
                bindListFavoriteActions() // ← 생성 시 1회만 바인딩
                didBindOfficialListActions = true
            }
        }

        officialPlaceListViewController?.apply(places: places)

        if floatingPanel.contentViewController !== officialPlaceListViewController {
            floatingPanel.delegate = self
            floatingPanel.set(contentViewController: officialPlaceListViewController!)
            
            let sv = officialPlaceListViewController!.tableView
            trackedScrollView = sv
            floatingPanel.track(scrollView: sv)
        }
        floatingPanel.move(to: .tip, animated: true)
        lockScroll(for: .tip)
    }

    private func bindListFavoriteActions() {
        guard let vc = officialPlaceListViewController else { return }

        vc.favoriteActionRequested
            .emit(onNext: { [weak vc, weak self] action in
                guard let vc, let self else { return }
                switch action {
                case .add(let req):
                    PlaceService.shared.registerFavoritePlace(body: req)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onSuccess: { res in
                            vc.applyFavoriteChange(placeId: req.placeId, isFavorite: true)
                        }, onFailure: { _ in })
                        .disposed(by: self.listBindingsBag)

                case .remove(let req):
                    PlaceService.shared.removeFavoritePlace(body: req)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onSuccess: { _ in
                            vc.applyFavoriteChange(placeId: req.placeId, isFavorite: false)
                        }, onFailure: { _ in })
                        .disposed(by: self.listBindingsBag)
                }
            })
            .disposed(by: listBindingsBag)
    }
    
    private func showOfficialDetailPanel(with places: OfficialPlaceDetailInfo) {
        if officialPlaceDetailViewController == nil {
            officialPlaceDetailViewController = OfficialPlaceDetailViewController()
            officialDetailBindingsBag = DisposeBag()
        }
        officialPlaceDetailViewController?.configure(data: places)
        
        // TODO: 서버 통신 부분도 나중에 ViewModel로 옮기기
        if didBindOfficialDetailActions == false, let detailVC = officialPlaceDetailViewController {
            detailVC.favoriteActionRequested
                .emit(onNext: { [weak detailVC, weak self] action in
                    guard let detailVC, let self else { return }
                    detailVC.setFavoriteLoading(true)

                    switch action {
                    case .add(let req):
                        PlaceService.shared.registerFavoritePlace(body: req)
                            .observe(on: MainScheduler.instance)
                            .subscribe(onSuccess: { _ in
                                detailVC.setFavoriteSelected(true)
                                detailVC.setFavoriteLoading(false)
                            }, onFailure: { _ in
                                detailVC.setFavoriteLoading(false)
                            })
                            .disposed(by: self.officialDetailBindingsBag)

                    case .remove(let req):
                        PlaceService.shared.removeFavoritePlace(body: req)
                            .observe(on: MainScheduler.instance)
                            .subscribe(onSuccess: { _ in
                                detailVC.setFavoriteSelected(false)
                                detailVC.setFavoriteLoading(false)
                                detailVC.setFavoriteId(nil)
                            }, onFailure: { _ in
                                detailVC.setFavoriteLoading(false)
                            })
                            .disposed(by: self.officialDetailBindingsBag)
                    }
                })
                .disposed(by: officialDetailBindingsBag)

            didBindOfficialDetailActions = true
        }
       
        if floatingPanel.contentViewController !== officialPlaceDetailViewController {
            floatingPanel.delegate = self
            floatingPanel.set(contentViewController: officialPlaceDetailViewController!)
            
            let sv = officialPlaceDetailViewController!.scrollView
            trackedScrollView = sv
            floatingPanel.track(scrollView: sv)
        }
        
        if let layout = floatingPanel.layout as? AboveTabBarLayout {
            layout.halfFraction = 0.36
            floatingPanel.invalidateLayout()
            floatingPanel.move(to: .half, animated: true)
            lockScroll(for: .half)
        }
    }
    
    private func showUserListPanel(with places: [UserPlaceItem]) {
        if userPlaceListViewController == nil {
            userPlaceListViewController = UserPlaceListViewController()
            listBindingsBag = DisposeBag()
            if didBindUserListActions == false {
                bindUserListFavoriteActions()
                didBindUserListActions = true
            }
        }
//        userPlaceListViewController?.updateHeader(title: "내 주변 여유로운 장소에요!")
        userPlaceListViewController?.apply(places: places)
        
        if floatingPanel.contentViewController !== userPlaceListViewController {
            floatingPanel.delegate = self
            floatingPanel.set(contentViewController: userPlaceListViewController!)
            
            // 내부 스크롤뷰(예: tableView) 추적 시작
            let sv = userPlaceListViewController!.tableView
            trackedScrollView = sv
            floatingPanel.track(scrollView: sv)
        }
        floatingPanel.move(to: .tip, animated: true)
        lockScroll(for: .tip)
    }
    
    private func bindUserListFavoriteActions() {
        guard let vc = userPlaceListViewController else { return }

        vc.favoriteActionRequested
            .emit(onNext: { [weak vc, weak self] action in
                guard let vc, let self else { return }
                switch action {
                case .add(let req):
                    PlaceService.shared.registerFavoritePlace(body: req)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onSuccess: { res in
                            vc.applyFavoriteChange(placeId: req.placeId, isFavorite: true)
                        }, onFailure: { _ in })
                        .disposed(by: self.listBindingsBag)

                case .remove(let req):
                    PlaceService.shared.removeFavoritePlace(body: req)
                        .observe(on: MainScheduler.instance)
                        .subscribe(onSuccess: { _ in
                            vc.applyFavoriteChange(placeId: req.placeId, isFavorite: false)
                        }, onFailure: { _ in })
                        .disposed(by: self.listBindingsBag)
                }
            })
            .disposed(by: listBindingsBag)
    }
    
    private func showUserDetailPanel(with places: UserPlaceDetailInfo) {
        if userPlaceDetailViewController == nil {
            userPlaceDetailViewController = UserPlaceDetailViewController()
            userDetailBindingsBag = DisposeBag()
        }
        userPlaceDetailViewController?.configure(data: places)
        
        if didBindUserDetailActions == false, let detailVC = userPlaceDetailViewController {
            detailVC.favoriteActionRequested
                .emit(onNext: { [weak detailVC, weak self] action in
                    guard let detailVC, let self else { return }
                    detailVC.setFavoriteLoading(true)

                    switch action {
                    case .add(let req):
                        PlaceService.shared.registerFavoritePlace(body: req)
                            .observe(on: MainScheduler.instance)
                            .subscribe(onSuccess: { _ in
                                detailVC.setFavoriteSelected(true)
                                detailVC.setFavoriteLoading(false)
                            }, onFailure: { _ in
                                detailVC.setFavoriteLoading(false)
                            })
                            .disposed(by: self.userDetailBindingsBag)

                    case .remove(let req):
                        PlaceService.shared.removeFavoritePlace(body: req)
                            .observe(on: MainScheduler.instance)
                            .subscribe(onSuccess: { _ in
                                detailVC.setFavoriteSelected(false)
                                detailVC.setFavoriteLoading(false)
                                detailVC.setFavoriteId(nil)
                            }, onFailure: { _ in
                                detailVC.setFavoriteLoading(false)
                            })
                            .disposed(by: self.userDetailBindingsBag)
                    }
                })
                .disposed(by: userDetailBindingsBag)

            didBindUserDetailActions = true
        }
        
        if floatingPanel.contentViewController !== userPlaceDetailViewController {
            floatingPanel.delegate = self
            floatingPanel.set(contentViewController: userPlaceDetailViewController!)
            
            // 내부 스크롤뷰(예: tableView) 추적 시작
            let sv = userPlaceDetailViewController!.tableView
            trackedScrollView = sv
            floatingPanel.track(scrollView: sv)
        }
        
        if let layout = floatingPanel.layout as? AboveTabBarLayout {
            layout.halfFraction = 0.27
            floatingPanel.invalidateLayout()
            floatingPanel.move(to: .half, animated: true)
            lockScroll(for: .half)
        }
    }
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        lockScroll(for: fpc.state)
        setMapButtonsHidden(fpc.state == .full, animated: true)
    }
    
    private func lockScroll(for state: FloatingPanelState) {
        guard let sv = trackedScrollView else { return }
        
        switch state {
        case .half, .tip:
            // 패널이 스크롤뷰 제스처를 추적하지 않도록 해제 + 스크롤 자체도 잠금
            floatingPanel.untrack(scrollView: sv)
            sv.isScrollEnabled = false
            sv.showsVerticalScrollIndicator = false
            if sv.contentOffset.y > 0 { sv.setContentOffset(.zero, animated: false) } // 튕김 방지(옵션)
            
        case .full:
            // 다시 추적 연결 + 스크롤 허용
            floatingPanel.track(scrollView: sv)
            sv.isScrollEnabled = true
            sv.showsVerticalScrollIndicator = true
            
        default:
            break
        }
    }
    
    private func setMapButtonsHidden(_ hidden: Bool, animated: Bool = true) {
        let targets: [UIView] = [currentLocationButton, zoomStackView]
        let apply: () -> Void = {
            targets.forEach { $0.alpha = hidden ? 0 : 1 }
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: apply) { _ in
                targets.forEach {
                    $0.isHidden = hidden
                    $0.isUserInteractionEnabled = !hidden
                }
            }
        } else {
            apply()
            targets.forEach {
                $0.isHidden = hidden
                $0.isUserInteractionEnabled = !hidden
            }
        }
    }
}

// MARK: - MapControllerDelegate
extension MapViewController: MapControllerDelegate {
    func authenticationSucceeded() {
        print("kakao map 인증 성공")
    }
        
    func addViews() {
        let defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
        
        let mapviewInfo = MapviewInfo(viewName: "mapview",
                                              viewInfoName: "map",
                                              defaultPosition: defaultPosition,
                                              defaultLevel: 14)
        mapController.addView(mapviewInfo)
//        kakaoMap = mapController.getView("mapView") as! KakaoMap
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("addViewSucceeded")
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        map.viewRect = mapContainer.bounds
        kakaoMap = map
        
        kakaoMap.eventDelegate = self
        overlay = MapOverlayManager(map: kakaoMap)
        
        let defaultCenter = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9784)
        self.moveCamera(to: defaultCenter, level: 14)
        
        mapReady.accept(())
        
        // 초기 모드(실시간) 선택
        selectMode(.official)
    }
    
    private func moveCamera(to coord: CLLocationCoordinate2D, level: Int32) {
        guard let mapView = kakaoMap else { return }
        let update = CameraUpdate.make(
            target: MapPoint(longitude: coord.longitude, latitude: coord.latitude),
            zoomLevel: Int(level),
            mapView: mapView
        )
        mapView.moveCamera(update)
    }
}

// MARK: - KakaoMapEventDelegate
extension MapViewController: KakaoMapEventDelegate {
    func cameraDidStopped(kakaoMap: KakaoMap, by: MoveBy) {
        let rect = currentViewportRect()
        let zoom = kakaoMap.zoomLevel
        cameraRectSubject.onNext(rect)
        zoomLevelSubject.onNext(Int(zoom))
    }
}

