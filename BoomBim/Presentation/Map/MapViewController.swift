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

//
//final class MapViewController: BaseViewController {
//    private let viewModel: MapViewModel
//    private let disposeBag = DisposeBag()
//    
//    private var mapContainer: KMViewContainer!
//    private var mapController: KMController!
//    
//    private let searchTextField: AppSearchTextField = {
//        let textField = AppSearchTextField()
//        textField.tapOnly = true
//        
//        return textField
//    }()
//    
//    private let buttonsContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = .clear
//        
//        return view
//    }()
//    
//    private let favoriteButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.setImage(.buttonUnselectedFavorite, for: .normal)
//        button.setImage(.buttonSelectedFavorite,  for: .selected)
//        
//        return button
//    }()
//    
//    private let dividerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .grayScale6
//        
//        return view
//    }()
//    
//    private lazy var publicButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("map.button.public".localized(), for: .normal)
//        button.titleLabel?.font = Typography.Body03.regular.font
//        button.setTitleColor(.grayScale8, for: .normal)
//        button.setTitleColor(.grayScale9, for: .selected)
//        button.backgroundColor = .grayScale1 // .grayScale4
//        
//        button.layer.cornerRadius = 17
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.grayScale6.cgColor // UIColor.grayScale7.cgColor
//        button.clipsToBounds = true
//        
//        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
//        
//        return button
//    }()
//    
//    private lazy var realtimeButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("map.button.realtime".localized(), for: .normal)
//        button.titleLabel?.font = Typography.Body03.regular.font
//        button.setTitleColor(.grayScale8, for: .normal)
//        button.setTitleColor(.grayScale9, for: .selected)
//        button.backgroundColor = .grayScale1 // .grayScale4
//        
//        button.layer.cornerRadius = 17
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.grayScale6.cgColor // UIColor.grayScale7.cgColor
//        button.clipsToBounds = true
//        
//        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
//        
//        return button
//    }()
//    
//    private let currentLocationButton: UIButton = {
//        let button = UIButton()
//        button.setImage(.buttonCurrentLocation, for: .normal)
//        
//        return button
//    }()
//    
//    private let zoomStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.distribution = .fillEqually
//        
//        return stackView
//    }()
//    
//    private let zoomInButton: UIButton = {
//        let button = UIButton()
//        button.setImage(.buttonZoomIn, for: .normal)
//        
//        return button
//    }()
//    
//    private let zoomOutButton: UIButton = {
//        let button = UIButton()
//        button.setImage(.buttonZoomOut, for: .normal)
//        
//        return button
//    }()
//    
//    // 카메라 이벤트 → VM 입력
//    private let cameraRectSubject = PublishSubject<ViewportRect>()
//    private let zoomLevelSubject = PublishSubject<Int>()
//    
//    // POI 상태
//    private var poiLayer: LabelLayer?
//    private let layerID = "PoiLayer"
//    private let officialPoiStyleID = "OfficialPoiStyle"
//    
//    private var polygonStyleSetID: String { "official.polygon.style" }
//    private var shapeLayerID: String { "official.polygon.layer" }
//    private var poiLayerID: String { "official.poi.layer" }
//    private var poiStyleID: String { "official.poi.style" }
//    /** 기존에 표시 했던 Poi List */
//    private var visibleIDs = Set<String>() // Set으로 설정한 이유는 중복 방지 및 연산 속도를 올리기 위해
//    
//    // MARK: - init
//    init(viewModel: MapViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    deinit {
//        mapController?.pauseEngine()
//        mapController?.resetEngine()
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    // MARK: Life Cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//        
//        setActions()
//        
//        bindViewModel()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if mapController?.isEngineActive == false { mapController?.activateEngine() }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        mapController?.pauseEngine()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if let map = mapController?.getView("mapview") as? KakaoMap {
//            map.viewRect = mapContainer.bounds
//        }
//    }
//    
//    // MARK: UI
//    private func setupUI() {
//        view.backgroundColor = .white
//        
//        configureMapUI()
//        configureKakaoMap()
//        configureTextField()
//        configureButton()
//        configureMapButton()
//    }
//    
//    private func configureMapUI() {
//        mapContainer = KMViewContainer()
//        mapContainer.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(mapContainer)
//        
//        NSLayoutConstraint.activate([
//            mapContainer.topAnchor.constraint(equalTo: view.topAnchor),
//            mapContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mapContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            mapContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
//    }
//    
//    private func configureKakaoMap() {
//        mapController = KMController(viewContainer: mapContainer)
//        mapController.delegate = self
//        mapController.prepareEngine()
//    }
//    
//    private func configureTextField() {
//        searchTextField.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(searchTextField)
//        
//        NSLayoutConstraint.activate([
//            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            searchTextField.heightAnchor.constraint(equalToConstant: 46)
//        ])
//    }
//    
//    private func configureButton() {
//        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(buttonsContainer)
//        
//        [favoriteButton, dividerView, publicButton, realtimeButton].forEach { button in
//            button.translatesAutoresizingMaskIntoConstraints = false
//            buttonsContainer.addSubview(button)
//        }
//        
//        NSLayoutConstraint.activate([
//            buttonsContainer.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
//            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            buttonsContainer.heightAnchor.constraint(equalToConstant: 42),
//            
//            favoriteButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
//            favoriteButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
//            favoriteButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
//            favoriteButton.heightAnchor.constraint(equalToConstant: 42),
//            
//            dividerView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
//            dividerView.leadingAnchor.constraint(equalTo: favoriteButton.trailingAnchor, constant: 4),
//            dividerView.widthAnchor.constraint(equalToConstant: 2),
//            dividerView.heightAnchor.constraint(equalToConstant: 15),
//            
//            publicButton.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
//            publicButton.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor, constant: 4),
//            publicButton.heightAnchor.constraint(equalToConstant: 34),
//            
//            realtimeButton.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
//            realtimeButton.leadingAnchor.constraint(equalTo: publicButton.trailingAnchor, constant: 8),
//            realtimeButton.heightAnchor.constraint(equalToConstant: 34),
//        ])
//    }
//    
//    private func configureMapButton() {
//        [currentLocationButton, zoomStackView].forEach { view in
//            view.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(view)
//        }
//        
//        [zoomInButton, zoomOutButton].forEach { button in
//            button.translatesAutoresizingMaskIntoConstraints = false
//            zoomStackView.addArrangedSubview(button)
//        }
//        
//        NSLayoutConstraint.activate([
//            currentLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            currentLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
//            
//            zoomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            zoomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -170)
//        ])
//    }
//    
//    private func setActions() {
//        favoriteButton.addTarget(self, action: #selector(tapFavorite), for: .touchUpInside)
//        publicButton.addTarget(self, action: #selector(tapPublic), for: .touchUpInside)
//        realtimeButton.addTarget(self, action: #selector(tapRealtime), for: .touchUpInside)
//        currentLocationButton.addTarget(self, action: #selector(tapCurrentLocation), for: .touchUpInside)
//        zoomInButton.addTarget(self, action: #selector(tapZoomIn), for: .touchUpInside)
//        zoomOutButton.addTarget(self, action: #selector(tapZoomOut), for: .touchUpInside)
//    }
//    
//    @objc private func tapFavorite() {
//        print("tapFavorite")
//    }
//    
//    @objc private func tapPublic() {
//        print("tapPublic")
//    }
//    
//    @objc private func tapRealtime() {
//        print("tapRealtime")
//    }
//    
//    @objc private func tapCurrentLocation() {
//        print("tapCurrentLocation")
//    }
//    
//    @objc private func tapZoomIn() {
//        print("tapZoomIn")
//    }
//    
//    @objc private func tapZoomOut() {
//        print("tapZoomOut")
//    }
//
//    // MARK: ViewModel binding
//    private func bindViewModel() {
//        let input = MapViewModel.Input(
//            cameraRect: cameraRectSubject.asObservable(),
//            zoomLevel: zoomLevelSubject.asObservable()
//        )
//        
//        let output = viewModel.transform(input: input)
//
//        output.officialPlace
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] place in
//                print("place : \(place)")
//                self?.drawOfficialPlace(place)
//            })
//            .disposed(by: disposeBag)
//    }
//
//    // MARK: Poi 스타일 생성 및 Poi 좌표 설정
//    /** Poi의 스타일을 구현
//     - note: 스타일 변경이 필요한 경우 Style을 제거하고 새로 만들어야함. */
//    private func createPoiStyle(on map: KakaoMap) {
//        print("kakaoMap ensurePoiInfra")
//        let labelManager = map.getLabelManager()
//
//        if labelManager.getLabelLayer(layerID: layerID) == nil { // 해당 Layer가 있는지 확인
//            let opt = LabelLayerOptions(layerID: layerID,
//                                        competitionType: .none,
//                                        competitionUnit: .symbolFirst,
//                                        orderType: .rank,
//                                        zOrder: 0)
//            _ = labelManager.addLabelLayer(option: opt)
//        }
//        poiLayer = labelManager.getLabelLayer(layerID: layerID)
//
//        var image = UIImage.iconRedMapPoi
//        image = image.resized(to: CGSize(width: 20, height: 20))
//        
//        let iconStyle = PoiIconStyle(symbol: UIImage.iconStar, anchorPoint: CGPoint(x: 0.5, y: 0.5), badges: [])
//        let poiStyle = PoiStyle(styleID: officialPoiStyleID, styles: [
//            PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
//        ])
//        
//        labelManager.addPoiStyle(poiStyle)
//    }
//
//    /** 서버로부터 받아온 장소를 표시 */
////    private func render(places: [Place]) {
////        guard let map = mapController?.getView("mapview") as? KakaoMap,
////              let layer = poiLayer else { return }
////        
////        print("places:", places.count, "zoom:", (mapController?.getView("mapview") as? KakaoMap)?.zoomLevel ?? -1)
////        
////        print("layer exists:", poiLayer != nil, "styleID:", officialPoiStyleID)
////        
////        let placeIDList = Set(places.map { $0.id })
////        let toAdd = placeIDList.subtracting(visibleIDs) // 새로 추가할 place
////        let toRemove = visibleIDs.subtracting(placeIDList) // 삭제할 place
////        
////        // 사라져야하는 poi 일괄 삭제
////        if !toRemove.isEmpty {
////            layer.removePois(poiIDs: Array(toRemove))
////        }
////        
////        // 장소 추가
////        if !toAdd.isEmpty {
////            let addPlaces = places.filter { toAdd.contains($0.id) }
////            
////            // 스타일 및 고유 ID 설정
////            let poiOptions: [PoiOptions] = addPlaces.map {
////                let option = PoiOptions(styleID: officialPoiStyleID, poiID: $0.id)
////                option.rank = 0
////                return option
////            }
////            
////            // 위치 설정
////            let positions: [MapPoint] = addPlaces.map {
////                MapPoint(longitude: $0.coord.longitude, latitude: $0.coord.latitude)
////            }
////            
////            if let created = layer.addPois(options: poiOptions, at: positions) {
////                created.forEach { $0.show() } // 장소 poi 표시
////            }
////        }
////        
////        visibleIDs = placeIDList
////    }
//
//    // MARK: View Rect 생성 (+ 패딩 20%)
//    private func emitCurrentRect(paddingRatio: Double = 0.2) {
//        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
//        let r = map.viewRect
//        print("r : \(r)")
//        guard r.width > 0, r.height > 0 else { return } // ✅ 방어
//        
//        // 1) 화면 꼭지점(패딩 없음) → 지도 좌표
//        let center = map.getPosition(CGPoint(x: r.midX, y: r.midY))
//        print("center : \(center)")
//        let corners = [
//            CGPoint(x: r.minX, y: r.minY),
//            CGPoint(x: r.maxX, y: r.minY),
//            CGPoint(x: r.maxX, y: r.maxY),
//            CGPoint(x: r.minX, y: r.maxY),
//        ].map {
//            print("$0.x: \(String(describing: $0.x)), $0.y: \(String(describing: $0.y))")
//            return map.getPosition($0)
//        }
//        
//        let centerLon = center.wgsCoord.longitude
//        let centerLat = center.wgsCoord.latitude
//        let lons = corners.map { $0.wgsCoord.longitude }
//        let lats = corners.map { $0.wgsCoord.latitude }
//        
//        var left   = lons.min() ?? 0 // 서쪽 경도
//        var right  = lons.max() ?? 0 // 동쪽 경도
//        var bottom = lats.min() ?? 0 // 남쪽 위도
//        var top    = lats.max() ?? 0 // 북쪽 위도
//        
//        // 현재 화면에서 20% 넓게 조회해서 받아놓은 영역 내에서 표시할 수 있게 구현
//        let lonPad = (right - left) * paddingRatio
//        let latPad = (top - bottom) * paddingRatio
//        left   -= lonPad
//        right  += lonPad
//        bottom -= latPad
//        top    += latPad
//        
//        let rect = ViewportRect(x: centerLon, y: centerLat, left: left, bottom: bottom, right: right, top: top)
//        cameraRectSubject.onNext(rect)
//        zoomLevelSubject.onNext(map.zoomLevel)
//    }
//    
//    func drawOfficialPlace(_ place: OfficialPlace) {
//        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
//        
//        // ========== 1) 폴리곤 그리기 ==========
//        let shapeManager = mapView.getShapeManager()
//        
//        // 스타일셋(투명 폴리곤 + 테두리) 한 번만 등록. 동일 ID 중복 추가는 overwrite 안됨.
//        let fill = PerLevelPolygonStyle(color: UIColor.systemBlue.withAlphaComponent(0.2),
//                                        strokeWidth: 2,
//                                        strokeColor: .systemBlue,
//                                        level: 0)
//        let polyStyle = PolygonStyle(styles: [fill])
//        let styleSet = PolygonStyleSet(styleSetID: polygonStyleSetID, styles: [polyStyle])
//        shapeManager.addPolygonStyleSet(styleSet) // 이미 있으면 그대로 유지
//        
//        // 이전 레이어가 있으면 제거 후 새로 생성 (깨끗한 갱신)
//        if shapeManager.getShapeLayer(layerID: shapeLayerID) != nil {
//            shapeManager.removeShapeLayer(layerID: shapeLayerID)
//        }
//        let shapeLayer = shapeManager.addShapeLayer(layerID: shapeLayerID, zOrder: 10)
//        
//        // 좌표 변환: [CLLocationCoordinate2D] -> [MapPoint]
//        let ring: [MapPoint] = place.polygon.map { MapPoint(longitude: $0.longitude, latitude: $0.latitude) }
//        let mapPolygon = MapPolygon(exteriorRing: ring, hole: nil, styleIndex: 0)
//        
//        let polyOpt = MapPolygonShapeOptions(shapeID: "official.\(place.id)", styleID: polygonStyleSetID, zOrder: 0)
//        polyOpt.polygons = [mapPolygon]
//        
//        let polygonShape = shapeLayer?.addMapPolygonShape(polyOpt)
//        polygonShape?.show()
//        
//        // ========== 2) 중심점 POI 찍기 ==========
//        let labelManager = mapView.getLabelManager()
//        
//        // POI 스타일(아이콘만) 등록. 같은 styleID는 중복 추가되지 않음.
//        if labelManager.getPoiStyle(styleID: poiStyleID) == nil { // 편의 확장(아래 정의)
//            let icon = UIImage.iconRedMapPoi
//            let iconStyle = PoiIconStyle(symbol: icon, anchorPoint: CGPoint(x: 0.5, y: 1.0), badges: [])
//            let perLevel = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
//            let poiStyle = PoiStyle(styleID: poiStyleID, styles: [perLevel])
//            labelManager.addPoiStyle(poiStyle)
//        }
//        
//        // 레이어가 없으면 생성하고, 있으면 기존 POI 정리 후 재추가
//        let layer: LabelLayer = {
//            if let l = labelManager.getLabelLayer(layerID: poiLayerID) { return l }
//            let opt = LabelLayerOptions(layerID: poiLayerID,
//                                        competitionType: .none,
//                                        competitionUnit: .symbolFirst,
//                                        orderType: .rank,
//                                        zOrder: 2000) // 기본 POI 위로
//            _ = labelManager.addLabelLayer(option: opt)
//            return labelManager.getLabelLayer(layerID: poiLayerID)!
//        }()
//        
//        // 이전 항목 제거하고 새 POI 추가
//        layer.clearAllItems()
//        let poiOpt = PoiOptions(styleID: poiStyleID)
//        let centroid = MapPoint(longitude: place.centroid.longitude, latitude: place.centroid.latitude)
//        let poi = layer.addPoi(option: poiOpt, at: centroid)
//        poi?.show()
//    }
//}
//
//// MARK: 현재 위치 권한 설정 및 카메라 이동
//extension MapViewController {
//    private func setLocation() {
//        let locationManager = AppLocationManager.shared
//        
//        if locationManager.authorization.value == .notDetermined { // 권한 설정이 안된 경우 권한 요청
//            locationManager.requestWhenInUseAuthorization()
//        }
//        
//        // 권한 상태 스트림에서 '최종 상태(허용/거부)'만 대기 → 1회 처리
//        locationManager.authorization
//            .asObservable()
//            .startWith(locationManager.authorization.value) // 현재 상태 먼저 흘려보내기
//            .distinctUntilChanged()
//            .filter { status in
//                switch status {
//                case .authorizedWhenInUse, .authorizedAlways, .denied, .restricted:
//                    return true // 최종 상태만 통과
//                default:
//                    return false // .notDetermined은 대기
//                }
//            }
//            .take(1) // 허용 or 거부 중 첫 결과 한 번만
//            .flatMapLatest { [weak self] status -> Observable<CLLocationCoordinate2D> in
//                guard let self else { return .empty() }
//                switch status {
//                case .authorizedWhenInUse, .authorizedAlways:
//                    return locationManager.requestOneShotLocation(timeout: 5)
//                        .asObservable()
//                        .map {
//                            print("위도 : \($0.coordinate.latitude), 경도 : \($0.coordinate.longitude)")
//                            return $0.coordinate
//                        }
//                case .denied, .restricted:
//                    self.showLocationDeniedAlert()
//                    return .empty()
//                default:
//                    return .empty()
//                }
//            }
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] coord in
//                self?.viewModel.setCurrentCoordinate(coord)
//                self?.moveCamera(to: coord, level: 14)
//            })
//            .disposed(by: disposeBag)
//    }
//    
//    /** 위치 접근 안내 Alert */
//    private func showLocationDeniedAlert() {
//        let alert = UIAlertController(
//            title: "위치 접근이 꺼져 있어요",
//            message: "현재 위치를 기반으로 검색하려면 설정 > 앱 > 위치에서 허용해 주세요.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url)
//            }
//        })
//        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: Kakao Map Camera 동작
//extension MapViewController {
//    private func moveCamera(to coord: CLLocationCoordinate2D, level: Int32) {
//        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
//        let update = CameraUpdate.make(
//            target: MapPoint(longitude: coord.longitude, latitude: coord.latitude),
//            zoomLevel: Int(level),
//            mapView: mapView
//        )
//        mapView.moveCamera(update)
//    }
//}
//
//// MARK: Kakao Map Delegate
//extension MapViewController: MapControllerDelegate {
//    // 인증에 성공했을 경우 호출.
//    func authenticationSucceeded() {
//        print("kakao map 인증 성공")
//    }
//    
//    // 인증 실패시 호출.
//    func authenticationFailed(_ errorCode: Int, desc: String) {
//        print("error code: \(errorCode)")
//        print("desc: \(desc)")
//        switch errorCode {
//        case 400:
//            print("지도 종료(API인증 파라미터 오류)")
//            break;
//        case 401:
//            print("지도 종료(API인증 키 오류)")
//            break;
//        case 403:
//            print("지도 종료(API인증 권한 오류)")
//            break;
//        case 429:
//            print("지도 종료(API 사용쿼터 초과)")
//            break;
//        case 499:
//            print("지도 종료(네트워크 오류) 5초 후 재시도..")
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                print("retry auth...")
//                
//                self.mapController?.prepareEngine() // 인증 재시도
//            }
//            break;
//        default:
//            break;
//        }
//    }
//    
//    func addViews() {
//        // 여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
//        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
//        // 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
//        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 14)
//        
//        // KakaoMap 추가.
//        mapController?.addView(mapviewInfo)
//    }
//
//    // addViewSucceeded에서 지도 생성 직후 호출
//    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
//        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
//
//        // ❗️viewRect는 AutoLayout 이후에도 갱신 필요 (아래 viewDidLayoutSubviews 참고)
//        map.viewRect = mapContainer.bounds
//
//        // (A) POI가 올라갈 레이어 생성
//        let labelManager = map.getLabelManager()
//        if poiLayer == nil {
//            let opt = LabelLayerOptions(
//                layerID: "officialPoiLayer",
//                competitionType: .none,
//                competitionUnit: .symbolFirst,
//                orderType: .rank,
//                zOrder: 10
//            )
//            poiLayer = labelManager.addLabelLayer(option: opt)
//        } // 레이어가 있어야 POI를 만들 수 있습니다. :contentReference[oaicite:3]{index=3}
//
//        // (B) POI 스타일 등록 (한 번만)
//        if labelManager.getPoiStyle(styleID: poiStyleID) == nil {
//            let icon = PoiIconStyle(
//                symbol: .iconRedMapPoi,
//                anchorPoint: CGPoint(x: 0.5, y: 1.0)
//            )
//            let perLevel = PerLevelPoiStyle(iconStyle: icon, level: 0)
//            let style = PoiStyle(styleID: poiStyleID, styles: [perLevel])
//            labelManager.addPoiStyle(style) // LabelManager를 통해 스타일 등록. :contentReference[oaicite:4]{index=4}
//        }
//
//        // (C) 현재 위치 이동 등 기존 로직
//        setLocation()
//
//        // (D) 초기 검색 트리거 → 응답에서 POI 추가
//        DispatchQueue.main.async { [weak self] in
//            self?.emitCurrentRect()
//        }
//
//        _ = map.addCameraStoppedEventHandler(target: self) { owner in
//            return { [weak owner] _ in
//                owner?.emitCurrentRect()
//            }
//        }
//    }
//
//    /// 서버에서 장소 배열을 받았다고 가정하고 POI로 그립니다.
//    func renderOfficialPlaces(_ places: [OfficialPlace]) {
//        guard let layer = poiLayer else { return }
//
//        // 기존 아이템 정리(중복 방지)
//        layer.clearAllItems()
//
//        // 옵션 배열 + 위치 배열을 만들어 한 번에 추가
//        let options: [PoiOptions] = places.map { p in
//            let opt = PoiOptions(styleID: poiStyleID, poiID: "poi_\(p.id)")
//            opt.rank = 0
//            // 필요 시 텍스트 라벨도 추가 가능 (스타일에 TextLineStyle이 있을 때)
//            // opt.addText(PoiText(text: p.name, styleIndex: 0))
//            return opt
//        }
//        let positions: [MapPoint] = places.map { p in
//            MapPoint(longitude: p.centroid.longitude, latitude: p.centroid.latitude)
//        }
//
//        _ = layer.addPois(options: options, at: positions)
//
//        // ❗️show 호출을 해야 화면에 표시됩니다.
//        layer.showAllPois()  // 혹은 poi.show() 개별 호출. :contentReference[oaicite:5]{index=5}
//    }
//    
//    // addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
//    func addViewFailed(_ viewName: String, viewInfoName: String) {
//        print("Failed")
//    }
//
//    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
//    func containerDidResized(_ size: CGSize) {
//        if let map = mapController?.getView("mapview") as? KakaoMap {
//            map.viewRect = CGRect(origin: .zero, size: size)
//            emitCurrentRect() // 사이즈 바뀌면 범위도 변경
//        }
//    }
//}

final class MapViewController: BaseViewController {
    private let viewModel: MapViewModel
    private let disposeBag = DisposeBag()

    private var mapContainer: KMViewContainer!
    private var mapController: KMController!

    // ✅ Overlay Manager (별도 파일)
    private var overlay: MapOverlayManager!

    // UI
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

    // 카메라 이벤트 → VM 입력
    private let cameraRectSubject = PublishSubject<ViewportRect>()
    private let zoomLevelSubject = PublishSubject<Int>()

    // 현재 선택된 그룹 (버튼 토글용)
    private var selectedGroup: OverlayGroup = .official {
        didSet { updateButtonStates(for: selectedGroup) }
    }

    // 그룹별 비주얼(원하는 색/아이콘으로 교체 가능)
    private let vOfficial = GroupVisual(
        icon: .iconRedMapPoi,
        fill: UIColor.systemBlue.withAlphaComponent(0.2),
        stroke: .systemBlue,
        zPOI: 2000,
        zShape: 10
    )
    private let vRealtime = GroupVisual(
        icon: .buttonUnselectedBusy, // 예시 아이콘
        fill: UIColor.systemOrange.withAlphaComponent(0.18),
        stroke: .systemOrange,
        zPOI: 2001,
        zShape: 11
    )
    private let vFavorite = GroupVisual(
        icon: .iconStar,
        fill: UIColor.systemYellow.withAlphaComponent(0.18),
        stroke: .systemYellow,
        zPOI: 2002,
        zShape: 12
    )

    // MARK: - init
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setActions()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mapController?.isEngineActive == false { mapController?.activateEngine() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapController?.pauseEngine()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let map = mapController?.getView("mapview") as? KakaoMap {
            map.viewRect = mapContainer.bounds
        }
    }

    // MARK: UI
    private func setupUI() {
        view.backgroundColor = .white
        configureMapUI()
        configureKakaoMap()
        configureTextField()
        configureButton()
        configureMapButton()
    }

    private func configureMapUI() {
        mapContainer = KMViewContainer()
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainer)

        NSLayoutConstraint.activate([
            mapContainer.topAnchor.constraint(equalTo: view.topAnchor),
            mapContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureKakaoMap() {
        mapController = KMController(viewContainer: mapContainer)
        mapController.delegate = self
        mapController.prepareEngine()
    }

    private func configureTextField() {
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchTextField)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    private func configureButton() {
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsContainer)

        [favoriteButton, dividerView, publicButton, realtimeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview($0)
        }

        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 16),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonsContainer.heightAnchor.constraint(equalToConstant: 42),

            favoriteButton.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            favoriteButton.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            favoriteButton.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
            favoriteButton.heightAnchor.constraint(equalToConstant: 42),

            dividerView.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            dividerView.leadingAnchor.constraint(equalTo: favoriteButton.trailingAnchor, constant: 4),
            dividerView.widthAnchor.constraint(equalToConstant: 2),
            dividerView.heightAnchor.constraint(equalToConstant: 15),

            publicButton.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            publicButton.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor, constant: 4),
            publicButton.heightAnchor.constraint(equalToConstant: 34),

            realtimeButton.centerYAnchor.constraint(equalTo: buttonsContainer.centerYAnchor),
            realtimeButton.leadingAnchor.constraint(equalTo: publicButton.trailingAnchor, constant: 8),
            realtimeButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    private func configureMapButton() {
        [currentLocationButton, zoomStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [zoomInButton, zoomOutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            zoomStackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            currentLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            currentLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            zoomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            zoomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -170)
        ])
    }

    private func setActions() {
        favoriteButton.addTarget(self, action: #selector(tapFavorite), for: .touchUpInside)
        publicButton.addTarget(self, action: #selector(tapPublic), for: .touchUpInside)
        realtimeButton.addTarget(self, action: #selector(tapRealtime), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(tapCurrentLocation), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(tapZoomIn), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(tapZoomOut), for: .touchUpInside)
    }

    // MARK: - Button Actions
    @objc private func tapFavorite() {
        selectedGroup = .favorite
        overlay?.showOnly(.favorite)
    }

    @objc private func tapPublic() {
        selectedGroup = .official
        overlay?.showOnly(.official)
    }

    @objc private func tapRealtime() {
        selectedGroup = .realtime
        overlay?.showOnly(.realtime)
    }

    @objc private func tapCurrentLocation() {
        setLocation()
    }

    @objc private func tapZoomIn() {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        let current = map.zoomLevel
        let update = CameraUpdate.make(zoomLevel: current - 1, mapView: map)
        map.moveCamera(update)
        zoomLevelSubject.onNext(current - 1)
    }

    @objc private func tapZoomOut() {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        let current = map.zoomLevel
        let update = CameraUpdate.make(zoomLevel: current + 1, mapView: map)
        map.moveCamera(update)
        zoomLevelSubject.onNext(current + 1)
    }

    private func updateButtonStates(for group: OverlayGroup) {
        // favoriteButton은 이미지 토글, 나머지는 selected로 텍스트 컬러만
        favoriteButton.isSelected = (group == .favorite)
        publicButton.isSelected   = (group == .official)
        realtimeButton.isSelected = (group == .realtime)
    }

    // MARK: ViewModel binding
    private func bindViewModel() {
        let input = MapViewModel.Input(
            cameraRect: cameraRectSubject.asObservable(),
            zoomLevel: zoomLevelSubject.asObservable()
        )
        let output = viewModel.transform(input: input)

        // 예: 단일 공식 장소 스트림
        output.officialPlace
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] place in
                self?.drawOfficialPlace(place)
            })
            .disposed(by: disposeBag)

        // 필요 시, 여러 장소/다른 그룹 출력도 같은 패턴으로 바인딩하세요.
        // output.realtimePlaces
        // output.favoritePlaces
    }

    // MARK: View Rect 생성 (+ 패딩 20%)
    private func emitCurrentRect(paddingRatio: Double = 0.2) {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        let r = map.viewRect
        guard r.width > 0, r.height > 0 else { return }

        let center = map.getPosition(CGPoint(x: r.midX, y: r.midY))
        let corners = [
            CGPoint(x: r.minX, y: r.minY),
            CGPoint(x: r.maxX, y: r.minY),
            CGPoint(x: r.maxX, y: r.maxY),
            CGPoint(x: r.minX, y: r.maxY),
        ].map { map.getPosition($0) }

        let centerLon = center.wgsCoord.longitude
        let centerLat = center.wgsCoord.latitude
        let lons = corners.map { $0.wgsCoord.longitude }
        let lats = corners.map { $0.wgsCoord.latitude }

        var left   = lons.min() ?? 0
        var right  = lons.max() ?? 0
        var bottom = lats.min() ?? 0
        var top    = lats.max() ?? 0

        let lonPad = (right - left) * paddingRatio
        let latPad = (top - bottom) * paddingRatio
        left   -= lonPad
        right  += lonPad
        bottom -= latPad
        top    += latPad

        let rect = ViewportRect(x: centerLon, y: centerLat, left: left, bottom: bottom, right: right, top: top)
        cameraRectSubject.onNext(rect)
        zoomLevelSubject.onNext(map.zoomLevel)
    }

    // MARK: - Overlay Rendering (MapOverlayManager 사용)
    /// 단일 공식 장소(폴리곤 + 중심 POI) 렌더링
    private func drawOfficialPlace(_ place: OfficialPlace) {
        guard overlay != nil else { return }

        let ring: [MapPoint] = place.polygon.map {
            MapPoint(longitude: $0.longitude, latitude: $0.latitude)
        }
        overlay.setPolygons(for: .official, rings: [ring], visual: vOfficial)

        let centroid = MapPoint(longitude: place.centroid.longitude, latitude: place.centroid.latitude)
        overlay.setPOIs(for: .official, items: [(id: "\(place.id)", point: centroid)], visual: vOfficial)

        // 공개 탭을 눌렀을 때 보이는 상태 유지
        if selectedGroup == .official {
            overlay.show(.official)
        }
    }

    /// 여러 공식 장소를 한 번에 렌더링하고 싶을 때 사용
    private func renderOfficialPlaces(_ places: [OfficialPlace]) {
        guard overlay != nil else { return }

        let rings: [[MapPoint]] = places.map { p in
            p.polygon.map { MapPoint(longitude: $0.longitude, latitude: $0.latitude) }
        }
        overlay.setPolygons(for: .official, rings: rings, visual: vOfficial)

        let items: [(id: String, point: MapPoint)] = places.map { p in
            (id: "\(p.id)",
             point: MapPoint(longitude: p.centroid.longitude, latitude: p.centroid.latitude))
        }
        overlay.setPOIs(for: .official, items: items, visual: vOfficial)

        if selectedGroup == .official {
            overlay.show(.official)
        }
    }
}

// MARK: 현재 위치 권한 설정 및 카메라 이동
extension MapViewController {
    private func setLocation() {
        let locationManager = AppLocationManager.shared

        if locationManager.authorization.value == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.authorization
            .asObservable()
            .startWith(locationManager.authorization.value)
            .distinctUntilChanged()
            .filter { status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways, .denied, .restricted: return true
                default: return false
                }
            }
            .take(1)
            .flatMapLatest { [weak self] status -> Observable<CLLocationCoordinate2D> in
                guard let self else { return .empty() }
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    return locationManager.requestOneShotLocation(timeout: 5)
                        .asObservable()
                        .map { $0.coordinate }
                case .denied, .restricted:
                    self.showLocationDeniedAlert()
                    return .empty()
                default:
                    return .empty()
                }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] coord in
                self?.viewModel.setCurrentCoordinate(coord)
                self?.moveCamera(to: coord, level: 14)
            })
            .disposed(by: disposeBag)
    }

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

// MARK: Kakao Map Camera 동작
extension MapViewController {
    private func moveCamera(to coord: CLLocationCoordinate2D, level: Int32) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let update = CameraUpdate.make(
            target: MapPoint(longitude: coord.longitude, latitude: coord.latitude),
            zoomLevel: Int(level),
            mapView: mapView
        )
        mapView.moveCamera(update)
    }
}

// MARK: Kakao Map Delegate
extension MapViewController: MapControllerDelegate {
    func authenticationSucceeded() {
        print("kakao map 인증 성공")
    }

    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        switch errorCode {
        case 400: break // 파라미터 오류
        case 401: break // 키 오류
        case 403: break // 권한 오류
        case 429: break // 쿼터 초과
        case 499:
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.mapController?.prepareEngine()
            }
        default: break
        }
    }

    func addViews() {
        let defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo = MapviewInfo(viewName: "mapview",
                                      viewInfoName: "map",
                                      defaultPosition: defaultPosition,
                                      defaultLevel: 14)
        mapController?.addView(mapviewInfo)
    }

    // KakaoMap 생성 완료
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        map.viewRect = mapContainer.bounds

        // ✅ Overlay 매니저 주입
        overlay = MapOverlayManager(map: map)

        // 현재 위치 이동 등 기존 로직
        setLocation()

        // 최초 검색 트리거 + 카메라 이벤트
        DispatchQueue.main.async { [weak self] in self?.emitCurrentRect() }
        _ = map.addCameraStoppedEventHandler(target: self) { owner in
            return { [weak owner] _ in owner?.emitCurrentRect() }
        }

        // 기본은 공개(official) 탭 노출
        selectedGroup = .official
        overlay.showOnly(.official)
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Map addViewFailed")
    }

    func containerDidResized(_ size: CGSize) {
        if let map = mapController?.getView("mapview") as? KakaoMap {
            map.viewRect = CGRect(origin: .zero, size: size)
            emitCurrentRect()
        }
    }
}
