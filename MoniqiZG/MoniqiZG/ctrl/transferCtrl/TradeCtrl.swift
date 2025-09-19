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
    let transferView:UIView = UIView()
    let receiveView:UIView = UIView()
    let paymentMethodView:UIView = UIView()
    
    let customSwitch = CustomSwitch()
    
    private var cardField:UITextField?
    private var nameField:UITextField?
    private var moneyField:UITextField?
    private let moneyRemindlb:UILabel = creatLabel(CGRect.zero, "", fontRegular(14), HXColor(0x999999))
    
    private let banklb:UILabel = UILabel()
    private let cardlb:UILabel = UILabel()
    private let transferlb:UILabel = UILabel()
    
    private let tansBanklb:UILabel = UILabel()
    private let balancelb:UILabel = UILabel()
    private var remindField:UITextField?
    
    var realAmount:String = ""
    var transferAmount:String = ""
    
    var banktype:String = "bank_type_7"
    
    private let keyboard = NumberKeyboard(type: .decimal,frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: CustomKeyboardHeight))
    
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
        headView.backgroundColor = .white
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
            make.width.height.equalTo(24)
        }
        
        let infoImg:UIImageView = UIImageView(image: UIImage(named: "face_right"))
        headView.addSubview(infoImg)
        
        infoImg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "账号转账", fontMedium(18), Main_TextColor)
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
        
        topView.backgroundColor = Main_backgroundColor
        contentView.addSubview(topView)
        
        transferView.backgroundColor = .white
        contentView.addSubview(transferView)
        
        receiveView.backgroundColor = .white
        contentView.addSubview(receiveView)
        
        paymentMethodView.backgroundColor = .white
        contentView.addSubview(paymentMethodView)
        
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
            make.height.equalTo(90)
        }
        
        transferView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(170)
        }
        
        receiveView.snp.makeConstraints { make in
            make.top.equalTo(transferView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(150)
        }
        
        paymentMethodView.snp.makeConstraints { make in
            make.top.equalTo(receiveView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(150)
        }
        
        
        bottomImg.snp.makeConstraints { make in
            make.top.equalTo(paymentMethodView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(high)
        }
        
        bottomBtn.snp.makeConstraints { make in
            make.top.equalTo(bottomImg).offset(45)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
        }
        
        addTopView()
        addTransferView()
        addReceiveView()
        addPaymentMethodView()
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomImg.snp.bottom)
        }
        
        ViewRadius(transferView, 4)
        ViewRadius(receiveView, 4)
        ViewRadius(paymentMethodView, 4)
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
    
    //MARK: - 付款框
    func addTopView(){
        topView.backgroundColor = Main_backgroundColor
        
        let cardView:UIView = UIView()
        cardView.backgroundColor = .white
        topView.addSubview(cardView)
        
        cardView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(15)
            make.height.equalTo(50)
        }
        
        let namelb:UILabel = creatLabel(CGRect.zero, "付款账户", fontMedium(16), Main_TextColor)
        cardView.addSubview(namelb)
        
        namelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        let rightimg:UIImageView = UIImageView()
        rightimg.image = UIImage(named: "trade_right_black")
        cardView.addSubview(rightimg)
        
        rightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(namelb)
            make.width.height.equalTo(14)
        }
        
        let cardlb:UILabel = creatLabel(CGRect.zero, "1111 ****** 2222", fontRegular(16), Color333333)
        cardView.addSubview(cardlb)
        
        cardlb.snp.makeConstraints { make in
            make.right.equalTo(rightimg.snp.left).offset(-3)
            make.centerY.equalTo(rightimg)
            make.height.equalTo(20)
        }
        
        let balancelb:UILabel = creatLabel(CGRect.zero, "可用余额", fontRegular(12), Main_detailColor)
        topView.addSubview(balancelb)
        
        balancelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(cardView.snp.bottom).offset(10)
        }
        
        let amountlb:UILabel = creatLabel(CGRect.zero, "人民币元 \(getNumberFormatter(myUser!.myBalance))", fontRegular(14), MoneyColor)
        topView.addSubview(amountlb)
        
        amountlb.snp.makeConstraints { make in
            make.left.equalTo(balancelb.snp.right).offset(5)
            make.centerY.equalTo(balancelb)
        }
        
        let allbtn:UIButton = creatButton(CGRect.zero, " 全部转出 ", fontRegular(14), HXColor(0x2d70ed), .clear, self, #selector(transferOut))
        topView.addSubview(allbtn)
        
        allbtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(balancelb)
            make.height.equalTo(40)
        }
        
        ViewRadius(cardView, 4)
    }
    
    //MARK: - 转账框
    func addTransferView(){
        let unitlb:UILabel = creatLabel(CGRect.zero, "币种", fontMedium(16), Main_TextColor)
        transferView.addSubview(unitlb)
        
        unitlb.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
        }
        
        let rightlb:UILabel = creatLabel(CGRect.zero, "人民币元", fontRegular(16), Main_detailColor)
        transferView.addSubview(rightlb)
        
        rightlb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(unitlb)
        }
        
        let line:UIView = UIView()
        line.backgroundColor = defaultLineColor
        transferView.addSubview(line)
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(unitlb.snp.bottom).offset(15)
            make.height.equalTo(0.5)
        }
        
        let transferlb:UILabel = creatLabel(CGRect.zero, "转账金额", fontMedium(16), Main_TextColor)
        transferView.addSubview(transferlb)
        
        transferlb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(line.snp.bottom).offset(15)
        }
        
        moneyField = createField(CGRect.zero, "请输入", fontNumber(30), MoneyColor, UIView(), UIView())
        moneyField?.delegate = self
        transferView.addSubview(moneyField!)
        moneyField?.inputView = keyboard
        moneyField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let str:NSMutableAttributedString = NSMutableAttributedString.init(string: "请输入", attributes: [NSAttributedString.Key.font:fontRegular(24) , NSAttributedString.Key.foregroundColor:fieldPlaceholderColor])
        moneyField?.attributedPlaceholder = str
        
        moneyField!.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(45)
            make.top.equalTo(transferlb.snp.bottom).offset(24)
        }
        
        transferView.addSubview(moneyRemindlb)
        moneyRemindlb.isHidden = true
        
        moneyRemindlb.snp.makeConstraints { make in
            make.left.equalTo(transferlb)
            make.top.equalTo(transferlb.snp.bottom)
        }
    }
    
    //MARK: - 收款框
    func addReceiveView(){
        let titles:Array<String> = ["收款人名称","收款账号","收款银行"]
        let images:Array<String> = ["transfer_address_book","transfer_camera","trade_right_black"]

        var y:CGFloat = 0
        
        for (i,str) in titles.enumerated() {
            let recievelb:UILabel = creatLabel(CGRect.zero, str, fontMedium(16), Main_TextColor)
            receiveView.addSubview(recievelb)
            
            recievelb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(y+15)
            }
            
            let rightimg:UIImageView = UIImageView()
            receiveView.addSubview(rightimg)
            
            if i < titles.count - 1 {
                rightimg.image = UIImage(named: images[i])?.withRenderingMode(.alwaysTemplate)
                rightimg.tintColor = HXColor(0x2d70ed)
                
                rightimg.snp.makeConstraints { make in
                    make.right.equalToSuperview().offset(-15)
                    
                    if i == 0{
                        make.width.height.equalTo(18)
                    }else{
                        make.height.equalTo(15)
                        make.width.equalTo(18)
                    }
                    make.centerY.equalTo(recievelb)
                }
                
                let line:UIView = UIView()
                line.backgroundColor = defaultLineColor
                receiveView.addSubview(line)
                
                line.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.height.equalTo(0.5)
                    make.top.equalTo(recievelb.snp.bottom).offset(15)
                }
            }
            
            if i == 0 {
                nameField = createField(CGRect.zero, "请输入", fontRegular(16), Main_TextColor, UIView(), UIView())
                nameField!.delegate = self
                receiveView.addSubview(nameField!)
                
                nameField!.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(120)
                    make.right.equalTo(rightimg.snp.left).offset(-10)
                    make.height.equalTo(30)
                    make.centerY.equalTo(recievelb)
                }
            }else if i == 1 {
                cardField = createField(CGRect.zero, "请输入", fontRegular(16), Main_TextColor, UIView(), UIView())
                cardField!.enableBankCardFormat()
                cardField!.delegate = self
                cardField!.keyboardType = .numberPad
                cardField!.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                receiveView.addSubview(cardField!)
                
                cardField!.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(120)
                    make.right.equalTo(rightimg.snp.left).offset(-10)
                    make.height.equalTo(30)
                    make.centerY.equalTo(recievelb)
                }
            }else{
                rightimg.image = UIImage(named: images[i])
                
                rightimg.snp.makeConstraints { make in
                    make.right.equalToSuperview().offset(-15)
                    make.width.height.equalTo(14)
                    make.centerY.equalTo(recievelb)
                }
                
                banklb.text = "选择银行"
                banklb.textColor = Main_detailColor
                banklb.font = fontRegular(16)
                banklb.textAlignment = .right
                banklb.isUserInteractionEnabled = true
                receiveView.addSubview(banklb)
                
                banklb.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-3)
                    make.centerY.equalTo(recievelb)
                }
                
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectBank))
                banklb.addGestureRecognizer(tap)
            }
            y+=50
        }
    }
    
    //MARK: - 转账方式
    func addPaymentMethodView(){
        let titles:Array<String> = ["转账方式","附言","短信通知收款人（0.00元/条）"]
        let details:Array<String> = ["实时","选填",""]

        //选择银行
        var y:CGFloat = 0
        
        for (i,str) in titles.enumerated() {
            let recievelb:UILabel = creatLabel(CGRect.zero, str, fontMedium(16), Main_TextColor)
            paymentMethodView.addSubview(recievelb)
            
            recievelb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(y+15)
            }
            
            let rightimg:UIImageView = UIImageView()
            
            if i <= 1 {
                rightimg.image = UIImage(named: "trade_right_black")
                paymentMethodView.addSubview(rightimg)
                
                rightimg.snp.makeConstraints { make in
                    make.right.equalToSuperview().offset(-15)
                    make.centerY.equalTo(recievelb)
                    make.width.height.equalTo(14)
                }
            }
            
            
            if i == 0 {
                let rightlb:UILabel = creatLabel(CGRect.zero, details[i], fontRegular(16), Main_TextColor)
                paymentMethodView.addSubview(rightlb)
                
                rightlb.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-3)
                    make.height.equalTo(30)
                    make.centerY.equalTo(recievelb)
                }
            }else if(i == 1){
                //附言
                remindField = createField(CGRect.zero,  details[i], fontRegular(16), Main_detailColor, UIView(), UIView())
                remindField?.textAlignment = .right
                remindField?.delegate = self
                paymentMethodView.addSubview(remindField!)
                
                remindField!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-3)
                    make.height.equalTo(20)
                    make.centerY.equalTo(recievelb)
                }
            }else{
                //开关
                customSwitch.onTintColor = Main_Color // 开启时颜色
                customSwitch.offTintColor = .white      // 关闭时颜色
                customSwitch.thumbShadowEnabled = true // 是否显示阴影
                customSwitch.isOn = false              // 初始状态
                customSwitch.isUserInteractionEnabled = false
//                customSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
                paymentMethodView.addSubview(customSwitch)
                
                customSwitch.snp.makeConstraints { make in
                    make.right.equalToSuperview().offset(-15)
                    make.centerY.equalTo(recievelb)
                    make.height.equalTo(30)
                    make.width.equalTo(56)
                }
            }
            
            if i < titles.count - 1 {
                let line:UIView = UIView()
                line.backgroundColor = defaultLineColor
                paymentMethodView.addSubview(line)
                
                line.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.height.equalTo(0.5)
                    make.top.equalTo(recievelb.snp.bottom).offset(15)
                }
            }
            y+=50
        }
    }
    
    @objc func switchChanged(_ sender: CustomSwitch) {
        print("当前状态: \(sender.isOn)")
    }
    
    @objc func transferOut(){
        realAmount = String(format: "%02f",myUser?.myBalance ?? 0.00)
        transferAmount = getNumberFormatter(myUser?.myBalance ?? 0.00)
        moneyField?.text = transferAmount
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
    
    override func touchedView(){
        moneyField?.text = transferAmount
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
            }else{
                moneyRemindlb.isHidden = true
            }
            realAmount = textField.text!
            transferAmount = getNumberFormatter(Double(textField.text!) ?? 0.00)
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
                self.moneyField?.text = transferAmount
            case .close:
                self.moneyField?.resignFirstResponder()
                self.moneyField?.text = transferAmount
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
                textField?.textColor = Main_TextColor
            }, onCancel: {
                // optional
            })
            // return false 阻止外部 textField 成为第一响应者（避免两个编辑器冲突）
            return false
        }
        if textField == moneyField {
            moneyField?.text = realAmount
        }
        return true
    }
}
