//
//  BaseViewController.swift
//  BoomBim
//
//  Created by 조영현 on 8/18/25.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        logLifeCycle("viewDidLoad")
        
        setupNavigationBar()
        setupTabBar()
        setupTapToDismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logLifeCycle("viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logLifeCycle("viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logLifeCycle("viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logLifeCycle("viewDidDisappear")
    }
    
    // MARK: - Navigation Bar Color
    private func setupNavigationBar() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = .white
        navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor.grayScale10, .font: Typography.Body02.semiBold.font]
        
        navigationController?.navigationBar.standardAppearance = navigationAppearance
        navigationController?.navigationBar.compactAppearance = navigationAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationAppearance
    }
    
    // MARK: - Tab Bar Color
    private func setupTabBar() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .white
        
        tabBarController?.tabBar.standardAppearance = tabAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabAppearance
        
        tabBarController?.tabBar.tintColor = .grayScale9
        tabBarController?.tabBar.unselectedItemTintColor = .grayScale5
    }

    // MARK: - Log
    private func logLifeCycle(_ methodName: String) {
        let className = String(describing: type(of: self))
        print("🌀 \(className) - \(methodName)")
    }

    // MARK: - Keyboard Dismiss
    private func setupTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view is UIControl { return false }
        
        return true
    }
}
