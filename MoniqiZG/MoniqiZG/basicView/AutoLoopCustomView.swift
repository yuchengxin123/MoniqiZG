//
//  AutoLoopScrollView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/12.
//

import UIKit


enum LoopScrollDirection {
    case horizontal
    case vertical
}

class AutoLoopCustomView: UIView, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private var views: [UIView] = []
    private var timer: Timer?
    private var index: Int = 1
    private var direction: LoopScrollDirection
    private var pendingConfigure: Bool = false
    
    var autoScrollInterval: TimeInterval = 5.0
    var isAutoScrollEnabled: Bool = true

    init(direction: LoopScrollDirection = .vertical, autoScrollInterval: TimeInterval = 5.0) {
        self.direction = direction
        self.autoScrollInterval = autoScrollInterval
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        self.direction = .vertical
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with views: [UIView]) {
        guard !views.isEmpty else { return }
        stopAutoScroll()
        self.views = views
        pendingConfigure = true
        setNeedsLayout() // 等布局完再配置
    }
    
    private func buildContent() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let size = bounds.size
        guard size.width > 0, size.height > 0 else { return }
        
        // 扩展头尾
        
        
        if direction == .vertical {
            scrollView.contentSize = CGSize(width: size.width, height: size.height * CGFloat(views.count))
            scrollView.contentOffset = CGPoint(x: 0, y: size.height)
        } else {
            scrollView.contentSize = CGSize(width: size.width * CGFloat(views.count), height: size.height)
            scrollView.contentOffset = CGPoint(x: size.width, y: 0)
        }
        
        for (i, v) in views.enumerated() {
            if direction == .vertical {
                v.frame = CGRect(x: 0, y: CGFloat(i) * size.height,
                                 width: size.width, height: size.height)
            } else {
                v.frame = CGRect(x: CGFloat(i) * size.width, y: 0,
                                 width: size.width, height: size.height)
            }
            scrollView.addSubview(v)
        }

        print("测试loopview=\(scrollView.subviews)")
        
        index = 1
        if isAutoScrollEnabled { startAutoScroll() }
    }
    
    private func startAutoScroll() {
        stopAutoScroll()
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { [weak self] _ in
            self?.scrollToNext()
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scrollToNext() {
        guard views.count > 1 else { return }
        index += 1
        let size = bounds.size
        var offset: CGPoint
        if direction == .vertical {
            offset = CGPoint(x: 0, y: CGFloat(index) * size.height)
        } else {
            offset = CGPoint(x: CGFloat(index) * size.width, y: 0)
        }
        self.scrollView.setContentOffset(offset, animated: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        adjustFrameIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustFrameIfNeeded()
    }
    
    private func adjustFrameIfNeeded() {
        if index == views.count - 1 {
            index = 1
            jumpToIndex(index)
        }
//        else if index == 0 {
//            index = views.count
//            jumpToIndex(index)
//        }
    }
    
    private func jumpToIndex(_ index: Int) {
        let size = bounds.size
        let offset: CGPoint
        if direction == .vertical {
            offset = CGPoint(x: 0, y: CGFloat(index) * size.height)
        } else {
            offset = CGPoint(x: CGFloat(index) * size.width, y: 0)
        }
        scrollView.setContentOffset(offset, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let size = bounds.size
        if direction == .vertical {
            index = Int(round(scrollView.contentOffset.y / size.height))
        } else {
            index = Int(round(scrollView.contentOffset.x / size.width))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if pendingConfigure {
            pendingConfigure = false
            buildContent()
        }
    }
    
    deinit {
        stopAutoScroll()
    }
}
