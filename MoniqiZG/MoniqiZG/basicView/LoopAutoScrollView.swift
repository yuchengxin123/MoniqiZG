//
//  SmallCarouselLabel.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/2.
//

import UIKit

enum AutoScrollDirection {
    case horizontal
    case vertical
}

class LoopAutoScrollView: UIView {
    
    private let scrollView = UIScrollView()
    private var contentViews: [UIView] = []
    private var spacing: CGFloat = 10
    private var speed: CGFloat = 20
    private var direction: AutoScrollDirection = .horizontal
    private var displayLink: CADisplayLink?

    private var isScrolling: Bool = false

    init(direction: AutoScrollDirection = .horizontal, speed: CGFloat = 20, spacing: CGFloat = 10) {
        self.direction = direction
        self.speed = speed
        self.spacing = spacing
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = true
        addSubview(scrollView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        reloadLayout()
    }

    func setViews(_ views: [UIView]) {
        stopScrolling()
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        contentViews.removeAll()

        // 添加两倍视图（用于循环）
        for _ in 0..<2 {
            for view in views {
                let container = UIView()
                container.addSubview(view)
                scrollView.addSubview(container)
                contentViews.append(container)
            }
        }
        reloadLayout()
        startScrolling()
    }

    private func reloadLayout() {
        var offset: CGFloat = 0
        for container in contentViews {
            guard let inner = container.subviews.first else { continue }
            inner.sizeToFit()
            let size = inner.bounds.size

            if direction == .horizontal {
                container.frame = CGRect(x: offset, y: 0, width: size.width, height: bounds.height)
                inner.center = CGPoint(x: size.width / 2, y: bounds.height / 2)
                offset += size.width + spacing
            } else {
                container.frame = CGRect(x: 0, y: offset, width: bounds.width, height: size.height)
                inner.center = CGPoint(x: bounds.width / 2, y: size.height / 2)
                offset += size.height + spacing
            }
        }

        if direction == .horizontal {
            scrollView.contentSize = CGSize(width: offset, height: bounds.height)
        } else {
            scrollView.contentSize = CGSize(width: bounds.width, height: offset)
        }
    }

    func startScrolling() {
        guard !isScrolling else { return }
        isScrolling = true
        displayLink = CADisplayLink(target: self, selector: #selector(updateScroll))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stopScrolling() {
        isScrolling = false
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateScroll() {
        let offsetDelta = speed / 60.0
        var offset = scrollView.contentOffset

        switch direction {
        case .horizontal:
            offset.x += offsetDelta
            if offset.x >= scrollView.contentSize.width / 2 {
                offset.x -= scrollView.contentSize.width / 2
            }
        case .vertical:
            offset.y += offsetDelta
            if offset.y >= scrollView.contentSize.height / 2 {
                offset.y -= scrollView.contentSize.height / 2
            }
        }

        scrollView.contentOffset = offset
    }

    deinit {
        stopScrolling()
    }
}
