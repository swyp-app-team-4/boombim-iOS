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
    
    private var mapContainer: KMViewContainer!
    private var mapController: KMController!
    
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

// MARK: 현재 위치 권한 설정 및 카메라 이동
extension MapPickerViewController {
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
                print("coord : \(coord)")
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
extension MapPickerViewController {
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
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        // 지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 14)
        
        // KakaoMap 추가.
        mapController?.addView(mapviewInfo)
    }

    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        print("view Successed")
        // Kakao Map 위치 설정
        guard let map = mapController?.getView("mapview") as? KakaoMap else { return }
        map.viewRect = mapContainer.bounds

        // 현재 위치로 이동(옵션)
        setLocation()
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
