//
//  RecordEditingCtrl.swift
//  MoniqiZG
//
//  Created by apple on 2025/8/24.
//

import UIKit
import CoreLocation
import SnapKit

class TradeRecordEditingCtrl: BaseCtrl,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,CustomDatePickerDelegate {

    private var didSetupCorner = false
    var isIncome:Bool = false
    //数据类型
    var selectIndex:Int = 0
    //交易方式
    var tradeStyle:Int = 0
    
    private var nameField:UITextField?
    private var moneyField:UITextField?
    private var cardField:UITextField?
    private let banklb:UILabel = UILabel()
    private var timeField:UITextField?
    private var remindField:UITextField?
    private var cardFieldView:UIView = UIView()
    
    let expenditureBtn:UIButton = UIButton()
    let incomeBtn:UIButton = UIButton()
    let recordColor:UIColor = HXColor(0x72d5b4)
    var selectButton:UIButton?
    
    var addRecordBtn:UIButton = UIButton()
    var sumbitBtn:UIButton = UIButton()
    
    private let transferRemindlb:UILabel = UILabel()
    var banktype:String = "bank_type_7"
    
    private let keyboard = NumberKeyboard(type: .decimal,frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: 320))
    
    private var bankMatchDict: [String: [String: Any]] = [:] // 预处理后的字典
    private var searchTimer: Timer?
    
    private var cardName:String = ""
    
    private var cardType:String = "借记卡"
    
    
    private var incomeArray:Array<Dictionary<String,Any>> = [
        ["icon":TransactionChildType.typeTransfer101.type,"title":"他人转入"],["icon":TransactionChildType.typeTransfer102.type,"title":"转账给自己"],["icon":TransactionChildType.typeTransfer103.type,"title":"微信提现"],["icon":TransactionChildType.typeTransfer104.type,"title":"微信商户提现"],
        ["icon":TransactionChildType.typeTransfer105.type,"title":"支付宝提现"],["icon":TransactionChildType.typeTransfer108.type,"title":"账户结息"],["icon":TransactionChildType.typeTransfer109.type,"title":"退款"]
    ]
    private var expenditureArray:Array<Dictionary<String,Any>> = [
        ["icon":TransactionChildType.typeTransfer200.type,"title":"转账给他人"],["icon":TransactionChildType.typeTransfer201.type,"title":"转账给自己"],["icon":TransactionChildType.typeTransfer212.type,"title":"取现"],
        ["icon":TransactionChildType.typeTransfer213.type,"title":"京东金融"],
        ["icon":TransactionChildType.typeTransfer214.type,"title":"出行"],
        ["icon":TransactionChildType.typeTransfer215.type,"title":"手续费"],
        ["icon":TransactionChildType.typeTransfer216.type,"title":"购物"],
        ["icon":TransactionChildType.typeTransfer217.type,"title":"还款"],
        ["icon":TransactionChildType.typeTransfer218.type,"title":"休闲娱乐"],
        ["icon":TransactionChildType.typeTransfer219.type,"title":"红包"],
        ["icon":TransactionChildType.typeTransfer220.type,"title":"餐饮"],
        ["icon":TransactionChildType.typeTransfer221.type,"title":"充值缴费"],
        ["icon":TransactionChildType.typeTransfer222.type,"title":"其他支出"]
    ]
    private var tradeArray:Array<Dictionary<String,Any>> = [
        ["icon":"0","title":"财付通"],["icon":"1","title":"支付宝"],["icon":"","title":"美团"],["icon":"","title":"抖音支付"],
        ["icon":"4","title":"京东支付"],["icon":"5","title":"一网通支付"]
    ]
    
    private var customDatePicker: CustomDatePickerView?
    
    private lazy var tradeCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: tradeLayout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(TradeEditCell.self, forCellWithReuseIdentifier: "tradeCell")
        return cv
    }()
    
    private let tradeLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.itemSize = CGSizeMake((SCREEN_WDITH/3.0 - 50.0/3.0), 24)
        return layout
    }()
    
    private lazy var recordCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: recordLayout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(TradeEditCell.self, forCellWithReuseIdentifier: "TradeEditCell")
        return cv
    }()
    
    private let recordLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.itemSize = CGSizeMake((SCREEN_WDITH/3.0 - 50.0/3.0), 24)
        return layout
    }()
    
    var oldModel:TransferModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor

        addTap = true

        addTopView()
    }

    override func setupUI() {
        super.setupUI()
        preprocessBankData()
        
        addView()
        setupKeyboard()
    }
    
    func addTopView(){
        let headView:UIView = UIView()
        headView.backgroundColor = .white
        view.addSubview(headView)
        
        headView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }


        let titlelb:UILabel = creatLabel(CGRect.zero, "随机数据", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        
        let img:UIImageView = UIImageView(image: UIImage(named: "gray_back")?.withRenderingMode(.alwaysTemplate))
        img.tintColor = .black
        headView.addSubview(img)
        
        img.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(titlelb)
            make.width.equalTo(13)
            make.height.equalTo(21)
        }
        
        
        let button:UIButton = UIButton()
        button.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
    }
    
    func addView(){
        nameField = createField(CGRect.zero, "真实姓名|也可以是公司名字|流水页面显示的文字", fontRegular(15), Main_TextColor, nil, nil)
        nameField?.delegate = self
        nameField?.returnKeyType = .done
        contentView.addSubview(nameField!)
        
        moneyField = createField(CGRect.zero, "转入或转出金额", fontRegular(15), Main_TextColor, nil, nil)
        moneyField?.delegate = self
        contentView.addSubview(moneyField!)
        moneyField?.inputView = keyboard
        
        cardFieldView.backgroundColor = Main_backgroundColor
        contentView.addSubview(cardFieldView)
        
        cardField = createField(CGRect.zero, "请输入收款账户|付款账户", fontRegular(15), Main_TextColor, UIView(), nil)
        cardField?.enableBankCardFormat()
        cardField?.delegate = self
        cardField?.keyboardType = .numberPad
        cardField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cardFieldView.addSubview(cardField!)
        
        let bankrightimg:UIImageView =  UIImageView(image: UIImage(named: "gray_right"))
        cardFieldView.addSubview(bankrightimg)
        
        banklb.text = "银行名字"
        banklb.textColor = Main_detailColor
        banklb.font = fontRegular(14)
        banklb.textAlignment = .right
        banklb.isUserInteractionEnabled = true
        cardFieldView.addSubview(banklb)
        
        let button:UIButton = UIButton()
        cardFieldView.addSubview(button)
        button.addTarget(self, action: #selector(selectBank), for: .touchUpInside)
        
        timeField = createField(CGRect.zero, "交易时间", fontRegular(15), Main_TextColor, nil, nil)
        timeField?.delegate = self
        contentView.addSubview(timeField!)
        
        remindField = createField(CGRect.zero, "转账附言", fontRegular(15), Main_TextColor, nil, nil)
        remindField?.delegate = self
        contentView.addSubview(remindField!)
        
        expenditureBtn.setTitle("支出", for: .normal)
        expenditureBtn.setTitleColor(recordColor, for: .normal)
        expenditureBtn.backgroundColor = .white
        expenditureBtn.titleLabel?.font = fontRegular(15)
        expenditureBtn.addTarget(self, action: #selector(changeList(button:)), for: .touchUpInside)
        contentView.addSubview(expenditureBtn)
        
        
        incomeBtn.setTitle("收入", for: .normal)
        incomeBtn.setTitleColor(HXColor(0x8b8b93), for: .normal)
        incomeBtn.backgroundColor = HXColor(0xcecfd4)
        incomeBtn.titleLabel?.font = fontRegular(15)
        incomeBtn.addTarget(self, action: #selector(changeList(button:)), for: .touchUpInside)
        contentView.addSubview(incomeBtn)
        
        recordCollectionView.backgroundColor = Main_backgroundColor
        recordCollectionView.isScrollEnabled = false
        contentView.addSubview(recordCollectionView)
        
        
        tradeCollectionView.backgroundColor = Main_backgroundColor
        tradeCollectionView.isScrollEnabled = false
        contentView.addSubview(tradeCollectionView)
        tradeCollectionView.isHidden = true
        
        addRecordBtn = creatButton(CGRect.zero, "随机数据", fontRegular(16), .white, Main_Color, self, #selector(addRecord))
        contentView.addSubview(addRecordBtn)
        
        sumbitBtn = creatButton(CGRect.zero, "插入", fontRegular(16), .white, Main_Color, self, #selector(isOpenVIPAction))
        contentView.addSubview(sumbitBtn)
        
        nameField!.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(navigationHeight + 10)
            make.height.equalTo(40)
        }
        
        moneyField!.snp.makeConstraints { make in
            make.left.right.height.equalTo(nameField!)
            make.top.equalTo(nameField!.snp.bottom).offset(15)
        }
        
        cardFieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(moneyField!.snp.bottom).offset(15)
            make.height.equalTo(nameField!)
        }
        
        cardField!.snp.makeConstraints { make in
            make.top.height.equalToSuperview()
            make.left.equalToSuperview().inset(15)
            make.right.equalToSuperview().offset(-130)
        }
        
        bankrightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(cardField!)
        }
        
        banklb.snp.makeConstraints { make in
            make.left.equalTo(cardField!.snp.right).offset(5)
            make.right.equalTo(bankrightimg.snp.left).offset(-5)
            make.height.equalTo(30)
            make.centerY.equalTo(bankrightimg)
        }
        
        button.snp.makeConstraints { make in
            make.left.right.equalTo(banklb)
            make.height.equalTo(50)
            make.centerY.equalTo(banklb)
        }
        
        timeField!.snp.makeConstraints { make in
            make.left.right.height.equalTo(nameField!)
            make.top.equalTo(cardFieldView.snp.bottom).offset(15)
        }
        
        tradeCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(34 * 2 + 20)
            make.top.equalTo(timeField!.snp.bottom)
        }
        
        remindField!.snp.makeConstraints { make in
            make.left.right.height.equalTo(nameField!)
            make.top.equalTo(timeField!.snp.bottom).offset(15)
        }
        
        expenditureBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(remindField!.snp.bottom).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        incomeBtn.snp.makeConstraints { make in
            make.left.equalTo(expenditureBtn.snp.right).offset(15)
            make.top.equalTo(expenditureBtn)
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        selectButton = expenditureBtn
        recordCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(34.0 * 5 + 20)
            make.top.equalTo(expenditureBtn.snp.bottom)
        }
        
        addRecordBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(recordCollectionView.snp.bottom)
            make.height.equalTo(48)
            make.width.equalTo(SCREEN_WDITH/2.0 - 20)
        }
        
        sumbitBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.top.width.equalTo(addRecordBtn)
            make.height.equalTo(48)
        }
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(SCREEN_HEIGTH)
        }
        
        ViewBorderRadius(nameField!, 20, 1, recordColor)
        ViewBorderRadius(moneyField!, 20, 1, recordColor)
        ViewBorderRadius(cardField!, 20, 1, recordColor)
        ViewBorderRadius(timeField!, 20, 1, recordColor)
        ViewBorderRadius(remindField!, 20, 1, recordColor)
        
        ViewBorderRadius(expenditureBtn, 15, 1, recordColor)
        ViewBorderRadius(incomeBtn, 15, 1, HXColor(0xcecfd4))
        ViewRadius(addRecordBtn, 24)
        ViewRadius(sumbitBtn, 24)
        
        
        // 添加点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDateField))
        timeField?.addGestureRecognizer(tapGesture)
        
        if oldModel != nil {
            uploadInfo()
        }
    }
    
//    override func touchedView(){
//        hideDatePicker()
//    }

    
    @objc func didTapDateField() {
        self.view.endEditing(true)
        showDatePicker()
    }
    
    private func showDatePicker() {
        // 移除已有的选择器
        customDatePicker?.removeFromSuperview()
        
        // 创建新的选择器
        let high:CGFloat = 150 + bottomSafeAreaHeight + 40
        let frame = CGRect(x: 0, y: SCREEN_HEIGTH - high,width: SCREEN_WDITH, height: high)
        
        customDatePicker = CustomDatePickerView(frame: frame)
        customDatePicker?.delegate = self
        
        // 设置默认值（如果有）
        if let currentTime = timeField?.text {
            customDatePicker?.setDefaultDate(currentTime)
        }
        
        view.addSubview(customDatePicker!)
        
        // 添加动画
        customDatePicker?.transform = CGAffineTransform(translationX: 0, y: high)
        UIView.animate(withDuration: 0.3) {
            self.customDatePicker?.transform = .identity
        }
    }
    
    private func hideDatePicker() {
        UIView.animate(withDuration: 0.3, animations: {
            self.customDatePicker?.transform = CGAffineTransform(translationX: 0, y: self.customDatePicker?.frame.height ?? 0)
        }) { _ in
            self.customDatePicker?.removeFromSuperview()
            self.customDatePicker = nil
        }
    }
    
    // MARK: - CustomDatePickerDelegate
    func datePickerDidConfirm(_ date: String) {
        timeField?.text = date
        hideDatePicker()
    }
    
    @objc func changeList(button:UIButton){
        if button == selectButton {
            return
        }
        selectButton = button
        
        if button == expenditureBtn {
            ViewBorderRadius(expenditureBtn, 15, 1, recordColor)
            expenditureBtn.backgroundColor = .white
            expenditureBtn.setTitleColor(recordColor, for: .normal)
            
            ViewBorderRadius(incomeBtn, 15, 1, HXColor(0xcecfd4))
            incomeBtn.setTitleColor(HXColor(0x8b8b93), for: .normal)
            incomeBtn.backgroundColor = HXColor(0xcecfd4)
            isIncome = false
            
        }else{
            ViewBorderRadius(incomeBtn, 15, 1, recordColor)
            incomeBtn.backgroundColor = .white
            incomeBtn.setTitleColor(recordColor, for: .normal)
            
            ViewBorderRadius(expenditureBtn, 15, 1, HXColor(0xcecfd4))
            expenditureBtn.setTitleColor(HXColor(0x8b8b93), for: .normal)
            expenditureBtn.backgroundColor = HXColor(0xcecfd4)
            isIncome = true
            
        }
        
        recordCollectionView.snp.updateConstraints { make in
            make.height.equalTo(isIncome ? (34.0 * 3 + 20) : (34.0 * 5 + 20))
        }
        
        
        print("recordCollectionView=\(recordCollectionView.frame)")
        
        recordCollectionView.reloadData()
        DispatchQueue.main.async {
            self.recordCollectionView.collectionViewLayout.invalidateLayout()
            self.recordCollectionView.layoutIfNeeded()
        }
    }
    
    @objc func selectBank(){
        let ctrl:SelectBankCtrl = SelectBankCtrl()
        ctrl.onTap = { dic in
            self.banklb.text = dic["bankName"] as? String
            self.banklb.textColor = Main_TextColor
            
            self.cardName = dic["cardName"] as? String ?? ""
            self.cardType = dic["cardType"] as? String ?? ""
            self.banktype = "bank_type_\(dic["cardIconInt"] as? String ?? "7")"
        }
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    //MARK: - 验证可用的功能
    @objc func isOpenVIPAction(){
        //水印版本不受限制 可以用
        if myUser!.vip_time == .typeNotActivated || myUser!.vip_level == .typeNoAction{
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
                        //过期不能用提示
                        KWindow?.makeToast("会员已到期", .center, .information)
                    }
                }else{
                    KWindow?.makeToast(msg, .center, .fail)
                }
            }
        }
    }
    
    //MARK: - 编辑流水
    func uploadInfo(){
        sumbitBtn.setTitle("修改", for: .normal)
        addRecordBtn.setTitle("删除", for: .normal)
        
        isIncome = oldModel!.isIncome
        tradeStyle = oldModel!.tradeStyle
        
        switch oldModel!.tradeType {
        case TransactionChildType.typeTransfer101.type,
            TransactionChildType.typeTransfer102.type,
            TransactionChildType.typeTransfer200.type,
            TransactionChildType.typeTransfer201.type:
            
            self.nameField?.text = oldModel!.partner.name
            self.moneyField?.text = String(format: "%.02f", oldModel!.amount)
            self.cardField?.text = oldModel!.partner.card
            self.timeField?.text = oldModel!.bigtime
            self.remindField?.text = oldModel!.remind
            
            banklb.text = oldModel!.partner.bankName
            self.banktype = oldModel!.partner.icon
            self.cardType = oldModel!.partner.cardType
            self.cardName = oldModel!.partner.cardName

            selectIndex = (isIncome) ? (oldModel!.tradeType - 101):(oldModel!.tradeType - 200)
            break
        default:
            self.nameField?.text = oldModel!.remind
            self.moneyField?.text = String(format: "%.02f", oldModel!.amount)
            self.timeField?.text = oldModel!.bigtime
            tradeStyle = oldModel!.tradeStyle
            
            if isIncome {
                if oldModel!.tradeType < TransactionChildType.typeTransfer106.type {
                    selectIndex = oldModel!.tradeType - 101
                }else{
                    selectIndex = oldModel!.tradeType - 103
                }
            }else{
                selectIndex = oldModel!.tradeType - 210
            }
            break
        }
        
        uptodateView()
        
        changeList(button: isIncome ? incomeBtn : expenditureBtn)
    }
    
    // MARK: - 确认插入数据或修改数据
    func sumbitTransfer(){
        //要加入输入判断
        if ((nameField?.text?.count) == 0) ||
           ((moneyField?.text?.count) == 0) ||
           ((timeField?.text?.count) == 0){
            KWindow?.makeToast("请填写完整数据", .center, .fail)
            return
        }
        
        if selectIndex == 0 || selectIndex == 1{
            if ((cardField?.text?.count) == 0){
                KWindow?.makeToast("请填写完整数据", .center, .fail)
                return
            }
        }
        
        var tradModel:TransferModel = TransferModel()
        var partner:TransferPartner = TransferPartner()
        let cardmodel:CardModel = myCardList[0]
        
        
        let serialNumber:String = generateRandom16DigitString()
        var calculatedBalance:Double = 0.00
        
        if isIncome {
            
            let amount:Double = Double(self.moneyField?.text ?? "0.00") ?? 0.00
            calculatedBalance = (myUser?.myBalance ?? 0.0) + amount
            
            switch selectIndex {
            case 0, 1:
                //0他人转入 1转账给自己
                partner = TransferPartner(
                    ["name": self.nameField?.text ?? "",
                     "card":self.cardField!.text!,
                     "icon": self.banktype,
                     "lastCard": String((cardField!.text!.replacingOccurrences(of: " ", with: "")).suffix(4)),
                     "bankName": self.banklb.text ?? "", "cardName": self.cardName,
                     "cardType": self.cardType]
                )
                
                tradModel = TransferModel(
                    ["amount": amount,
                     "remind": self.remindField?.text ?? "转账",
                     "payBank": cardmodel.bank,
                     "payCard": cardmodel.card,
                     "tradeType":incomeArray[selectIndex]["icon"] ?? 101,
                     "isIncome":true,
                     "bigtime":self.timeField!.text!,
                     "smalltime":self.timeField!.text!,
                     "serialNumber":serialNumber,
                     "partner":partner,
                     "calculatedBalance":calculatedBalance])

                break
            
            case 2,3,4,5:
                //微信提现 微信商户提现 支付宝提现 账户结息 退款
                tradModel = TransferModel(
                    ["amount": self.moneyField?.text ?? "",
                     "remind": self.nameField!.text ?? "",
                     "payBank": cardmodel.bank,
                     "payCard": cardmodel.card,
                     "tradeType":incomeArray[selectIndex]["icon"] ?? 101,
                     "isIncome":true,
                     "bigtime":self.timeField!.text!,
                     "smalltime":self.timeField!.text!,
                     "serialNumber":serialNumber,
                     "calculatedBalance":calculatedBalance])
                
   
                break
            default:
                //退款
                tradModel = TransferModel(
                    ["amount": self.moneyField?.text ?? "",
                     "remind": self.nameField!.text ?? "",
                     "payBank": cardmodel.bank,
                     "payCard": cardmodel.card,
                     "tradeType":incomeArray[selectIndex]["icon"] ?? 101,
                     "isIncome":true,
                     "tradeStyle":tradeStyle,
                     "bigtime":self.timeField!.text!,
                     "smalltime":self.timeField!.text!,
                     "serialNumber":serialNumber,
                     "calculatedBalance":calculatedBalance])
                
                break
            }
        }else{
            let amount:Double = Double(self.moneyField?.text ?? "0.00") ?? 0.00
            calculatedBalance = (myUser?.myBalance ?? 0.0) - amount
            
            
            if calculatedBalance < 0 && oldModel == nil{
                KWindow?.makeToast("余额不足，请修改余额后重新插入", .center, .fail)
                return
            }
            
            switch selectIndex {
            case 0, 1:
                //0转账他人 1转账自己
                partner = TransferPartner(
                    ["name": self.nameField?.text ?? "",
                     "card":self.cardField!.text!,
                     "icon": self.banktype,
                     "lastCard": String((cardField!.text!.replacingOccurrences(of: " ", with: "")).suffix(4)),
                     "bankName": self.banklb.text ?? "",
                     "cardName": self.cardName,
                     "cardType": self.cardType]
                )
                
                tradModel = TransferModel(
                    ["amount": self.moneyField?.text ?? "",
                     "remind": self.remindField?.text ?? "转账",
                     "payBank": cardmodel.bank,
                     "payCard": cardmodel.card,
                     "tradeType":expenditureArray[selectIndex]["icon"] ?? 200,
                     "isIncome":false,
                     "bigtime":self.timeField!.text!,
                     "smalltime":self.timeField!.text!,
                     "serialNumber":serialNumber,
                     "partner":partner,
                     "calculatedBalance":calculatedBalance])
                
                //去重
//                if selectIndex == 0 {
//                    if !myPartnerList.contains(where: { $0.card == partner.card }) {
//                        myPartnerList.append(partner)
//                    }
//                }
//               
//                TransferPartner.saveArray(myPartnerList, forKey: MyTransferPartnerCards)
                break
            
            case 2,5:
                //取现 手续费
                tradModel = TransferModel(
                    ["amount": self.moneyField?.text ?? "",
                     "remind": self.nameField!.text ?? "",
                     "payBank": cardmodel.bank,
                     "payCard": cardmodel.card,
                     "tradeType":expenditureArray[selectIndex]["icon"] ?? 200,
                     "isIncome":false,
                     "bigtime":self.timeField!.text!,
                     "smalltime":self.timeField!.text!,
                     "serialNumber":serialNumber,
                     "calculatedBalance":calculatedBalance])
                
                break
            default:
                //京东金融 出行 购物
                tradModel = TransferModel(
                    ["amount": self.moneyField?.text ?? "",
                     "remind": self.nameField!.text ?? "",
                     "payBank": cardmodel.bank,
                     "payCard": cardmodel.card,
                     "tradeType":expenditureArray[selectIndex]["icon"] ?? 200,
                     "isIncome":false,
                     "tradeStyle":tradeStyle,
                     "bigtime":self.timeField!.text!,
                     "smalltime":self.timeField!.text!,
                     "serialNumber":serialNumber,
                     "calculatedBalance":calculatedBalance,
                     "merchantNumber":generateRandomMerchantNumber()])
                break
            }
        }
        
        //如果是修改数据，先删除原数据，在添加新数据
        if oldModel != nil {
            //重新计算余额 修改不重算余额
//            var oldCalculatedBalance:Double = 0.00
//            
//            if oldModel!.isIncome {
//                oldCalculatedBalance = calculatedBalance - oldModel!.amount
//            }else{
//                oldCalculatedBalance = calculatedBalance + oldModel!.amount
//            }
//            
//            myUser?.myBalance = oldCalculatedBalance
//            UserManager.shared.update { user in
//                user.myBalance = oldCalculatedBalance
//            }
            
            //删除对应流水
            myTradeList.removeFirstExactMatch(of: oldModel!)
            KWindow?.makeToast("修改成功", .center, .success)
            self.navigationController?.popViewController(animated: true)
        }else{
            
            myUser?.myBalance = calculatedBalance
            UserManager.shared.update { user in
                user.myBalance = calculatedBalance
            }
            KWindow?.makeToast("添加成功", .center, .success)
        }
        
        //通知余额更新
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: nil)
        
        myTradeList.append(tradModel)
        TransferModel.saveArray(myTradeList, forKey: MyTradeRecord)
        
    }
    
    
    // MARK: - 生成随机数据或删除数据
    @objc func addRecord(){
        
        //删除流水
        if oldModel != nil {
            //重新计算余额
//            var calculatedBalance:Double = 0.00
//            
//            if oldModel!.isIncome {
//                calculatedBalance = myUser!.myBalance - oldModel!.amount
//            }else{
//                calculatedBalance = myUser!.myBalance + oldModel!.amount
//            }
//            
//            myUser?.myBalance = calculatedBalance
//            UserManager.shared.update { user in
//                user.myBalance = calculatedBalance
//            }
            KWindow?.makeToast("已删除", .center, .fail)
            //删除对应流水
            myTradeList.removeFirstExactMatch(of: oldModel!)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        nameField?.text = randomChineseName()
        
        moneyField?.text = randomAmount(min: 0,max: Int(myUser!.myBalance))
        
        let dic:Dictionary<String,Any> = randomBankCardNumber()
        let hootbank:Dictionary<String,Any> = dic["hotBank"] as! Dictionary
        cardField?.text = dic["card"] as? String
        
        
        banklb.text = hootbank["bankName"] as? String
        banklb.textColor = Main_TextColor
        
        cardName = hootbank["cardName"] as? String ?? ""
        cardType = hootbank["cardType"] as? String ?? ""
        
        if let intValue = hootbank["cardIconInt"] as? Int {
            banktype = "bank_type_\(intValue)" // 使用字符串插值，更简单
        } else {
            let stringValue = hootbank["cardIconInt"] as? String ?? "7"
            banktype = "bank_type_\(stringValue)"
        }
        
        timeField?.text = randomDate(from: 2020, to:2026)
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
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == tradeCollectionView {
            
            return tradeArray.count
            
        }else{
            
            if isIncome {
                return incomeArray.count
            }else{
                return expenditureArray.count
            }
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == tradeCollectionView {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell", for: indexPath) as? TradeEditCell else {
                return UICollectionViewCell()
            }
            
            cell.addData(_data: tradeArray[indexPath.row],_isSelect: (tradeStyle == indexPath.row) ? true : false,istrade: true)
            
            return cell
            
        }else{
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TradeEditCell", for: indexPath) as? TradeEditCell else {
                return UICollectionViewCell()
            }
            
            let data = isIncome ? incomeArray[indexPath.row] : expenditureArray[indexPath.row]
            let isSelected = (selectIndex == indexPath.row)
            
            
            cell.addData(_data: data, _isSelect: isSelected)
            return cell
        }
        
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        
        if collectionView == tradeCollectionView {
            
            tradeStyle = indexPath.row
            tradeCollectionView.reloadData()
            
        }else{
            selectIndex = indexPath.row
            tradeStyle = 0
            
            switch selectIndex {
            case 1:
                nameField?.text = myUser?.myName
            case 2:
                if isIncome == true{
                    nameField?.text = "财付通"
                }
            case 3:
                if isIncome == false{
                    tradeStyle = 4
                }else{
                    nameField?.text = "财付通支付科技有限公司"
                }
            case 4:
                if isIncome == true{
                    nameField?.text = "支付宝（中国）网络科技有限..."
                }
            case 5:
                if isIncome == false{
                    let card:CardModel = myCardList[0]
                    let time:String = getCurrentTimeString(dateFormat:"yyyy-MM")
                    nameField?.text = "\(time)短信服务扣费尾号:\(card.lastCard)"
                }else{
                    nameField?.text = "结息：xx.xx扣税：0"
                }
            default:
                break
            }
            
            
            uptodateView()
        }
 
    }
    
    //MARK: - 通过选择的selectIndex 更新UI
    func uptodateView(){
        switch selectIndex {
        case 0, 1:
            //0转账他人 1转账自己
            //展示 cardFieldView timeField remindField
            //隐藏 tradeCollectionView
            cardFieldView.isHidden = false
            remindField?.isHidden = false
            
            timeField!.snp.remakeConstraints { make in
                make.left.right.height.equalTo(nameField!)
                make.top.equalTo(cardFieldView.snp.bottom).offset(15)
            }
            
            expenditureBtn.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalTo(remindField!.snp.bottom).offset(20)
                make.height.equalTo(30)
                make.width.equalTo(80)
            }
            tradeCollectionView.isHidden = true
            
            //修改数据 按钮不隐藏
            if oldModel == nil {
                addRecordBtn.isHidden = false
                
                sumbitBtn.snp.updateConstraints { make in
                    make.right.equalToSuperview().inset(15)
                }
            }
            break
        
        case 2,5:
            //取现 手续费
            //隐藏 cardFieldView tradeCollectionView remindField
            
            cardFieldView.isHidden = true
            remindField?.isHidden = true
            
            timeField!.snp.remakeConstraints { make in
                make.left.right.height.equalTo(nameField!)
                make.top.equalTo(moneyField!.snp.bottom).offset(15)
            }
            
            expenditureBtn.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalTo(timeField!.snp.bottom).offset(20)
                make.height.equalTo(30)
                make.width.equalTo(80)
            }
            
            tradeCollectionView.isHidden = true
            
            if oldModel == nil {
                addRecordBtn.isHidden = true
                
                sumbitBtn.snp.updateConstraints { make in
                    make.right.equalToSuperview().inset(SCREEN_WDITH/4.0 - 10 + 15)
                }
            }

            break
        default:
            //京东金融 出行 购物
            //隐藏 cardFieldView remindField
 
            cardFieldView.isHidden = true
            remindField?.isHidden = true
            
            timeField!.snp.remakeConstraints { make in
                make.left.right.height.equalTo(nameField!)
                make.top.equalTo(moneyField!.snp.bottom).offset(15)
            }
            
            expenditureBtn.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalTo(tradeCollectionView.snp.bottom)
                make.height.equalTo(30)
                make.width.equalTo(80)
            }
            
            tradeCollectionView.isHidden = false
            
            if oldModel == nil {
                addRecordBtn.isHidden = true
                
                sumbitBtn.snp.updateConstraints { make in
                    make.right.equalToSuperview().inset(SCREEN_WDITH/4.0 - 10 + 15)
                }
            }
            
            break
        }
        
        tradeCollectionView.reloadData()
        recordCollectionView.reloadData()
    }
}


class TradeEditCell: UICollectionViewCell {
    let titlelb:UILabel = UILabel()
    let icon:UIImageView = UIImageView()
    var model:Dictionary<String,Any>?
    var isSelect:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = HXColor(0xe7e6eb)
        
        addSubview(icon)
        
        titlelb.font = fontMedium(12)
        titlelb.textColor = HXColor(0xcccbd0)
        addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(9)
        }
        
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.right.equalTo(titlelb.snp.left).offset(-4)
        }
        
        ViewRadius(self, 12)
    }
    
    func addData(_data:Dictionary<String,Any>,_isSelect:Bool = false,istrade:Bool = false) {
        model = _data
         
        isSelect = _isSelect
        
        titlelb.text = _data["title"] as? String
       
        
        let iconstr:String = istrade ? "icon_channels_\(_data["icon"]!)" : getBankTransactionIcon(type: ((_data["icon"] as! Int)))
        
        icon.image = UIImage(named: iconstr) ?? UIImage()
        
        backgroundColor = isSelect ? Main_Color : HXColor(0xe7e6eb)
        titlelb.textColor = isSelect ? .white : HXColor(0xcccbd0)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

