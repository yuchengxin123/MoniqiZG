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
    case phone     // 手机号转账
    case decimal      // 账号转账
}

enum NumberKeyboardKey {
    case number(String)   // 普通数字或点
    case delete           // 删除
    case done             // 完成
    case close             // 关闭
}

let space:CGFloat = 4

class NumberKeyboard: UIView {
    
    var keyTapped: ((NumberKeyboardKey) -> Void)?
    private let type: NumberKeyboardType
    
    init(type: NumberKeyboardType, frame: CGRect = CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: CustomKeyboardHeight)) {
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
        grid.spacing = space
        addSubview(grid)
        grid.translatesAutoresizingMaskIntoConstraints = false
        
        bottomview.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
        }
        let wide:CGFloat = (SCREEN_WDITH - 12 - space * 2)/4.0 * 3.0 + 8
        let btnHigh:CGFloat = 52
        
        grid.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(6)
            make.width.equalTo(wide)
            make.bottom.equalTo(bottomview.snp.top).offset(-space)
            make.height.equalTo(btnHigh * 4 + space * 3)
        }
        
        var titles: [[String]] = []
        
        switch type {
        case .phone:
            backgroundColor = HXColor(0xe5e5e5)
            bottomview.backgroundColor = HXColor(0xe5e5e5)
            // 银行卡数字密码输入键盘
            titles = [
                ["1","2","3"],
                ["4","5","6"],
                ["7","8","9"],
                ["phone_dot_black","0","phone_keyboard_black"]
            ]
            
            let deleteBtn:UIButton = UIButton()
            deleteBtn.setImage(UIImage(named: "phone_delete_black"), for: .normal)
            deleteBtn.setImage(UIImage(named: "phone_delete_black"), for: .selected)
            deleteBtn.addTarget(self, action: #selector(deleteKeyboard), for: .touchUpInside)
            addSubview(deleteBtn)

            let high:CGFloat = btnHigh * 3 + space * 2
            
            deleteBtn.snp.makeConstraints { make in
                make.left.equalTo(grid.snp.right).offset(space)
                make.top.equalToSuperview().offset(6)
                make.right.equalToSuperview().offset(-6)
                make.height.equalTo(btnHigh)
            }
            
            let sureBtn:UIButton = creatButton(CGRect.zero, "确认", fontSemibold(24), .white, blueColor, self, #selector(sureKeyboard))
            addSubview(sureBtn)

            sureBtn.snp.makeConstraints { make in
                make.left.equalTo(deleteBtn)
                make.top.equalTo(deleteBtn.snp.bottom).offset(space)
                make.right.equalToSuperview().offset(-6)
                make.height.equalTo(high)
            }
            
            self.layoutIfNeeded()
            ViewRadius(deleteBtn, 5)
            ViewRadius(sureBtn, 5)
//            setRoundedCornersAndShadow(view: deleteBtn)
//            setRoundedCornersAndShadow(view: sureBtn)
            
        case .decimal:
            backgroundColor = HXColor(0xe5e5e5)
            bottomview.backgroundColor = HXColor(0xe5e5e5)
            // 金额输入键盘
            titles = [
                ["1","2","3"],
                ["4","5","6"],
                ["7","8","9"],
                ["key_dot_black","0","key_keyboard_black"]
            ]
            
            let deleteBtn:UIButton = UIButton()
            deleteBtn.setImage(UIImage(named: "key_delete_black"), for: .normal)
            deleteBtn.setImage(UIImage(named: "key_delete_black"), for: .selected)
            deleteBtn.addTarget(self, action: #selector(deleteKeyboard), for: .touchUpInside)
            addSubview(deleteBtn)

            let high:CGFloat = btnHigh * 2 + space
            
            deleteBtn.snp.makeConstraints { make in
                make.left.equalTo(grid.snp.right).offset(space)
                make.top.equalToSuperview().offset(6)
                make.right.equalToSuperview().offset(-6)
                make.height.equalTo(high)
            }
            
            let sureBtn:UIButton = creatButton(CGRect.zero, "确认", fontSemibold(24), .white, blueColor, self, #selector(sureKeyboard))
            addSubview(sureBtn)

            sureBtn.snp.makeConstraints { make in
                make.left.equalTo(deleteBtn)
                make.top.equalTo(deleteBtn.snp.bottom).offset(space)
                make.right.equalToSuperview().offset(-6)
                make.height.equalTo(high)
            }
            
            ViewRadius(deleteBtn, 5)
            ViewRadius(sureBtn, 5)
        }

        for (i,row) in titles.enumerated() {
            let hstack = UIStackView()
            hstack.axis = .horizontal
            hstack.distribution = .fillEqually
            hstack.spacing = space
            grid.addArrangedSubview(hstack)
            
            for (a,title) in row.enumerated() {
                let btn = UIButton()
                btn.setTitle(title, for: .normal)
                btn.tag = 1000 + (i * 3 + a)
                btn.titleLabel?.font = fontSemibold(30)
                
                if type == .decimal {
                    btn.backgroundColor = .white
                }else{
                    btn.backgroundColor = HXColor(0xf9f9fa)
                }
                
                btn.setTitleColor(Main_TextColor, for: .normal)
                btn.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                hstack.addArrangedSubview(btn)
                
                if i == 3{
                    if a == 0 || a == 2{
                        btn.setImage(UIImage(named: title), for: .normal)
                        btn.setImage(UIImage(named: title), for: .selected)
                    }
                }
                ViewRadius(btn, 5)
            }
        }
        
//        self.layoutIfNeeded()
//        
//        for hstack in grid.subviews {
//            for btn in hstack.subviews {
//                if type == .decimal {
//                    ViewRadius(btn, 5)
//                }else{
//                    setRoundedCornersAndShadow(view: btn)
//                }
//            }
//        }
    }
    
    func setRoundedCornersAndShadow(view:UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        
        let border = CALayer()
        border.backgroundColor = HXColor(0x828486).cgColor
        border.frame = CGRect(x: 0, y: view.frame.size.height-1,
                              width: view.frame.size.width, height: 1.0)
        view.layer.addSublayer(border)
    }
    
    
    @objc func sureKeyboard(){
        keyTapped?(.done)
    }
    
    
    @objc private func keyPressed(_ sender: UIButton) {
        if sender.tag ==  1009 {
            keyTapped?(.number("."))
        }else if sender.tag ==  1011 {
            keyTapped?(.close)
        }else{
            keyTapped?(.number(sender.currentTitle ?? ""))
        }
    }
    
    @objc func deleteKeyboard(){
        keyTapped?(.delete)
    }
}
