//
//  TradeDayHeaderView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/25.
//
import UIKit
import SnapKit
class DayHeaderView: UIView {
    private let headlb = UILabel()
    let bgView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Main_backgroundColor
        
        bgView.backgroundColor = .white
        bgView.frame = CGRect(x: 15, y: 0, width: frame.size.width - 30, height: frame.size.height)
        addSubview(bgView)
        
        
        headlb.textColor = Main_TextColor
        headlb.font = fontRegular(12)
        headlb.backgroundColor = Main_backgroundColor
        headlb.textAlignment = .center
        headlb.text = "01.01"
        bgView.addSubview(headlb)
        
        headlb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        ViewRadius(headlb, 4)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(date: String) {
        let wide:CGFloat = sizeWide(fontRegular(12), date) + 20
        headlb.text = date
        
        headlb.snp.updateConstraints { make in
            make.width.equalTo(wide)
        }
    }
}
