//
//  PollGaugeView.swift
//  BoomBim
//
//  Created by 조영현 on 8/24/25.
//

import UIKit

final class GaugeView: UIView {
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
