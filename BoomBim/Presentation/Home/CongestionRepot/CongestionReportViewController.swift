//
//  CongestionReportViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/12/25.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

final class CongestionReportViewController: UIViewController {
    private let viewModel: CongestionReportViewModel
    private let disposeBag = DisposeBag()
    
    private let locationManager = AppLocationManager.shared
    
    private let currentLocationSubject = PublishSubject<CLLocationCoordinate2D>()
    
    // MARK: - UI Components
    private let locationSearchView = LocationSearchFieldView()
    
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
        
        bindViewModel()
        
        setLocation()
    }
    
    // MARK: ViewModel binding
    private func bindViewModel() {
        let input = CongestionReportViewModel.Input(
            currentLocation: currentLocationSubject.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.places
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] places in
                guard let firstPlaceName = places.first?.name else { return }
                
                self?.locationSearchView.setText(firstPlaceName)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        configureNavigationBar()
        configureSearchView()
    }
    
    private func configureNavigationBar() {
        title = "혼잡도 공유"
    }
    
    private func configureSearchView() {
        view.addSubview(locationSearchView)
        locationSearchView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationSearchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            locationSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: Bind Action
    private func bindAction() {
        locationSearchView.onTapSearch = { [weak self] in
            self?.viewModel.didTapSearch()
        }
    }
}

// MARK: 현재 위치 권한 설정 및 View Rect 값 확인
extension CongestionReportViewController {
    private func setLocation() {
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
                self?.viewModel.setCurrentCoordinate(coord)
                self?.currentLocationSubject.onNext(coord)
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
