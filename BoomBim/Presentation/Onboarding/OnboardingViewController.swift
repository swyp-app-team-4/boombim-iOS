//
//  OnboardingViewController.swift
//  BoomBim
//
//  Created by 조영현 on 9/3/25.
//

import UIKit

final class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pages: [UIViewController] = [
        OnboardingPageViewController(title: "onboarding.label.title.first".localized(), subTitle: nil, image: .onboarding1),
        OnboardingPageViewController(title: "onboarding.label.title.second".localized(), subTitle: "onboarding.label.subtitle.second".localized(), image: .onboarding2),
        OnboardingPageViewController(title: "onboarding.label.title.third".localized(), subTitle: "onboarding.label.subtitle.third".localized(), image: .onboarding3),
        OnboardingPageViewController(title: "onboarding.label.title.fourth".localized(), subTitle: "onboarding.label.subtitle.fourth".localized(), image: .onboarding4),
        OnboardingPageViewController(title: "onboarding.label.title.fifth".localized(), subTitle: "onboarding.label.subtitle.fifth".localized(), image: .onboarding5),
        OnboardingPageViewController(title: "onboarding.label.title.sixth".localized(), subTitle: "onboarding.label.subtitle.sixth".localized(), image: .onboarding6)
    ]
    
    var onFinish: (() -> Void)?

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let pageControl = UIPageControl()
    private var currentIndex = 0
    
    private let skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("onboarding.button.skip".localized(), for: .normal)
        button.backgroundColor = .grayScale4
        button.titleLabel?.font = Typography.Body03.medium.font
        button.setTitleColor(.grayScale8, for: .normal)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12.5, bottom: 4, right: 12.5)
        
        return button
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("onboarding.button.start".localized(), for: .normal)
        button.titleLabel?.font = Typography.Body02.medium.font
        button.setTitleColor(.grayScale7, for: .normal)
        button.backgroundColor = .grayScale4
//        button.setTitleColor(.grayScale1, for: .normal)
//        button.backgroundColor = .main
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .grayScale1
        
        configureButton()
        configurePageViewController()
    }
    
    private func configureButton() {
        [skipButton, startButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
        }
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            skipButton.heightAnchor.constraint(equalToConstant: 30),
            
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        // 버튼 액션
        skipButton.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
        updateUI()
    }
    
    private func configurePageViewController() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pageControl)
        view.addSubview(pageViewController.view)
        addChild(pageViewController)
        
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false)
        
        pageControl.numberOfPages = pages.count
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = .grayScale4
        pageControl.currentPageIndicatorTintColor = .grayScale9

        updatePageControlAppearance(current: 0) // ← 핵심
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -15),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 6),
            
            pageViewController.view.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 4),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -15)
        ])
        
        if #available(iOS 14.0, *) { pageControl.allowsContinuousInteraction = true } // 선택
        pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func pageControlChanged(_ sender: UIPageControl) {
        let index = sender.currentPage
        guard index != currentIndex else { return }
        goTo(index: index)
    }
    
    @objc private func didTapSkip() {
        onFinish?() // ✅ 온보딩 즉시 종료
    }
    
    @objc private func didTapNext() {
        if currentIndex < pages.count - 1 {
            goTo(index: currentIndex + 1)
        } else {
            onFinish?() // ✅ 마지막 페이지에서 '시작하기' → 종료
        }
    }
    
    private func goTo(index: Int) {
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true) { [weak self] _ in
            
            self?.currentIndex = index
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        pageControl.currentPage = currentIndex
        updatePageControlAppearance(current: currentIndex)
        
        let isLast = (currentIndex == pages.count - 1)
        print("isLast : \(isLast)")
        print("currentIndex : \(currentIndex)")
        print("page.count : \(pages.count)")
        
        startButton.isEnabled = isLast
        startButton.backgroundColor = isLast ? .main : .grayScale4
        startButton.setTitleColor(isLast ? .grayScale1 : .grayScale7, for: .normal)
    }

    // MARK: - Page Control: 점 vs 알약
    private func updatePageControlAppearance(current: Int) {
        guard #available(iOS 14.0, *) else { return } // iOS13↓는 커스텀 뷰로 구현

        let dot = Self.makeDotImage(diameter: 6).withRenderingMode(.alwaysTemplate)
        let pill = Self.makePillImage(size: CGSize(width: 16, height: 6), cornerRadius: 3).withRenderingMode(.alwaysTemplate)

        for i in 0..<pageControl.numberOfPages {
            pageControl.setIndicatorImage(i == current ? pill : dot, forPage: i)
        }
        pageControl.currentPage = current
    }

    private static func makeDotImage(diameter: CGFloat) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
    }

    private static func makePillImage(size: CGSize, cornerRadius: CGFloat) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius).fill()
        }
    }

    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pvc: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: vc), idx > 0 else { return nil }
        
        return pages[idx - 1]
    }
    func pageViewController(_ pvc: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: vc), idx < pages.count - 1 else { return nil }
        
        return pages[idx + 1]
    }

    // MARK: - Delegate: 페이지 전환 완료 시 알약 갱신
    func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let vc = pvc.viewControllers?.first, let idx = pages.firstIndex(of: vc) else { return }
        currentIndex = idx
        updateUI() // ✅ 알약 + 버튼/시작하기 상태 한 번에 갱신
    }
}

