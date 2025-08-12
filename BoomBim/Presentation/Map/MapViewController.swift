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

final class MapViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: MapViewModel

    private var mapContainer: KMViewContainer!
    private var mapController: KMController!

    // 카메라 이벤트 → VM 입력
    private let cameraRectSubject = PublishSubject<ViewportRect>()
    private let zoomLevelSubject = PublishSubject<Int>()

    // POI 상태
    private var poiLayer: LabelLayer?
    private let layerID = "PoiLayer"
    private let poiStyleID = "StarbucksPoi"
    /** 기존에 표시 했던 Poi List */
    private var visibleIDs = Set<String>() // Set으로 설정한 이유는 중복 방지 및 연산 속도를 올리기 위해

    // MARK: - init
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "지도"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupMapUI()

        mapController = KMController(viewContainer: mapContainer)
        mapController.delegate = self
        mapController.prepareEngine()

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
    private func setupMapUI() {
        mapContainer = KMViewContainer()
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainer)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapContainer.topAnchor.constraint(equalTo: g.topAnchor),
            mapContainer.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            mapContainer.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            mapContainer.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])
    }

    // MARK: VM binding
    private func bindViewModel() {
        let input = MapViewModel.Input(
            cameraRect: cameraRectSubject.asObservable(),
            zoomLevel: zoomLevelSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.places
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places in
                self?.render(places: places)
            })
            .disposed(by: disposeBag)
    }

    // MARK: Poi 스타일 생성 및 Poi 좌표 설정
    /** Poi의 스타일을 구현
     - note: 스타일 변경이 필요한 경우 Style을 제거하고 새로 만들어야함. */
    private func createPoiStyle(on map: KakaoMap) {
        print("kakaoMap ensurePoiInfra")
        let labelManager = map.getLabelManager()

        if labelManager.getLabelLayer(layerID: layerID) == nil { // 해당 Layer가 있는지 확인
            let opt = LabelLayerOptions(layerID: layerID,
                                        competitionType: .none,
                                        competitionUnit: .symbolFirst,
                                        orderType: .rank,
                                        zOrder: 0)
            _ = labelManager.addLabelLayer(option: opt)
        }
        poiLayer = labelManager.getLabelLayer(layerID: layerID)

        let iconStyle = PoiIconStyle(symbol: UIImage.iconStar, anchorPoint: CGPoint(x: 0.5, y: 0.5), badges: [])
        let poiStyle = PoiStyle(styleID: poiStyleID, styles: [
            PerLevelPoiStyle(iconStyle: iconStyle, level: 14)
        ])
        
        labelManager.addPoiStyle(poiStyle)
    }

    /** 서버로부터 받아온 장소를 표시 */
    private func render(places: [Place]) {
        guard let map = mapController?.getView("mapview") as? KakaoMap,
              let layer = poiLayer else { return }
        
        print("places:", places.count, "zoom:", (mapController?.getView("mapview") as? KakaoMap)?.zoomLevel ?? -1)
        
        print("layer exists:", poiLayer != nil, "styleID:", poiStyleID)
        
        let placeIDList = Set(places.map { $0.id })
        let toAdd = placeIDList.subtracting(visibleIDs) // 새로 추가할 place
        let toRemove = visibleIDs.subtracting(placeIDList) // 삭제할 place
        
        // 사라져야하는 poi 일괄 삭제
        if !toRemove.isEmpty {
            layer.removePois(poiIDs: Array(toRemove))
        }
        
        // 장소 추가
        if !toAdd.isEmpty {
            let addPlaces = places.filter { toAdd.contains($0.id) }
            
            // 스타일 및 고유 ID 설정
            let poiOptions: [PoiOptions] = addPlaces.map {
                let option = PoiOptions(styleID: poiStyleID, poiID: $0.id)
                option.rank = 0
                return option
            }
            
            // 위치 설정
            let positions: [MapPoint] = addPlaces.map {
                MapPoint(longitude: $0.coord.longitude, latitude: $0.coord.latitude)
            }
            
            if let created = layer.addPois(options: poiOptions, at: positions) {
                created.forEach { $0.show() } // 장소 poi 표시
            }
        }
        
        visibleIDs = placeIDList
    }

    // MARK: View Rect 생성 (+ 패딩 20%)
    private func emitCurrentRect(paddingRatio: Double = 0.2) {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        let r = map.viewRect
        print("r : \(r)")
        guard r.width > 0, r.height > 0 else { return } // ✅ 방어
        
        // 1) 화면 꼭지점(패딩 없음) → 지도 좌표
        let center = map.getPosition(CGPoint(x: r.midX, y: r.midY))
        print("center : \(center)")
        let corners = [
            CGPoint(x: r.minX, y: r.minY),
            CGPoint(x: r.maxX, y: r.minY),
            CGPoint(x: r.maxX, y: r.maxY),
            CGPoint(x: r.minX, y: r.maxY),
        ].map {
            print("$0.x: \(String(describing: $0.x)), $0.y: \(String(describing: $0.y))")
            return map.getPosition($0)
        }
        
        let centerLon = center.wgsCoord.longitude
        let centerLat = center.wgsCoord.latitude
        let lons = corners.map { $0.wgsCoord.longitude }
        let lats = corners.map { $0.wgsCoord.latitude }
        
        var left   = lons.min() ?? 0 // 서쪽 경도
        var right  = lons.max() ?? 0 // 동쪽 경도
        var bottom = lats.min() ?? 0 // 남쪽 위도
        var top    = lats.max() ?? 0 // 북쪽 위도
        
        // 현재 화면에서 20% 넓게 조회해서 받아놓은 영역 내에서 표시할 수 있게 구현
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
}

// MARK: 현재 위치 권한 설정 및 카메라 이동
extension MapViewController {
    private func setLocation() {
        let locationManager = AppLocationManager.shared
        
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
                self?.moveCamera(to: coord, level: 14)
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
    // 인증에 성공했을 경우 호출.
    func authenticationSucceeded() {
        print("kakao map 인증 성공")
    }
    
    // 인증 실패시 호출.
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        switch errorCode {
        case 400:
            print("지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            print("지도 종료(API인증 키 오류)")
            break;
        case 403:
            print("지도 종료(API인증 권한 오류)")
            break;
        case 429:
            print("지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            print("지도 종료(네트워크 오류) 5초 후 재시도..")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine() // 인증 재시도
            }
            break;
        default:
            break;
        }
    }
    
    func addViews() {
        // 여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        // 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 14)
        
        // KakaoMap 추가.
        mapController?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        // Kakao Map 위치 설정
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        map.viewRect = mapContainer.bounds
        
        createPoiStyle(on: map)

        // 현재 위치로 이동(옵션)
        setLocation()

        // 최초 rect 발행 + 카메라 이벤트 연결
        DispatchQueue.main.async { [weak self] in
            self?.emitCurrentRect() // 첫 검색 트리거
        }
        
        _ = map.addCameraStoppedEventHandler(target: self) { owner in
            return { [weak owner] _ in
                owner?.emitCurrentRect()
            }
        }
    }
    
    // addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }

    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        if let map = mapController?.getView("mapview") as? KakaoMap {
            map.viewRect = CGRect(origin: .zero, size: size)
            emitCurrentRect() // 사이즈 바뀌면 범위도 변경
        }
    }
}
