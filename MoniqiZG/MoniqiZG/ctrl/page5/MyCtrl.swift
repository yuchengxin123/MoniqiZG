//
//  MyCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/28.
//

import UIKit
import SnapKit
import YPImagePicker

import LocalAuthentication

class MyCtrl: BaseCtrl,UIScrollViewDelegate {
    
    private var didSetupCorner = false
    
    
    var faceView:FaceRecognitionView?
    let tabbar:UIView = UIView()
    
    var searchimg:UIImageView?
    var setimg:UIImageView?
    var msgimg:UIImageView?
    var exitimg:UIImageView?
    
    let headView:UIView = UIView()
    var userBtn:UIButton?//头像
    var nameBtn:UIButton?//名字
    var dazhongBtn:UIButton?//大众
    
    var cardsBtn:UIButton?//银行卡数
    var daibanBtn:UIButton?//待办
    var couponsBtn:UIButton?//银行卡数
    var pointsBtn:UIButton?//积分
    let dazhongimg:UIImageView = UIImageView()
    
    //账户总览
    let billView:UIView = UIView()
    let showImage:UIImageView = UIImageView()
    var moneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    var incomeBtn:SecureLoadingLabel = SecureLoadingLabel()

    //本月收支
    let monthView:UIView = UIView()
    var incomeMoneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    var expenditureMoneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    let percentageLineView:PercentageLine = PercentageLine()
    
    //信用卡 贷款
    var creditView:UIView = UIView()
    var loanView:UIView = UIView()
    var creditMoneyBtn:SecureLoadingLabel = SecureLoadingLabel()//信用卡消费
    var creditMonthBtn:SecureLoadingLabel = SecureLoadingLabel()//信用卡账单日期
    var loanMoneyBtn:SecureLoadingLabel = SecureLoadingLabel()//贷款额度
    var loanRateBtn:SecureLoadingLabel = SecureLoadingLabel()//利率
    
    //五险一金
    let providentFundView:UIView = UIView()
    var yibaoBtn:SecureLoadingLabel = SecureLoadingLabel()
    var gongjijinBtn:SecureLoadingLabel = SecureLoadingLabel()
    var yuefenBtn:UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicScrollView.delegate = self
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.addContentView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeIcon(noti:)), name: NSNotification.Name(rawValue: changeUserIconNotificationName), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeMyBalance(noti:)), name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeMyIncomeNotification(noti:)), name: NSNotification.Name(rawValue: changeMyIncomeNotificationName), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //头像 名字
        if let avatar = loadUserImage(fileName: "usericon.png") {
            userBtn?.setImage(avatar, for: .normal)
        } else {
            userBtn?.setImage(UIImage(named: "user_default"), for: .normal)
        }
        nameBtn?.setTitle(String(format: "**%@", String(myUser!.myName.suffix(1))), for: .normal)
        
        //银行卡 待办 卡券 积分
        cardsBtn?.setTitle("\(myCardList.count)", for: .normal)
        daibanBtn?.setTitle("\(myUser?.myWorks ?? 0)", for: .normal)
        couponsBtn?.setTitle("\(myUser?.myCoupons ?? 0)", for: .normal)
        pointsBtn?.setTitle(getNumberFormatter(Double(myUser?.myPoints ?? 0),0), for: .normal)
        
        //账户总览
        moneyBtn.text = String(format: "%@¥ %@",(myUser!.isCut ? "-":""), getNumberFormatter(myUser?.myBalance ?? 0.00))
        incomeBtn.text = String(format: "¥ %@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        
        //本月收支
        expenditureMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.myMonthCost ?? 0.00))
        incomeMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.myMonthIncome ?? 0.00))
        uploadPercentageLineView()
        
        //信用卡账单
        creditMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.creditCardSpending ?? 0.00))
        creditMonthBtn.text = "\(myUser?.billingDate ?? "08-16")出账"
        loanMoneyBtn.text = "最高可借 \(getNumberFormatter(Double(myUser?.loanAmount ?? 0),0)) 万"
        //年利率 怎么算
        
        yibaoBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.medicalInsurance ?? 0.00))
        gongjijinBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.providentFund ?? 0.00))
        yuefenBtn.setTitle("\(myUser?.providentUpdateTime ?? "08-01") 余额", for: .normal)
        
        self.uploadVip()
        
        if faceCheck {
            faceView = FaceRecognitionView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH - tabBarHeight))
            faceView?.ctrl = self
            faceView?.faceRecognitionSuccess = { [weak self] in
                
                faceCheck = false
                
                self?.faceView?.removeFromSuperview()

                self?.moneyBtn.show()
                self?.incomeBtn.show()

                self?.creditMonthBtn.show()
                self?.incomeMoneyBtn.show()
                self?.expenditureMoneyBtn.show()

                self?.creditMoneyBtn.show()

                self?.yibaoBtn.show()
                self?.gongjijinBtn.show()
                
            }
            self.view.addSubview(faceView!)

            faceView!.authenticateWithFaceID()
        }
    }
    
    @objc func changeMyBalance(noti:NSNotification){
        self.moneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.myBalance ?? 0.00))
    }
    
    @objc func changeMyIncomeNotification(noti:NSNotification){
        let str:String = (noti.object ?? "") as! String
        self.incomeBtn.text = String(format: "+%@", getNumberFormatter(Double(str) ?? 0.00))
    }
    
    @objc func changeIcon(noti:NSNotification){
        let img:UIImage = (noti.object ?? UIImage()) as! UIImage
        userBtn?.setImage(img, for:.normal)
    }
    
    
    func addContentView(){
        let bg:UIImageView = UIImageView()
        bg.image = UIImage(named: "shequbg")
        view.insertSubview(bg, at: 0)
        
        bg.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addTopView()
        
        self.addHeadInfoView()
        
        self.addBillOverView()
        
        self.addMonthView()
        
        self.addCreditAndCardView()
        
        self.addProvidentFundView()
        
        self.addCreditAndCardView()
        
        self.addBottomView()
        
        self.cancelButtonAction()
    }
    
    // MARK: - 取消外面编辑
    func cancelButtonAction(){
        nameBtn?.isUserInteractionEnabled = false
        
        daibanBtn?.isUserInteractionEnabled = false
        couponsBtn?.isUserInteractionEnabled = false
        pointsBtn?.isUserInteractionEnabled = false
        
//        moneyBtn.isUserInteractionEnabled = false
        incomeBtn.isUserInteractionEnabled = false
        
//        incomeMoneyBtn.isUserInteractionEnabled = false
//        expenditureMoneyBtn.isUserInteractionEnabled = false
        
        creditMoneyBtn.isUserInteractionEnabled = false
        creditMonthBtn.isUserInteractionEnabled = false
        loanMoneyBtn.isUserInteractionEnabled = false
        loanRateBtn.isUserInteractionEnabled = false
        
        yibaoBtn.isUserInteractionEnabled = false
        gongjijinBtn.isUserInteractionEnabled = false
        yuefenBtn.isUserInteractionEnabled = false
    }
    
    //导航栏
    func addTopView(){
        view.addSubview(tabbar)
        tabbar.backgroundColor = .clear
        
        tabbar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        
        exitimg = UIImageView(image: UIImage(named: "exit")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(exitimg!)
        exitimg!.tintColor = .black
        
        exitimg!.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(7)
        }
        
        msgimg = UIImageView(image: UIImage(named: "main_msg_balck")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(msgimg!)
        msgimg!.tintColor = .black
        
        msgimg!.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(exitimg!)
        }
        
        setimg = UIImageView(image: UIImage(named: "set")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(setimg!)
        setimg!.tintColor = .black
        
        setimg!.snp.makeConstraints { make in
            make.width.height.equalTo(28)
            make.right.equalTo(msgimg!.snp.left).offset(-25)
            make.centerY.equalTo(exitimg!)
        }

        searchimg = UIImageView(image: UIImage(named: "main_search")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(searchimg!)
        searchimg!.tintColor = .black
        
        searchimg!.snp.makeConstraints { make in
            make.width.height.equalTo(26)
            make.right.equalTo(setimg!.snp.left).offset(-25)
            make.centerY.equalTo(exitimg!)
        }
        
        let btn:UIButton = UIButton()
        btn.addTarget(self, action: #selector(setVip), for: .touchUpInside)
        tabbar.addSubview(btn)
        
        btn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerX.bottom.equalTo(setimg!)
        }
        
        let rightBtn:UIButton = UIButton()
        rightBtn.addTarget(self, action: #selector(setInfo), for: .touchUpInside)
        tabbar.addSubview(rightBtn)
        
        rightBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerX.bottom.equalTo(msgimg!)
        }
    }
    
    func uploadVip(){
        switch Int(myUser!.myBalance) {
        case 0...50000:
            dazhongimg.image = UIImage(named: "icon_m_vip_1")
        case 50000...500000:
            dazhongimg.image = UIImage(named: "icon_m_vip_2")
        case 500000...10000000:
            dazhongimg.image = UIImage(named: "icon_m_vip_3")
        default:
            dazhongimg.image = UIImage(named: "icon_m_vip_4")
            break
        }
    }
    
    //用户信息
    func addHeadInfoView(){
        headView.backgroundColor = .clear
        contentView.addSubview(headView)
        
        userBtn = UIButton()
        userBtn?.imageView?.contentMode = .scaleAspectFill
        headView.addSubview(userBtn!)
        userBtn?.addTarget(self, action: #selector(addImage), for: .touchUpInside)
               
        if let avatar = loadUserImage(fileName: "usericon.png") {
            userBtn?.setImage(avatar, for: .normal)
        } else {
            userBtn?.setImage(UIImage(named: "user_default"), for: .normal)
        }
        
        nameBtn = creatButton(CGRect.zero, String(format: "**%@", String(myUser!.myName.suffix(1))), fontMedium(20), Main_TextColor, .clear, self, #selector(changeName))
        headView.addSubview(nameBtn!)
        
        let infolb:UILabel = UILabel()
        infolb.font = fontRegular(12)
        infolb.text = "个人主页"
        infolb.textColor = HXColor(0x565656)
        headView.addSubview(infolb)
        
        let rightimg = UIImageView()
        rightimg.image = UIImage(named: "my_right")
        headView.addSubview(rightimg)
        
        dazhongBtn = UIButton()
        dazhongBtn?.setBackgroundImage(UIImage(named: "dazhongbg"), for: .normal)
        dazhongBtn?.addTarget(self, action: #selector(setVipRank), for: .touchUpInside)
        headView.addSubview(dazhongBtn!)
        
        dazhongimg.image = UIImage(named: "icon_m_vip_1")
        dazhongimg.contentMode = .scaleAspectFit
        dazhongBtn!.addSubview(dazhongimg)

        let wide:CGFloat = (SCREEN_WDITH - 30)/4.0
        
        cardsBtn = creatButton(CGRect.zero, "\(myCardList.count)", fontNumber(20), Main_TextColor, .clear, self, #selector(setCards))
        headView.addSubview(cardsBtn!)
        
        daibanBtn = creatButton(CGRect.zero, "\(myUser?.myWorks ?? 0)", fontNumber(20), Main_TextColor, .clear, self, #selector(setDaiban))
        headView.addSubview(daibanBtn!)
        
        couponsBtn = creatButton(CGRect.zero, "\(myUser?.myCoupons ?? 0)", fontNumber(20), Main_TextColor, .clear, self, #selector(setCoupons))
        headView.addSubview(couponsBtn!)
        
        pointsBtn = creatButton(CGRect.zero, getNumberFormatter(Double(myUser?.myPoints ?? 0),0), fontNumber(20), Main_TextColor, .clear, self, #selector(setPoints))
        headView.addSubview(pointsBtn!)
        
        let cardslb = creatLabel(CGRect.zero, "银行卡", fontRegular(12), HXColor(0x565656))
        cardslb.textAlignment = .center
        headView.addSubview(cardslb)
        
        let daibanlb = creatLabel(CGRect.zero, "待办", fontRegular(12), HXColor(0x565656))
        daibanlb.textAlignment = .center
        headView.addSubview(daibanlb)
        
        let couponlb = creatLabel(CGRect.zero, "卡券", fontRegular(12), HXColor(0x565656))
        couponlb.textAlignment = .center
        headView.addSubview(couponlb)
        
        let pointlb = creatLabel(CGRect.zero, "积分", fontRegular(12), HXColor(0x565656))
        pointlb.textAlignment = .center
        headView.addSubview(pointlb)
        
        headView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(navigationHeight)
            make.height.equalTo(150)
        }
       
        userBtn?.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(20)
        }
        
        nameBtn?.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalTo(userBtn!.snp.right).offset(15)
            make.top.equalTo(userBtn!)
        }
        
        infolb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(nameBtn!)
            make.bottom.equalTo(userBtn!.snp.bottom)
        }
        
        rightimg.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(20)
            make.left.equalTo(infolb.snp.right)
            make.centerY.equalTo(infolb)
        }
        
        dazhongBtn!.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(90)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(userBtn!)
        }
        
        //288 87
        dazhongimg.snp.makeConstraints { make in
            make.height.equalTo(15)
//            make.width.equalTo(90)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        cardsBtn!.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(wide)
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(userBtn!.snp.bottom).offset(15)
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
        
        ViewRadius(userBtn!, 25)
    }
    
    //账户总览
    func addBillOverView(){
        //0xf0effc
        //MyDetailColor
        billView.backgroundColor = .white
        contentView.addSubview(billView)

        let titlelb = creatLabel(CGRect.zero, "账户总览", fontMedium(16), Main_TextColor)
        billView.addSubview(titlelb)
        
        let line:UIView = UIView()
        line.backgroundColor = HXColor(0xf0effc)
        billView.insertSubview(line, at: 0)
        
        showImage.image = UIImage(named: "showMoney")
        showImage.contentMode = .scaleAspectFill
        billView.addSubview(showImage)
        
        let showBtn:UIButton = UIButton()
        showBtn.backgroundColor = .clear
        showBtn.addTarget(self, action: #selector(showMoney(button:)), for: .touchUpInside)
        showBtn.isSelected = false
        billView.addSubview(showBtn)
        
        let totallb = creatLabel(CGRect.zero, "总资产", fontRegular(14), HXColor(0xb5b5b5))
        billView.addSubview(totallb)
       
        
        moneyBtn.text =  String(format: "¥ %@", getNumberFormatter(myUser?.myBalance ?? 0.00))
        moneyBtn.isSecureText = false
        moneyBtn.font = fontNumber(25)
        moneyBtn.addTarget(self, action: #selector(changeMyMoney), for: .touchUpInside)
        moneyBtn.textAlignment = .left
        billView.addSubview(moneyBtn)
        
        let incomelb = creatLabel(CGRect.zero, "昨日收益", fontRegular(14), HXColor(0xb5b5b5))
        billView.addSubview(incomelb)
        
        incomeBtn.text =  String(format: "+%@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        incomeBtn.isSecureText = false
        incomeBtn.font = fontNumber(25)
        incomeBtn.addTarget(self, action: #selector(changeMyIncome), for: .touchUpInside)
        incomeBtn.textAlignment = .right
        billView.addSubview(incomeBtn)
        
        incomeBtn.setPosition(position: .right)
        
        let smallline:UIView = UIView()
        smallline.backgroundColor = defaultLineColor
        billView.addSubview(smallline)
        
        let redDot:UIView = UIView()
        redDot.backgroundColor = HXColor(0xe85433)
        billView.addSubview(redDot)
        
        let detaillb = creatLabel(CGRect.zero, "闪电贷提款达标有礼，至高赢华为运动手表", fontRegular(14), HXColor(0x808080))
        billView.addSubview(detaillb)
        
        billView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(headView.snp.bottom).offset(5)
            make.height.equalTo(180)
        }
        
        titlelb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(titlelb.snp.bottom).offset(-4)
            make.left.width.equalTo(titlelb)
            make.height.equalTo(8)
        }
        
        showImage.snp.makeConstraints { make in
            make.centerY.equalTo(titlelb)
            make.left.equalTo(titlelb.snp.right).offset(10)
            make.height.equalTo(13)
            make.width.equalTo(19)
        }
        
        showBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titlelb)
            make.left.equalTo(titlelb.snp.right)
            make.height.width.equalTo(60)
        }
        
        totallb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(15)
            make.top.equalTo(titlelb.snp.bottom).offset(20)
        }
        
        incomelb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.top.equalTo(totallb)
        }
        
        moneyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(40)
            make.top.equalTo(totallb.snp.bottom)
        }
        
        incomeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.top.equalTo(moneyBtn)
        }
        
        smallline.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(1)
        }
        
        redDot.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-22)
            make.left.equalToSuperview().inset(15)
            make.height.width.equalTo(6)
        }
        
        detaillb.snp.makeConstraints { make in
            make.centerY.equalTo(redDot)
            make.left.equalTo(redDot.snp.right).offset(5)
            make.height.equalTo(15)
        }
        
        ViewRadius(redDot, 3)
        ViewRadius(billView, 10)
    }
    
    //本月收支
    func addMonthView(){
        monthView.backgroundColor = .white
        contentView.addSubview(monthView)

        let titlelb = creatLabel(CGRect.zero, "本月收支", fontMedium(16), Main_TextColor)
        monthView.addSubview(titlelb)
        
        
        let totallb = creatLabel(CGRect.zero, "支出", fontRegular(14), HXColor(0xb5b5b5))
        monthView.addSubview(totallb)
        
        incomeMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.myMonthCost ?? 0.00))
        incomeMoneyBtn.isSecureText = false
        incomeMoneyBtn.font = fontNumber(20)
        incomeMoneyBtn.addTarget(self, action: #selector(changeMonthIncome), for: .touchUpInside)
        incomeMoneyBtn.textAlignment = .left
        monthView.addSubview(incomeMoneyBtn)
        
        let incomelb = creatLabel(CGRect.zero, "收入", fontRegular(14), HXColor(0xb5b5b5))
        monthView.addSubview(incomelb)
        
        expenditureMoneyBtn.text =  String(format: "¥ %@", getNumberFormatter(myUser?.myMonthIncome ?? 0.00))
        expenditureMoneyBtn.isSecureText = false
        expenditureMoneyBtn.font = fontNumber(20)
        expenditureMoneyBtn.addTarget(self, action: #selector(changeMyExpenses), for: .touchUpInside)
        expenditureMoneyBtn.textAlignment = .right
        monthView.addSubview(expenditureMoneyBtn)
        expenditureMoneyBtn.setPosition(position: .right)
        
        monthView.addSubview(percentageLineView)
        
        let detaillb = creatLabel(CGRect.zero, "我的外卖点单账单", fontRegular(14), HXColor(0x808080))
        monthView.addSubview(detaillb)
        
        let rightlb = creatLabel(CGRect.zero, "查看", fontRegular(14), HXColor(0x5995ef))
        monthView.addSubview(rightlb)
        
        monthView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(billView.snp.bottom).offset(15)
            make.height.equalTo(190)
        }
        
        titlelb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
        }
        
        totallb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(15)
            make.top.equalTo(titlelb.snp.bottom).offset(18)
        }
        
        incomelb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.top.equalTo(totallb)
        }
        
        expenditureMoneyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(40)
            make.top.equalTo(totallb.snp.bottom)
        }
        
        incomeMoneyBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.top.equalTo(expenditureMoneyBtn)
        }
        
        percentageLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-65)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(2)
        }
        
        detaillb.snp.makeConstraints { make in
            make.top.equalTo(percentageLineView).offset(25)
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(16)
        }
        
        rightlb.snp.makeConstraints { make in
            make.centerY.equalTo(detaillb)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(16)
        }
        
        uploadPercentageLineView()
        ViewRadius(monthView, 10)
    }
    
    func uploadPercentageLineView(){
        if myUser?.myMonthCost == 0.0 {
            percentageLineView.updateRatio(0.0)
        }else{
            let ratio:CGFloat =  (myUser?.myMonthCost ?? 0.0) / ((myUser?.myMonthCost ?? 0.0) + (myUser?.myMonthIncome ?? 0.0))
            percentageLineView.updateRatio(ratio)
        }
    }
    
    //信用卡 贷款
    func addCreditAndCardView(){
        
        let bigTiitles:Array = ["信用卡","贷款"]
        let smallTitles:Array = ["还款有礼","抽好礼"]
        let detailsTitle:Array = ["\(myUser?.billingDate ?? "08-16")出账","最高可借 \(getNumberFormatter(Double(myUser?.loanAmount ?? 0),0)) 万"]
        
        let tiitles:Array = [String(format: "¥ %@", getNumberFormatter(myUser?.creditCardSpending ?? 0.00)),"年利率(单利)低至"]
        
        let wide:CGFloat = (SCREEN_WDITH/2.0) - 20
        
        for (i,str) in bigTiitles.enumerated() {
            let basicView:UIView = UIView()
            basicView.backgroundColor = .white
            contentView.addSubview(basicView)
            

            let titlelb:UILabel = creatLabel(CGRect.zero, str, fontMedium(16), Main_TextColor)
            basicView.addSubview(titlelb)
         
            let smallView:UIView = UIView()
            smallView.backgroundColor = HXColor(0xff766e)
            basicView.addSubview(smallView)
            
            let smalllb:UILabel = creatLabel(CGRect.zero, smallTitles[i], fontRegular(12), .white)
            smalllb.backgroundColor = .clear
            basicView.addSubview(smalllb)
            
            let smallBtn:SecureLoadingLabel = SecureLoadingLabel()
            smallBtn.text = detailsTitle[i]
            smallBtn.isSecureText = false
            smallBtn.font = fontRegular(14)
            smallBtn.textColor = HXColor(0xb5b5b5)
            smallBtn.addTarget(self, action: #selector(changeContent(button:)), for: .touchUpInside)
            
            basicView.addSubview(smallBtn)
            
            let bigBtn:SecureLoadingLabel = SecureLoadingLabel()
            bigBtn.text = tiitles[i]
            bigBtn.isSecureText = false
            bigBtn.font = fontRegular(14)
            bigBtn.textColor = HXColor(0xb5b5b5)
            bigBtn.addTarget(self, action: #selector(changeCreditAndRate(button:)), for: .touchUpInside)
            basicView.addSubview(bigBtn)
            
            if i == 0 {
                bigBtn.textColor = Main_TextColor
                bigBtn.font = fontNumber(20)
                bigBtn.textAlignment = .left
                
                creditMonthBtn = smallBtn
                creditMoneyBtn = bigBtn
                creditView = basicView
                
            }else{
                let richText = NSAttributedString.makeAttributedString(components: [
                    .init(text: tiitles[i], color: Main_TextColor, font: fontRegular(14)),
                    .init(text: "\(myUser?.annualInterestRate ?? 3.05)%", color: HXColor(0xffa862), font: fontRegular(14))
                ])
                bigBtn.attributedText = richText
                loanMoneyBtn = smallBtn
                loanRateBtn = bigBtn
                loanView = basicView
            }
            
            
            basicView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15 + (wide + 10)*Double(i))
                make.height.equalTo(120)
                make.width.equalTo(wide)
                make.top.equalTo(monthView.snp.bottom).offset(15)
            }
            
            titlelb.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.left.equalToSuperview().offset(15)
                make.height.equalTo(20)
            }
            
            smalllb.snp.makeConstraints { make in
                make.centerY.equalTo(titlelb)
                make.left.equalTo(titlelb.snp.right).offset(10)
            }
            
            smallView.snp.makeConstraints { make in
                make.left.equalTo(smalllb).offset(-3)
                make.right.equalTo(smalllb).offset(3)
                make.top.equalTo(smalllb).offset(-1)
                make.bottom.equalTo(smalllb)
            }
            
            smallBtn.snp.makeConstraints { make in
                make.left.equalTo(titlelb)
                make.height.equalTo(30)
                make.top.equalTo(titlelb.snp.bottom).offset(5)
            }
            
            bigBtn.snp.makeConstraints { make in
                make.left.equalTo(titlelb)
                make.height.equalTo(35)
                make.top.equalTo(smallBtn.snp.bottom)
            }
            
            basicView.layoutIfNeeded()
            ViewRadius(basicView, 10)
            SetCornersAndBorder(smallView, radius: 5.5, corners: [.topLeft,.topRight,.bottomRight])
        }
    }
    
    //五险一金
    func addProvidentFundView(){
        providentFundView.backgroundColor = .white
        contentView.addSubview(providentFundView)

        let titlelb = creatLabel(CGRect.zero, "五险一金", fontMedium(16), Main_TextColor)
        providentFundView.addSubview(titlelb)
        
        yuefenBtn = creatButton(CGRect.zero, "\(myUser?.providentUpdateTime ?? "08-01") 余额", fontRegular(14), HXColor(0x808080), .clear, self, #selector(changeMonth))
        providentFundView.addSubview(yuefenBtn)
        
        let shebaolb = creatLabel(CGRect.zero, "社保", fontRegular(14), Main_TextColor)
        shebaolb.textAlignment = .center
        providentFundView.addSubview(shebaolb)
        
        let shebaoline:UIView = UIView()
        shebaoline.backgroundColor = HXColor(0xf0effc)
        providentFundView.insertSubview(shebaoline, at: 0)
        
        let chaxunlb = creatLabel(CGRect.zero, "查询", fontRegular(14), HXColor(0x5995ef))
        chaxunlb.textAlignment = .center
        providentFundView.addSubview(chaxunlb)
        
        let totallb = creatLabel(CGRect.zero, "医保", fontRegular(14), Main_TextColor)
        totallb.textAlignment = .center
        providentFundView.addSubview(totallb)
        
        let totalline:UIView = UIView()
        totalline.backgroundColor = HXColor(0xf0effc)
        providentFundView.insertSubview(totalline, at: 0)
        
        yibaoBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.medicalInsurance ?? 0.00))
        yibaoBtn.isSecureText = false
        yibaoBtn.font = fontNumber(14, .regular)//fontRegular(14)
        yibaoBtn.textColor = Main_TextColor
        yibaoBtn.addTarget(self, action: #selector(changeMyyibao), for: .touchUpInside)
        providentFundView.addSubview(yibaoBtn)
        
        let incomelb = creatLabel(CGRect.zero, "住房公积金", fontRegular(14), Main_TextColor)
        incomelb.textAlignment = .center
        providentFundView.addSubview(incomelb)
        
        let incomeline:UIView = UIView()
        incomeline.backgroundColor = HXColor(0xf0effc)
        providentFundView.insertSubview(incomeline, at: 0)
        
        gongjijinBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.providentFund ?? 0.00))
        gongjijinBtn.isSecureText = false
        gongjijinBtn.font = fontNumber(14, .regular)//fontRegular(14)
        gongjijinBtn.textColor = Main_TextColor
        gongjijinBtn.addTarget(self, action: #selector(changeMygongjijin), for: .touchUpInside)
        providentFundView.addSubview(gongjijinBtn)
        
        let bottomView:UIView = UIView()
        bottomView.backgroundColor = ColorF5F5F5
        providentFundView.addSubview(bottomView)
        
        let bottomlb = creatLabel(CGRect.zero, "小招", fontMedium(14), Main_TextColor)
        bottomView.addSubview(bottomlb)
        
        let bottomDetaillb = creatLabel(CGRect.zero, "交了社保，还要自己准备养老钱吗?", fontRegular(14), HXColor(0x808080))
        bottomView.addSubview(bottomDetaillb)
        
        providentFundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(creditView.snp.bottom).offset(15)
            make.height.equalTo(190)
        }
        
        titlelb.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
        }
        
        yuefenBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titlelb)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
        }
        
        shebaolb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titlelb.snp.bottom).offset(25)
            make.height.equalTo(16)
            make.width.equalTo(100)
        }
        
        shebaoline.snp.makeConstraints { make in
            make.centerX.equalTo(shebaolb)
            make.height.equalTo(8)
            make.width.equalTo(28)
            make.top.equalTo(shebaolb.snp.bottom).offset(-4)
        }
        
        chaxunlb.snp.makeConstraints { make in
            make.centerX.equalTo(shebaolb)
            make.height.equalTo(35)
            make.top.equalTo(shebaolb.snp.bottom)
        }
        
        totallb.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(shebaolb.snp.left)
            make.height.top.equalTo(shebaolb)
        }
        
        totalline.snp.makeConstraints { make in
            make.centerX.equalTo(totallb)
            make.width.equalTo(28)
            make.top.height.equalTo(shebaoline)
        }
        
        yibaoBtn.snp.makeConstraints { make in
            make.centerX.width.equalTo(totallb)
            make.height.equalTo(chaxunlb)
            make.top.equalTo(totallb.snp.bottom)
        }
        
        incomelb.snp.makeConstraints { make in
            make.left.equalTo(shebaolb.snp.right)
            make.right.equalToSuperview()
            make.height.top.equalTo(shebaolb)
        }
        
        incomeline.snp.makeConstraints { make in
            make.centerX.equalTo(incomelb)
            make.width.equalTo(70)
            make.top.height.equalTo(shebaoline)
        }
        
        gongjijinBtn.snp.makeConstraints { make in
            make.centerX.width.equalTo(incomelb)
            make.height.equalTo(chaxunlb)
            make.top.equalTo(incomelb.snp.bottom)
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(42)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        bottomlb.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        bottomDetaillb.snp.makeConstraints { make in
            make.left.equalTo(bottomlb.snp.right).offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        ViewRadius(providentFundView, 10)
        ViewRadius(bottomView, 10)
    }
    
    //底部图片
    func addBottomView(){
        
        let images:Array = ["my1","my2","my3"]
        
        var y:CGFloat = 15
        for (i, icon) in images.enumerated() {
            let image:UIImage = UIImage(named: icon) ?? UIImage()
            
            let imageV:UIImageView = UIImageView()
            imageV.image = image
            
            let high:CGFloat = (SCREEN_WDITH - 30) * (image.size.height/image.size.width)
            
            contentView.addSubview(imageV)
            
            imageV.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(providentFundView.snp.bottom).offset(y)
                make.height.equalTo(high)
            }
            
            y = y + high + 15
            
            if i == images.count - 1 {
                contentView.snp.makeConstraints { make in
                    make.bottom.equalTo(imageV.snp.bottom)
                }
            }
        }
    }
    
    @objc func changeMygongjijin(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "公积金")
        fieldview.type = .amountType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            self.gongjijinBtn.text = String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00))
            myUser?.providentFund = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.providentFund = Double(text) ?? 0.00
            }
        }
    }
    
    @objc func changeMyyibao(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "医保")
        fieldview.type = .amountType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            self.yibaoBtn.text = String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00))
            myUser?.medicalInsurance = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.medicalInsurance = Double(text) ?? 0.00
            }
        }
    }
    
    @objc func changeMonth(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "医保时间")
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            self.yuefenBtn.setTitle(text + " 余额", for: .normal)
            myUser?.providentUpdateTime = text
            UserManager.shared.update { user in
                user.providentUpdateTime = text
            }
        }
    }
    
    @objc func changeMyIncome(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "昨日收益")
        fieldview.type = .revenueType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
//            String(format: "¥ %@", getNumberFormatter(myUser?.myBalance ?? 0.00))
            self.incomeBtn.text = String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00))
            myUser?.myIncome = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.myIncome = Double(text) ?? 0.00
            }
            //通知更新
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyIncomeNotificationName), object: text)
        }
    }
    
    @objc func changeMyMoney(){
        let ctrl:MyAmountCtrl = MyAmountCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
//        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
//        fieldview.setContent(str: "总资产")
//        fieldview.type = .amountType
//        KWindow?.addSubview(fieldview)
//        
//        fieldview.changeContent = { text in
////            String(format: "¥ %@", getNumberFormatter(myUser?.myBalance ?? 0.00))
//            self.moneyBtn.text = String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00))
//            myUser?.myBalance = Double(text) ?? 0.00
//            UserManager.shared.update { user in
//                user.myBalance = Double(text) ?? 0.00
//            }
//            //通知更新
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: text)
//        }
    }
    
    @objc func showMoney(button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected {
            showImage.image = UIImage(named: "hideMoney")
        }else{
            showImage.image = UIImage(named: "showMoney")
        }
        incomeMoneyBtn.isSecureText = button.isSelected
        expenditureMoneyBtn.isSecureText = button.isSelected
        
        moneyBtn.isSecureText = button.isSelected
        incomeBtn.isSecureText = button.isSelected
        
        creditMoneyBtn.isSecureText = button.isSelected
        
        yibaoBtn.isSecureText = button.isSelected
        gongjijinBtn.isSecureText = button.isSelected
    }
    
    @objc func changeMonthIncome(){
        let ctrl:TradeRecordListCtrl = TradeRecordListCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
//        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
//        fieldview.setContent(str: "本月支出")
//        fieldview.type = .amountType
//        KWindow?.addSubview(fieldview)
//        
//        fieldview.changeContent = { text in
////            String(format: "¥ %@", getNumberFormatter(myUser?.myBalance ?? 0.00))
//            self.incomeMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00))
//            myUser?.myMonthCost = Double(text) ?? 0.00
//            UserManager.shared.update { user in
//                user.myMonthCost = Double(text) ?? 0.00
//            }
//            self.uploadPercentageLineView()
//        }
    }
    
    @objc func changeMyExpenses(){
        let ctrl:TradeRecordListCtrl = TradeRecordListCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
//        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
//        fieldview.setContent(str: "本月收入")
//        fieldview.type = .amountType
//        KWindow?.addSubview(fieldview)
//        
//        fieldview.changeContent = { text in
//            self.expenditureMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00))
//            myUser?.myMonthIncome = Double(text) ?? 0.00
//            UserManager.shared.update { user in
//                user.myMonthIncome = Double(text) ?? 0.00
//            }
//            self.uploadPercentageLineView()
//        }
    }
    
    @objc func setCards(){
        let ctrl:MyCardCtrl = MyCardCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
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
    
    @objc func setVipRank(){
        print("修改我的vip等级")
        
    }
    
    @objc func changeContent(button:SecureLoadingLabel){
        if button == creditMonthBtn {
            let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
            fieldview.setContent(str: "出账日期")
            KWindow?.addSubview(fieldview)
            
            fieldview.changeContent = { text in
                self.creditMonthBtn.text =  text + "出账"
                myUser?.billingDate = text
                UserManager.shared.update { user in
                    user.billingDate = text
                }
            }
        }else{
            let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
            fieldview.setContent(str: "最高可借")
            fieldview.type = .integerType
            KWindow?.addSubview(fieldview)
            
            fieldview.changeContent = { text in
                self.loanMoneyBtn.text =  "最高可借 \(text) 万"
                myUser?.loanAmount = Int(text) ?? 10
                UserManager.shared.update { user in
                    user.loanAmount = Int(text) ?? 10
                }
            }
        }
    }
    
    //消费 利率
    @objc func changeCreditAndRate(button:SecureLoadingLabel){
        if button == creditMoneyBtn {
            print("修改信用卡消费记录")
            let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
            fieldview.setContent(str: "信用卡消费")
            fieldview.type = .amountType
            KWindow?.addSubview(fieldview)
            
            fieldview.changeContent = { text in
                self.creditMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(Double(text) ?? 0.00))
                myUser?.creditCardSpending = Double(text) ?? 0.00
                UserManager.shared.update { user in
                    user.creditCardSpending = Double(text) ?? 0.00
                }
            }
        }else{
            let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
            fieldview.setContent(str: "年利率")
            fieldview.type = .amountType
            KWindow?.addSubview(fieldview)
            
            fieldview.changeContent = { text in
                let richText = NSAttributedString.makeAttributedString(components: [
                    .init(text:"年利率(单利)低至", color: Main_TextColor, font: fontRegular(14)),
                    .init(text: "\(text)%", color: HXColor(0xffa862), font: fontRegular(14))
                ])
                
                self.loanRateBtn.attributedText =  richText
                myUser?.annualInterestRate = Double(text) ?? 1.00
                UserManager.shared.update { user in
                    user.annualInterestRate = Double(text) ?? 1.00
                }
            }
        }
    }
    
    
    @objc func changeName(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "修改名称")
        fieldview.setKeyboardType(type: .default)
        KWindow?.addSubview(fieldview)
        fieldview.changeContent = { text in
            self.nameBtn!.setTitle("**\(text)", for: .normal)
            
            myUser?.myName = text
            UserManager.shared.update { user in
                user.myName = text
            }
        }
    }
    
    @objc func addImage(){
        let ctrl:UserEditCtrl = UserEditCtrl()
        self.navigationController?.pushViewController(ctrl, animated: true)
      
        
//        var config = YPImagePickerConfiguration()
//        // 允许使用相册和相机
//        config.screens = [.library, .photo]
//        
//        // 相册配置
//        config.library.mediaType = .photo
//        config.library.defaultMultipleSelection = true
//        config.library.maxNumberOfItems = 1
//        config.library.minNumberOfItems = 1
//        config.library.skipSelectionsGallery = true // 不进入编辑页
//        config.library.preSelectItemOnMultipleSelection = false
//        
//        // 拍照配置
//        config.onlySquareImagesFromCamera = false
//        config.usesFrontCamera = false
//        
//        // UI 优化
//        config.showsPhotoFilters = false
//        config.showsCrop = .none
//        config.hidesStatusBar = false
//        config.hidesBottomBar = false
//        
//        // 保存到相册（可选）
//        config.shouldSaveNewPicturesToAlbum = false
//        
//        let picker = YPImagePicker(configuration: config)
//        picker.didFinishPicking { [unowned picker] items, cancelled in
//            if cancelled {
//                picker.dismiss(animated: true)
//                return
//            }
//            
//            for item in items {
//                switch item {
//                case .photo(let photo):
//                    self.userBtn!.setImage(photo.image, for: .normal)
//                    saveUserImage(photo.image, fileName: "usericon.png")
//                    //通知更新
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeUserIconNotificationName), object: photo.image)
//                default: break
//                }
//            }
//            picker.dismiss(animated: true)
//        }
//        present(picker, animated: true, completion: nil)
    }
    
    //MARK: - vip续费升级
    @objc func setVip(){
        let ctrl:VIPCtrl = VIPCtrl()
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func setInfo(){
        print("设置用户信息")
//        let ctrl:UserEditCtrl = UserEditCtrl()
//        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let offsetY = scrollView.contentOffset.y
        
        let progress = min(max(offsetY / navigationHeight, 0), 1)

        tabbar.backgroundColor = .white.withAlphaComponent(min(max(progress, 0), 1))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
}
