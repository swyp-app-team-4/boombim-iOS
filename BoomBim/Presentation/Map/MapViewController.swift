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

    // MARK: - Rx (카메라 이벤트 파이프)
    private let cameraRectSubject = PublishSubject<ViewportRect>()
    private let zoomLevelSubject  = PublishSubject<Int>()
    
    // id ↔︎ Place 매핑(POI 탭 시 detail로 전환하기 위해
    private var placeIndex = [String: OfficialPlaceItem]()

    // MARK: - UI
    private lazy var floatingPanel: FloatingPanelController = {
        let f = FloatingPanelController()
        f.surfaceView.grabberHandle.isHidden = false
        f.isRemovalInteractionEnabled = true
        f.delegate = self
        return f
    }()
    
    private var placeListViewController: PlaceListViewController?
    private var placeDetailViewController: PlaceListViewController?
    
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

    private func buildUI() {
        // 검색창
        view.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 44)
        ])

        // 버튼 컨테이너(즐겨찾기 | 구분선 | [공식, 실시간])
        view.addSubview(buttonsContainer)
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
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

            dividerView.leadingAnchor.constraint(equalTo: favoriteButton.trailingAnchor, constant: 12),
            dividerView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            dividerView.widthAnchor.constraint(equalToConstant: 1),
            dividerView.heightAnchor.constraint(equalTo: buttonsContainer.heightAnchor, multiplier: 0.7),

            segmentStack.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor, constant: 12),
            segmentStack.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            segmentStack.trailingAnchor.constraint(lessThanOrEqualTo: buttonsContainer.trailingAnchor)
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
            zoomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -170),

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
            didTapMyLocation: currentLocationButton.rx.tap.asObservable() // 사용하는 경우
        )
        let output = viewModel.transform(input: input)

        // places → 실시간 그룹 POI
        output.places
            .withLatestFrom(modeRelay) { places, mode in (places, mode) }
            .filter { $0.1 == .realtime }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places, _ in
                guard let self, let map = self.kakaoMap else { return }
                let visual = self.visual(for: .realtime)
                
                let items: [POIItem] = places.map {
                    .init(
                        id: String($0.memberPlaceId),
                        point: MapPoint(longitude: $0.coordinate.longitude,
                                        latitude:  $0.coordinate.latitude),
                        styleKey: self.styleKey(for: $0)       // ✅ 메서드 호출
                    )
                }
                
                self.overlay.setPOIs(
                    for: .realtime,
                    items: items,
                    visual: visual,
                    iconProvider: self.iconForStyleKey)
                
//                let items: [(id: String, point: MapPoint)] = places.map {
//                    (id: String($0.memberPlaceId),
//                     point: MapPoint(longitude: $0.coordinate.longitude, latitude: $0.coordinate.latitude))
//                }
//                self.overlay.setPOIs(for: .realtime, items: items, visual: visual)
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

                let items: [(id: String, point: MapPoint)] = official.map {
                    (id: String($0.id),
                     point: MapPoint(longitude: $0.coordinate.longitude, latitude: $0.coordinate.latitude))
                }
                self.overlay.setPOIs(for: .official, items: items, visual: visual)
                
                // id ↔︎ Place 보관 (POI 탭 → 상세 전환용)
                self.placeIndex = Dictionary(uniqueKeysWithValues: official.map { (String($0.id), $0) })
                
                // 결과가 있으면 목록 패널을 .half로 띄움, 없으면 .tip
                if official.isEmpty {
                    self.floatingPanel.move(to: .tip, animated: true)
                } else {
                    self.showListPanel(with: official) // 아래 함수
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
    
    private func styleKey(for p: UserPlaceItem) -> String {
        // 혼잡도명/브랜드/카테고리 등 원하는 규칙으로 키 생성
        let key = p.congestionLevelName.lowercased()
        print("key : \(key)")
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
        realtimeButton.isSelected = (group == .realtime)

        // 선택된 버튼에만 진한 테두리 색
        publicButton.layer.borderColor   = (publicButton.isSelected ? UIColor.grayScale9 : .grayScale6).cgColor
        realtimeButton.layer.borderColor = (realtimeButton.isSelected ? UIColor.grayScale9 : .grayScale6).cgColor

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
        // e.g., coordinator?.showSearch()
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
            self.cameraRectSubject.onNext(rect)
            self.zoomLevelSubject.onNext(target)
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
    private func showListPanel(with places: [OfficialPlaceItem]) {
        if placeListViewController == nil { placeListViewController = PlaceListViewController() }
        placeListViewController?.apply(places: places)         // 테이블/컬렉션 갱신
        if floatingPanel.contentViewController !== placeListViewController {
            floatingPanel.set(contentViewController: placeListViewController!)
        }
        floatingPanel.move(to: .tip, animated: true)
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
        selectMode(.realtime)
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
