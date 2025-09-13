//
//  TradeMonthHeaderView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/25.
//

import UIKit
import SnapKit

class MonthHeaderView: UIView {
    private let backgroundImageView = UIImageView()
    private let monthLabel = UILabel()
    private let incomeLabel = UILabel()
    private let expenseLabel = UILabel()
    private let balanceLabel = UILabel()
    private let symbolLabel = UILabel()
    
    private let bgView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Main_backgroundColor
        
        bgView.backgroundColor = .white
        bgView.frame = CGRect(x: 15, y: 10, width: frame.size.width - 30, height: frame.size.height - 10)
        addSubview(bgView)
        
        // 阴影效果
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.1
        bgView.layer.shadowOffset = CGSize(width: 0, height: 3)
        bgView.layer.shadowRadius = 10
        bgView.layer.masksToBounds = false
        
        backgroundImageView.image = UIImage(named: "month_bg") // 自备背景图
        backgroundImageView.contentMode = .scaleAspectFill
        bgView.addSubview(backgroundImageView)
        
        monthLabel.textColor = Main_TextColor
        addSubview(monthLabel)
        
        let analyzelb:UILabel = creatLabel(CGRect.zero, "分析", fontRegular(12), .white)
        analyzelb.backgroundColor = Main_TextColor
        analyzelb.textAlignment = .center
        backgroundImageView.addSubview(analyzelb)
        
        let wide:CGFloat = (SCREEN_WDITH - 90)/3.0
        
        incomeLabel.textColor = Main_TextColor
        incomeLabel.textAlignment = .center
        incomeLabel.font = fontNumber(18)
        incomeLabel.numberOfLines = 2
        backgroundImageView.addSubview(incomeLabel)
        
        expenseLabel.textColor = Main_TextColor
        expenseLabel.font = fontNumber(18)
        expenseLabel.textAlignment = .right
        expenseLabel.numberOfLines = 2
        backgroundImageView.addSubview(expenseLabel)
        
        
        symbolLabel.textColor = Main_TextColor
        symbolLabel.font = fontNumber(18)
        backgroundImageView.addSubview(symbolLabel)
        
        balanceLabel.textColor = Main_TextColor
        balanceLabel.font = fontNumber(18)
        balanceLabel.numberOfLines = 2
        backgroundImageView.addSubview(balanceLabel)
        
        
        let eqaullb:UILabel = creatLabel(CGRect.zero, "=", fontRegular(15), Main_TextColor)
        backgroundImageView.addSubview(eqaullb)
        
        let minuslb:UILabel = creatLabel(CGRect.zero, "-", fontRegular(15), Main_TextColor)
        backgroundImageView.addSubview(minuslb)
        
        
        let leftlb:UILabel = creatLabel(CGRect.zero, "结余", fontRegular(15), Main_TextColor)
        backgroundImageView.addSubview(leftlb)
        
        let infoimg:UIImageView = UIImageView()
        infoimg.image = UIImage(named: "balance_info")
        backgroundImageView.addSubview(infoimg)
        
        
        let centerlb:UILabel = creatLabel(CGRect.zero, "收入", fontRegular(15), Main_TextColor)
        centerlb.textAlignment = .center
        backgroundImageView.addSubview(centerlb)
        
        let rightlb:UILabel = creatLabel(CGRect.zero, "支出", fontRegular(15), Main_TextColor)
        rightlb.textAlignment = .right
        backgroundImageView.addSubview(rightlb)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        monthLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(35)
            make.top.equalToSuperview().offset(5)
        }
        
        analyzelb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(22)
            make.height.equalTo(24)
            make.width.equalTo(45)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(analyzelb.snp.bottom).offset(22)
        }
        
        balanceLabel.snp.makeConstraints { make in
            make.left.equalTo(symbolLabel.snp.right)
            make.top.equalTo(analyzelb.snp.bottom).offset(22)
            make.width.equalTo(wide - 25)
        }
        
        eqaullb.snp.makeConstraints { make in
            make.left.equalTo(balanceLabel.snp.right)
            make.bottom.equalTo(balanceLabel)
            make.width.equalTo(10)
        }
        
        incomeLabel.snp.makeConstraints { make in
            make.left.equalTo(eqaullb.snp.right)
            make.centerY.height.equalTo(balanceLabel)
            make.width.equalTo(wide)
        }
        
        minuslb.snp.makeConstraints { make in
            make.left.equalTo(incomeLabel.snp.right)
            make.centerY.equalTo(eqaullb)
            make.width.equalTo(10)
        }
        
        expenseLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.height.equalTo(balanceLabel)
            make.width.equalTo(wide)
        }
        
        
        leftlb.snp.makeConstraints { make in
            make.left.equalTo(balanceLabel)
            make.top.equalTo(balanceLabel.snp.bottom).offset(5)
            make.height.equalTo(15)
        }
        
        infoimg.snp.makeConstraints { make in
            make.left.equalTo(leftlb.snp.right).offset(5)
            make.height.width.equalTo(15)
            make.centerY.equalTo(leftlb)
        }
        
        centerlb.snp.makeConstraints { make in
            make.left.right.equalTo(incomeLabel)
            make.top.equalTo(incomeLabel.snp.bottom).offset(8)
            make.height.equalTo(15)
        }

        rightlb.snp.makeConstraints { make in
            make.left.right.equalTo(expenseLabel)
            make.top.equalTo(expenseLabel.snp.bottom).offset(8)
            make.height.equalTo(15)
        }
        
        self.layoutIfNeeded()
        
        SetCornersAndBorder(bgView, radius: 10, corners: [.topLeft,.topRight])
        ViewRadius(analyzelb, 12)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(month: MonthSection) {
        let number:String = month.displayMonth
        
        let richText = NSAttributedString.makeAttributedString(components: [
            .init(text: String(number.dropLast(1)), color: Main_TextColor, font: fontNumber(40)),
            .init(text: String(number.suffix(1)), color: Main_TextColor, font: fontMedium(25))
        ])
        monthLabel.attributedText = richText
        
        incomeLabel.text = getNumberFormatter(month.income)
        expenseLabel.text = getNumberFormatter(month.expense)
        balanceLabel.text = getNumberFormatter(abs(month.income - month.expense))
        symbolLabel.text = (month.income >= month.expense) ? "¥":"-¥"
    }
}
