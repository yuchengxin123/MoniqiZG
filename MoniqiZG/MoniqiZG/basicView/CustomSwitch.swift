//
//  CustomSwitch.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/27.
//

import UIKit

class CustomSwitch: UIControl {
    
    // MARK: - Public properties
    var isOn: Bool = true {
        didSet { updateUI(animated: true) }
    }
    
    var onTintColor: UIColor = .systemGreen {
        didSet { updateUI(animated: false) }
    }
    
    var offTintColor: UIColor = .lightGray {
        didSet { updateUI(animated: false) }
    }
    
    var thumbTintColor: UIColor = .white {
        didSet { thumbView.backgroundColor = thumbTintColor }
    }
    
    /// 滑块图片（nil 表示使用默认圆形）
    var thumbImage: UIImage? {
        didSet {
            thumbImageView.image = thumbImage
            thumbImageView.isHidden = (thumbImage == nil)
        }
    }
    
    /// 是否添加滑块阴影
    var thumbShadowEnabled: Bool = true {
        didSet { updateThumbShadow() }
    }
    
    /// 控件缩放比例
    var scale: CGFloat = 1.0 {
        didSet { invalidateIntrinsicContentSize(); setNeedsLayout() }
    }
    
    // MARK: - Private views
    private let backgroundView = UIView()
    private let thumbView = UIView()
    private let thumbImageView = UIImageView()
    
    private var thumbSize: CGSize {
        return CGSize(width: bounds.height - 4, height: bounds.height - 4)
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 51 * scale, height: 31 * scale)
    }
    
    // MARK: - Setup
    private func setup() {
        backgroundView.layer.cornerRadius = bounds.height / 2
        backgroundView.isUserInteractionEnabled = false
        addSubview(backgroundView)
        
        thumbView.backgroundColor = thumbTintColor
        thumbView.layer.cornerRadius = (bounds.height - 4) / 2
        thumbView.isUserInteractionEnabled = false
        addSubview(thumbView)
        
        thumbImageView.contentMode = .scaleAspectFit
        thumbImageView.isHidden = true
        thumbView.addSubview(thumbImageView)
        
        updateUI(animated: false)
        updateThumbShadow()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSwitch))
        addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2
        
        let size = thumbSize
        let y = (bounds.height - size.height) / 2
        let x = isOn ? bounds.width - size.width - 2 : 2
        thumbView.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        thumbView.layer.cornerRadius = size.height / 2
        
        thumbImageView.frame = thumbView.bounds.insetBy(dx: 4, dy: 4)
    }
    
    // MARK: - Update
    private func updateUI(animated: Bool) {
        let changes = {
            self.backgroundView.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
            self.layoutSubviews()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }
    }
    
    private func updateThumbShadow() {
        if thumbShadowEnabled {
            thumbView.layer.shadowColor = UIColor.black.cgColor
            thumbView.layer.shadowOpacity = 0.3
            thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
            thumbView.layer.shadowRadius = 2
        } else {
            thumbView.layer.shadowOpacity = 0
        }
    }
    
    // MARK: - Actions
    @objc private func didTapSwitch() {
        isOn.toggle()
        sendActions(for: .valueChanged)
    }
}
