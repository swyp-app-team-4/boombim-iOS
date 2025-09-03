//
//  TokenManager.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import Foundation
import RxSwift
import RxCocoa

/// 인증 상태 표현: 라우팅/화면 전환에 활용
public enum AuthState: Equatable {
    case loggedOut
    case loggedIn
    case refreshing
}

public enum AuthError: Error {
    case refreshExpired     // refresh가 만료/폐기됨 → 재로그인 필요
    case invalidTokens      // 토큰 자체가 손상/없음
    case network(Error)     // 네트워크 에러 래핑
}

/// 우리 백엔드의 access/refresh 수명 관리를 전담하는 매니저.
/// - Keychain에서 TokenPair를 로드/저장
/// - access 만료 시 refresh로 갱신
/// - 여러 API가 동시에 401을 맞아도 refresh는 "한 번만" 수행하고 결과 공유
public final class TokenManager {

    private static var _shared: TokenManager?
    public static var shared: TokenManager {
        guard let inst = _shared else {
            fatalError("TokenManager not configured. Call TokenManager.configure(...) at app launch.")
        }
        return inst
    }
    
    public static func configure(store: KeychainTokenStore<TokenPair>) {
        precondition(_shared == nil, "TokenManager configured twice")
        _shared = TokenManager(store: store)
    }

    private let store: KeychainTokenStore<TokenPair>    // 실제 저장소
    private let stateRelay = BehaviorRelay<AuthState>(value: .loggedOut)
    private let lock = NSRecursiveLock()                // 스레드 안전 보장(갱신 동시 접근 방지)
    private var inFlightRefresh: Single<TokenPair>?     // 진행 중인 refresh 요청 공유용

    // 메모리 상의 현재 토큰
    private var pair: TokenPair? {
        didSet { try? persist() } // 값이 바뀌면 Keychain 반영
    }

    // 외부에서 구독: 라우팅/화면 분기
    public var authState: Observable<AuthState> { stateRelay.asObservable().distinctUntilChanged() }

    /// 초기화 시 Keychain에서 토큰을 불러와 유효하면 로그인 상태로 둡니다.
    public init(store: KeychainTokenStore<TokenPair>) {
        self.store = store
        self.pair = store.load()

        // 시작 시점에 refresh 유효성으로 상태 판정
        if let p = pair, isRefreshValid(p) {
            stateRelay.accept(.loggedIn)
        } else {
            clear() // 없거나(refresh 만료) 문제 있으면 정리 → loggedOut
        }
    }

    // MARK: - 현재 토큰 읽기(헤더 첨부 등에서 사용)
    public func currentAccessToken() -> String? { pair?.accessToken }
    public func currentRefreshToken() -> String? { pair?.refreshToken }

    // MARK: - 저장/삭제
    /// 신규 토큰 세트 저장(로그인/리프레시 성공 시 호출)
    public func set(pair newPair: TokenPair) {
        lock.lock(); defer { lock.unlock() }
        var p = newPair
        // 서버가 만료 시각을 안 주면 JWT에서 파싱해 채워넣음
        if p.accessExp == nil { p.accessExp = p.accessToken.jwtExpDate() }
        if p.refreshExp == nil { p.refreshExp = p.refreshToken.jwtExpDate() }
        pair = p
        stateRelay.accept(.loggedIn)
    }

    /// 로그아웃/만료 시 호출: 메모리+Keychain 모두 정리
    public func clear() {
        print("TokenManager Clear 실행")
        lock.lock(); defer { lock.unlock() }
        pair = nil
        store.clear()
        stateRelay.accept(.loggedOut)
    }

    /// Keychain에 현재 pair를 반영
    private func persist() throws {
        if let p = pair { try store.save(p) }
        else { store.clear() }
    }

    // MARK: - 유효성 검사
    /// accessToken이 아직 유효한가?
    public func isAccessValid(_ p: TokenPair? = nil, now: Date = .init()) -> Bool {
        let t = p ?? pair
        guard let t else { return false }
        // 만료 시각이 있으면 그것으로 판단, 없으면 토큰 문자열 유무로 fallback
        guard let exp = t.accessExp else { return !t.accessToken.isEmpty }
        return exp > now
    }

    /// refreshToken이 아직 유효한가?
    public func isRefreshValid(_ p: TokenPair? = nil, now: Date = .init()) -> Bool {
        let t = p ?? pair
        guard let t else { return false }
        guard let exp = t.refreshExp else { return !t.refreshToken.isEmpty }
        return exp > now
    }

    // MARK: - access 토큰을 보장(만료면 자동 갱신)
    /// API 호출 전 이 함수를 통해 access를 확보하세요.
    /// - refreshFunc: (refreshToken) -> Single<TokenPair>
    ///   서버의 refresh API를 호출하는 함수(의존성 주입).
    public func ensureValidAccessToken(refreshFunc: @escaping (String) -> Single<TokenPair>) -> Single<String> {
        lock.lock(); defer { lock.unlock() }

        // 1) access가 아직 유효하면 그대로 반환
        if isAccessValid(), let at = pair?.accessToken {
            return .just(at)
        }

        // 2) refresh가 없거나 만료 → 세션 종료 처리
        guard let rt = pair?.refreshToken, isRefreshValid() else {
            clear()
            return .error(AuthError.refreshExpired)
        }

        // 3) 이미 리프레시 진행 중이면 그 결과를 공유(동시성 폭발 방지)
        if let inflight = inFlightRefresh {
            return inflight.map { [weak self] _ in self?.pair?.accessToken ?? "" }
        }

        // 4) 새로 리프레시 시작
        stateRelay.accept(.refreshing)

        let started = refreshFunc(rt)
            .do(onSuccess: { [weak self] newPair in
                // 성공 시 새 토큰 저장 → 상태 loggedIn
                self?.set(pair: newPair)
            }, onError: { [weak self] _ in
                // 실패(401/만료) 시 세션 종료
                self?.clear()
            }, onDispose: { [weak self] in
                // 완료/에러 상관없이 inFlightRef를 비워 다음 요청 준비
                self?.lock.lock(); self?.inFlightRefresh = nil; self?.lock.unlock()
            })

        inFlightRefresh = started
        // refresh 이후 access 토큰 문자열만 돌려줌
        return started.map { [weak self] _ in self?.pair?.accessToken ?? "" }
    }
    
    // TODO: 추후 개선 예정
    // MARK: - FCM
    private let defaults = UserDefaults.standard
    
    var fcmToken: String? {
        get { defaults.string(forKey: UserDefaultsKeys.Fcm.fcmToken) }
        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Fcm.fcmToken) }
    }
    
    var fcmTokenUploadState: Bool? {
        get { defaults.bool(forKey: UserDefaultsKeys.Fcm.fcmTokenUpdate) }
        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Fcm.fcmTokenUpdate) }
    }
}


//final class TokenManager {
//    static let shared = TokenManager()
//    
//    private let defaults = UserDefaults.standard
//    
//    // MARK: - Login
//    var accessToken: String? {
//        get { defaults.string(forKey: UserDefaultsKeys.Auth.accessToken) }
//        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.accessToken) }
//    }
//    
//    var refreshToken: String? {
//        get { defaults.string(forKey: UserDefaultsKeys.Auth.refreshToken) }
//        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.refreshToken) }
//    }
//
////    var expiresIn: Int? {
////        get { defaults.integer(forKey: UserDefaultsKeys.Auth.expiresIn) }
////        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.expiresIn) }
////    }
////
////    var idToken: String? {
////        get { defaults.string(forKey: UserDefaultsKeys.Auth.idToken) }
////        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Auth.idToken) }
////    }
//    
//    var isLoggedIn: Bool {
//        guard let token = accessToken, !token.isEmpty else { return false }
//        return true
//    }
//
//    func save(tokenInfo: TokenResponse) {
//        accessToken = tokenInfo.accessToken
//        refreshToken = tokenInfo.refreshToken
////        expiresIn = tokenInfo.expiresIn
////        idToken = tokenInfo.idToken
//    }
//
//    // 추후 로그아웃 적용하고 UserDefaults 해제할 때 사용
//    func logout() {
//        defaults.removeObject(forKey: UserDefaultsKeys.Auth.accessToken)
//        defaults.removeObject(forKey: UserDefaultsKeys.Auth.refreshToken)
////        defaults.removeObject(forKey: UserDefaultsKeys.Auth.expiresIn)
////        defaults.removeObject(forKey: UserDefaultsKeys.Auth.idToken)
//    }
//    
//    // MARK: - FCM
//    var fcmToken: String? {
//        get { defaults.string(forKey: UserDefaultsKeys.Fcm.fcmToken) }
//        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Fcm.fcmToken) }
//    }
//    
//    var fcmTokenUploadState: Bool? {
//        get { defaults.bool(forKey: UserDefaultsKeys.Fcm.fcmTokenUpdate) }
//        set { defaults.setValue(newValue, forKey: UserDefaultsKeys.Fcm.fcmTokenUpdate) }
//    }
//}
