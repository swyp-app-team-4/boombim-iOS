//
//  MapPickerViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import KakaoMapsSDK
import CoreLocation
import RxSwift
import RxCocoa

final class MapPickerViewController: UIViewController {
    private let viewModel: MapPickerViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    private var mapContainer: KMViewContainer!
    private var mapController: KMController!
    
    private var zoomLevel: Int = 18 // Default zoom
    
    private var currentBodyPoi: Poi?
    private var currentArrowPoi: Poi?
    private var mapPickerPoi: Poi?
    
    init(viewModel: MapPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "지도 선택"
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
        print("please mappicker")
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mapController?.isEngineActive == false { mapController?.activateEngine() }
        
        setHeading()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.locationManager.setHeadingOrientation(self.currentCLDeviceOrientation())
        }
    }
    
    // MARK: UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        configureMapUI()
        configureKakaoMap()
    }
    
    private func configureMapUI() {
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
    
    private func configureKakaoMap() {
        mapController = KMController(viewContainer: mapContainer)
        mapController.delegate = self
        mapController.prepareEngine()
    }
}

// MARK: - Poi Image 생성
extension MapPickerViewController {
    // 주황색 내부 원 + 흰색 외곽 원 + 그림자
    func makeCurrentBodyIcon(diameter: CGFloat = 15) -> UIImage {
        let blur: CGFloat = 6
        let offset = CGSize(width: 0, height: 2)

        // 그림자가 잘리지 않도록 캔버스에 여유 공간을 확보
        let padX = blur * 2 + abs(offset.width)
        let padY = blur * 2 + abs(offset.height)
        let canvas = CGSize(width: diameter + padX * 2, height: diameter + padY * 2)

        let outerR = diameter * 0.5
        let innerR = diameter * 0.3

        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: canvas, format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setAllowsAntialiasing(true)
            cg.setShouldAntialias(true)

            // 실제 도형은 패딩만큼 안쪽으로 평행이동해서 그림
            cg.translateBy(x: padX, y: padY)

            // 바깥 흰 원 + 그림자
            let outerRect = CGRect(
                x: (diameter / 2) - outerR,
                y: (diameter / 2) - outerR,
                width: outerR * 2,
                height: outerR * 2
            )
            cg.setShadow(offset: offset, blur: blur, color: UIColor.black.withAlphaComponent(0.25).cgColor)
            cg.setFillColor(UIColor.white.cgColor)
            cg.addEllipse(in: outerRect)
            cg.fillPath()

            // 내부 주황 원(그림자 없음)
            cg.setShadow(offset: .zero, blur: 0, color: nil)
            let innerRect = CGRect(
                x: (diameter / 2) - innerR,
                y: (diameter / 2) - innerR,
                width: innerR * 2,
                height: innerR * 2
            )
            cg.setFillColor(UIColor.systemOrange.cgColor)
            cg.addEllipse(in: innerRect)
            cg.fillPath()
        }.withRenderingMode(.alwaysOriginal)
    }

    func makeDirectionArrowIcon(
        diameter: CGFloat = 15,
        angle: CGFloat = 0,
        gap: CGFloat = 2,
        arrowLength: CGFloat = 6,
        baseWidth: CGFloat = 5
    ) -> UIImage {
        let R = diameter * 0.5
        let halfW = baseWidth * 0.5
        
        // 그림자 여유 공간
        let shadowBlur: CGFloat = 3
        let shadowOffset = CGSize(width: 0, height: 1)
        let pad: CGFloat = gap + arrowLength + shadowBlur + max(abs(shadowOffset.width), abs(shadowOffset.height))
        
        let canvas = CGSize(width: diameter + pad * 2, height: diameter + pad * 2)
        let center = CGPoint(x: canvas.width / 2, y: canvas.height / 2)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: canvas, format: format)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.setAllowsAntialiasing(true)
            cg.setShouldAntialias(true)
            
            // 원 중심으로 이동 후 회전
            cg.translateBy(x: center.x, y: center.y)
            cg.rotate(by: angle)
            
            let baseY = -(R + gap)
            let tipY  = baseY - arrowLength
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: tipY))
            path.addLine(to: CGPoint(x: -halfW, y: baseY))
            path.addLine(to: CGPoint(x:  halfW, y: baseY))
            path.close()
            
            // 그림자
            cg.setShadow(offset: shadowOffset, blur: shadowBlur, color: UIColor.black.withAlphaComponent(0.25).cgColor)
            
            // 클리핑해서 그라디언트 채우기
            cg.saveGState()
            cg.addPath(path.cgPath)
            cg.clip()
            
            let colors = [UIColor.systemOrange.withAlphaComponent(1).cgColor,
                          UIColor.systemOrange.withAlphaComponent(0.85).cgColor] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]
            let space = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: space, colors: colors, locations: locations) {
                cg.drawLinearGradient(gradient,
                                      start: CGPoint(x: 0, y: tipY),
                                      end: CGPoint(x: 0, y: baseY),
                                      options: [])
            }
            cg.restoreGState()
            
            // 외곽선 얇게
            cg.setShadow(offset: .zero, blur: 0)
            cg.addPath(path.cgPath)
            cg.setStrokeColor(UIColor.black.withAlphaComponent(0.15).cgColor)
            cg.setLineWidth(0.5)
            cg.strokePath()
        }
    }
}

// MARK: 카메라 이동
extension MapPickerViewController {
    private func setHeading() {
        // 시작: 5도 이상 변화 시 콜백, 현재 UI 방향 반영(필요 시 조정)
        locationManager.startUpdatingHeading(
            filter: 5,
            orientation: currentCLDeviceOrientation()
        )
        
        // 구독: degree(0~360) → 카카오 POI 삼각형 회전
        locationManager.headingDegrees
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] deg in
                self?.updateHeading(deg)   // ← 이전에 구현한 "삼각형 POI 회전" 함수
            })
            .disposed(by: disposeBag)
    }
    
    // UIDevice → CLDeviceOrientation 매핑
    private func currentCLDeviceOrientation() -> CLDeviceOrientation {
        switch UIDevice.current.orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight   // 카메라/센서 기준이 반대일 수 있어 교차 매핑 권장
        case .landscapeRight: return .landscapeLeft
        default: return .portrait
        }
    }
}

// MARK: Kakao Map Camera 동작
extension MapPickerViewController {
    private func moveCamera(to coord: CLLocationCoordinate2D, level: Int) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let update = CameraUpdate.make(
            target: MapPoint(longitude: coord.longitude, latitude: coord.latitude),
            zoomLevel: Int(level),
            mapView: mapView
        )
        
        mapView.animateCamera(cameraUpdate: update, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 0)) { [weak self] in
            guard let self else { return }
            self.lockCamera(map: mapView)
        }
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
extension MapPickerViewController {
    // MARK: - Set up Poi layer & Style
    func setupCurrentLocationLayersAndStyles(on map: KakaoMap) {
        let manager = map.getLabelManager()

        // 1) 레이어 생성
        if manager.getLabelLayer(layerID: CurrentMarkerConstants.Body.layerID) == nil {
            _ = manager.addLabelLayer(
                option: LabelLayerOptions(layerID: CurrentMarkerConstants.Body.layerID,
                                          competitionType: .none,
                                          competitionUnit: .symbolFirst,
                                          orderType: .rank,
                                          zOrder: 1000)
            )
        }
        if manager.getLabelLayer(layerID: CurrentMarkerConstants.Arrow.layerID) == nil {
            _ = manager.addLabelLayer(
                option: LabelLayerOptions(layerID: CurrentMarkerConstants.Arrow.layerID,
                                          competitionType: .none,
                                          competitionUnit: .symbolFirst,
                                          orderType: .rank,
                                          zOrder: 1001) // 화살표가 위에 오도록
            )
        }

        // 2) 스타일(아이콘) 등록 — 스타일은 preset처럼 재사용 권장
        let bodyImage = makeCurrentBodyIcon()
        let bodyIcon = PoiIconStyle(symbol: bodyImage,
                                anchorPoint: CGPoint(x: 0.5, y: 0.5),
                                badges: [])
        let bodyPerLevel = PerLevelPoiStyle(iconStyle: bodyIcon, level: 0)
        let bodyStyle = PoiStyle(styleID: CurrentMarkerConstants.Body.styleID, styles: [bodyPerLevel])
        manager.addPoiStyle(bodyStyle)
        
        let arrowImage = makeDirectionArrowIcon()
        let arrowIcon = PoiIconStyle(symbol: arrowImage,
                                anchorPoint: CGPoint(x: 0.5, y: 0.5),
                                badges: [])
        let arrowPerLevel = PerLevelPoiStyle(iconStyle: arrowIcon, level: 0)
        let arrowStyle = PoiStyle(styleID: CurrentMarkerConstants.Arrow.styleID, styles: [arrowPerLevel])
        manager.addPoiStyle(arrowStyle)
    }

    func ensureCurrentLocationPois(on map: KakaoMap, at coord: CLLocationCoordinate2D) {
        let manager = map.getLabelManager()
        let bodyLayer = manager.getLabelLayer(layerID: CurrentMarkerConstants.Body.layerID)
        let arrowLayer = manager.getLabelLayer(layerID: CurrentMarkerConstants.Arrow.layerID)
        let mp = MapPoint(longitude: coord.longitude, latitude: coord.latitude)

        if currentBodyPoi == nil {
            var opt = PoiOptions(styleID: CurrentMarkerConstants.Body.styleID, poiID: CurrentMarkerConstants.Body.poiID)
            opt.rank = 1
            opt.transformType = .decal
            currentBodyPoi = bodyLayer?.addPoi(option: opt, at: mp)
            currentBodyPoi?.show()
        } else {
            currentBodyPoi?.position = mp
        }

        if currentArrowPoi == nil {
            var opt = PoiOptions(styleID: CurrentMarkerConstants.Arrow.styleID, poiID: CurrentMarkerConstants.Arrow.poiID)
            opt.rank = 2
            opt.transformType = .absoluteRotationDecal // 카메라 회전에 영향받지 않는 절대 회전 :contentReference[oaicite:5]{index=5}
            currentArrowPoi = arrowLayer?.addPoi(option: opt, at: mp)
            currentArrowPoi?.show()

            // 위치만 공유 (회전은 별도로 heading에서 갱신)
            currentArrowPoi?.sharePositionWithPoi(currentBodyPoi!) // :contentReference[oaicite:6]{index=6}
        } else {
            currentArrowPoi?.position = mp
        }
    }
    
    private func setupPickedLocationLayerAndStyle(on map: KakaoMap) {
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

        let image = UIImage.iconMap
        let icon = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0), badges: [])
        let perLevel = PerLevelPoiStyle(iconStyle: icon, level: 0)
        let style = PoiStyle(styleID: MapPickerConstants.Picker.styleID, styles: [perLevel])
        manager.addPoiStyle(style)
    }

    private func ensurePickedPoi(on map: KakaoMap, at coord: CLLocationCoordinate2D) {
        let manager = map.getLabelManager()
        let layer = manager.getLabelLayer(layerID: MapPickerConstants.Picker.layerID)
        let mp = MapPoint(longitude: coord.longitude, latitude: coord.latitude)
        
        if let pickerPoi = mapPickerPoi {
            layer?.removePoi(poiID: MapPickerConstants.Picker.poiID) // 기존 Poi 삭제
            mapPickerPoi = nil
        }
        
        var poiOption = PoiOptions(styleID: MapPickerConstants.Picker.styleID, poiID: MapPickerConstants.Picker.poiID)
        poiOption.clickable = true
        mapPickerPoi = layer?.addPoi(option: poiOption, at: mp)

        mapPickerPoi?.show()
    }

    // MARK: - Poi Action
    // 헤딩(방향) 갱신 — CLHeading의 각도를 라디안으로 바꿔서 arrow POI에만 적용
    func updateHeading(_ degrees: CLLocationDirection) {
        guard let arrow = currentArrowPoi else { return }

        let rad = CGFloat(degrees) * .pi / 180.0
        arrow.rotateAt(rad, duration: 150)
    }
    
    private func poiTappedHandler(_ eventParam: PoiInteractionEventParam, coord: CLLocationCoordinate2D) {
        print("poiTappedHandler : \(coord.latitude), \(coord.longitude)")
    }
    
//    private func handleSingleTap(on map: KakaoMap, mapPoint: MapPoint) {
//        // 1) 좌표 → CLLocationCoordinate2D
//        let coord = CLLocationCoordinate2D(latitude: mapPoint.wgsY, longitude: mapPoint.wgsX)
//
//        // 2) POI 추가/갱신
//        ensurePickedPoi(on: map, at: coord)
//
//        // 3) Alert 표시 (위도/경도 타이틀 + TextField)
//        presentPickAlert(for: coord) { [weak self] name in
//            guard let self else { return }
//            // 저장/전달이 필요하면 ViewModel로 Emit/바인딩
//            self.viewModel.didPickLocation(name: name, latitude: coord.latitude, longitude: coord.longitude)
//            // 필요 시 화면 닫기나 토스트 처리 등
//        }
//    }
}

// MARK: Kakao Map Delegate
extension MapPickerViewController: MapControllerDelegate {
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
            longitude: viewModel.getCurrentLocation().longitude, latitude: viewModel.getCurrentLocation().latitude)
        
        print("viewModel.getCurrentLocation().longitude : \(viewModel.getCurrentLocation().longitude)")
        print("viewModel.getCurrentLocation().latitude : \(viewModel.getCurrentLocation().latitude)")
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
        mapview.eventDelegate = self
        let coord = viewModel.getCurrentLocation()
        
        setupCurrentLocationLayersAndStyles(on: mapview)
        setupPickedLocationLayerAndStyle(on: mapview)
        
        ensureCurrentLocationPois(on: mapview, at: coord)
        
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

extension MapPickerViewController: KakaoMapEventDelegate {
    func kakaoMapDidTapped(kakaoMap: KakaoMap, point: CGPoint) {
        let mapPoint = kakaoMap.getPosition(point)
        let coord = CLLocationCoordinate2D(latitude: mapPoint.wgsCoord.latitude, longitude: mapPoint.wgsCoord.longitude)
        
        if let mapPickerPoiPosition = mapPickerPoi?.position {
            let distance = Primitives.distance(p1: kakaoMap.getPosition(point), p2: mapPickerPoiPosition)
            if distance < 20 {
                return
            } else {
                ensurePickedPoi(on: kakaoMap, at: coord)
            }
            
        } else {
            ensurePickedPoi(on: kakaoMap, at: coord)
        }
    }
    
    func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
        guard let layer = kakaoMap.getLabelManager().getLabelLayer(layerID: layerID),
              let poi = layer.getPoi(poiID: poiID) else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: poi.position.wgsCoord.latitude, longitude: poi.position.wgsCoord.longitude)
        
        presentPickAlert(for: coordinate) { string in
            print("string : \(string)")
        }
    }
}

// MARK: - Alert View
extension MapPickerViewController {
    private func presentPickAlert(for coord: CLLocationCoordinate2D, onSave: @escaping (String) -> Void) {
        let lat = String(format: "%.6f", coord.latitude)
        let lon = String(format: "%.6f", coord.longitude)

        let alert = UIAlertController(
            title: "위도 \(lat), 경도 \(lon)",
            message: "장소 이름을 입력하세요",
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "예) 강남역 11번 출구"
            tf.autocapitalizationType = .none
            tf.clearButtonMode = .whileEditing
        }

        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let save = UIAlertAction(title: "저장", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            onSave(name)
        }

        alert.addAction(cancel)
        alert.addAction(save)
        present(alert, animated: true, completion: nil)
    }
}
