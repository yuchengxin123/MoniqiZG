//
//  SecureLoadingLabel.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/7.
//

import UIKit
import SnapKit

/// 图片位置枚举
enum SecureLoadingPosition {
    case left
    case right
    case center
}

//转圈显示文本
class SecureLoadingLabel: UIControl {
    
    // MARK: - Public Properties
    
    var attributedText: NSAttributedString? {
        didSet {
            originalAttributedText = attributedText
            originalText = attributedText?.string ?? ""
            updateLabelText()
            invalidateIntrinsicContentSize()
        }
    }
    
    var text: String = "0.00" {
        didSet {
            originalText = text
            if isSecureText {
                label.text = maskedText
            } else {
                label.text = text
            }
            invalidateIntrinsicContentSize()
        }
    }
    
    var textAlignment: NSTextAlignment = .center {
        didSet {
            label.textAlignment = textAlignment
            invalidateIntrinsicContentSize()
        }
    }

    var font: UIFont = fontMedium(25) {
        didSet {
            label.font = font
            invalidateIntrinsicContentSize()
        }
    }

    var textColor: UIColor = Main_TextColor {
        didSet {
            label.textColor = textColor
        }
    }

    var numberOfLines: Int = 1 {
        didSet {
            label.numberOfLines = numberOfLines
            invalidateIntrinsicContentSize()
        }
    }

    var isSecureText: Bool = false {
        didSet {
            updateLabelText()
        }
    }

    var spinnerDuration: TimeInterval = 1.0

    // MARK: - Private Properties

    private let label = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private var originalText: String = "0.00"
    private var originalAttributedText: NSAttributedString?
    
    private var maskedText: String {
        return "******"
//        return String(repeating: "•", count: originalText.count)
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupGesture()
    }

    // MARK: - Setup
    private func setupViews() {
        self.backgroundColor = .clear
        addSubview(label)
        addSubview(spinner)
        label.textColor = Main_TextColor
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        spinner.color = .lightGray
        spinner.hidesWhenStopped = true
        spinner.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        isUserInteractionEnabled = true
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        sendActions(for: .touchUpInside)
    }

    func setPosition(position:SecureLoadingPosition = .left) {
        switch position {
        case .left:
            spinner.snp.remakeConstraints { make in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        case .right:
            spinner.snp.remakeConstraints { make in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
        default:
            spinner.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            break
        }
    }
    
    // MARK: - Public Methods

    /// 触发加载动画，加载结束后显示文本
    func show() {
        label.isHidden = true
        spinner.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + spinnerDuration) {
            self.spinner.stopAnimating()
            self.label.isHidden = false
        }
    }

    /// 获取当前纯文本内容（无论是否密文），包括富文本
    func getOriginalText() -> String {
        return originalAttributedText?.string ?? originalText
    }

    /// 获取原始富文本内容（无论是否密文）
    func getOriginalAttributedText() -> NSAttributedString? {
        return originalAttributedText
    }

    private func updateLabelText() {
        if isSecureText {
            label.attributedText = nil
            label.text = maskedText
        } else {
            if let attrText = originalAttributedText {
                label.attributedText = attrText
            } else {
                label.text = originalText
            }
        }
    }
    
    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        return label.intrinsicContentSize
    }
}
