//
//  CongestionReportViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import KakaoMapsSDK
import CoreLocation
import RxSwift
import RxCocoa

final class CongestionReportViewController: BaseViewController {
    private let viewModel: CongestionReportViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    private let currentLocationSubject = PublishSubject<CLLocationCoordinate2D>()
    
    private var isMapPrepared = false
    
    private var mapHeightRatioConstraint: NSLayoutConstraint!
    private var voteTopToMap: NSLayoutConstraint!
    private var voteTopToLocation: NSLayoutConstraint!
    private var didCallAddViews = false
    
    // MARK: - UI Components
    private let timeContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconTime
        imageView.tintColor = .grayScale9
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let timeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .left
        label.text = "report.label.title.time".localized()
        label.sizeToFit()
        
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.regular.font
        label.textColor = .grayScale8
        label.textAlignment = .left
        label.text = AppDateFormatter.koChatDateTime.string(from: Date())
        
        return label
    }()
    
    private let locationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconPin
        imageView.tintColor = .grayScale9
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .left
        label.text = "report.label.title.location".localized()
        label.sizeToFit()
        
        return label
    }()
    
    private let locationTextField: AppSearchTextField = {
        let textField = AppSearchTextField()
        textField.tapOnly = true
        
        return textField
    }()
    
    private var mapContainer: KMViewContainer!
    private var mapController: KMController!
    
    private var zoomLevel: Int = 17 // Default zoom
    private var mapPickerPoi: Poi?
    
    private let voteContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let voteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .iconVote
        imageView.tintColor = .grayScale9
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let voteTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Typography.Body02.medium.font
        label.textColor = .grayScale10
        label.textAlignment = .left
        label.text = "report.label.title.vote".localized()
        label.sizeToFit()
        
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let relaxedButton = makeButton(off: .buttonLargeUnselectedRelaxed, on: .buttonLargeSelectedRelaxed, disable: .buttonLargeDefaultRelaxed)
    private let normalButton  = makeButton(off: .buttonLargeUnselectedNormal, on: .buttonLargeSelectedNormal, disable: .buttonLargeDefaultNormal)
    private let busyButton   = makeButton(off: .buttonLargeUnselectedBusy, on: .buttonLargeSelectedBusy, disable: .buttonLargeDefaultBusy)
    private let crowdedButton = makeButton(off: .buttonLargeUnselectedCrowded, on: .buttonLargeSelectedCrowded, disable: .buttonLargeDefaultCrowded)
    
    private lazy var buttons: [UIButton] = [relaxedButton, normalButton, busyButton, crowdedButton]
    
    private static func makeButton(off: UIImage, on: UIImage, disable: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(disable, for: .disabled)
        button.setImage(off, for: .normal)
        button.setImage(on,  for: .selected)
        button.setImage(on,  for: [.selected, .highlighted])
        
        return button
    }
    
    private lazy var descriptionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.grayScale4.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = Typography.Body03.medium.font
        
        return textView
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "report.label.placeholder".localized()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale7
        
        return label
    }()
    
    private let descriptionCount: UILabel = {
        let label = UILabel()
        label.font = Typography.Body03.regular.font
        label.textColor = .grayScale7
        
        return label
    }()
    
    init(viewModel: CongestionReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindAction()
        setActions()
        
        bind()
    }
    
    private func bind() {
        viewModel.selectedPlace
            .compactMap { $0 }                // nil은 무시
        // .distinctUntilChanged()        // Place가 Equatable이면 중복 갱신 방지
            .drive(with: self) { vc, place in
                print("place : \(place)")
                vc.locationTextField.text = place.name
                
                if !vc.isMapPrepared {
                    // 최초 진입: 지도 준비 + 컨테이너 표시
                    vc.showMapSection()
                    vc.configureKakaoMap()          // prepareEngine() 호출 (아래 4번 참고)
                    vc.isMapPrepared = true
                    // addViews → addViewSucceeded delegate가 이어서 불립니다.
                } else {
                    // 이미 지도 존재: 위치/POI만 갱신
                    vc.updateMap(for: place)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        
        configureTime()
        configureLocation()
        configureMapUI()
//        configureKakaoMap()
        configureVote()
        configureTextView()
    }
    
    private func configureNavigationBar() {
        self.title = "알리기"
        
        let backButton = UIButton(type: .system)
        backButton.setImage(.iconLeftArrow, for: .normal)
        backButton.tintColor = .grayScale9
        backButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func configureTime() {
        timeContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeContainerView)
        
        [timeImageView, timeTitleLabel, timeLabel].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            timeContainerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            timeContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timeContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            timeContainerView.heightAnchor.constraint(equalToConstant: 24),
            
            timeImageView.centerYAnchor.constraint(equalTo: timeContainerView.centerYAnchor),
            timeImageView.leadingAnchor.constraint(equalTo: timeContainerView.leadingAnchor),
            timeImageView.widthAnchor.constraint(equalToConstant: 18),
            timeImageView.heightAnchor.constraint(equalToConstant: 18),
            
            timeTitleLabel.topAnchor.constraint(equalTo: timeContainerView.topAnchor),
            timeTitleLabel.bottomAnchor.constraint(equalTo: timeContainerView.bottomAnchor),
            timeTitleLabel.leadingAnchor.constraint(equalTo: timeImageView.trailingAnchor, constant: 4),
            
            timeLabel.topAnchor.constraint(equalTo: timeContainerView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: timeContainerView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: timeTitleLabel.trailingAnchor, constant: 10)
        ])
    }
    
    private func configureLocation() {
        locationContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationContainerView)
        
        [locationImageView, locationTitleLabel, locationTextField].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            locationContainerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            locationContainerView.topAnchor.constraint(equalTo: timeContainerView.bottomAnchor, constant: 18),
            locationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            locationImageView.centerYAnchor.constraint(equalTo: locationTitleLabel.centerYAnchor),
            locationImageView.leadingAnchor.constraint(equalTo: locationContainerView.leadingAnchor),
            locationImageView.widthAnchor.constraint(equalToConstant: 18),
            locationImageView.heightAnchor.constraint(equalToConstant: 18),
            
            locationTitleLabel.topAnchor.constraint(equalTo: locationContainerView.topAnchor),
            locationTitleLabel.leadingAnchor.constraint(equalTo: timeImageView.trailingAnchor, constant: 4),
            
            locationTextField.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 10),
            locationTextField.bottomAnchor.constraint(equalTo: locationContainerView.bottomAnchor),
            locationTextField.leadingAnchor.constraint(equalTo: locationContainerView.leadingAnchor),
            locationTextField.trailingAnchor.constraint(equalTo: locationContainerView.trailingAnchor),
        ])
    }
    
    private func configureMapUI() {
        mapContainer = KMViewContainer()
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapContainer)
        
        mapContainer.layer.cornerRadius = 14
        mapContainer.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            mapContainer.topAnchor.constraint(equalTo: locationContainerView.bottomAnchor, constant: 10),
            mapContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        
        // 높이 비율 제약 보관
        mapHeightRatioConstraint = mapContainer.heightAnchor.constraint(equalTo: mapContainer.widthAnchor, multiplier: 0.4)
        
        // 초기 상태: 맵 숨김
        mapContainer.isHidden = true
        mapHeightRatioConstraint.isActive = false
    }
    
    private func showMapSection() {
        // 제약 토글
        voteTopToLocation.isActive = false
        voteTopToMap.isActive = true
        mapHeightRatioConstraint.isActive = true

        mapContainer.isHidden = false
        view.layoutIfNeeded()
        print("뷰 초기화")
    }
    
    private func configureKakaoMap() {
        print("prepareEngine() start")
        mapController = KMController(viewContainer: mapContainer)
        mapController.delegate = self
        mapController.prepareEngine()
    }
    
    private func configureVote() {
        voteContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voteContainerView)
        
        buttons.forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(button)
        }
        
        [voteImageView, voteTitleLabel, buttonStackView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            voteContainerView.addSubview(view)
        }
        
        // vote의 top 제약 두 개를 만들고 보관
        voteTopToMap = voteContainerView.topAnchor.constraint(equalTo: mapContainer.bottomAnchor, constant: 18)
        voteTopToLocation = voteContainerView.topAnchor.constraint(equalTo: locationContainerView.bottomAnchor, constant: 18)
        
        voteTopToMap.isActive = false
        voteTopToLocation.isActive = true
        
        NSLayoutConstraint.activate([
//            voteContainerView.topAnchor.constraint(equalTo: mapContainer.bottomAnchor, constant: 18),
            voteContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            voteContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            voteContainerView.heightAnchor.constraint(equalToConstant: 128),
            
            voteImageView.centerYAnchor.constraint(equalTo: voteTitleLabel.centerYAnchor),
            voteImageView.leadingAnchor.constraint(equalTo: voteContainerView.leadingAnchor),
            voteImageView.widthAnchor.constraint(equalToConstant: 18),
            voteImageView.heightAnchor.constraint(equalToConstant: 18),
            
            voteTitleLabel.topAnchor.constraint(equalTo: voteContainerView.topAnchor),
            voteTitleLabel.leadingAnchor.constraint(equalTo: voteImageView.trailingAnchor, constant: 4),
            
            buttonStackView.topAnchor.constraint(equalTo: voteTitleLabel.bottomAnchor, constant: 10),
            buttonStackView.bottomAnchor.constraint(equalTo: voteContainerView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: voteContainerView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: voteContainerView.trailingAnchor),
        ])
        
        buttonSetting()
    }
    
    private func buttonSetting() {
        buttons.forEach { button in
            button.isEnabled = false
        }
    }
    
    private func configureTextView() {
        descriptionContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionContainerView)
        
        [descriptionTextView, descriptionPlaceholder, descriptionCount].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            descriptionContainerView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            descriptionContainerView.topAnchor.constraint(equalTo: voteContainerView.bottomAnchor, constant: 18),
            descriptionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionContainerView.heightAnchor.constraint(equalToConstant: 165),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor, constant: 12),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionCount.topAnchor, constant: 4),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -16),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 12),
            descriptionPlaceholder.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor),
            
            descriptionCount.bottomAnchor.constraint(equalTo: descriptionContainerView.bottomAnchor, constant: -12),
            descriptionCount.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor, constant: -16),
        ])
        
        descriptionTextView.delegate = self
    }
    
    // MARK: Bind Action
    private func bindAction() {
        
    }
    
    private func setActions() {
        didTapLocation()
    }
    
    private func didTapLocation() {
        locationTextField.onTap = { [weak self] in
            self?.viewModel.didTapSearch()
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

extension CongestionReportViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
        updateCounter()
    }
    
    private func updateCounter() {
        descriptionCount.text = "\(descriptionTextView.text.count)/\(500)자"
    }
}

// MARK: Kakao Map Camera 동작
extension CongestionReportViewController {
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
        let toDisable: [GestureType] = [
            .pan, .zoom, .doubleTapZoomIn, .twoFingerTapZoomOut,
            .oneFingerZoom, .rotate, .tilt, .rotateZoom
        ]
        toDisable.forEach { map.setGestureEnable(type: $0, enable: false) }

        let level = map.zoomLevel
        map.cameraMinLevel = level
        map.cameraMaxLevel = level
    }
}

// MARK: Poi Layer 및 Style
extension CongestionReportViewController {
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
extension CongestionReportViewController: MapControllerDelegate {
    // 인증에 성공했을 경우 호출.
    func authenticationSucceeded() {
        print("kakao map 인증 성공")

        // ✅ 인증 직후에 1회만 직접 addViews 호출
        guard !didCallAddViews else { return }
        didCallAddViews = true
        DispatchQueue.main.async { [weak self] in
            self?.addViews()
        }
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
        print("addViews")
        // 여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
        let coord = viewModel.currentSelectedPlace?.coord ?? CLLocationCoordinate2D(latitude: 37.382605, longitude: 127.136328)
        
        let defaultPosition = MapPoint(
            longitude: coord.longitude,   // 경도
            latitude:  coord.latitude     // 위도
        )
        
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
        let coord = viewModel.currentSelectedPlace?.coord ?? .init(latitude: 37.382605, longitude: 127.136328)
        
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
    
    private func updateMap(for place: Place) {
        guard let mapview = mapController?.getView("mapview") as? KakaoMap else { return }
        setupLocationLayerAndStyle(on: mapview)       // idempotent하게 작성됨
        ensureLocationPoi(on: mapview, at: place.coord)
        moveCamera(to: place.coord, level: zoomLevel)
    }
}
