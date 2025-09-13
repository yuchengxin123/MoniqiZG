//
//  CarouselView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/9/13.
//

import UIKit
import SnapKit

// MARK: - 数据模型
struct CarouselItem {
    let image: UIImage
    let title: String
}

// MARK: - 自定义 Cell
class CarouselCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with item: CarouselItem) {
        imageView.image = item.image
    }
}

// MARK: - 主控件
class CarouselView: UIView {
    
    private var collectionView: UICollectionView!
    private var timer: Timer?
    
    private var realItems: [CarouselItem] = []    // 原始数据
    private var displayItems: [CarouselItem] = [] // 扩展后的数据（首尾各加一份）
    
    private let textLabel = UILabel()
    private let pageLabel = UILabel()
    
    private let itemWide:CGFloat = 100
    private let itemHigh:CGFloat = 130
    private let itemSpace:CGFloat = 15
    
    
    private var currentIndex: Int = 0 {
        didSet { updateTextAndPage() }
    }
    
    init(items: [CarouselItem]) {
        self.realItems = items
        super.init(frame: .zero)
        
        prepareDisplayItems()
        setupCollectionView()
        setupLabels()
        startTimer()
        
        // 初始定位到第 1 个真实 item
        DispatchQueue.main.async {
            let startIndex = 1
            self.collectionView.scrollToItem(at: IndexPath(item: startIndex, section: 0), at: .left, animated: false)
            self.currentIndex = 0
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - 组装显示数据
    private func prepareDisplayItems() {
        guard !realItems.isEmpty else { return }

        if let last = realItems.last { displayItems.append(last) }
        displayItems.append(contentsOf: realItems)
        if let first = realItems.first { displayItems.append(first) }
    }
    
    // MARK: - CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemWide, height: itemHigh)
        layout.minimumLineSpacing = itemSpace
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "cell")
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Label
    private func setupLabels() {
        textLabel.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel.textColor = .black
        addSubview(textLabel)
        
        pageLabel.font = .systemFont(ofSize: 14)
        pageLabel.textColor = .darkGray
        pageLabel.textAlignment = .right
        addSubview(pageLabel)
        
        textLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        pageLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
        }
        
        updateTextAndPage()
    }
    
    private func updateTextAndPage() {
        guard !realItems.isEmpty else { return }
        let safeIndex = max(0, min(currentIndex, realItems.count - 1))
        textLabel.text = realItems[safeIndex].title
        pageLabel.text = String(format: "%02d/%02d", safeIndex + 1, realItems.count)
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.scrollToNext()
        }
    }
    
    private func scrollToNext() {
        guard !displayItems.isEmpty else { return }
        let nextIndex = (collectionView.indexPathsForVisibleItems.first?.item ?? 1) + 1
        collectionView.scrollToItem(at: IndexPath(item: nextIndex, section: 0), at: .left, animated: true)
    }
}

// MARK: - CollectionView Delegate
extension CarouselView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarouselCell
        cell.configure(with: displayItems[indexPath.item])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let itemWidth: CGFloat = itemWide + itemSpace
        
        let index = Int(round(offsetX / itemWidth))
        if index >= 1 && index <= realItems.count {
            currentIndex = index - 1
        }
        
        // 缩放处理：左边 item 放大
        for cell in collectionView.visibleCells {
            let cellCenter = collectionView.convert(cell.center, to: self).x
            let distance = abs(cellCenter - 100) // 左边固定点
            let scale = max(0.6, 1 - distance / 300)
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustPositionIfNeeded()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        adjustPositionIfNeeded()
    }
    
    private func adjustPositionIfNeeded() {
        let visibleIndex = collectionView.indexPathsForVisibleItems.sorted().first?.item ?? 0
        if visibleIndex == 0 {
            // 滚动到假的最后一张，跳转到真实最后
            let target = IndexPath(item: realItems.count, section: 0)
            collectionView.scrollToItem(at: target, at: .left, animated: false)
            currentIndex = realItems.count - 1
        } else if visibleIndex == displayItems.count - 1 {
            // 滚动到假的第一张，跳转到真实第一
            let target = IndexPath(item: 1, section: 0)
            collectionView.scrollToItem(at: target, at: .left, animated: false)
            currentIndex = 0
        }
    }
}
