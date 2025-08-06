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
    private var observer: AnyObserver<String>?  // 👈 관찰자 저장
    private let nonce = UUID().uuidString  // optional: 나중에 secure하게 만들 수도 있음

    func login() -> Observable<String> {
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
              let identityToken = credentials.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            return
        }
        
        print("fullName : \(fullName)")
        print("identityTokenString : \(identityTokenString)")
        
        observer?.onNext(identityTokenString)
        observer?.onCompleted()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        observer?.onError(error)
    }
}
