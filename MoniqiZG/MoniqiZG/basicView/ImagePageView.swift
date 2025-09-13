//
//  ImagePageView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/30.
//
import UIKit
import SnapKit

class ImagePageView: UIView, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    let pageControl = CustomPageControl()
    private var images: [String] = []
    private var timer: Timer?
    private var index: Int = 1
    
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

        
        pageControl.spacing = 5
        pageControl.normalColor = HXColor(0xdedede)
        pageControl.selectedColor = .clear
        pageControl.selectedGradientColors = [HXColor(0xf7606a), HXColor(0xfeb39f)]
        pageControl.normalSize = CGSize(width: 4, height: 4)
        pageControl.selectedSize = CGSize(width: 12, height: 4)
        
        addSubview(pageControl)

        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
    }

    func configure(with images: [String]) {
        guard !images.isEmpty else { return }
        self.images = images
        setupImageViews()
        //设置pageControl 的page数量和重置宽度
        pageControl.numberOfPages = images.count
        pageControl.invalidateIntrinsicContentSize()
        
        scrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false) // 从第1页开始
        startAutoScroll()
    }

    //是否展示page page scrollView上还是在底部
    func showPage(_ hide:Bool,full: Bool? = true){
        pageControl.isHidden = hide
        
        if full == true {
            scrollView.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
        }else{
            scrollView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-35)
            }
        }

    }
    
    private func setupImageViews() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        if images.count > 0 {
            let extendedImages = [images.last!] + images + [images.first!]

            for (i, name) in extendedImages.enumerated() {
                let imageView = UIImageView()
                imageView.image = UIImage(named: name)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                scrollView.addSubview(imageView)

                imageView.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.width.height.equalToSuperview()
                    make.left.equalToSuperview().offset(CGFloat(i) * self.bounds.width)
                }
                
                ViewRadius(imageView, 4)
            }

            scrollView.contentSize = CGSize(width: bounds.width * CGFloat(extendedImages.count), height: bounds.height)
            
            scrollView.contentOffset = CGPoint(x: CGFloat(index) * bounds.width, y: 0)
        }
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
        guard images.count > 1 else { return }
        index+=1
        let offset = CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
        adjustFrame()
    }

    private func adjustFrame() {
        if index == images.count + 1 {
            index = 1
            let offset = CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
            scrollView.setContentOffset(offset, animated: false)
        }else if index == 0 {
            index = images.count
            let offset = CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
            scrollView.setContentOffset(offset, animated: false)
        }
        pageControl.currentPage = index - 1
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageControl.currentPage = page - 1
        index = page
        adjustFrame()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("是不是一直在走?--\(String(describing: self.superview))")
    }

    deinit {
        stopAutoScroll()
    }
}
