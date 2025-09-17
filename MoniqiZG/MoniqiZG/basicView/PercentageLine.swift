//
//  PercentageLine.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/11.
//

import UIKit
import SnapKit


class PercentageLine: UIView {
    
    private let leftLine = UIView()
    private let rightLine = UIView()
    private let gap: CGFloat = 5 // 中间间隙宽度
    
    // 配色
    var leftColor: UIColor = HXColor(0xcd9a53) {
        didSet { leftLine.backgroundColor = leftColor }
    }
    var rightColor: UIColor = HXColor(0xe5e5e5) {
        didSet { rightLine.backgroundColor = rightColor }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(leftLine)
        addSubview(rightLine)
        
        leftLine.backgroundColor = leftColor
        rightLine.backgroundColor = rightColor
        
        // 默认布局（占满，稍后 update）
        leftLine.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
        
        rightLine.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
    }
    
    /// 更新比例
    /// - Parameter ratio: 左边所占比例（0~1）
    func updateRatio(_ ratio: CGFloat) {
        let clampedRatio = max(0, min(1, ratio))
        
        if clampedRatio == 0 || clampedRatio == 1 {
            // 单色状态
            leftLine.backgroundColor = clampedRatio == 0 ? rightColor : leftColor
            rightLine.backgroundColor = clampedRatio == 0 ? rightColor : leftColor
            
            leftLine.snp.remakeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalToSuperview()
            }
            rightLine.snp.remakeConstraints { make in
                make.width.equalTo(0)
            }
        } else {
            // 双色状态（带中间 gap）
            leftLine.backgroundColor = leftColor
            rightLine.backgroundColor = rightColor
            
            leftLine.snp.remakeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(clampedRatio).offset(-(gap/2))
            }
            
            rightLine.snp.remakeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(1 - clampedRatio).offset(-(gap/2))
            }
        }
    }
}
