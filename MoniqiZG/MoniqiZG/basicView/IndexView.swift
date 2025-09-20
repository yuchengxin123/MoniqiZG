//
//  IndexView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/9/20.
//

import UIKit
import SnapKit

// MARK: - 协议
protocol IndexViewDelegate: AnyObject {
    func indexView(_ indexView: IndexView, didSelect index: Int, title: String)
}

// MARK: - 索引视图
class IndexView: UIView {
    
    // MARK: - 属性
    private var titles: [String]
    private var stackView = UIStackView()
    private var labels: [UILabel] = []
    
    weak var delegate: IndexViewDelegate?
    
    var textColor: UIColor = HXColor(0x696969)
    var selectedTextColor:UIColor = HXColor(0x696969)
    var font: UIFont = fontRegular(12)
    
    // 当前选中
    private var currentIndex: Int? {
        didSet {
            updateSelection()
        }
    }
    
    // MARK: - 初始化
    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private func setupUI() {
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titles.enumerated().forEach { index, title in
            let label = UILabel()
            label.text = title
            label.textColor = textColor
            label.font = font
            label.textAlignment = .center
            label.isUserInteractionEnabled = false
            labels.append(label)
            stackView.addArrangedSubview(label)
        }
    }
    
    // MARK: - 手势
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        addGestureRecognizer(tap)
        addGestureRecognizer(pan)
    }
    
    @objc private func handleTouch(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: self)
        for (index, label) in labels.enumerated() {
            if label.frame.contains(convert(location, to: label)) {
                currentIndex = index
                delegate?.indexView(self, didSelect: index, title: titles[index])
                break
            }
        }
    }
    
    // MARK: - 更新选中状态
    private func updateSelection() {
        for (index, label) in labels.enumerated() {
            if index == currentIndex {
                label.textColor = selectedTextColor
                label.font = font
            } else {
                label.textColor = textColor
                label.font = font
            }
        }
    }
}
