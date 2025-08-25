//
//  PollGaugeView.swift
//  BoomBim
//
//  Created by 조영현 on 8/24/25.
//

import UIKit

final class PollGaugeView: UIView {
    // MARK: Style
    var trackColor: UIColor = .systemGray6 { didSet { trackLayer.strokeColor = trackColor.cgColor } }
    var fillColor:  UIColor = .systemGreen { didSet { fillLayer.strokeColor  = fillColor.cgColor  } }
    var lineHeight: CGFloat = 8 { didSet { setNeedsLayout() } }
    var showsThumb: Bool = false { didSet { thumbLayer.isHidden = !showsThumb } }

    enum AnimationBehavior { case fromPrevious, fromZero }
    var animationBehavior: AnimationBehavior = .fromZero   // 항상 0→목표로 차오르게

    // MARK: Layers
    private let trackLayer = CAShapeLayer()
    private let fillLayer  = CAShapeLayer()
    private let thumbLayer = CALayer()

    // MARK: State
    private var startPoint = CGPoint.zero
    private var endPoint   = CGPoint.zero
    private var laidOut = false
    private(set) var modelProgress: CGFloat = 0 // 0~1

    private struct Pending {
        let value: CGFloat
        let animated: Bool
        let duration: CFTimeInterval
        let delay: CFTimeInterval
    }
    private var pending: Pending?

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true

        [trackLayer, fillLayer].forEach {
            $0.fillColor = UIColor.clear.cgColor
            $0.lineCap   = .round
        }
        trackLayer.strokeColor = trackColor.cgColor
        fillLayer.strokeColor  = fillColor.cgColor

        layer.addSublayer(trackLayer)
        layer.addSublayer(fillLayer)
        layer.addSublayer(thumbLayer)

        // 초기 상태: 0 (아예 비어있음)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fillLayer.strokeEnd = 0
        CATransaction.commit()

        thumbLayer.isHidden = true
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        let inset = lineHeight / 2
        startPoint = CGPoint(x: inset, y: bounds.midY)
        endPoint   = CGPoint(x: bounds.width - inset, y: bounds.midY)

        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        [trackLayer, fillLayer].forEach {
            $0.path = path.cgPath
            $0.lineWidth = lineHeight
        }
        // ★ 여기서 strokeEnd를 건드리지 않음 (애니메이션 보존)
        CATransaction.commit()

        thumbLayer.cornerRadius = lineHeight / 2
        thumbLayer.bounds = CGRect(x: 0, y: 0, width: lineHeight, height: lineHeight)

        laidOut = true

        // 레이아웃 전에 들어온 요청이 있으면 지금 애니메이션 그대로 적용
        if let p = pending, bounds.width > 0 {
            pending = nil
            setProgress(p.value, animated: p.animated, duration: p.duration, delay: p.delay)
        }
    }

    // MARK: API
    func setProgress(_ value: CGFloat,
                     animated: Bool = true,
                     duration: CFTimeInterval = 1,
                     delay: CFTimeInterval = 0) {
        let clamped = max(0, min(1, value))

        // 아직 사이즈가 0이면 보류 후 레이아웃 때 실행
        guard laidOut, bounds.width > 0 else {
            pending = .init(value: clamped, animated: animated, duration: duration, delay: delay)
            modelProgress = clamped
            return
        }

        // 같은 값이면 굳이 애니메이션 안 함
        let current = (fillLayer.presentation()?.strokeEnd) ?? fillLayer.strokeEnd
        guard animated && abs(current - clamped) > .ulpOfOne else {
            // 최종 상태만 고정
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            fillLayer.strokeEnd = clamped
            CATransaction.commit()
            modelProgress = clamped
            return
        }

        // 새 애니메이션 전 기존 'strokeEnd'만 제거
        fillLayer.removeAnimation(forKey: "strokeEnd")

        let from: CGFloat = {
            switch animationBehavior {
            case .fromZero:     return 0
            case .fromPrevious: return current
            }
        }()

        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = from
        anim.toValue   = clamped
        anim.duration  = duration
        anim.beginTime = CACurrentMediaTime() + delay
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fillLayer.add(anim, forKey: "strokeEnd")

        // 최종 상태 고정(암묵적 애니메이션 방지)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fillLayer.strokeEnd = clamped
        CATransaction.commit()

        modelProgress = clamped

        accessibilityLabel = "진행률"
        accessibilityValue = "\(Int(modelProgress * 100))퍼센트"
    }

    func resetToEmpty() {
        fillLayer.removeAnimation(forKey: "strokeEnd")
        modelProgress = 0
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fillLayer.strokeEnd = 0
        CATransaction.commit()
    }
}





//final class PollGaugeView: UIView {
//    // 스타일
//    var trackColor: UIColor = .systemGray6 { didSet { track.backgroundColor = trackColor.cgColor } }
//    var fillColor:  UIColor = .systemGreen { didSet { fill.backgroundColor  = fillColor.cgColor  } }
//    var corner: CGFloat = 8 { didSet { updateCorners() } }
//    var duration: CFTimeInterval = 0.35
//
//    // 내부
//    private let track = CALayer()
//    private let fill  = CALayer()
//    private(set) var progress: CGFloat = 0 // 0~1
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        isAccessibilityElement = true
//
//        track.backgroundColor = trackColor.cgColor
//        layer.addSublayer(track)
//
//        fill.backgroundColor = fillColor.cgColor
//        fill.anchorPoint = CGPoint(x: 0, y: 0.5) // 왼쪽 기준으로 늘어남
//        layer.addSublayer(fill)
//    }
//    required init?(coder: NSCoder) { super.init(coder: coder) }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        track.frame = bounds
//        fill.bounds = bounds                   // 전체 폭 기준으로
//        fill.position = CGPoint(x: bounds.minX, y: bounds.midY)
//        fill.transform = CATransform3DMakeScale(progress, 1, 1) // 현재 진행률 반영
//        updateCorners()
//    }
//
//    private func updateCorners() {
//        track.cornerRadius = corner
//        fill.cornerRadius = corner
//        track.masksToBounds = true
//    }
//
//    /// 0~1 진행률
//    func setProgress(_ value: CGFloat, animated: Bool = true) {
//        let p = max(0, min(1, value))
//        let from = (fill.presentation()?.transform.m11 ?? fill.transform.m11)
//        let to   = p
//
//        if animated {
//            let anim = CABasicAnimation(keyPath: "transform.scale.x")
//            anim.fromValue = from
//            anim.toValue   = to
//            anim.duration  = duration
//            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            fill.add(anim, forKey: "scaleX")
//        }
//
//        CATransaction.begin()
//        CATransaction.setDisableActions(true) // 암묵적 애니메이션 방지
//        fill.transform = CATransform3DMakeScale(to, 1, 1)
//        CATransaction.commit()
//
//        progress = to
//        accessibilityLabel = "진행률"
//        accessibilityValue = "\(Int(progress * 100))퍼센트"
//    }
//}


///// 투표/진행률 게이지 (둥근 캡 + 애니메이션)
//final class PollGaugeView: UIView {
//
//    // MARK: - Style
//    var trackColor: UIColor = .systemGray6 { didSet { trackLayer.strokeColor = trackColor.cgColor } }
//    var fillColor: UIColor  = .systemGreen { didSet { fillLayer.strokeColor  = fillColor.cgColor  } }
//    var lineHeight: CGFloat = 12 { didSet { setNeedsLayout() } }
////    var showsThumb: Bool = true { didSet { thumbLayer.isHidden = !showsThumb } }
//
//    // MARK: - Private
//    private let trackLayer = CAShapeLayer()
//    private let fillLayer  = CAShapeLayer()
//    private let thumbLayer = CALayer()
//    private var startPoint = CGPoint.zero
//    private var endPoint   = CGPoint.zero
//    private(set) var progress: CGFloat = 0 // 0~1
//
//    // MARK: - Init
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        isAccessibilityElement = true
//        backgroundColor = .grayScale3
//
//        [trackLayer, fillLayer].forEach {
//            $0.fillColor = UIColor.clear.cgColor
//            $0.lineCap = .round
//        }
//        trackLayer.strokeColor = trackColor.cgColor
//        fillLayer.strokeColor  = fillColor.cgColor
//
//        layer.addSublayer(trackLayer)
//        layer.addSublayer(fillLayer)
//
//        thumbLayer.backgroundColor = UIColor.white.cgColor
//        thumbLayer.shadowColor = UIColor.black.cgColor
//        thumbLayer.shadowOpacity = 0.12
//        thumbLayer.shadowRadius = 2
//        layer.addSublayer(thumbLayer)
//    }
//    
//    required init?(coder: NSCoder) { super.init(coder: coder) }
//
//    // MARK: - Layout
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        let inset = lineHeight / 2
//        startPoint = CGPoint(x: inset, y: bounds.midY)
//        endPoint   = CGPoint(x: bounds.width - inset, y: bounds.midY)
//
//        let path = UIBezierPath()
//        path.move(to: startPoint)
//        path.addLine(to: endPoint)
//
//        [trackLayer, fillLayer].forEach {
//            $0.path = path.cgPath
//            $0.lineWidth = lineHeight
//        }
//
//        thumbLayer.cornerRadius = lineHeight / 2
//        thumbLayer.bounds = CGRect(x: 0, y: 0, width: lineHeight, height: lineHeight)
//
////        updateThumbPosition()
//    }
//
//    // MARK: - API
//    /// 0~1 진행률 설정
//    func setProgress(_ value: CGFloat, animated: Bool = true, duration: CFTimeInterval = 0.35, delay: CFTimeInterval = 0) {
//        let clamped = max(0, min(1, value))
//        let from = fillLayer.presentation()?.strokeEnd ?? fillLayer.strokeEnd
//        let to   = clamped
//
//        if animated {
//            let anim = CABasicAnimation(keyPath: "strokeEnd")
//            anim.fromValue = from
//            anim.toValue   = to
//            anim.duration  = duration
//            anim.beginTime = CACurrentMediaTime() + delay
//            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//            fillLayer.add(anim, forKey: "strokeEnd")
//        }
//        fillLayer.strokeEnd = to
//        progress = to
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
//            self?.updateThumbPosition()
//        }
//
//        // A11y
//        accessibilityLabel = "진행률"
//        accessibilityValue  = "\(Int(progress * 100))퍼센트"
//    }
//
//    // MARK: - Helpers
//    private func updateThumbPosition() {
////        thumbLayer.isHidden = !showsThumb || progress <= 0
//        guard !thumbLayer.isHidden else { return }
//        let x = startPoint.x + (endPoint.x - startPoint.x) * progress
//        thumbLayer.position = CGPoint(x: x, y: bounds.midY)
//    }
//}
