//
//  CustomPageControl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/2.
//

import UIKit

//默认轮播
class CustomPageControl: UIView {

    // MARK: - Public Configurable Properties
    var numberOfPages: Int = 0 {
        didSet { setupDots() }
    }
    
    //didSet属性观察器 属性变化就会执行updateDots
    var currentPage: Int = 0 {
        didSet { updateDots() }
    }

    var spacing: CGFloat = 8

    // 尺寸
    var selectedSize: CGSize = CGSize(width: 20, height: 6)
    var normalSize: CGSize = CGSize(width: 6, height: 6)

    // 颜色
    var selectedColor: UIColor = .black
    var normalColor: UIColor = UIColor.black.withAlphaComponent(0.2)

    // 渐变
    var selectedGradientColors: [UIColor]? = nil  // 设置后启用渐变
    var cornerRadius: CGFloat? = nil  // 如果为 nil 则自动设为 height/2

    // MARK: - Private
    private var dotViews: [UIView] = []

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: - 自动宽度支持
    override var intrinsicContentSize: CGSize {
        let totalWidth: CGFloat = {
            guard numberOfPages > 0 else { return 0 }
            let totalDotWidth = CGFloat(numberOfPages - 1) * (normalSize.width + spacing) + selectedSize.width
            return totalDotWidth
        }()
        
        let height = max(selectedSize.height, normalSize.height)
        return CGSize(width: totalWidth, height: height)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Setup
    private func setupDots() {
        dotViews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()

        for i in 0..<numberOfPages {
            let dot = UIView()
            dot.layer.masksToBounds = true
            dot.tag = i
            addSubview(dot)
            dotViews.append(dot)
        }

        layoutDots()
        updateDots()
    }

    private func layoutDots() {
        var x: CGFloat = 0

        for (i, dot) in dotViews.enumerated() {
            let isSelected = (i == currentPage)
            let size = isSelected ? selectedSize : normalSize

            let newFrame = CGRect(x: x, y: (bounds.height - size.height)/2, width: size.width, height: size.height)

            if dot.frame != newFrame {
                dot.frame = newFrame
                dot.layer.cornerRadius = cornerRadius ?? (size.height / 2)
            }

            x += size.width + spacing
        }
    }

    private func updateDots() {
        for (i, dot) in dotViews.enumerated() {
            let isSelected = (i == currentPage)
            let size = isSelected ? selectedSize : normalSize
            let color = isSelected ? selectedColor : normalColor

            // 仅当 size 变化时才修改 frame，避免频繁触发 layout
            if dot.frame.size != size {
                dot.frame.size = size
                dot.frame.origin.y = (bounds.height - size.height)/2
                dot.layer.cornerRadius = cornerRadius ?? (size.height / 2)
            }

            if isSelected, let gradientColors = selectedGradientColors {
                applyGradient(dot, colors: gradientColors)
            } else {
                dot.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
                dot.backgroundColor = color
            }
        }
    }

    // MARK: - Gradient
    private func applyGradient(_ view: UIView, colors: [UIColor]) {
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = view.layer.cornerRadius
        view.layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDots()
    }
}
