//
//  CountdownCircleView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/20.
//

import UIKit

//倒计时转圈
class CountdownCircleView: UIView {

    // MARK: - Configs
    var lineWidth: CGFloat = 1 { didSet { baseLayer.lineWidth = lineWidth; highlightLayer.lineWidth = lineWidth; setNeedsLayout() } }
    var baseColor: UIColor = HXColor(0xe8e8e8) { didSet { baseLayer.strokeColor = baseColor.cgColor } }
    var highlightColor: UIColor = HXColor(0x7e7e7e) { didSet { highlightLayer.strokeColor = highlightColor.cgColor } }
    /// 高亮段占整圈比例(0~1)，如0.2=20%
    var highlightLength: CGFloat = 0.06 { didSet { updateHighlightPath() } }
    /// 旋转一圈所需秒数
    var rotationPeriod: Double = 1.5 { didSet { if isAnimating { startSpin() } } }
    /// 倒计时起始值(秒)
    var maxValue: Int = 6 { didSet { currentValue = maxValue; updateLabel() } }

    /// 结束回调
    var onFinished: ((Int) -> Void)?

    // MARK: - Internal
    private let baseLayer = CAShapeLayer()
    private let spinnerLayer = CALayer()         // 负责旋转
    private let highlightLayer = CAShapeLayer()  // 高亮小弧
    private let numberLabel = UILabel()
    private var timer: Timer?
    private var currentValue: Int = 6
    private var isAnimating = false

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // 基础圆
        baseLayer.fillColor = UIColor.clear.cgColor
        baseLayer.strokeColor = baseColor.cgColor
        baseLayer.lineWidth = lineWidth
        layer.addSublayer(baseLayer)

        // 旋转容器
        spinnerLayer.masksToBounds = false
        layer.addSublayer(spinnerLayer)

        // 高亮弧
        highlightLayer.fillColor = UIColor.clear.cgColor
        highlightLayer.strokeColor = highlightColor.cgColor
        highlightLayer.lineWidth = lineWidth
        highlightLayer.lineCap = .round
        spinnerLayer.addSublayer(highlightLayer)

        // 中心数字
        numberLabel.font = fontRegular(40)
        numberLabel.textColor = .black
        numberLabel.textAlignment = .center
        addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        currentValue = maxValue
        updateLabel()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        baseLayer.frame = bounds
        spinnerLayer.frame = bounds
        spinnerLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        spinnerLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        highlightLayer.frame = spinnerLayer.bounds

        let c = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let r = min(bounds.width, bounds.height)/2 - lineWidth/2
        let full = UIBezierPath(arcCenter: c, radius: r, startAngle: -.pi/2, endAngle: 1.5 * .pi, clockwise: true)
        baseLayer.path = full.cgPath

        updateHighlightPath()
    }

    private func updateHighlightPath() {
        guard bounds.width > 0 else { return }
        let c = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let r = min(bounds.width, bounds.height)/2 - lineWidth/2
        let start = -CGFloat.pi/2
        let end = start + 2 * .pi * max(0.01, min(1, highlightLength))
        let arc = UIBezierPath(arcCenter: c, radius: r, startAngle: start, endAngle: end, clockwise: true)
        highlightLayer.path = arc.cgPath
    }

    // MARK: - Public controls
    func start() {
        guard !isAnimating else { return }
        isAnimating = true
        currentValue = maxValue
        updateLabel()
        startSpin()
        startTimer()
    }

    func stop() {
        isAnimating = false
        spinnerLayer.removeAnimation(forKey: "spin")
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Spin
    private func startSpin() {
        spinnerLayer.removeAnimation(forKey: "spin")
        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue = 0
        spin.toValue = 2 * Double.pi
        spin.duration = max(0.1, rotationPeriod)
        spin.repeatCount = .infinity
        spin.timingFunction = CAMediaTimingFunction(name: .linear)
        spin.isRemovedOnCompletion = false
        spinnerLayer.add(spin, forKey: "spin")
    }

    // MARK: - Countdown
    private func startTimer() {
        timer?.invalidate()
        // 每秒递减
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.currentValue -= 1
            self.updateLabel()
            
            self.onFinished?(self.currentValue)
            
            if self.currentValue <= 0 {
                t.invalidate()
                self.stop()
            }
        }
        // 更省电一点
        timer?.tolerance = 0.1
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func updateLabel() {
        numberLabel.text = "\(max(0, currentValue))"
    }
}
