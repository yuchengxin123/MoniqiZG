//
//  transfer.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/18.
//

import UIKit
import CoreLocation
import SnapKit
import RxSwift
import RxCocoa
import LocalAuthentication
import Foundation

class TradeCtrl: BaseCtrl,UIScrollViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate {
    
    private var didSetupCorner = false
    
    var oldModel:TransferPartner?
    var isIncome:Bool = false
    let payCard:CardModel = myCardList.first ?? CardModel()
    
    let topView:UIView = UIView()
    let bottomView:UIView = UIView()
    
    private var cardField:UITextField?
    private var nameField:UITextField?
    private var moneyField:UITextField?
    private let moneyRemindImg:UIImageView = UIImageView.init(image: UIImage(named: "money_bottom"))
    private let moneyRemindlb:UILabel = creatLabel(CGRect.zero, "", fontRegular(10), .white)
    
    private let banklb:UILabel = UILabel()
    private let cardlb:UILabel = UILabel()
    private let transferlb:UILabel = UILabel()
    
    private let tansBanklb:UILabel = UILabel()
    private let balancelb:UILabel = UILabel()
//    private let transferRemindlb:UILabel = UILabel()
    private var remindField:UITextField?
    
    var banktype:String = "bank_type_7"
    
    private let keyboard = NumberKeyboard(type: .decimal,frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: 320))
    
    private var bankMatchDict: [String: [String: Any]] = [:] // 预处理后的字典
    private var searchTimer: Timer?
    
    private var cardName:String = ""
    
    private var cardType:String = "借记卡"
    
    var transferFail:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicScrollView.delegate = self
        basicScrollView.bounces = false
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor
        addTap = true
        
        addHeadView()
    }
    
    override func setupUI() {
        super.setupUI()
        preprocessBankData()
        
        addView()
        setupKeyboard()
    }

    func addHeadView(){
        let headView:UIView = UIView()
        headView.backgroundColor = Main_backgroundColor
        view.addSubview(headView)
        
        headView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        ///15 26
        let leftImg:UIImageView = UIImageView(image: UIImage(named: "back_blcak"))
        headView.addSubview(leftImg)
        leftImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(12)
            make.height.equalTo(20.5)
        }
      
        let rightImg:UIImageView = UIImageView(image: UIImage(named: "more_black"))
        headView.addSubview(rightImg)
        
        rightImg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalTo(leftImg)
            make.width.equalTo(19)
            make.height.equalTo(4)
        }
        
        let infoImg:UIImageView = UIImageView(image: UIImage(named: "face_right"))
        headView.addSubview(infoImg)
        
        infoImg.snp.makeConstraints { make in
            make.right.equalTo(rightImg.snp.left).offset(-20)
            make.centerY.equalTo(leftImg)
            make.height.width.equalTo(22)
        }
        
        let leftButton:UIButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "转账", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    
    func addView(){
        contentView.backgroundColor = Main_backgroundColor
        
        contentView.addSubview(topView)
        
        contentView.addSubview(bottomView)
        
        let img:UIImage = UIImage(named: "transfer_bottom") ?? UIImage()
        let high:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
        
        let bottomImg:UIImageView = UIImageView()
        bottomImg.image = img
        contentView.addSubview(bottomImg)
        
        let bottomBtn:UIButton = UIButton()
        bottomBtn.addTarget(self, action: #selector(handlTap), for: .touchUpInside)
        contentView.addSubview(bottomBtn)
        
        // 2. 添加长按手势识别器
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        bottomBtn.addGestureRecognizer(longPressGesture)

        topView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(navigationHeight)
            make.left.right.equalToSuperview()
            if oldModel != nil && isIncome == false {
                make.height.equalTo(130)
            }else{
                make.height.equalTo(260)
            }
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(276)
        }
        
        bottomImg.snp.makeConstraints { make in
            make.top.equalTo(bottomView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(high)
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.top.equalTo(bottomImg).offset(45)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
        }
        
        addTopView()
        addBottomView()
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomImg.snp.bottom)
        }
    }
    
    //MARK: - 确认转账
    func sumbitTransfer(){
        if oldModel != nil && isIncome == false {
            if moneyField?.text?.isEmpty == true {
                return
            }
        }else{
            if nameField?.text?.isEmpty == true {
                return
            }
            
            if moneyField?.text?.isEmpty == true {
                return
            }
            
            if banklb.text?.isEmpty == true {
                return
            }
            
            if cardField?.text?.isEmpty == true{
                return
            }
            
            if  cardField!.text!.count < 10{
                return
            }
        }
        
        var text = ""
        
        if oldModel != nil && isIncome == false {
            text = String(format: "%@ (%@)\n%@\n",oldModel!.name,oldModel!.bankName,oldModel!.card)
        }else{
            text = String(format: "%@ (%@)\n%@\n",nameField!.text!,banklb.text!,cardField!.text!)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: fontRegular(18),
            .foregroundColor: Main_TextColor,
            .paragraphStyle: paragraphStyle
        ]
        

        let attributedString:NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: fontNumber(23),
            .foregroundColor: Main_TextColor,
            .paragraphStyle: paragraphStyle
        ]
        
        attributedString.append(NSAttributedString(string: "¥ \(String(format: "%@", getNumberFormatter(Double(moneyField?.text ?? "") ?? 0.00)))", attributes: boldAttributes))
        
        YCXAlertView.YCX_showBankAlert(title: "转给TA", message: attributedString) { index in
            
            if index == 1 {
                self.checkFaceRecognition()
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // 允许同时识别多个手势
    }
    
    //MARK: - 长按转账失败
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("按钮被长按")
            transferFail = true
            // 这里处理长按开始时的逻辑
            isOpenVIPAction()
        }
    }
    
    //MARK: - 单击转账成功
    @objc func handlTap() {
        transferFail = false
        isOpenVIPAction()
    }
    
    //MARK: - 验证可用的功能
    func isOpenVIPAction(){
        //水印版本不受限制 可以用
        if myUser!.vip_level == .typeNoAction {
            sumbitTransfer()
            isShowWater()
        }else{
            //非水印版本 要考虑使用该功能要求的最低会员等级 以及 有效期
            YcxHttpManager.getTimestamp() { msg,data,code  in
                if code == 1{
                    let currentTime:TimeInterval = TimeInterval(data)
                    
                    print("本地时间--\((Date().timeIntervalSince1970))\n服务器时间--\(currentTime)")
                    
                    //没过期
                    if myUser!.expiredDate > currentTime {
                        // 只能改余额
                        if myUser!.vip_level == .typeVip{
                            KWindow?.makeToast("需要升级会员", .center, .information)
                        }else if myUser!.vip_level == .typeSVip || myUser!.vip_level == .typeAll{
                            self.sumbitTransfer()
                        }
                        
                    }else{
                        //全部能用但是变成水印版本
                        self.sumbitTransfer()
                        self.isShowWater()
                    }
                }else{
                    KWindow?.makeToast(msg, .center, .fail)
                }
            }
        }
    }
    
    //MARK: - 人脸识别
    func checkFaceRecognition(){
        let balance:Double = (myUser?.myBalance ?? 0.00) - (Double(self.moneyField!.text!) ?? 0.0)
        if balance < 0 {
            KWindow?.makeToast("余额不足，请修改转账金额", .center, .fail)
            return
        }
        
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "请使用 Face ID 验证身份") { success, authError in
                DispatchQueue.main.async {
                    
                    if success {
                        print("Face ID 验证通过")
                    } else {
                        print("验证失败：\(authError?.localizedDescription ?? "")")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let bigtime:String = getCurrentTimeString()
                        let smalltime:String = getCurrentTimeString(dateFormat: "MM.dd HH:mm")
                        
                        var model:TransferModel?
                        var partner:TransferPartner = TransferPartner()
                        
                        let serialNumber:String = generateRandom16DigitString()
                        
                        if self.oldModel != nil {
                            
                            partner = self.oldModel!
                            
                            model = TransferModel(
                                ["amount": self.moneyField?.text ?? "", "remind": self.remindField!.text ?? "转账",
                                 "payBank": self.payCard.bank,"payCard": self.payCard.card,
                                 "bigtime":bigtime,"smalltime":smalltime,"serialNumber":serialNumber,"partner":partner,"tradeType":TransactionChildType.typeTransfer200.type,"calculatedBalance":balance]
                            )
                        }else{
                            
                            let lastCard:String = String((self.cardField!.text!.replacingOccurrences(of: " ", with: "")).suffix(4))
                            
                            partner = TransferPartner(
                                ["name": self.nameField?.text ?? "","card":self.cardField!.text!,
                                 "icon": self.banktype,"lastCard": lastCard,
                                 "bankName": self.banklb.text ?? "", "cardName": self.cardName,
                                 "cardType": self.cardType]
                            )
                            
                            model = TransferModel(
                                ["amount": self.moneyField?.text ?? "", "remind": self.remindField!.text ?? "转账",
                                 "payBank": self.payCard.bank,"payCard": self.payCard.card,
                                 "bigtime":bigtime,"smalltime":smalltime,"serialNumber":serialNumber,"partner":partner,"tradeType":TransactionChildType.typeTransfer200.type,"calculatedBalance":balance]
                            )
                        }
                        
                        //转账失败 不需要保存记录
                        if self.transferFail == true {
                            let ctrl:TransferWaitCtrl = TransferWaitCtrl()
                            ctrl.oldModel = model
                            ctrl.transferFail = self.transferFail
                            self.pushAndCloseCtrl(ctrl)
                           // self.navigationController?.pushViewController(ctrl, animated: true)
                            return
                        }
                        
                        myTradeList.append(model!)
                        
                        TransferModel.saveArray(myTradeList, forKey: MyTradeRecord)
                        
                        myUser?.myBalance = balance
                        
                        UserManager.shared.update { user in
                            user.myBalance = balance
                        }
                        
                        //通知余额更新
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: nil)

                        let ctrl:TransferWaitCtrl = TransferWaitCtrl()
                        ctrl.oldModel = model
                        ctrl.transferFail = self.transferFail
                        self.pushAndCloseCtrl(ctrl)
                        
                        //去重
//                        if !myPartnerList.contains(where: { $0.card == partner.card }) {
//                            //添加并保存
//                            myPartnerList.append(partner)
//                            TransferPartner.saveArray(myPartnerList, forKey: MyTransferPartnerCards)
//                        }
                        
                        //通知更新
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyTransferNotificationName), object: nil)
                    }
                }
            }
        } else {
            print("设备不支持 Face ID：\(error?.localizedDescription ?? "")")
            showLocationPermissionAlert()
        }
    }
    
    func showLocationPermissionAlert() {
        // 创建 alert controller
        let alert = UIAlertController(
            title: "需要开启人脸识别",
            message: "人脸识别用于支付验证以及个人信息查看",
            preferredStyle: .alert
        )
        
        // 取消按钮
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel
        )
        alert.addAction(cancelAction)
        
        // 确定按钮 - 打开设置
        let settingsAction = UIAlertAction(
            title: "确认",
            style: .default
        ) { [weak self] _ in
            self?.openAppSettings()
        }
        alert.addAction(settingsAction)
        
        // 显示 alert
        self.navigationController?.present(alert, animated: true)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                print("打开设置: \(success ? "成功" : "失败")")
            }
        }
    }
    
    
    func addTopView(){
        topView.backgroundColor = .white
        
        let namelb:UILabel = creatLabel(CGRect.zero, "收款人", fontMedium(18), Main_TextColor)
        topView.addSubview(namelb)
        
        if oldModel != nil && isIncome == false {
            let bankimg:UIImageView = UIImageView()
            bankimg.image = UIImage(named: oldModel!.icon)
            topView.addSubview(bankimg)
            
            let oldNamelb:UILabel = creatLabel(CGRect.zero, oldModel!.name, fontRegular(16), Main_TextColor)
            topView.addSubview(oldNamelb)
            
            let banklb:UILabel = creatLabel(CGRect.zero, "\(oldModel!.bankName)", fontRegular(15), fieldPlaceholderColor)
            topView.addSubview(banklb)
            
            let cardlb:UILabel = creatLabel(CGRect.zero, "\(oldModel!.card)", fontRegular(15), Main_TextColor)
            topView.addSubview(cardlb)
            
            namelb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.height.equalTo(20)
                make.top.equalTo(20)
            }
            
            bankimg.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.height.width.equalTo(40)
                make.top.equalTo(namelb.snp.bottom).offset(35)
            }
            
            oldNamelb.snp.makeConstraints { make in
                make.left.equalTo(bankimg.snp.right).offset(10)
                make.height.equalTo(20)
                make.top.equalTo(bankimg).offset(-2)
            }
            
            banklb.snp.makeConstraints { make in
                make.left.equalTo(oldNamelb.snp.right).offset(15)
                make.height.equalTo(20)
                make.centerY.equalTo(oldNamelb)
            }
            
            cardlb.snp.makeConstraints { make in
                make.left.equalTo(oldNamelb)
                make.bottom.equalTo(bankimg).offset(2)
            }
            return
        }
        

        let nameimg:UIImageView = UIImageView(image: UIImage(named: "transfer_pic"))
        topView.addSubview(nameimg)
        
        let addresslb:UILabel = creatLabel(CGRect.zero, "户名", fontRegular(16), Main_TextColor)
        topView.addSubview(addresslb)
        addresslb.setContentHuggingPriority(.required, for: .horizontal) // 不被拉伸
        addresslb.setContentCompressionResistancePriority(.required, for: .horizontal) // 不被压缩
        
        let addressimg:UIImageView = UIImageView(image: UIImage(named: "transfer_user"))
        topView.addSubview(addressimg)
        
        nameField = createField(CGRect.zero, "请输入收款人户名", fontRegular(16), Main_TextColor, UIView(), UIView())
        nameField?.textAlignment = .right
        nameField?.delegate = self
        topView.addSubview(nameField!)
        
        let line:UIView = UIView()
        line.backgroundColor = defaultLineColor
        topView.addSubview(line)
        
        let accountlb:UILabel = creatLabel(CGRect.zero, "账号", fontRegular(16), Main_TextColor)
        topView.addSubview(accountlb)
        accountlb.setContentHuggingPriority(.required, for: .horizontal) // 不被拉伸
        accountlb.setContentCompressionResistancePriority(.required, for: .horizontal) // 不被压缩
        
        
        let accountimg:UIImageView = UIImageView(image: UIImage(named: "transfer_scan"))
        topView.addSubview(accountimg)
        
        cardField = createField(CGRect.zero, "卡号", fontRegular(16), Main_TextColor, UIView(), UIView())
        cardField?.enableBankCardFormat()
        cardField?.textAlignment = .right
        cardField?.delegate = self
        cardField?.keyboardType = .numberPad
        cardField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contentView.addSubview(cardField!)
        
        let bankline:UIView = UIView()
        bankline.backgroundColor = defaultLineColor
        topView.addSubview(bankline)
        
        let bankremindlb:UILabel = creatLabel(CGRect.zero, "银行", fontRegular(16), Main_TextColor)
        topView.addSubview(bankremindlb)
        bankremindlb.setContentHuggingPriority(.required, for: .horizontal) // 不被拉伸
        bankremindlb.setContentCompressionResistancePriority(.required, for: .horizontal) // 不被压缩
        
        
        let bankrightimg:UIImageView =  UIImageView(image: UIImage(named: "gray_right"))
        topView.addSubview(bankrightimg)
        
        banklb.text = "选择银行"
        banklb.textColor = Main_detailColor
        banklb.font = fontRegular(16)
        banklb.textAlignment = .right
        banklb.isUserInteractionEnabled = true
        topView.addSubview(banklb)
        
        let button:UIButton = UIButton()
        topView.addSubview(button)
        button.addTarget(self, action: #selector(selectBank), for: .touchUpInside)
        
        if oldModel != nil {
            nameField?.text = oldModel!.name
            cardField?.text = oldModel!.card
            banklb.text = oldModel!.bankName
            banktype = oldModel!.icon
            cardType = oldModel!.cardType
            cardName = oldModel!.cardName
        }
        
        
        namelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalTo(20)
        }
        
        nameimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
            make.width.equalTo(88.2)
            make.centerY.equalTo(namelb)
        }
        
        addresslb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalTo(namelb.snp.bottom).offset(48)
        }
        
        addressimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.width.equalTo(18)
            make.centerY.equalTo(addresslb)
        }
        
        nameField!.snp.makeConstraints { make in
            make.leading.equalTo(addresslb.snp.trailing).offset(5)
            make.right.equalTo(addressimg.snp.left).offset(-10)
            make.height.equalTo(40)
            make.centerY.equalTo(addresslb)
        }
        
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(nameField!.snp.bottom).offset(10)
        }
        
        accountlb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalTo(line.snp.bottom).offset(20)
        }
        
        accountimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.width.equalTo(18)
            make.centerY.equalTo(accountlb)
        }
        
        cardField!.snp.makeConstraints { make in
            make.leading.equalTo(accountlb.snp.trailing).offset(5)
            make.right.equalTo(accountimg.snp.left).offset(-10)
            make.height.equalTo(40)
            make.centerY.equalTo(accountlb)
        }
        
        bankline.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(cardField!.snp.bottom).offset(10)
        }
        
        bankremindlb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalTo(bankline.snp.bottom).offset(25)
        }
        
        bankrightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(bankremindlb)
        }
        
        banklb.snp.makeConstraints { make in
            make.leading.equalTo(bankremindlb.snp.trailing).offset(5)
            make.right.equalTo(bankrightimg.snp.left).offset(-10)
            make.height.equalTo(30)
            make.centerY.equalTo(bankremindlb)
        }
        
        button.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.centerY.equalTo(banklb)
        }
    }

    @objc func selectBank(){
        let ctrl:SelectBankCtrl = SelectBankCtrl()
        ctrl.onTap = { dic in
            self.banklb.text = dic["bankName"] as? String
            self.banklb.textColor = Main_TextColor
            self.banktype = String(format: "bank_type_%@", dic["cardIconInt"] as! CVarArg)
        }
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    func addBottomView(){
        bottomView.backgroundColor = .white
        
        let namelb:UILabel = creatLabel(CGRect.zero, "转账金额", fontMedium(18), Main_TextColor)
        bottomView.addSubview(namelb)
        
        let leftLb:UILabel = creatLabel(CGRect.zero, "¥ ", fontNumber(30), Main_TextColor)
        
        //百-十万亿 0x808080 money_bottom
        moneyField = createField(CGRect.zero, "0手续费", fontNumber(30), Main_TextColor, UIView(), leftLb)
        moneyField?.delegate = self
        bottomView.addSubview(moneyField!)
        moneyField?.inputView = keyboard
        moneyField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        bottomView.addSubview(moneyRemindImg)

        moneyRemindlb.backgroundColor = HXColor(0x808080)
        bottomView.addSubview(moneyRemindlb)
        
        moneyRemindImg.isHidden = true
        moneyRemindlb.isHidden = true
        
        let line:UIView = UIView()
        line.backgroundColor = defaultLineColor
        bottomView.addSubview(line)
        
        let accountlb:UILabel = creatLabel(CGRect.zero, "付款卡", fontRegular(16), Main_TextColor)
        bottomView.addSubview(accountlb)
        
         
        tansBanklb.text = "\(payCard.bank)(\(payCard.lastCard))"
        tansBanklb.textColor = Main_TextColor
        tansBanklb.font = fontRegular(16)
        tansBanklb.textAlignment = .right
        bottomView.addSubview(tansBanklb)
        
        let rightimg:UIImageView = UIImageView()
        rightimg.image = UIImage(named: "gray_right")
        bottomView.addSubview(rightimg)
        
        balancelb.text = "可用余额 ¥\(getNumberFormatter(myUser?.myBalance ?? 0.00))"
        balancelb.textColor = Main_TextColor
        balancelb.font = fontRegular(12)
        balancelb.textAlignment = .right
        bottomView.addSubview(balancelb)
        
        let infoimg:UIImageView = UIImageView()
        infoimg.image = UIImage(named: "transfer_info")
        bottomView.addSubview(infoimg)
        
        let remindLine:UIView = UIView()
        remindLine.backgroundColor = Main_backgroundColor
        bottomView.addSubview(remindLine)
        
        let remindView:UIView = UIView()
        remindView.backgroundColor = .white
        bottomView.addSubview(remindView)
        
        let remindlb:UILabel = creatLabel(CGRect.zero, "转账附言", fontRegular(16), Main_TextColor)
        remindView.addSubview(remindlb)
        
        remindField = createField(CGRect.zero, "转账", fontRegular(16), Main_TextColor, UIView(), UIView())
        remindField?.textAlignment = .right
        remindField?.delegate = self
        remindView.addSubview(remindField!)
        
        
        let transferRemindimg:UIImageView = UIImageView()
        transferRemindimg.image = UIImage(named: "transfer_edit")
        remindView.addSubview(transferRemindimg)
        
        
        namelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalTo(20)
        }
        
        moneyField!.snp.makeConstraints { make in
            make.top.equalTo(namelb.snp.bottom).offset(26)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
            make.height.equalTo(48)
        }
        
        moneyRemindlb.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.bottom.equalTo(moneyField!.snp.top)
            make.left.equalTo(moneyField!).offset(20)
        }
        
        moneyRemindImg.snp.makeConstraints { make in
            make.top.equalTo(moneyRemindlb.snp.bottom).offset(-2)
            make.centerX.equalTo(moneyRemindlb)
            make.height.width.equalTo(6)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalTo(moneyField!)
            make.height.equalTo(1)
            make.top.equalTo(moneyField!.snp.bottom).offset(16)
        }
        
        accountlb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalTo(line.snp.bottom).offset(15)
        }
        
        rightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(accountlb)
        }
        
        tansBanklb.snp.makeConstraints { make in
            make.leading.equalTo(accountlb.snp.trailing).offset(5)
            make.height.equalTo(30)
            make.centerY.equalTo(accountlb)
            make.right.equalTo(rightimg.snp.left).offset(-10)
        }
        
        infoimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.width.equalTo(12)
            make.top.equalTo(tansBanklb.snp.bottom).offset(10)
        }
        
        balancelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.centerY.equalTo(infoimg)
            make.right.equalTo(infoimg.snp.left).offset(-10)
        }
        
        remindLine.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(10)
            make.top.equalTo(balancelb.snp.bottom).offset(20)
        }
        
        remindView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(remindLine.snp.bottom)
        }
        
        remindlb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.width.equalTo(100)
            make.centerY.equalToSuperview()
        }
        
        transferRemindimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(17)
            make.height.equalTo(18)
            make.top.equalTo(remindlb)
        }
        
        remindField!.snp.makeConstraints { make in
            make.right.equalTo(transferRemindimg.snp.left).offset(-10)
            make.height.equalTo(40)
            make.centerY.equalTo(remindlb)
            make.left.equalTo(remindlb.snp.right).offset(5)
        }
        
        ViewRadius(moneyRemindlb, 2)
    }
    
    //预处理后的字典
    private func preprocessBankData() {
        
        let array = bankList + hotBank
        
        for bankDict in array {
            guard let matchValue = bankDict["matchValue"] as? Int,
                  let matchLength = bankDict["matchLength"] as? Int else {
                continue
            }
            
            let matchString = String(matchValue)
            // 以匹配字符串为key存储
            bankMatchDict[matchString] = bankDict
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.endEditing(true)
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) -> Void{
        //判断卡类型和名字
        if textField == cardField {
            guard let inputText = textField.text, !inputText.isEmpty else { return }
            
            searchTimer?.invalidate()
            
            guard let inputText = textField.text, !inputText.isEmpty else { return }
            
            // 防抖处理，300毫秒后执行
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                self?.performBankSearch(with: inputText)
            }
        }else if textField == moneyField {
            if textField.text?.first == "." {
                textField.text = "0."
            }
            if textField.text?.isEmpty == false && Double(textField.text!)! > 100 {
                moneyRemindlb.text = getChineseMoney(str: textField.text!)
                moneyRemindlb.isHidden = false
                moneyRemindImg.isHidden = false
            }else{
                moneyRemindlb.isHidden = true
                moneyRemindImg.isHidden = true
            }
        }
    }
    
    private func performBankSearch(with input: String) {
        let content = input.replacingOccurrences(of: " ", with: "")
        print("匹配内容:\(content)")
        // 尝试不同长度的前缀匹配 最长10位
        for length in (1...min(content.count, 10)).reversed() {
            let prefix = String(content.prefix(length))
            
            if let matchedBank = bankMatchDict[prefix] {
                if let bankName = matchedBank["bankName"] as? String {
                    print("✅ 匹配到: \(bankName) (前缀: \(prefix))")
                    banklb.text = bankName
                    banklb.textColor = Main_TextColor
                    
                    cardName = matchedBank["cardName"] as? String ?? ""
                    cardType = matchedBank["cardType"] as? String ?? ""
                    banktype = "bank_type_\(matchedBank["cardIconInt"] as? String ?? "7")"
                    return
                }
            }
        }
        
        print("❌ 未找到匹配银行")
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    private func setupKeyboard() {
        keyboard.keyTapped = { [weak self] key in
            guard let self = self else { return }
            switch key {
            case .number(let value):
                self.moneyField?.insertText(value)
            case .delete:
                self.moneyField?.deleteBackward()
            case .done:
                self.moneyField?.resignFirstResponder()
            }
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            print("键盘高度: \(frame.height)")
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        print("键盘收起")
    }
    
    
    // 拦截点击：不让系统弹键盘给这个 field，而是用自定义 accessory 弹出并在确认后回填
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == remindField {
            TransferAccessoryPresenter.shared.present(from: textField, tags: transferTags, initialText: textField.text, onConfirm: { [weak textField] text in
                textField?.text = text
            }, onCancel: {
                // optional
            })

            // return false 阻止外部 textField 成为第一响应者（避免两个编辑器冲突）
            return false
        }
        return true
    }
}
