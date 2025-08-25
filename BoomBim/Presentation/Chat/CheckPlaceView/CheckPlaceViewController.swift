//
//  CheckPlaceViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import UIKit
import KakaoMapsSDK
import CoreLocation
import RxSwift
import RxCocoa

final class CheckPlaceViewController: BaseViewController {
    private let viewModel: CheckPlaceViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "check.label.title".localized()
        label.font = Typography.Heading01.semiBold.font
        label.textColor = .grayScale9
        label.numberOfLines = 0
        
        return label
    }()
    
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Heading03.semiBold.font
        label.textColor = .grayScale9
        label.numberOfLines = 0
        
        return label
    }()
    
    private let placeAddressLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale8
        label.numberOfLines = 0
        
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("check.button.ask".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale1, for: .normal)
        button.backgroundColor = .main
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        return button
    }()
    
    private var mapContainer: KMViewContainer!
    private var mapController: KMController!
    
    private var zoomLevel: Int = 17 // Default zoom
    private var mapPickerPoi: Poi?
    
    init(viewModel: CheckPlaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = ""
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
    }

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mapController?.isEngineActive == false { mapController?.activateEngine() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapController?.pauseEngine()
        locationManager.stopUpdatingHeading()
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
        
        configureNavigationBar()
        
        configureText()
        configureButton()
        configureMapUI()
        configureKakaoMap()
    }
    
    private func configureNavigationBar() {
        let backButton = UIButton(type: .system)
        backButton.setImage(.iconLeftArrow, for: .normal)
        backButton.tintColor = .grayScale9
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureText() {
        [titleLabel, placeNameLabel, placeAddressLabel].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeNameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 26),
            placeNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeNameLabel.heightAnchor.constraint(equalToConstant: 28),
            
            placeAddressLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor),
            placeAddressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeAddressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeAddressLabel.heightAnchor.constraint(equalToConstant: 22),
        ])
    }
    
    private func configureMapUI() {
        mapContainer = KMViewContainer()
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainer)
        
        mapContainer.layer.cornerRadius = 14
        mapContainer.clipsToBounds = true
        
        let middleGuide = UILayoutGuide()
        view.addLayoutGuide(middleGuide)
        
        NSLayoutConstraint.activate([
            middleGuide.topAnchor.constraint(equalTo: placeAddressLabel.bottomAnchor),
            middleGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            middleGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            middleGuide.bottomAnchor.constraint(equalTo: nextButton.topAnchor),
            
            mapContainer.topAnchor.constraint(equalTo: middleGuide.topAnchor, constant: 10),
            mapContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapContainer.heightAnchor.constraint(equalTo: middleGuide.heightAnchor, multiplier: 0.55)
        ])
    }
    
    private func configureKakaoMap() {
        mapController = KMController(viewContainer: mapContainer)
        mapController.delegate = self
        mapController.prepareEngine()
    }
    
    private func configureButton() {
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setText() {
        let place = viewModel.getPlace()
        
        placeNameLabel.text = place.name
        placeAddressLabel.text = place.address
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Kakao Map Camera 동작
extension CheckPlaceViewController {
    private func moveCamera(to coord: CLLocationCoordinate2D, level: Int) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let update = CameraUpdate.make(
            target: MapPoint(longitude: coord.longitude, latitude: coord.latitude),
            zoomLevel: Int(level),
            mapView: mapView
        )
        
        // ✅ 애니메이션 없이 즉시 이동
        mapView.moveCamera(update)
        
        // 필요하면 이동 직후 카메라 잠그기
        lockCamera(map: mapView)
    }
    
    func lockCamera(map: KakaoMap) {
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }

        let toDisable: [GestureType] = [
            .pan, .zoom, .doubleTapZoomIn, .twoFingerTapZoomOut,
            .oneFingerZoom, .rotate, .tilt, .rotateZoom
        ]
        toDisable.forEach { map.setGestureEnable(type: $0, enable: false) } // 제스처 OFF

        let level = map.zoomLevel
        map.cameraMinLevel = level
        map.cameraMaxLevel = level
    }
}

// MARK: Poi Layer 및 Style
extension CheckPlaceViewController {
    private func setupLocationLayerAndStyle(on map: KakaoMap) {
        let manager = map.getLabelManager()

        if manager.getLabelLayer(layerID: MapPickerConstants.Picker.layerID) == nil {
            let layer = manager.addLabelLayer(
                option: LabelLayerOptions(
                    layerID: MapPickerConstants.Picker.layerID,
                    competitionType: .none,
                    competitionUnit: .symbolFirst,
                    orderType: .rank,
                    zOrder: 1100
                )
            )
        }

        var image = UIImage.iconMapPoint
        image = image.resized(to: CGSize(width: 40, height: 40))
        
        let icon = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0), badges: [])
        let perLevel = PerLevelPoiStyle(iconStyle: icon, level: 0)
        let style = PoiStyle(styleID: MapPickerConstants.Picker.styleID, styles: [perLevel])
        manager.addPoiStyle(style)
    }

    private func ensureLocationPoi(on map: KakaoMap, at coord: CLLocationCoordinate2D) {
        let manager = map.getLabelManager()
        let layer = manager.getLabelLayer(layerID: MapPickerConstants.Picker.layerID)
        let mp = MapPoint(longitude: coord.longitude, latitude: coord.latitude)
        
        if let pickerPoi = mapPickerPoi {
            layer?.removePoi(poiID: MapPickerConstants.Picker.poiID) // 기존 Poi 삭제
            mapPickerPoi = nil
        }
        
        var poiOption = PoiOptions(styleID: MapPickerConstants.Picker.styleID, poiID: MapPickerConstants.Picker.poiID)
//        poiOption.clickable = true
        mapPickerPoi = layer?.addPoi(option: poiOption, at: mp)

        mapPickerPoi?.show()
    }
}

// MARK: Kakao Map Delegate
extension CheckPlaceViewController: MapControllerDelegate {
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
        let defaultPosition: MapPoint = MapPoint(
            longitude: viewModel.getPlace().coord.longitude, latitude: viewModel.getPlace().coord.latitude)
        
        print("viewModel.getCurrentLocation().longitude : \(viewModel.getPlace().coord.longitude)")
        print("viewModel.getCurrentLocation().latitude : \(viewModel.getPlace().coord.latitude)")
        // 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: zoomLevel)
        
        // KakaoMap 추가.
        mapController?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("view Successed")
        // Kakao Map 위치 설정
        guard let mapview = mapController?.getView("mapview") as? KakaoMap else { return }
        mapview.viewRect = mapContainer.bounds
        let coord = viewModel.getPlace().coord
        
        setupLocationLayerAndStyle(on: mapview)
        ensureLocationPoi(on: mapview, at: coord)
        
        moveCamera(to: coord, level: zoomLevel)
    }
    
    // addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    func containerDidResized(_ size: CGSize) {
        if let map = mapController?.getView("mapview") as? KakaoMap {
            map.viewRect = CGRect(origin: .zero, size: size)
        }
    }
}
