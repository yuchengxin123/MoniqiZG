//
//  UserEditCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/27.
//

import UIKit
import CoreLocation
import SnapKit
import YPImagePicker
import LocalAuthentication
import RxSwift
import RxCocoa

class UserEditCtrl: BaseCtrl,CustomDatePickerDelegate {
    
    private var didSetupCorner = false
    
    var phoneBtn:UIButton?//手机号
    var userBtn:UIButton?//头像
    var nameBtn:UIButton?//昵称
    var realBtn:UIButton?//真实名字
    
    var cardsBtn:UIButton?//银行卡数
    var daibanBtn:UIButton?//待办
    var couponsBtn:UIButton?//银行卡数
    var pointsBtn:UIButton?//积分
    
    //账户总览
    var moneyBtn:UIButton?
    
    //本月收支
    var incomeMoneyBtn:UIButton?
    var expenditureMoneyBtn:UIButton?
    
    //信用卡 贷款
    var creditMoneyBtn:UIButton?//信用卡消费
    var creditMonthBtn:UIButton?//信用卡账单日期
    var loanMoneyBtn:UIButton?//贷款额度
//    var loanRateBtn:UIButton?//利率
    
    //五险一金
    var yibaoBtn:UIButton?
    var gongjijinBtn:UIButton?
    var yuefenBtn:UIButton?
    
    var selectTag:Int = 1000
    
    private var customDatePicker: CustomDatePickerView?
    
    private let tableView:UITableView = UITableView()
    
    private let disposeBag = DisposeBag()
    private let datas = BehaviorRelay<[CardModel]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        basicScrollView.isScrollEnabled = true
        addTap = true;
        
        addTopView()
    }
    
    override func setupUI() {
        super.setupUI()
        addView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datas.accept(myCardList)
        
        tableView.snp.updateConstraints { make in
            make.height.equalTo(210 * (datas.value.count))
        }
    }
    
    func addTopView(){
        let headView:UIView = UIView()
        headView.backgroundColor = .white
        view.addSubview(headView)
        
        headView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }

        let titlelb:UILabel = creatLabel(CGRect.zero, "个人信息", fontRegular(19), Main_TextColor)
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
        datas.accept(myCardList)
        
        let titles:Array<String> = ["绑定手机号","头像","真实姓名","登录界面显示的昵称","总金额"]
//
        let avatar:UIImage = loadUserImage(fileName: "usericon.png") ?? UIImage(named: "user_default")!
        
        let details:Array<Any> = [myUser!.phone,avatar,myUser!.myName,myUser!.nickname,getNumberFormatter(myUser?.myBalance ?? 0.00)]
        
        var y:CGFloat = 20 + navigationHeight
        
        for (i,str) in titles.enumerated() {
            let leftlb:UILabel = creatLabel(CGRect.zero, str, fontRegular(15), fieldPlaceholderColor)
            contentView.addSubview(leftlb)
            
            leftlb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(y)
                make.height.equalTo(20)
            }
            
            leftlb.setContentHuggingPriority(.required, for: .horizontal)
            leftlb.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            let rightimg:UIImageView = UIImageView()
            rightimg.image = UIImage(named: "gray_right")
            contentView.addSubview(rightimg)
            
            rightimg.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-18)
                make.centerY.equalTo(leftlb)
                make.width.equalTo(8)
                make.height.equalTo(15)
            }
            
            switch i {
            case 0:
                phoneBtn = creatButton(CGRect.zero, details[i] as! String, fontRegular(16), fieldPlaceholderColor, .clear, self, #selector(isOpenVIPAction(button:)))
                phoneBtn?.tag = 1000
                phoneBtn?.contentMode = .right
                contentView.addSubview(phoneBtn!)
                
                phoneBtn!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-15)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(40)
                    make.left.equalTo(leftlb.snp.right)
                }
                
                phoneBtn!.contentHorizontalAlignment = .right  // 文字右对齐
            case 1:
                userBtn = UIButton()
                userBtn?.imageView?.contentMode = .scaleAspectFill
                contentView.addSubview(userBtn!)
                userBtn?.addTarget(self, action: #selector(isOpenVIPAction(button:)), for: .touchUpInside)
                userBtn?.setImage(details[i] as? UIImage, for: .normal)
                userBtn?.tag = 1001
                userBtn!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-15)
                    make.centerY.equalTo(leftlb)
                    make.height.width.equalTo(40)
                }
            case 2:
                realBtn = creatButton(CGRect.zero, details[i] as! String, fontRegular(16), fieldPlaceholderColor, .clear, self, #selector(isOpenVIPAction(button:)))
                realBtn?.contentMode = .right
                realBtn?.tag = 1002
                contentView.addSubview(realBtn!)
                
                realBtn!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-15)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(40)
                    make.left.equalTo(leftlb.snp.right)
                }
                
                realBtn!.contentHorizontalAlignment = .right  // 文字右对齐
            case 3:
                nameBtn = creatButton(CGRect.zero, details[i] as! String, fontRegular(16), fieldPlaceholderColor, .clear, self, #selector(isOpenVIPAction(button:)))
                nameBtn?.contentMode = .right
                nameBtn?.tag = 1003
                contentView.addSubview(nameBtn!)
                
                nameBtn!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-15)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(40)
                    make.left.equalTo(leftlb.snp.right)
                }
                
                nameBtn!.contentHorizontalAlignment = .right  // 文字右对齐
            default:
                moneyBtn = creatButton(CGRect.zero, details[i] as! String, fontRegular(16), fieldPlaceholderColor, .clear, self, #selector(isOpenVIPAction(button:)))
                moneyBtn?.contentMode = .right
                moneyBtn?.tag = 1004
                contentView.addSubview(moneyBtn!)
                
                moneyBtn!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-15)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(40)
                    make.left.equalTo(leftlb.snp.right)
                }
                
                moneyBtn!.contentHorizontalAlignment = .right  // 文字右对齐
            }
            y += 50
        }
        
        ViewRadius(userBtn!, 20)
        
        
        let wide:CGFloat = (SCREEN_WDITH - 30)/4.0
        
        cardsBtn = creatButton(CGRect.zero, "\(myCardList.count)", fontNumber(20), Main_TextColor, .clear, self, #selector(isOpenVIPAction(button:)))
        cardsBtn?.tag = 1005
        contentView.addSubview(cardsBtn!)
        
        daibanBtn = creatButton(CGRect.zero, "\(myUser?.myWorks ?? 0)", fontNumber(20), Main_TextColor, .clear, self, #selector(isOpenVIPAction(button:)))
        daibanBtn?.tag = 1006
        contentView.addSubview(daibanBtn!)
        
        couponsBtn = creatButton(CGRect.zero, "\(myUser?.myCoupons ?? 0)", fontNumber(20), Main_TextColor, .clear, self, #selector(isOpenVIPAction(button:)))
        couponsBtn?.tag = 1007
        contentView.addSubview(couponsBtn!)
        
        pointsBtn = creatButton(CGRect.zero, getNumberFormatter(Double(myUser?.myPoints ?? 0),0), fontNumber(20), Main_TextColor, .clear, self, #selector(isOpenVIPAction(button:)))
        pointsBtn?.tag = 1008
        contentView.addSubview(pointsBtn!)
        
        let cardslb = creatLabel(CGRect.zero, "银行卡", fontRegular(13), HXColor(0x565656))
        cardslb.textAlignment = .center
        contentView.addSubview(cardslb)
        
        let daibanlb = creatLabel(CGRect.zero, "待办", fontRegular(13), HXColor(0x565656))
        daibanlb.textAlignment = .center
        contentView.addSubview(daibanlb)
        
        let couponlb = creatLabel(CGRect.zero, "卡券", fontRegular(13), HXColor(0x565656))
        couponlb.textAlignment = .center
        contentView.addSubview(couponlb)
        
        let pointlb = creatLabel(CGRect.zero, "积分", fontRegular(13), HXColor(0x565656))
        pointlb.textAlignment = .center
        contentView.addSubview(pointlb)
        
        
        cardsBtn!.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(wide)
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(y)
        }
        
        daibanBtn!.snp.makeConstraints { make in
            make.height.width.top.equalTo(cardsBtn!)
            make.left.equalToSuperview().offset(wide + 15)
        }
        
        couponsBtn!.snp.makeConstraints { make in
            make.height.width.top.equalTo(cardsBtn!)
            make.left.equalToSuperview().offset(wide * 2.0 + 15)
        }
        
        pointsBtn!.snp.makeConstraints { make in
            make.height.width.top.equalTo(cardsBtn!)
            make.left.equalToSuperview().offset(wide * 3.0 + 15)
        }
        
        cardslb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(wide)
            make.left.equalTo(cardsBtn!)
            make.top.equalTo(cardsBtn!.snp.bottom)
        }
        
        daibanlb.snp.makeConstraints { make in
            make.width.height.top.equalTo(cardslb)
            make.left.equalTo(daibanBtn!)
        }
        
        couponlb.snp.makeConstraints { make in
            make.width.height.top.equalTo(cardslb)
            make.left.equalTo(couponsBtn!)
        }
        
        pointlb.snp.makeConstraints { make in
            make.width.height.top.equalTo(cardslb)
            make.left.equalTo(pointsBtn!)
        }
        
        y+=60
    
        let creditTitles:Array<String> = [
            "\(myUser?.billingDate ?? "08-16")出账",
            getNumberFormatter(myUser?.creditCardSpending ?? 0.00),
            "\(getNumberFormatter(Double(myUser?.loanAmount ?? 0),0)) 万"]
        let creditDetails:Array<String> = ["\n信用卡出账日","\n信用卡金额","\n最高贷款"]
        
        let btnwide:CGFloat = SCREEN_WDITH/3.0
        
        for (i,str) in creditTitles.enumerated() {
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: str, color: Main_TextColor, font: fontNumber(15)),
                .init(text: creditDetails[i], color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            
            let btn:UIButton = UIButton()
            btn.addTarget(self, action: #selector(isOpenVIPAction(button:)), for: .touchUpInside)
            btn.tag = 1009 + i
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            contentView.addSubview(btn)
            
            btn.setAttributedTitle(richText, for: .normal)
            
            btn.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(y)
                make.width.equalTo(btnwide)
                make.left.equalToSuperview().offset(Double(i) * btnwide)
                make.height.equalTo(60)
            }
            switch i {
            case 0:
                creditMonthBtn = btn
            case 1:
                creditMoneyBtn = btn
            default:
                loanMoneyBtn = btn
            }
        }
        
        y+=70
        
        let socialTitles:Array<String> = [
            getNumberFormatter(myUser?.medicalInsurance ?? 0.00),
            myUser!.providentUpdateTime,
            getNumberFormatter(myUser?.providentFund ?? 0.00)]
        let socialDetails:Array<String> = ["\n医保","\n核算日期","\n住房公积金"]
        
        
        for (i,str) in socialTitles.enumerated() {
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: str, color: Main_TextColor, font: fontNumber(15)),
                .init(text: socialDetails[i], color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            
            let btn:UIButton = UIButton()
            btn.addTarget(self, action: #selector(isOpenVIPAction(button:)), for: .touchUpInside)
            btn.tag = 1012 + i
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            contentView.addSubview(btn)
            
            btn.setAttributedTitle(richText, for: .normal)
            
            btn.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(y)
                make.width.equalTo(btnwide)
                make.left.equalToSuperview().offset(Double(i) * btnwide)
                make.height.equalTo(60)
            }
            switch i {
            case 0:
                yibaoBtn = btn
            case 1:
                yuefenBtn = btn
            default:
                gongjijinBtn = btn
            }
        }
        
        y+=70
        
        
        let monthTitles:Array<String> = [
            String(format: "¥ %@", getNumberFormatter(myUser?.myMonthCost ?? 0.00)),
            String(format: "¥ %@", getNumberFormatter(myUser?.myMonthIncome ?? 0.00))]
        let monthDetails:Array<String> = ["\n本月支出","\n本月收入"]
        
        let monthwide:CGFloat = SCREEN_WDITH/2.0
        
        for (i,str) in monthTitles.enumerated() {
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: str, color: Main_TextColor, font: fontNumber(20)),
                .init(text: monthDetails[i], color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            
            let btn:UIButton = UIButton()
            btn.addTarget(self, action: #selector(isOpenVIPAction(button:)), for: .touchUpInside)
            btn.tag = 1015 + i
            contentView.addSubview(btn)
            btn.titleLabel?.numberOfLines = 0
            btn.titleLabel?.textAlignment = .center
            btn.setAttributedTitle(richText, for: .normal)
            
            btn.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(y)
                make.width.equalTo(monthwide)
                make.left.equalToSuperview().offset(Double(i) * monthwide)
                make.height.equalTo(60)
            }
            switch i {
            case 0:
                expenditureMoneyBtn = btn
            default:
                incomeMoneyBtn = btn
            }
        }
        
        y+=70
        
        // MARK: - 卡片列表
        tableView.register(BigCardCell.self, forCellReuseIdentifier: "BigCardCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.rowHeight = 210 // 设置固定高度
        contentView.addSubview(tableView)
        tableView.isScrollEnabled = false
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(y)
            make.height.equalTo(210 * (datas.value.count))
        }
        
        
        // 先绑定数据源
        datas
            .bind(to: tableView.rx.items(cellIdentifier: "BigCardCell", cellType: BigCardCell.self)) { index, model, cell in
                guard let model = model as? CardModel else { return }
                cell.addData(_data: model)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(CardModel.self))
            .subscribe(onNext: { [weak self] indexPath, model in
                
                self?.tableView.deselectRow(at: indexPath, animated: true)
                guard let model = model as? CardModel else { return }
                
                print("点击了 cell: \(model)")
                let ctrl:AddCardCtrl = AddCardCtrl()
                ctrl.oldModel = model
                ctrl.index = indexPath.row
                self?.navigationController?.pushViewController(ctrl, animated: true)
            })
            .disposed(by: disposeBag)
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(tableView.snp.bottom).offset(30)
        }
        
        print("tableView=\(tableView.frame)")
    }
    
    //MARK: - 验证可用的功能
    @objc func isOpenVIPAction(button:UIButton){
        //个人信息全部可以编辑
        self.changeAllInfo(tag: button.tag)
        self.isShowWater()
        //水印版本不受限制 可以用
//        if myUser!.vip_level == .typeNoAction {
//            self.changeAllInfo(tag: button.tag)
//            self.isShowWater()
//        }else{
//            //非水印版本 要考虑使用该功能要求的最低会员等级 以及 有效期
//            YcxHttpManager.getTimestamp() { msg,data,code  in
//                if code == 1{
//                    let currentTime:TimeInterval = TimeInterval(data)
//                    
//                    print("本地时间--\((Date().timeIntervalSince1970))\n服务器时间--\(currentTime)")
//                    
//                    //没过期
//                    if myUser!.expiredDate > currentTime {
//                        // 只能改余额
//                        if myUser!.vip_level == .typeVip{
//                            switch button.tag {
//                            case 1004:
//                                self.changeMyMoney()
//                            default:
//                                KWindow?.makeToast("需要升级会员", .center, .information)
//                            }
//                        }else if myUser!.vip_level == .typeSVip || myUser!.vip_level == .typeAll{
//                            self.changeAllInfo(tag: button.tag)
//                        }
//                        
//                    }else{
//                        //全部能用但是变成水印版本
//                        self.changeAllInfo(tag: button.tag)
//                        self.isShowWater()
//                    }
//                }else{
//                    KWindow?.makeToast(msg, .center, .fail)
//                }
//            }
//        }
    }
    
    func changeAllInfo(tag:Int){
        switch tag {
        case 1000:
            self.setPhone()
        case 1001:
            self.addImage()
        case 1002:
            self.changeName()
        case 1003:
            self.setNcikName()
        case 1004:
            self.changeMyMoney()
        case 1005:
            self.addCard()
        case 1006:
            self.setDaiban()
        case 1007:
            self.setCoupons()
        case 1008:
            self.setPoints()
        case 1009:
            self.changeCreditCardTime()
        case 1010:
            self.changeCreditCardMoney()
        case 1011:
            self.changeLoanAmount()
        case 1012:
            self.changeMedicalInsurance()
        case 1013:
            self.changeCalculationDate()
        case 1014:
            self.changeProvidentFund()
        case 1015:
            self.changeMonthCost()
        case 1016:
            self.changeMonthIncome()
        default:
            print("")
        }
    }
    
    //MARK: - 添加银行卡
    @objc func addCard(){
        let ctrl:AddCardCtrl = AddCardCtrl()
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    //MARK: - 本月收入
    @objc func changeMonthIncome(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "本月收入")
        fieldview.type = .amountType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: String(format: "¥%@", getNumberFormatter(Double(text) ?? 0.00)), color: Main_TextColor, font: fontNumber(20)),
                .init(text: "\n本月收入", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            self.incomeMoneyBtn?.setAttributedTitle(richText, for: .normal)
            
            myUser?.myMonthIncome = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.myMonthIncome = Double(text) ?? 0.00
            }
        }
    }
    
    //MARK: - 本月支出
    @objc func changeMonthCost(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "本月支出")
        fieldview.type = .amountType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: String(format: "¥%@", getNumberFormatter(Double(text) ?? 0.00)), color: Main_TextColor, font: fontNumber(20)),
                .init(text: "\n本月支出", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            self.expenditureMoneyBtn?.setAttributedTitle(richText, for: .normal)
            
            myUser?.myMonthCost = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.myMonthCost = Double(text) ?? 0.00
            }
            
        }
    }
    
    
    // MARK: - 医保
    @objc func changeMedicalInsurance(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "医保")
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: getNumberFormatter((Double(text) ?? 0.00)), color: Main_TextColor, font: fontNumber(15)),
                .init(text: "\n医保", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            self.yibaoBtn?.setAttributedTitle(richText, for: .normal)
            
            myUser?.medicalInsurance = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.medicalInsurance = Double(text) ?? 0.00
            }
        }
    }
    
    // MARK: - 社保核算日期
    @objc func changeCalculationDate(){
        selectTag = 1012
        showDatePicker()
//        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
//        fieldview.setContent(str: "核算日期")
//        fieldview.type = .integerType
//        KWindow?.addSubview(fieldview)
//        
//        fieldview.changeContent = { text in
//            
//            let richText = NSAttributedString.makeAttributedString(components: [
//                .init(text: text, color: Main_TextColor, font: fontNumber(15)),
//                .init(text: "\n核算日期", color: fieldPlaceholderColor, font: fontRegular(12))
//            ])
//            self.yuefenBtn?.setAttributedTitle(richText, for: .normal)
//            
//            myUser?.providentUpdateTime = text
//            UserManager.shared.update { user in
//                user.providentUpdateTime = text
//            }
//        }
    }
    
    // MARK: - 公积金
    @objc func changeProvidentFund(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "住房公积金")
        fieldview.type = .amountType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: getNumberFormatter((Double(text) ?? 0.00)), color: Main_TextColor, font: fontNumber(15)),
                .init(text: "\n住房公积金", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            self.gongjijinBtn?.setAttributedTitle(richText, for: .normal)
            
            myUser?.providentFund = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.providentFund = Double(text) ?? 0.00
            }
        }
    }
    
    // MARK: - 信用卡账单日
    @objc func changeCreditCardTime(){
        selectTag = 1008
        showDatePicker()
//        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
//        fieldview.setContent(str: "信用卡出账日")
//        KWindow?.addSubview(fieldview)
//        
//        fieldview.changeContent = { text in
//            let richText = NSAttributedString.makeAttributedString(components: [
//                .init(text: "\(text)出账", color: Main_TextColor, font: fontNumber(15)),
//                .init(text: "\n信用卡出账日", color: fieldPlaceholderColor, font: fontRegular(12))
//            ])
//            self.creditMonthBtn?.setAttributedTitle(richText, for: .normal)
//
//            myUser?.billingDate = text
//            UserManager.shared.update { user in
//                user.billingDate = text
//            }
//        }
    }
    
    // MARK: - 信用卡金额
    @objc func changeCreditCardMoney(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "出账金额")
        fieldview.type = .integerType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: String(format: "%@", getNumberFormatter(Double(text) ?? 0.00)), color: Main_TextColor, font: fontNumber(15)),
                .init(text: "\n信用卡金额", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            self.creditMoneyBtn?.setAttributedTitle(richText, for: .normal)
            
            myUser?.creditCardSpending = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.creditCardSpending = Double(text) ?? 0.00
            }
        }
    }
    
    // MARK: - 贷款额度
    @objc func changeLoanAmount(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "最高贷款")
        fieldview.type = .integerType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: "\(getNumberFormatter((Double(text) ?? 0.00),0)) 万", color: Main_TextColor, font: fontNumber(15)),
                .init(text: "\n最高贷款", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            self.loanMoneyBtn?.setAttributedTitle(richText, for: .normal)
            
            myUser?.loanAmount = Int(text) ?? 10
            UserManager.shared.update { user in
                user.loanAmount = Int(text) ?? 10
            }
        }
    }
    
    
    // MARK: - 修改余额
    @objc func changeMyMoney(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "总资产")
        fieldview.type = .amountType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            self.moneyBtn?.setTitle(String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00)), for: .normal)
            myUser?.myBalance = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.myBalance = Double(text) ?? 0.00
            }
            //通知更新
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: text)
        }
    }
    
    // MARK: - 设置待办
    @objc func setDaiban(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "待办")
        fieldview.type = .integerType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            self.daibanBtn?.setTitle(text, for: .normal)
            myUser?.myWorks = Int(text) ?? 1
            UserManager.shared.update { user in
                user.myWorks = Int(text) ?? 1
            }
        }
    }
    
    // MARK: - 设置卡券
    @objc func setCoupons(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "卡券")
        fieldview.type = .integerType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            self.couponsBtn?.setTitle(text, for: .normal)
            myUser?.myCoupons = Int(text) ?? 1
            UserManager.shared.update { user in
                user.myCoupons = Int(text) ?? 1
            }
        }
    }
    
    // MARK: - 修改积分
    @objc func setPoints(){
        print("修改我的积分数量")
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "积分")
        fieldview.type = .integerType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            self.pointsBtn?.setTitle(text, for: .normal)
            myUser?.myPoints = Int(text) ?? 0
            UserManager.shared.update { user in
                user.myPoints = Int(text) ?? 0
            }
        }
    }
    
    // MARK: - 添加头像
    @objc func addImage(){
        var config = YPImagePickerConfiguration()
        // 允许使用相册和相机
        config.screens = [.library, .photo]
        
        // 相册配置
        config.library.mediaType = .photo
        config.library.defaultMultipleSelection = true
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.skipSelectionsGallery = true // 不进入编辑页
        config.library.preSelectItemOnMultipleSelection = false
        
        // 拍照配置
        config.onlySquareImagesFromCamera = false
        config.usesFrontCamera = false
        
        // UI 优化
        config.showsPhotoFilters = false
        config.showsCrop = .none
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        
        // 保存到相册（可选）
        config.shouldSaveNewPicturesToAlbum = false
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                picker.dismiss(animated: true)
                return
            }
            
            for item in items {
                switch item {
                case .photo(let photo):
                    self.userBtn!.setImage(photo.image, for: .normal)
                    saveUserImage(photo.image, fileName: "usericon.png")
                    //通知更新
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeUserIconNotificationName), object: photo.image)
                default: break
                }
            }
            picker.dismiss(animated: true)
        }
        present(picker, animated: true, completion: nil)
    }
    // MARK: - 修改手机号
    @objc func setPhone(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "修改手机号")
        fieldview.setKeyboardType(type: .namePhonePad)
        KWindow?.addSubview(fieldview)
        fieldview.changeContent = { text in
            self.phoneBtn!.setTitle(text, for: .normal)
            
            myUser?.phone = text
            UserManager.shared.update { user in
                user.phone = text
            }
        }
    }

    // MARK: - 修改真实名称
    @objc func changeName(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "修改真实名称")
        fieldview.setKeyboardType(type: .default)
        KWindow?.addSubview(fieldview)
        fieldview.changeContent = { text in
            self.realBtn!.setTitle(text, for: .normal)
            
            myUser?.myName = text
            UserManager.shared.update { user in
                user.myName = text
            }
        }
    }

    // MARK: - 修改昵称
    @objc func setNcikName(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "修改昵称")
        fieldview.setKeyboardType(type: .default)
        KWindow?.addSubview(fieldview)
        fieldview.changeContent = { text in
            self.nameBtn!.setTitle(text, for: .normal)
            
            myUser?.nickname = text
            UserManager.shared.update { user in
                user.nickname = text
            }
        }
    }
    
    // MARK: - 日期设置
    private func showDatePicker() {
        // 移除已有的选择器
        customDatePicker?.removeFromSuperview()
        
        // 创建新的选择器
        let high:CGFloat = 150 + bottomSafeAreaHeight + 40
        let frame = CGRect(x: 0, y: SCREEN_HEIGTH - high,width: SCREEN_WDITH, height: high)
        
        customDatePicker = CustomDatePickerView(frame: frame)
        customDatePicker?.delegate = self
        // 只显示月日
        customDatePicker?.visibleComponents = [.month, .day]
        // 设置默认值（如果有）
//        if let currentTime = timeField?.text {
//            customDatePicker?.setDefaultDate(currentTime)
//        }
        
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
        
        let text:String = date.replacingOccurrences(of: ":", with: "-")
        
        if selectTag == 1008 {
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: "\(text)出账", color: Main_TextColor, font: fontNumber(15)),
                .init(text: "\n信用卡出账日", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            creditMonthBtn?.setAttributedTitle(richText, for: .normal)

            myUser?.billingDate = text
            UserManager.shared.update { user in
                user.billingDate = text
            }
        }else{
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: text, color: Main_TextColor, font: fontNumber(15)),
                .init(text: "\n核算日期", color: fieldPlaceholderColor, font: fontRegular(12))
            ])
            yuefenBtn?.setAttributedTitle(richText, for: .normal)

            myUser?.providentUpdateTime = text
            UserManager.shared.update { user in
                user.providentUpdateTime = text
            }
        }
        
        hideDatePicker()
    }
}

