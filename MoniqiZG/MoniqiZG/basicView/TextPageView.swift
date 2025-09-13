//
//  TextPageView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/30.
//

import UIKit
import SnapKit

//标题上下滚动
class TextPageView: UIView, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private var titles: [String] = []
    private var timer: Timer?
    private var index: Int = 1
    private var lbs:Array<UILabel> = []
    
    
    var autoScrollInterval: TimeInterval = 5.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func changeTextColor(_ color:UIColor){
        for lb in lbs {
            lb.textColor = color
        }
    }
    
    func changeNumberOfLines(_ num:Int){
        for lb in lbs {
            lb.numberOfLines = num
        }
    }

    func configure(with titles: [String]) {
        guard !titles.isEmpty else { return }
        self.titles = titles
        lbs.removeAll()
        setupImageViews()
        scrollView.setContentOffset(CGPoint(x: 0, y: bounds.height), animated: false) // 从第1页开始
        startAutoScroll()
    }

    
    private func setupImageViews() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        print("scrollView=\(scrollView.frame)")
        let extendedTitles = [titles.last!] + titles + [titles.first!]

        for (i, name) in extendedTitles.enumerated() {
            let titlelb = UILabel()
            titlelb.textColor = .white
            titlelb.font = fontRegular(14)
            titlelb.text = name
            scrollView.addSubview(titlelb)

            titlelb.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(CGFloat(i) * self.bounds.height)
                make.width.height.left.equalToSuperview()
            }
            lbs.append(titlelb)
        }

        scrollView.contentSize = CGSize(width: bounds.width, height: bounds.height * CGFloat(extendedTitles.count))
        
        scrollView.contentOffset = CGPoint(x: 0, y: CGFloat(index) * bounds.height)
        
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
        guard titles.count > 1 else { return }
        index+=1
        let offset = CGPoint(x: 0, y: CGFloat(index) * scrollView.bounds.height)
        scrollView.setContentOffset(offset, animated: true)
        adjustFrame()
    }

    private func adjustFrame() {
        if index == titles.count + 1 {
            index = 1
            let offset = CGPoint(x: 0, y: CGFloat(index) * scrollView.bounds.height)
            scrollView.setContentOffset(offset, animated: false)
        }else if index == 0 {
            index = titles.count
            let offset = CGPoint(x: 0, y: CGFloat(index) * scrollView.bounds.height)
            scrollView.setContentOffset(offset, animated: false)
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        adjustFrame()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        setupImageViews() // 重新布局
    }

    deinit {
        stopAutoScroll()
    }
}
