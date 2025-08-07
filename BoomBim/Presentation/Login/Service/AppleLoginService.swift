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

            return Disposables.create {
                // retain release
                _ = self
            }
        }
    }
}

extension AppleLoginService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential,
              let fullName = credentials.fullName,
              let authorizationCode = credentials.authorizationCode,
              let authorizationCodeString = String(data: authorizationCode, encoding: .utf8),
              let identityToken = credentials.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            return
        }
        
        print("fullName : \(fullName)")
        print("identityTokenString : \(identityTokenString)")
        
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
