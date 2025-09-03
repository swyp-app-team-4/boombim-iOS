//
//  CheckPlaceViewModel.swift
//  BoomBim
//
//  Created by 조영현 on 8/25/25.
//

import CoreLocation
import RxSwift
import RxCocoa

final class CheckPlaceViewModel {
    enum Mode {
        case justComplete, returnPlace
    }
    
    private let disposeBag = DisposeBag()
    private let loading = BehaviorRelay<Bool>(value: false)
    var loadingDriver: Driver<Bool> { loading.asDriver() }
    private let errorRelay = PublishRelay<String>()
    var errorSignal: Signal<String> { errorRelay.asSignal() }
    
    var onComplete: (() -> Void)?
    var onPlaceComplete: ((Place, Int) -> Void)?
    
    private let place: Place
    private let userLocation: CLLocationCoordinate2D
    private let mode: Mode
    
    init(place: Place, userLocation: CLLocationCoordinate2D, mode: Mode) {
        self.place = place
        self.userLocation = userLocation
        self.mode = mode
    }
    
    func getPlace() -> Place {
        return place
    }
    
    func didTapNext() {
        switch mode {
        case .justComplete:
            performCreateVote()
        case .returnPlace:
            performRegisterPlace()
        }
    }
    
    func performCreateVote() {
        let body: CreateVoteRequest = .init(
            posId: place.id,
            posLatitude: place.coord.latitude,
            posLongitude: place.coord.longitude,
            userLatitude: userLocation.latitude,
            userLongitude: userLocation.longitude,
            posName: place.name
        )
        
        print("preformCreateVote : \(body)")
        
        VoteService.shared.createVote(body)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                guard let self else { return }
                self.loading.accept(false)
                
                self.onComplete?()
            }, onFailure: { [weak self] error in
                guard let self else { return }
                self.loading.accept(false)
                if let e = error as? CreateVoteError {
                    self.errorRelay.accept(e.localizedDescription)
                } else {
                    self.errorRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func performRegisterPlace() {
        let body: RegisterPlaceRequest = .init(
            uuid: place.id,
            name: place.name,
            latitude: place.coord.latitude,
            longitude: place.coord.longitude)
        
        print("performRegisterPlace : \(body)")
        
        PlaceService.shared.registerReport(body: body)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] response in
                guard let self else { return }
                self.loading.accept(false)
                
                self.onPlaceComplete?(place, response.data.memberPlaceId)
            }, onFailure: { [weak self] error in
                guard let self else { return }
                self.loading.accept(false)
                if let e = error as? CreateVoteError {
                    self.errorRelay.accept(e.localizedDescription)
                } else {
                    self.errorRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
}
