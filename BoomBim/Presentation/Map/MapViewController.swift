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

final class MapViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let viewModel: MapViewModel
    
    private var mapContainer: KMViewContainer!
    private var mapController: KMController!
    private var authed = false
    
    private var didAddSamplePOIs = false
    private var registeredStyleIDs = Set<String>() // map 인스턴스 기준으로 관리
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "지도"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    // MARK: Life cycle
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        
        // KMController 생성
        mapController = KMController(viewContainer: mapContainer)
        mapController.delegate = self
        
        mapController.prepareEngine() // 엔진 prepare
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapController?.pauseEngine()  //렌더링 중지.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapController?.resetEngine()     //엔진 정지. 추가되었던 ViewBase들이 삭제된다.
    }
    
    // MARK: Set up
    private func setupUI() {
        setupMapUI()
    }
    
    private func setupMapUI() {
        mapContainer = KMViewContainer()
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainer)
        
        NSLayoutConstraint.activate([
            mapContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setLocation() {
        AppLocationManager.shared.requestWhenInUseAuthorization()
        
        // 최초 한 번만 받아서 카메라 이동
        AppLocationManager.shared.requestOneShotLocation(timeout: 5)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] loc in
                print("loc : \(loc)")
                print("loc : \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                self?.moveCamera(to: loc.coordinate, level: 14)
            }, onFailure: { error in
                print("현재 위치 실패:", error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        AppLocationManager.shared.startUpdatingLocation()
    }
    
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

extension MapViewController: MapControllerDelegate {
    // 인증에 성공했을 경우 호출.
    func authenticationSucceeded() {
        print("kakao map 인증 성공")
        authed = true
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
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }
    
    func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
        
        mapController?.addView(mapviewInfo)
    }
    
    // addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("OK") //추가 성공. 성공시 추가적으로 수행할 작업을 진행한다.
        
        if let mapView = mapController?.getView("mapview") as? KakaoMap {
            mapView.viewRect = mapContainer.bounds
        }
        
        setLocation()
        
        addSamplePOIs()
    }
    
    // addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    // Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        if let mapView = mapController?.getView("mapview") as? KakaoMap {
            mapView.viewRect = CGRect(origin: .zero, size: size) // 지도뷰의 크기를 리사이즈된 크기로 지정한다.
        }
    }
}

// MARK: 임의로 좌표를 생성해서 확인
extension MapViewController {

    private func makeRandomSeoulCoords(_ count: Int) -> [CLLocationCoordinate2D] {
        // 대략 서울 바운딩 박스(필요시 조정)
        let latRange: ClosedRange<Double> = 37.4133...37.7151
        let lonRange: ClosedRange<Double> = 126.7341...127.2693

        func rand(_ r: ClosedRange<Double>) -> Double {
            let t = Double.random(in: 0...1)
            return r.lowerBound + (r.upperBound - r.lowerBound) * t
        }

        return (0..<count).map { _ in
            CLLocationCoordinate2D(latitude: rand(latRange), longitude: rand(lonRange))
        }
    }

    // POI 추가 (addViewSucceeded에서 호출 권장)
    private func addSamplePOIs() {
        guard !didAddSamplePOIs else { return } // 중복 추가 방지
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }

        let labelMgr = mapView.getLabelManager()
        let layerID = "PoiLayer"
        let styleID = "BasicPoi"

        // (1) 레이어 보장
        if labelMgr.getLabelLayer(layerID: layerID) == nil {
            let opt = LabelLayerOptions(
                layerID: layerID,
                competitionType: .none,
                competitionUnit: .symbolFirst,
                orderType: .rank,
                zOrder: 0
            )
            _ = labelMgr.addLabelLayer(option: opt)
        }
        guard let layer = labelMgr.getLabelLayer(layerID: layerID) else { return }

        // (2) 스타일 보장 (PNG 에셋 사용! SF Symbols 금지)
        if !registeredStyleIDs.contains(styleID) {
            let image = UIImage.iconStar
            let icon = PoiIconStyle(
                symbol: image,
                anchorPoint: CGPoint(x: 0.5, y: 1.0),
                badges: []
            )
            // 줌 레벨 12부터 보이게(원하시면 조정)
            let perLevel = PerLevelPoiStyle(iconStyle: icon, level: 12)
            let style = PoiStyle(styleID: styleID, styles: [perLevel])
            labelMgr.addPoiStyle(style)
            registeredStyleIDs.insert(styleID)
        }

        // (3) 임의 좌표 50개 추가
        let coords = makeRandomSeoulCoords(50)
        print("coords : \(coords.count)")
        for (idx, c) in coords.enumerated() {
            var opt = PoiOptions(styleID: styleID)
            opt.rank = 0

            let pt = MapPoint(longitude: c.longitude, latitude: c.latitude)
            let poi = layer.addPoi(option: opt, at: pt)
            poi?.show()
        }

        didAddSamplePOIs = true
    }

}
