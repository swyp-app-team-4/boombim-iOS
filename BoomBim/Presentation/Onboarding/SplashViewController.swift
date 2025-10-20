//
//  SplashViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/2/25.
//

import UIKit

final class SplashViewController: UIViewController {
    private let logoView = UIImageView(image: .onboardingLogo)
    private let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main   // LaunchScreen과 색/레이아웃 최대한 동일
        logoView.contentMode = .scaleAspectFit
        logoView.clipsToBounds = true
        
        spinner.hidesWhenStopped = true
        spinner.color = .divider

        view.addSubview(logoView)
        view.addSubview(spinner)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            logoView.heightAnchor.constraint(equalToConstant: 70),
            logoView.widthAnchor.constraint(equalToConstant: 250),

            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spinner.startAnimating()
    }
}
