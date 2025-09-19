//
//  SwiftExpand.swift
//  MoniqiZG
//
//  Created by ycx on 2025/6/20.
//

import UIKit
import SnapKit

private var ActionKey: UInt8 = 0

/*
 UIControl+Closure.swift
 button.addAction(for: .touchUpInside) {
     print("按钮被点击！")
 }
 */
public extension UIControl {
    
    typealias UIControlClosure = () -> Void

    /// 给 UIControl 添加事件闭包（如 button 的点击）
    /// - Parameters:
    ///   - controlEvents: UIControl.Event，例如 `.touchUpInside`
    ///   - closure: 响应事件时要执行的代码块
    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping UIControlClosure) {
        // 绑定闭包
        objc_setAssociatedObject(self, &ActionKey, closure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 绑定触发事件
        addTarget(self, action: #selector(handleAction), for: controlEvents)
    }
    
    @objc private func handleAction() {
        if let closure = objc_getAssociatedObject(self, &ActionKey) as? UIControlClosure {
            closure()
        }
    }
}


/// 图片位置枚举
public enum ButtonImagePosition {
    case left
    case right
    case top
    case bottom
}

public extension UIButton {
    
    /// 设置图文按钮的布局样式
    /// - Parameters:
    ///   - image: 图片
    ///   - title: 文本
    ///   - font: 字体
    ///   - spacing: 图片与文字之间的间距
    ///   - position: 图片位置（上、下、左、右）
    func setImageTitleLayout(image: UIImage?,
                              title: String,
                              font: UIFont = UIFont.systemFont(ofSize: 14),
                              spacing: CGFloat = 8,
                              position: ButtonImagePosition = .left) {
        
        self.setImage(image, for: .normal)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        
        guard let imageSize = image?.size,
              let text = self.titleLabel?.text,
              let font = self.titleLabel?.font else { return }
        
        let titleSize = (text as NSString).size(withAttributes: [.font: font])
        
        var imageEdge = UIEdgeInsets.zero
        var titleEdge = UIEdgeInsets.zero
        
        switch position {
        case .left:
            imageEdge = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
            titleEdge = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
            
        case .right:
            imageEdge = UIEdgeInsets(top: 0, left: titleSize.width + spacing/2, bottom: 0, right: -(titleSize.width + spacing/2))
            titleEdge = UIEdgeInsets(top: 0, left: -(imageSize.width + spacing/2), bottom: 0, right: imageSize.width + spacing/2)
            
        case .top:
            imageEdge = UIEdgeInsets(top: -titleSize.height/2 - spacing/2, left: 0, bottom: titleSize.height/2 + spacing/2, right: -titleSize.width)
            titleEdge = UIEdgeInsets(top: imageSize.height/2 + spacing/2, left: -imageSize.width, bottom: -imageSize.height/2 - spacing/2, right: 0)
            
        case .bottom:
            imageEdge = UIEdgeInsets(top: titleSize.height/2 + spacing/2, left: 0, bottom: -titleSize.height/2 - spacing/2, right: -titleSize.width)
            titleEdge = UIEdgeInsets(top: -imageSize.height/2 - spacing/2, left: -imageSize.width, bottom: imageSize.height/2 + spacing/2, right: 0)
        }

        self.titleEdgeInsets = titleEdge
        self.imageEdgeInsets = imageEdge
    }
}


// MARK: - 图片文本按钮
enum YcxImagePosition {
    case top, bottom, left, right
}

class YcxImageTextButton: UIControl {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    var onTap: (() -> Void)?
    // Public config
    var spacing: CGFloat = 8
    var imageSize: CGSize?
    var position: YcxImagePosition = .top
    
    // 状态属性
    var normalImage: UIImage?
    var selectedImage: UIImage?
    
    var normalTextColor: UIColor = .black
    var selectedTextColor: UIColor = .blue
    
    var normalFont: UIFont = .systemFont(ofSize: 14)
    var selectedFont: UIFont = .boldSystemFont(ofSize: 14)
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    override var isSelected: Bool {
        didSet {
            refreshStyle()
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        imageView.contentMode = .scaleAspectFill
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let image = imageView.image else { return }
        
        let imgSize = imageSize ?? image.size
        let titleSize = titleLabel.intrinsicContentSize
        
        switch position {
        case .top, .bottom:
            let totalHeight = imgSize.height + spacing + titleSize.height
            let centerX = bounds.width / 2
            
            if position == .top {
                imageView.frame = CGRect(x: centerX - imgSize.width/2, y: (bounds.height - totalHeight)/2, width: imgSize.width, height: imgSize.height)
                titleLabel.frame = CGRect(x: 0, y: imageView.frame.maxY + spacing, width: bounds.width, height: titleSize.height)
            } else {
                titleLabel.frame = CGRect(x: 0, y: (bounds.height - totalHeight)/2, width: bounds.width, height: titleSize.height)
                imageView.frame = CGRect(x: centerX - imgSize.width/2, y: titleLabel.frame.maxY + spacing, width: imgSize.width, height: imgSize.height)
            }
        case .left, .right:
            let totalWidth = imgSize.width + spacing + titleSize.width
            let centerY = bounds.height / 2
            
            if position == .left {
                imageView.frame = CGRect(x: (bounds.width - totalWidth)/2, y: centerY - imgSize.height/2, width: imgSize.width, height: imgSize.height)
                titleLabel.frame = CGRect(x: imageView.frame.maxX + spacing, y: centerY - titleSize.height/2, width: titleSize.width, height: titleSize.height)
            } else {
                titleLabel.frame = CGRect(x: (bounds.width - totalWidth)/2, y: centerY - titleSize.height/2, width: titleSize.width, height: titleSize.height)
                imageView.frame = CGRect(x: titleLabel.frame.maxX + spacing, y: centerY - imgSize.height/2, width: imgSize.width, height: imgSize.height)
            }
        }
    }
    
    private func refreshStyle() {
        imageView.image = isSelected ? selectedImage : normalImage
        titleLabel.textColor = isSelected ? selectedTextColor : normalTextColor
        titleLabel.font = isSelected ? selectedFont : normalFont
        setNeedsLayout()
    }
    
    @objc private func handleTap() {
        // 可以切换选中状态，也可以只触发外部事件
        onTap?()
    }
}

// MARK: - 富文本 计算宽高和属性快捷设置
extension NSAttributedString {
    struct TextComponent {
        let text: String
        let color: UIColor
        let font: UIFont
    }

    static func makeAttributedString(components: [TextComponent], lineSpacing: CGFloat = 0) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for comp in components {
            let attr = NSAttributedString(string: comp.text, attributes: [
                .foregroundColor: comp.color,
                .font: comp.font
            ])
            result.append(attr)
        }

        if lineSpacing > 0 {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpacing
            result.addAttributes([.paragraphStyle: style], range: NSRange(location: 0, length: result.length))
        }

        return result
    }
    
    func width(constrainedToHeight height: CGFloat) -> CGFloat {
        let size = self.boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        return ceil(size.width)
    }
    
    func height(constrainedToWidth width: CGFloat) -> CGFloat {
        let size = self.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        return ceil(size.height) // 向上取整，避免显示不全
    }
}

// MARK: - 银行卡号格式化
extension UITextField {
    
    /// 启用银行卡号格式化（每4位加空格）
    func enableBankCardFormat() {
        self.keyboardType = .numberPad
        self.addTarget(self, action: #selector(formatBankCardNumber), for: .editingChanged)
    }
    
    @objc private func formatBankCardNumber() {
        // 1. 获取光标位置
        guard let selectedRange = self.selectedTextRange else { return }
        let cursorOffset = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
        
        // 2. 去掉空格
        let textWithoutSpaces = self.text?.replacingOccurrences(of: " ", with: "") ?? ""
        
        // 3. 每4位插入空格
        var formatted = ""
        for (index, char) in textWithoutSpaces.enumerated() {
            if index != 0 && index % 4 == 0 {
                formatted.append(" ")
            }
            formatted.append(char)
        }
        
        self.text = formatted
        
        // 4. 计算新的光标位置
        var targetPosition = cursorOffset
        if cursorOffset > 0 && cursorOffset < formatted.count {
            // 如果光标位置正好在空格后，往前挪一位
            if formatted[formatted.index(formatted.startIndex, offsetBy: cursorOffset-1)] == " " {
                targetPosition += 1
            }
        }
        
        // 5. 重新设置光标位置
        if let newPosition = self.position(from: self.beginningOfDocument, offset: targetPosition) {
            self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
        }
    }
}


// MARK: - 指定key 去重
extension Array where Element: SafeModel {
    /// 根据指定 keyPath 去重，保留最后一个
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var dict: [T: Element] = [:]
        for element in self {
            dict[element[keyPath: keyPath]] = element  // 后面的会覆盖前面的
        }
        return Array(dict.values)
    }
}

// MARK: - 获取 UIView 截图
extension UIView {
    /// 截图为 UIImage
    func snapshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}

// MARK: - 交易时间分组
extension Array where Element == TransferModel {
    //MARK: - 所有流水分组
    func groupedByMonthAndDay() -> [MonthSection] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let calendar = Calendar.current
       // let today = Date()
        
        var monthDict: [String: [TransferModel]] = [:]
        
        // 先按月分组
        for item in self {
            guard let date = dateFormatter.date(from: item.bigtime) else { continue }
            let comp = calendar.dateComponents([.year, .month], from: date)
            let key = String(format: "%04d-%02d", comp.year ?? 0, comp.month ?? 0)
            
            if monthDict[key] == nil { monthDict[key] = [] }
            monthDict[key]?.append(item)
        }
        
        var monthSections: [MonthSection] = []
        
        for (monthKey, monthModels) in monthDict {
            // ---- 按日期分组
            var dayDict: [String: [TransferModel]] = [:]
            
            for item in monthModels {
                guard let date = dateFormatter.date(from: item.bigtime) else { continue }
                let dayKey = String(format: "%04d-%02d-%02d",
                                    calendar.component(.year, from: date),
                                    calendar.component(.month, from: date),
                                    calendar.component(.day, from: date))
                
                if dayDict[dayKey] == nil { dayDict[dayKey] = [] }
                dayDict[dayKey]?.append(item)
            }
            
            var daySections: [DaySection] = []
            for (dayKey, dayModels) in dayDict {
                let date = dateFormatter.date(from: dayModels.first?.bigtime ?? "") ?? Date()
                
                let displayDate: String
                if calendar.isDateInToday(date) {
                    displayDate = "今天"
                } else if calendar.isDateInYesterday(date) {
                    displayDate = "昨天"
                } else {
                    let df = DateFormatter()
                    df.dateFormat = "MM.dd"
                    displayDate = df.string(from: date)
                }
                
                // ---- 按 bigtime 倒序排列每日记录
                let sortedDayModels = dayModels.sorted {
                    ($0.bigtime) > ($1.bigtime)
                }

                daySections.append(DaySection(date: dayKey,displayDate: displayDate,records: sortedDayModels))
            }
            
            // ---- 计算收入/支出
            let income = monthModels.filter { $0.isIncome == true }.reduce(0) { $0 + $1.amount }
            let expense = monthModels.filter { $0.isIncome  == false }.reduce(0) { $0 + $1.amount }
            
            let comp = monthKey.split(separator: "-")
            let displayMonth = "\(Int(comp[1]) ?? 0)月"
            
            // ---- 排序日期（倒序）
            daySections.sort { $0.date > $1.date }
            
            monthSections.append(MonthSection(yearMonth: monthKey,
                                              displayMonth: displayMonth,
                                              income: income,
                                              expense: expense,
                                              days: daySections))
        }
        
        // ---- 排序月份（倒序）
        monthSections.sort { $0.yearMonth > $1.yearMonth }
        return monthSections
    }
    
    //MARK: - 只是转账分组
    func groupedTransfersOnly() -> [TransferMonthSection] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let calendar = Calendar.current
        let now = Date()
        let currentComp = calendar.dateComponents([.year, .month], from: now)
        
        // 筛选 tradeType == 200 或 201
        let filtered = self.filter {
            $0.tradeType == TransactionChildType.typeTransfer200.type ||
            $0.tradeType == TransactionChildType.typeTransfer201.type
        }
        
        // 按月分组
        var monthDict: [String: [TransferModel]] = [:]
        
        for item in filtered {
            guard let date = dateFormatter.date(from: item.bigtime) else { continue }
            let comp = calendar.dateComponents([.year, .month], from: date)
            let key = String(format: "%04d-%02d", comp.year ?? 0, comp.month ?? 0)
            
            if monthDict[key] == nil { monthDict[key] = [] }
            monthDict[key]?.append(item)
        }
        
        var monthSections: [TransferMonthSection] = []
        
        for (monthKey, monthModels) in monthDict {
            let sortedModels = monthModels.sorted { $0.bigtime > $1.bigtime }
            
            let income = sortedModels.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
            let expense = sortedModels.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
            
            // ---- 生成 displayTitle
            let parts = monthKey.split(separator: "-")
            let year = Int(parts[0]) ?? 0
            let month = Int(parts[1]) ?? 0
            
            let displayTitle: String
            if year == currentComp.year && month == currentComp.month {
                displayTitle = "本月"
            } else if year == currentComp.year {
                displayTitle = "\(month)月"
            } else {
                displayTitle = "\(year)年\(month)月"
            }
            
            monthSections.append(TransferMonthSection(
                yearMonth: monthKey,
                displayTitle: displayTitle,
                income: income,
                expense: expense,
                records: sortedModels
            ))
        }
        
        // 按月份倒序排序
        monthSections.sort { $0.yearMonth > $1.yearMonth }
        return monthSections
    }
    
    //MARK: - 排序加重算数组所有流水
    mutating func sortAndCalculateBalance(initialBalance: Double) {
        // 1. 排序（按 bigtime 倒序，最近的时间在前）
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.sort { m1, m2 in
            guard let d1 = formatter.date(from: m1.bigtime),
                  let d2 = formatter.date(from: m2.bigtime) else {
                return false
            }
            return d1 > d2
        }
        
        // 2. 计算余额
        var currentBalance = initialBalance
        for model in self {
            model.calculatedBalance = currentBalance
            
            if model.isIncome {
                // 收入：余额减少
                currentBalance -= model.amount
            } else {
                // 支出：余额增加
                currentBalance += model.amount
            }
        }
    }
    
    //MARK: - 删除指定转账流水
    mutating func removeFirstExactMatch(of model: TransferModel) {
        // 回退：用可容忍浮点误差和标准化卡号来匹配
        let eps = 1e-6
        if let idx = firstIndex(where: {
            $0.isIncome == model.isIncome &&
            abs($0.amount - model.amount) < eps &&
            $0.payBank == model.payBank &&
            $0.payCard.replacingOccurrences(of: " ", with: "") == model.payCard.replacingOccurrences(of: " ", with: "") &&
            $0.bigtime == model.bigtime &&
            $0.smalltime == model.smalltime &&
            $0.serialNumber == model.serialNumber &&
            $0.merchantNumber == model.merchantNumber &&
            $0.remind == model.remind &&
            $0.tradeType == model.tradeType &&
            $0.tradeStyle == model.tradeStyle &&
            $0.area == model.area &&
            $0.receiveType == model.receiveType
        }) {
            remove(at: idx)
        }
    }

    //MARK: - 删除某人所有的交易流水
    mutating func removeAllTransactionsOfUser(of partner: TransferPartner) {
        self.removeAll { item in
            item.partner.card == partner.card &&
            item.partner.name == partner.name &&
            item.partner.lastCard == partner.lastCard &&
            item.partner.icon == partner.icon &&
            item.partner.bankName == partner.bankName &&
            item.partner.cardName == partner.cardName &&
            item.partner.cardType == partner.cardType
        }
    }
    
    //MARK: - 通过流水获取我的伙伴
    mutating func uniquePartnersForTransfer200And201() -> [TransferPartner] {
        // 1. 排序（按 bigtime 倒序，最近的时间在前）
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.sort { m1, m2 in
            guard let d1 = formatter.date(from: m1.bigtime),
                  let d2 = formatter.date(from: m2.bigtime) else {
                return false
            }
            return d1 > d2
        }
        
        let validTypes = [
            TransactionChildType.typeTransfer200.type,
            TransactionChildType.typeTransfer201.type
        ]
        
        var seenKeys = Set<String>()
        var result: [TransferPartner] = []
        
        for model in self where validTypes.contains(model.tradeType) {
            let partner = model.partner
            // 🔑 这里定义唯一性 key（你可以按业务调整）
            let key = "\(partner.card)|\(partner.name)|\(partner.bankName)|\(partner.cardName)"
            
            if !seenKeys.contains(key) {
                seenKeys.insert(key)
                result.append(partner)
            }
        }
        
        return result
    }
}

//MARK: -中文转拼音首字母
extension String {
    var firstPinyinLetter: String {
        guard !self.isEmpty else { return "#" }
        let mutableString = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let pinyin = mutableString as String
        let firstChar = pinyin.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1).uppercased()
        if let scalar = firstChar.unicodeScalars.first, CharacterSet.letters.contains(scalar) {
            return firstChar
        } else {
            return "#"
        }
    }
}
