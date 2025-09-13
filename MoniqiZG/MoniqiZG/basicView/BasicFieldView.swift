//
//  BasicFieldView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/1.
//

import UIKit
import SnapKit

enum FieldContentType {
    //默认输入 无限制
    case defaultType
    //整数
    case integerType
    //数字输入
    case amountType
    //带正负数的数字
    case revenueType
}

class BasicFieldView: UIView,UITextFieldDelegate {
    
    var changeContent: ((String) -> Void)?
    var type:FieldContentType = .defaultType
    private var field:UITextField?
    private var surebtn:UIButton?
    private var cancelbtn:UIButton?
    private let cardView:UIView = UIView()
    private let titlelb:UILabel = UILabel()
    private var copyBtn:UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black.withAlphaComponent(0.3)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.addSubview(cardView)
        cardView.backgroundColor = .white
        
        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview().offset(-80)
//            make.height.equalTo(180)
        }
        
        cardView.addSubview(titlelb)
        titlelb.text = "修改内容"
        titlelb.textAlignment = .center
        titlelb.textColor = Main_TextColor
        titlelb.font = fontMedium(14)
        titlelb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        copyBtn = creatButton(CGRect.zero, "qq:1783729901", fontMedium(16), Main_Color, .white, self, #selector(copyQQNumber))
        cardView.addSubview(copyBtn!)
        
        copyBtn!.snp.makeConstraints { make in
            make.top.equalTo(titlelb.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(0)
        }
        
        copyBtn?.isHidden = true
        
        field = createField(CGRect.zero, "", fontMedium(15), Main_TextColor, nil, nil)
        field?.backgroundColor = Main_backgroundColor
        field?.returnKeyType = .done
        field?.delegate = self
        field?.keyboardType = .numbersAndPunctuation
        cardView.addSubview(field!)
        
        field!.snp.makeConstraints { make in
            make.top.equalTo(copyBtn!.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(48)
        }
        
        cancelbtn = creatButton(CGRect.zero, "取消", fontMedium(16), Main_TextColor, Main_backgroundColor, self, #selector(dismissContent))
        cardView.addSubview(cancelbtn!)
        
        cancelbtn!.snp.makeConstraints { make in
            make.top.equalTo(field!.snp.bottom).offset(15)
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-20)
        }
        
        surebtn = creatButton(CGRect.zero, "确认", fontMedium(16), .white, Main_Color, self, #selector(sureContent))
        cardView.addSubview(surebtn!)
        
        surebtn!.snp.makeConstraints { make in
            make.top.equalTo(field!.snp.bottom).offset(15)
            make.left.equalTo(cancelbtn!.snp.right).offset(10)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(48)
        }
        
        cardView.snp.makeConstraints { make in
            make.bottom.equalTo(surebtn!.snp.bottom).offset(15)
        }
    }
    
    func setKeyboardType(type:UIKeyboardType){
        field?.keyboardType = type
    }
    
    func setContent(str:String){
        titlelb.text = str
    }
    
    func setPlaceholder(placeholder:String){
        let attributedStr:NSMutableAttributedString = NSMutableAttributedString.init(string: placeholder, attributes: [NSAttributedString.Key.font:fieldPlaceholderFont , NSAttributedString.Key.foregroundColor:fieldPlaceholderColor])
        field?.attributedPlaceholder = attributedStr
    }
    
    func showCopyNumber(){
        copyBtn!.snp.remakeConstraints { make in
            make.top.equalTo(titlelb.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        copyBtn?.isHidden = false
    }
    
    @objc func copyQQNumber(){
        UIPasteboard.general.string = "1783729901"
        KWindow?.makeToast("已复制", .center, .success)
    }
    
    @objc func dismissContent(){
        self.endEditing(true)
        self.removeFromSuperview()
    }
    
    
    @objc func sureContent(){
        if changeContent != nil {
            changeContent?(field?.text ?? "")
        }
        self.endEditing(true)
        self.removeFromSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ViewRadius(cardView, 12)
        ViewRadius(surebtn!, 8)
        ViewRadius(field!, 8)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // ✅ 禁止空格
        if string.contains(" ") {
            return false
        }

        // 获取当前输入后的内容
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // defaultType：仅禁用空格，其他全部允许
        if type == .defaultType {
            return true
        }

        // integerType：仅允许数字
        if type == .integerType {
            let digitsSet = CharacterSet.decimalDigits
            return string.rangeOfCharacter(from: digitsSet.inverted) == nil
        }

        // amountType / revenueType：允许小数点、数字；revenueType 再加首位正负号限制
        if type == .amountType || type == .revenueType {
            // 校验合法字符
            var allowedChars = "0123456789."
            if type == .revenueType {
                allowedChars += "+-"
            }
            let allowedSet = CharacterSet(charactersIn: allowedChars)
            if string.rangeOfCharacter(from: allowedSet.inverted) != nil {
                return false
            }

            // 小数点最多一个
            let dotCount = newText.components(separatedBy: ".").count - 1
            if dotCount > 1 {
                return false
            }

            // 小数点后最多两位
            if let dotIndex = newText.firstIndex(of: ".") {
                let fractional = newText[newText.index(after: dotIndex)...]
                if fractional.count > 2 {
                    return false
                }
            }

            if type == .revenueType {
                // 正负号最多一个，且必须在首位
                let plusCount = newText.components(separatedBy: "+").count - 1
                let minusCount = newText.components(separatedBy: "-").count - 1

                if plusCount > 1 || minusCount > 1 {
                    return false
                }
                if (newText.contains("+") && !newText.hasPrefix("+")) || (newText.contains("-") && !newText.hasPrefix("-")) {
                    return false
                }
                if newText.contains("+") && newText.contains("-") {
                    return false
                }
            }
            return true
        }

        return true
    }
    
    deinit {
        
    }
}

