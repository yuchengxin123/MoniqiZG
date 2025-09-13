//
//  FloatingTextTagView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/2.
//

import UIKit

class FloatingTextTagView: UIView {
    
    private let bigLabel = UILabel()
    private let smallLabel = UILabel()
    private let backgroundView = UIView()
    
    // MARK: - 初始化
    init(bigText: String, smallText: String) {
        super.init(frame: .zero)
        setupUI()
        configure(bigText: bigText, smallText: smallText)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // 背景视图
        addSubview(backgroundView)
        
        // 文本
        bigLabel.font = fontMedium(14)
        bigLabel.textColor = HXColor(0x585858)
        smallLabel.font = fontRegular(10)
        smallLabel.textColor = HXColor(0x808080)

        addSubview(bigLabel)
        addSubview(smallLabel)
    }

    private func configure(bigText: String, smallText: String) {
        bigLabel.text = bigText
        smallLabel.text = smallText

        backgroundView.backgroundColor = HXColor(0xe9ecf9)
        
        // 强制更新布局计算宽高
        layoutIfNeeded()
        
        // 计算大小
        let bigSize = bigLabel.intrinsicContentSize
        let smallSize = smallLabel.intrinsicContentSize

        let spacing: CGFloat = 3
        let paddingV: CGFloat = 10
        let paddingH: CGFloat = 6
        
        let totalWidth = bigSize.width + spacing + smallSize.width + paddingV * 2
        let totalHeight = max(bigSize.height, smallSize.height) + paddingH * 2

        // 设置自身大小
        self.frame = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
        backgroundView.frame = bounds

        // 对齐到底部
        let baseY = bounds.height - paddingH - max(bigSize.height, smallSize.height)
        bigLabel.frame = CGRect(x: paddingV, y: baseY + (max(bigSize.height, smallSize.height) - bigSize.height), width: bigSize.width, height: bigSize.height)
        smallLabel.frame = CGRect(x: bigLabel.frame.maxX + spacing, y: baseY + (max(bigSize.height, smallSize.height) - smallSize.height), width: smallSize.width, height: smallSize.height)
        
        
        setupViewWithRoundedCornersAndShadow(
            backgroundView,
            radius: totalHeight/2.0,
            corners: [.topLeft, .topRight , .bottomLeft], // 示例: 左上+右下圆角
            borderWidth: 1,
            borderColor: .white,
            shadowColor: .lightGray, // 浅灰色阴影
            shadowRadius: 3,         // 柔和扩散效果
            shadowOpacity: 0.2       // 浅色透明度
        )
    }

    // MARK: - 外部更新接口
    func update(bigText: String, smallText: String) {
        configure(bigText: bigText, smallText: smallText)
    }
}
