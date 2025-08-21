//
//  RegionCardCell.swift
//  BoomBim
//
//  Created by 조영현 on 8/11/25.
//

import UIKit

final class RegionCardCell: UICollectionViewCell {
    
    static let identifier = "RegionCardCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 4
        
        return stackView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    private let containerShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.grayScale10.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 3
        view.layer.shadowOffset  = .zero
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .grayScale9
        pageControl.pageIndicatorTintColor = .grayScale4
        
        return pageControl
    }()
    
    private var items: [RegionItem] = []
    private var autoScrollTimer: Timer?
    private let autoScrollInterval: TimeInterval = 5
    private var isUserInteracting = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAutoScroll()
        pageControl.currentPage = 0
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // 화면에 보일 때만 자동 스크롤; 사라지면 정지
        if window != nil {
            startAutoScrollIfNeeded()
        } else {
            stopAutoScroll()
        }
    }
    
    private func setupView() {
        configureStackView()
        configureContainerView()
        configureCollectionView()
        configurePageControl()
    }
    
    private func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func configureContainerView() {
        containerShadowView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(containerShadowView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerShadowView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: containerShadowView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: containerShadowView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: containerShadowView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: containerShadowView.trailingAnchor)
        ])
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(RegionCell.self, forCellWithReuseIdentifier: RegionCell.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    private func configurePageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(pageControl)
    }
    
    func configure(items: [RegionItem]) {
        self.items = items
        pageControl.numberOfPages = items.count
        collectionView.reloadData()
        
        // 셀 크기 변경 대비(레이아웃 확정 후 contentSize 기반 페이징 정확도 확보)
        DispatchQueue.main.async { [weak self] in
            self?.invalidateItemSizeForPaging()
            self?.restartAutoScroll()
        }
    }
    
    private func invalidateItemSizeForPaging() {
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flow.itemSize = collectionView.bounds.size  // 페이지 폭 = 컨테이너 폭
        flow.invalidateLayout()
    }
    
    // MARK: - Auto Scroll
    private func restartAutoScroll() {
        stopAutoScroll()
        startAutoScrollIfNeeded()
    }
    
    private func startAutoScrollIfNeeded() {
        guard window != nil, items.count > 1, autoScrollTimer == nil else { return }
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { [weak self] _ in
            self?.scrollToNextPage()
        }
        // 터치 중에도 멈추지 않게 .common에 등록
        if let t = autoScrollTimer {
            RunLoop.main.add(t, forMode: .common)
        }
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    private func scrollToNextPage() {
        guard items.count > 1, collectionView.bounds.width > 0 else { return }
        
        let w = collectionView.bounds.width
        let current = Int(round(collectionView.contentOffset.x / max(w, 1)))
        let next = (current + 1) % items.count
        
        let indexPath = IndexPath(item: next, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        pageControl.currentPage = next
    }
}

extension RegionCardCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegionCell.identifier, for: indexPath) as! RegionCell
        
        let index = indexPath.row
        
        cell.configure(items[index])
        
        return cell
    }
    
    // 회전/크기 변경 대응
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateItemSizeForPaging()
    }   
}

extension RegionCardCell: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserInteracting = true
        stopAutoScroll()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { // 감속이 없다면 바로 재개
            isUserInteracting = false
            startAutoScrollIfNeeded()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isUserInteracting = false
        startAutoScrollIfNeeded()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width > 0 ? scrollView.bounds.width : 1
        let page = Int(round(scrollView.contentOffset.x / width))
        pageControl.currentPage = max(0, min(page, pageControl.numberOfPages - 1))
    }
}
