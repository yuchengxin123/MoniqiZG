//
//  LoadingAmountLabel.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/7.
//

import UIKit
import SnapKit


class AnimatedNumberLabel: UIView {
    
    enum AnimationType {
        case simpleShow    // 直接展示
        case rollingText   // 数字滚动
    }
    
    // MARK: - Public Properties
    var animationType: AnimationType = .simpleShow
    // MARK: - Public Properties
    var indicatorViewType: UIActivityIndicatorView.Style = .large
    
    var font: UIFont {
        get { textLabel.font }
        set { textLabel.font = newValue }
    }
    var textColor: UIColor {
        get { textLabel.textColor }
        set { textLabel.textColor = newValue }
    }
    var textAlignment: NSTextAlignment {
        get { textLabel.textAlignment }
        set { textLabel.textAlignment = newValue }
    }
    var onTap: (() -> Void)? // 点击回调
    
    private var targetText: String?
    private var targetAttrText: NSAttributedString?
    private(set) var currentText: String?
    
    // MARK: - UI Elements
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // 调整缩放比例
        return indicator
    }()
    
    private let textLabel = UILabel()
    private let rightImg = UIImageView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGesture()
    }
    
    // MARK: - Setup
    private func setupUI() {
        activityIndicator.color = .white
        textLabel.textColor = .white
        addSubview(activityIndicator)
        addSubview(textLabel)
        addSubview(rightImg)
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        textLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        textLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        rightImg.snp.makeConstraints { make in
            make.leading.equalTo(textLabel.snp.trailing).offset(5)
            make.centerY.equalTo(textLabel)
            make.width.height.equalTo(15) // 避免超出父视图
        }
        
        activityIndicator.hidesWhenStopped = true
        textLabel.numberOfLines = 1
        textLabel.textAlignment = .center
    }
    
    private func setupGesture() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        onTap?()
    }
    
    // MARK: - Public API
    var activityType: UIActivityIndicatorView.Style {
        get { indicatorViewType }
        set {
            indicatorViewType = newValue
            activityIndicator.style = newValue
        }
    }
    
    var text: String {
        get { targetText ?? "" }
        set {
            targetText = newValue
            targetAttrText = nil
            currentText = nil
            textLabel.text = nil
            textLabel.attributedText = nil
        }
    }
    
    var attributedText: NSAttributedString? {
        get { targetAttrText }
        set {
            targetAttrText = newValue
            targetText = nil
            currentText = nil
            textLabel.text = nil
            textLabel.attributedText = nil
        }
    }
    
    func getText() -> String {
        return currentText ?? ""
    }
    
    func setRightImage(_ image: UIImage?) {
        rightImg.image = image
    }
    
    func play() {
        activityIndicator.startAnimating()
        textLabel.text = nil
        textLabel.attributedText = nil
        rightImg.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.activityIndicator.stopAnimating()
            self.rightImg.isHidden = false
            
            if let attr = self.targetAttrText {
                switch self.animationType {
                case .simpleShow:
                    self.textLabel.attributedText = attr
                    self.currentText = attr.string
                case .rollingText:
                    self.animateRollingAttributedText(to: attr)
                }
            } else if let text = self.targetText {
                switch self.animationType {
                case .simpleShow:
                    self.textLabel.text = text
                    self.currentText = text
                case .rollingText:
                    self.animateRollingText(to: text)
                }
            }
        }
    }
    
    // MARK: - Animation (纯文本)
    private func animateRollingText(to target: String) {
        guard let targetValue = Double(target.replacingOccurrences(of: ",", with: "")) else {
            self.textLabel.text = target
            self.currentText = target
            return
        }
        
        let duration: TimeInterval = 1.0
        let steps = 30
        let interval = duration / Double(steps)
        
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if currentStep >= steps {
                timer.invalidate()
                self.textLabel.text = target
                self.currentText = target
                return
            }
            
            let progress = Double(currentStep) / Double(steps)
            let currentValue = targetValue * progress
            let str = String(format: "%.2f", currentValue)
            
            self.textLabel.text = str
            self.currentText = str
            currentStep += 1
        }
    }
    
    // MARK: - Animation (富文本)
    private func animateRollingAttributedText(to target: NSAttributedString) {
        let plain = target.string
        guard let targetValue = Double(plain.replacingOccurrences(of: ",", with: "")) else {
            self.textLabel.attributedText = target
            self.currentText = target.string
            return
        }
        
        let baseAttrs = target.attributes(at: 0, effectiveRange: nil)
        
        let duration: TimeInterval = 1.0
        let steps = 30
        let interval = duration / Double(steps)
        
        var currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if currentStep >= steps {
                timer.invalidate()
                self.textLabel.attributedText = target
                self.currentText = target.string
                return
            }
            
            let progress = Double(currentStep) / Double(steps)
            let currentValue = targetValue * progress
            let str = String(format: "%.2f", currentValue)
            
            let attr = NSAttributedString(string: str, attributes: baseAttrs)
            self.textLabel.attributedText = attr
            self.currentText = str
            
            currentStep += 1
        }
    }
}
