//
//  NumberKeyboard.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/19.
//

import UIKit
import SnapKit

//黑色键盘 密码
//按键背景 #383838 背景#212121 完成和删除背景#565656

//白色键盘 金额
//按键背景 白色 背景#d1d5db 数字#070707 完成#515153 删除背景

/// 键盘类型
enum NumberKeyboardType {
    case bankCard     // 银行卡号/密码输入
    case decimal      // 金额输入（带小数点）
}

enum NumberKeyboardKey {
    case number(String)   // 普通数字或点
    case delete           // 删除
    case done             // 完成
}

class NumberKeyboard: UIView {
    
    var keyTapped: ((NumberKeyboardKey) -> Void)?
    private let type: NumberKeyboardType
    
    init(type: NumberKeyboardType, frame: CGRect = CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: 320)) {
        self.type = type
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let bottomview:UIView = UIView()
        addSubview(bottomview)
        
        let grid = UIStackView()
        grid.axis = .vertical
        grid.distribution = .fillEqually
        grid.spacing = 4
        addSubview(grid)
        grid.translatesAutoresizingMaskIntoConstraints = false
        
        
        bottomview.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
        }
        
        grid.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(3)
            make.bottom.equalTo(bottomview.snp.top).offset(-4)
            make.height.equalTo(232.0)
        }
        
        var titles: [[String]] = []
        
        switch type {
        case .bankCard:
            backgroundColor = HXColor(0x212121)
            bottomview.backgroundColor = HXColor(0x212121)
            // 银行卡数字密码输入键盘
            titles = [
                ["1","2","3"],
                ["4","5","6"],
                ["7","8","9"],
                ["完成","0","key_delete_white"]
            ]
            let titlelb:UILabel = creatLabel(CGRect.zero, "招商银行安全输入", fontMedium(16), HXColor(0x939393))
            titlelb.textAlignment = .center
            addSubview(titlelb)
            
            titlelb.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalToSuperview()
                make.height.equalTo(45)
            }
           
            bottomview.snp.makeConstraints { make in
                make.height.equalTo(bottomSafeAreaHeight + 26)
            }
        case .decimal:
            backgroundColor = HXColor(0xd1d5db)
            bottomview.backgroundColor = .white
            // 金额输入键盘
            titles = [
                ["1","2","3"],
                ["4","5","6"],
                ["7","8","9"],
                ["・","0","key_delete_black"]
            ]
            let titlebtn:UIButton = creatButton(CGRect.zero, "完成", fontRegular(16), HXColor(0x555658), .clear, self, #selector(closeKeyboard))
            addSubview(titlebtn)
            
            titlebtn.snp.makeConstraints { make in
                make.top.right.equalToSuperview()
                make.width.equalTo(80)
                make.height.equalTo(45)
            }
            
            bottomview.snp.makeConstraints { make in
                make.height.equalTo(bottomSafeAreaHeight)
            }
        }

        for (i,row) in titles.enumerated() {
            let hstack = UIStackView()
            hstack.axis = .horizontal
            hstack.distribution = .fillEqually
            hstack.spacing = 4
            grid.addArrangedSubview(hstack)
            
            for (a,title) in row.enumerated() {
                let btn = UIButton()
                btn.setTitle(title, for: .normal)
                
                if type == .decimal {
                    btn.titleLabel?.font = fontRegular(28)
                    btn.backgroundColor = .white
                    btn.setTitleColor(HXColor(0x070707), for: .normal)
                }else{
                    btn.backgroundColor = HXColor(0x383838)
                    btn.setTitleColor(.white, for: .normal)
                    btn.titleLabel?.font = fontMedium(28)
                }
                
                if i == 3{
                    if a == 0{
                        //金额
                        if type == .decimal {
                            
                        }else{
                            btn.backgroundColor = HXColor(0x565656)
                            btn.titleLabel?.font = fontMedium(20)
                            btn.setTitleColor(.white, for: .normal)
                        }
                    }else if(a == 2){
                        btn.setTitle("", for: .normal)
                        //密码
                        if type == .decimal {
                            
                            btn.setImage(UIImage(named: title), for: .normal)
                        }else{
                            btn.backgroundColor = HXColor(0x565656)
                            btn.setImage(UIImage(named: title), for: .normal)
                        }
                        
                    }
                }
                ViewRadius(btn, 6)
                btn.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                hstack.addArrangedSubview(btn)
            }
        }
    }
    
    @objc func closeKeyboard(){
        keyTapped?(.done)
    }
    
    @objc private func keyPressed(_ sender: UIButton) {
        if let title = sender.currentTitle,!title.isEmpty {
            if title == "完成" {
                keyTapped?(.done)
            }else if title == "・"{
                keyTapped?(.number("."))
            }else {
                keyTapped?(.number(title))
            }
        } else if sender.image(for: .normal) != nil {
            keyTapped?(.delete)
        }
    }
}
