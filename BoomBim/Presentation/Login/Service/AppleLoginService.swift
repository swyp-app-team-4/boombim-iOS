//
//  AppleLoginService.swift
//  BoomBim
//
//  Created by 조영현 on 8/6/25.
//

import Foundation
import RxSwift
import AuthenticationServices

final class AppleLoginService: NSObject, SocialLoginService {
    private var observer: AnyObserver<TokenInfo>?
    private let nonce = UUID().uuidString

    func login() -> Observable<TokenInfo> {
        return Observable.create { observer in
            self.observer = observer

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self

            controller.performRequests()

            return Disposables.create()
        }
    }
}

extension AppleLoginService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow } ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
              let _ = credentials.fullName,
              let _ = credentials.authorizationCode,
              let identityToken = credentials.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            return
        }
        
        let tokenInfo = TokenInfo(
            accessToken: "",
            refreshToken: "",
            expiresIn: 3600,
            idToken: identityTokenString)
        
        observer?.onNext(tokenInfo)
        observer?.onCompleted()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        observer?.onError(error)
    }
}
