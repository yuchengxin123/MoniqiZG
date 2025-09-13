//
//  WatermarkOverlay.swift
//  MoniqiZG
//
//  Created by ycx on 2025/9/1.
//
import UIKit

class WatermarkOverlay: UIView {

    var currentWatermarkText: String = "未激活版本"
    
    let fontSize: CGFloat = 16
    var spacingX: CGFloat = 220  // 横向间距
    let spacingY: CGFloat = 50   // 纵向间距
    let textColor = UIColor.black.withAlphaComponent(0.2)
    var upgradeBtn:UIButton?
    
    // 基础颜色池
    let baseColors: [UIColor] = [
        .systemRed.withAlphaComponent(0.25),
        .systemBlue.withAlphaComponent(0.25),
        .systemGreen.withAlphaComponent(0.25),
        .systemOrange.withAlphaComponent(0.25),
        .systemPurple.withAlphaComponent(0.25),
        .systemPink.withAlphaComponent(0.25),
        .brown.withAlphaComponent(0.25)
    ]
    
    var timer: Timer?
    var fixedColors: [UIColor] = []   // 固定的4个颜
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = .black.withAlphaComponent(0.1)
        self.isOpaque = false
        self.contentMode = .redraw  // 旋转或尺寸变化时重新绘制
        
        selectFixedColors()
        updateWatermark()
        startTimer()
        
        upgradeBtn = creatButton(CGRect(x: SCREEN_WDITH - 100, y: SCREEN_HEIGTH - navigationHeight - 100, width: 80, height: 80), "点击激活", fontMedium(14), .white, Main_Color, self, #selector(openVip))
        upgradeBtn?.isUserInteractionEnabled = true
        addSubview(upgradeBtn!)
        
        ViewRadius(upgradeBtn!, 40)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    @objc func openVip(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "微信容易被封，购买激活码请联系qq")
        fieldview.showCopyNumber()
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            
            //激活码
            UserManager.shared.checkPermissions(token: text, isUpgrade: (myUser?.vip_time == .typeNotActivated) ? true:false) {
                
                if myUser?.vip_level != .typeNoAction && myUser?.vip_time != .typeNotActivated{
                    rootCtrl.switchToTab(index: 0)
                    //已激活
                    WaterMark.removeFromSuperview()
                }
            }
        }
    }
    
    // 重写 hitTest 方法,只让按钮响应点击,返回响应视图
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 将点转换为按钮坐标系
        if let upgradeBtn = upgradeBtn {
            let buttonPoint = convert(point, to: upgradeBtn)
            // 如果点在按钮范围内，返回按钮
            if upgradeBtn.bounds.contains(buttonPoint) {
                return upgradeBtn
            }
        }
        // 其他区域返回 nil，不响应点击
        return nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 每分钟随机文案
    private func updateWatermark() {
        currentWatermarkText = String(format: "%@%@", randomChineseName(), getCurrentTimeString())
        spacingX = sizeWide(fontRegular(fontSize), currentWatermarkText) + 20
        setNeedsDisplay()
    }
    /// 随机选取固定的4个颜色
    private func selectFixedColors() {
        fixedColors = Array(baseColors.shuffled().prefix(4))
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateWatermark()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        
        // 旋转画布
        context.translateBy(x: rect.midX, y: rect.midY)
        context.rotate(by: -.pi / 6)
        context.translateBy(x: -rect.midX, y: -rect.midY)
        
        // ===== 构建彩色文案 =====
        let attributedText = NSMutableAttributedString(string: currentWatermarkText)
        let length = currentWatermarkText.count
        let colorCount = fixedColors.count
        
        // 基本分配
        let baseSize = length / colorCount
        var remainder = length % colorCount
        
        var startIndex = 0
        for (i, color) in fixedColors.enumerated() {
            var size = baseSize
            if remainder > 0 { // 平均分不尽，前面的颜色多分1个字
                size += 1
                remainder -= 1
            }
            let endIndex = startIndex + size
            if endIndex > startIndex {
                let range = NSRange(location: startIndex, length: endIndex - startIndex)
                attributedText.addAttributes([
                    .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
                    .foregroundColor: color
                ], range: range)
            }
            startIndex = endIndex
        }
        
        // ===== 绘制到屏幕 =====
        let startX = -rect.width
        let endX = rect.width * 2
        let startY = -rect.height
        let endY = rect.height * 2
        
        for x in stride(from: startX, to: endX, by: spacingX) {
            for y in stride(from: startY, to: endY, by: spacingY) {
                attributedText.draw(at: CGPoint(x: x, y: y))
            }
        }
        
        context.restoreGState()
    }
}

// MARK: - 安全取数组元素
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
