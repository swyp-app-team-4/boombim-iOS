//
//  AppleLoginService.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

//import Foundation
//import RxSwift
//import AuthenticationServices
//
//final class AppleLoginService: NSObject, SocialLoginService {
//    private var observer: AnyObserver<SocialToken>?
//    private let nonce = UUID().uuidString
//
//    func login() -> Observable<SocialToken> {
//        return Observable.create { observer in
//            self.observer = observer
//
//            let request = ASAuthorizationAppleIDProvider().createRequest()
//            request.requestedScopes = [.fullName, .email]
//
//            let controller = ASAuthorizationController(authorizationRequests: [request])
//            controller.delegate = self
//            controller.presentationContextProvider = self
//
//            controller.performRequests()
//
//            return Disposables.create()
//        }
//    }
//}
//
//extension AppleLoginService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        
//        return UIApplication.shared
//                .connectedScenes
//                .compactMap { $0 as? UIWindowScene }
//                .flatMap { $0.windows }
//                .first { $0.isKeyWindow } ?? UIWindow()
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
//              let _ = credentials.fullName,
//              let _ = credentials.authorizationCode,
//              let identityToken = credentials.identityToken,
//              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
//            return
//        }
//        
//        let tokenInfo = SocialToken(
//            accessToken: "",
//            refreshToken: "",
//            expiresIn: 3600,
//            idToken: identityTokenString)
//        
//        observer?.onNext(tokenInfo)
//        observer?.onCompleted()
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        observer?.onError(error)
//    }
//}

import Foundation
import RxSwift
import AuthenticationServices
import UIKit

/// Sign in with Apple 흐름:
/// 1) ASAuthorizationController로 Apple 로그인 → identityToken(JWT) 획득
/// 2) 서버 소셜 로그인 API에 provider=.apple, body(idToken만 채움) 요청
/// 3) 서버가 발급한 TokenPair(access/refresh) 반환
final class AppleLoginService: NSObject, SocialLoginService {
    private var singleObserver: ((SingleEvent<(idToken: String, authCode: String?)>) -> Void)?

    // 필요 시 nonce를 생성해 요청에 추가(백엔드 검증 강화 시)
    private let nonce = UUID().uuidString

    func loginAndIssueBackendToken() -> Single<TokenPair> {
        return appleSDKLogin() // 1) Apple SDK 로그인 → (idToken, authCode)
            .map { token in
                LoginRequest(
                    accessToken: "",
                    refreshToken: "",
                    expiresIn: 3600,
                    idToken: token.idToken) // idToken 보류
            }
            .flatMap { body in
                AuthService.shared.socialLogin(provider: .apple, body: body)
            }
    }

    // MARK: - Apple SDK 로그인 (Single로 1회성 결과 전달)
    private func appleSDKLogin() -> Single<(idToken: String, authCode: String?)> {
        return Single<(idToken: String, authCode: String?)>.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            self.singleObserver = { event in
                single(event)
            }

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            // 필요 시 nonce 적용(백엔드에서 nonce 검증 시)
            // request.nonce = SHA256(nonce) // 구현 시 해시해서 넣으세요.

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()

            return Disposables.create { [weak self] in
                // 필요하면 정리 로직
                self?.singleObserver = nil
            }
        }
    }
}

// MARK: - ASAuthorizationController Delegate & Presentation
extension AppleLoginService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 현재 Key Window 반환 (로그인 시트를 띄울 창)
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idTokenString = String(data: tokenData, encoding: .utf8)
        else {
            singleObserver?(.failure(NSError(domain: "AppleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple identityToken 없음"])))
            singleObserver = nil
            return
        }

        // authorizationCode(Data) → String 변환(서버 검증에 쓸 때 사용)
        var codeString: String? = nil
        if let codeData = credential.authorizationCode {
            codeString = String(data: codeData, encoding: .utf8)
        }

        singleObserver?(.success((idToken: idTokenString, authCode: codeString)))
        singleObserver = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        singleObserver?(.failure(error))
        singleObserver = nil
    }
}
