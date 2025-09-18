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
    
    
    let tabbar:UIView = UIView()
    let fieldView:UIView = UIView()
    
    var loginimg:UIImageView?
    var serviceimg:UIImageView?
    var msgimg:UIImageView?
    var versionimg:UIImageView?
    
    let headView:UIView = UIView()
    var userBtn:UIButton?//头像
    var nameBtn:UIButton?//名字
    let manageimg:UIImageView = UIImageView()
    
    //我的账户
    let accountView:UIView = UIView()
    var quanyiBtn:UIButton?//权益
    var cardsBtn:UIButton?//银行卡数
    var managerlb:UILabel?
    
    //我的资产
    let billView:UIImageView = UIImageView()
    let showImage:UIImageView = UIImageView()
    var timelb:UILabel?
    var moneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    var incomeBtn:SecureLoadingLabel = SecureLoadingLabel()

    //本月收支
    let monthView:UIImageView = UIImageView()
    var incomeMoneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    var expenditureMoneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    let percentageLineView:PercentageLine = PercentageLine()
    
    //我的网点
    var branchView:UIImageView?
    var banklb:UILabel?
    var locBanklb:UILabel?
    var distancelb:UILabel?
    
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
        
        if faceCheck == true {
            // 未登录情况 强制登录
            showFacelogin()
        }
        
        //头像 名字
        if let avatar = loadUserImage(fileName: "usericon.png") {
            userBtn?.setImage(avatar, for: .normal)
        } else {
            userBtn?.setImage(UIImage(named: "user_default"), for: .normal)
        }
        nameBtn?.setTitle(String(format: "**%@", String(myUser!.myName.suffix(1))), for: .normal)
        
        //银行卡 待办 卡券 积分
        cardsBtn?.setTitle("\(myCardList.count)", for: .normal)
        quanyiBtn?.setTitle("\(myUser?.myWorks ?? 0)", for: .normal)
        
        //账户总览
        moneyBtn.text = String(format: "%@¥ %@",(myUser!.isCut ? "-":""), getNumberFormatter(myUser?.myBalance ?? 0.00))
        incomeBtn.text = String(format: "¥ %@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        
        //本月收支
        expenditureMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.myMonthCost ?? 0.00))
        incomeMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.myMonthIncome ?? 0.00))
        uploadPercentageLineView()
        
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
        addTopView()
        
        addHeadInfoView()
        
        addMyAccountView()
        
        addBillOverView()
        
        addMonthView()
       
        addBottomView()
        
        addBranchView()
    }
    
    //导航栏
    func addTopView(){
        view.addSubview(tabbar)
        tabbar.backgroundColor = .white.withAlphaComponent(0.0)
        
        tabbar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        
        loginimg = UIImageView(image: UIImage(named: "head_exit1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(loginimg!)
        loginimg!.tintColor = .white
        loginimg!.isUserInteractionEnabled = true
        
        loginimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview()
        }
        
        msgimg = UIImageView(image: UIImage(named: "head_msg1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(msgimg!)
        msgimg!.tintColor = .white
        
        msgimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalTo(loginimg!)
        }
        
        serviceimg = UIImageView(image: UIImage(named: "head_kf1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(serviceimg!)
        serviceimg!.tintColor = .white
        
        serviceimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.right.equalTo(msgimg!.snp.left).offset(-3)
            make.centerY.equalTo(loginimg!)
        }
        
        versionimg = UIImageView(image: UIImage(named: "head_set1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(versionimg!)
        versionimg!.tintColor = .white
        
        versionimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.right.equalTo(serviceimg!.snp.left).offset(-3)
            make.centerY.equalTo(loginimg!)
        }
        
        tabbar.addSubview(fieldView)
        fieldView.backgroundColor = .white
   
        fieldView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.right.equalTo(versionimg!.snp.left).offset(-5)
            make.centerY.equalTo(loginimg!)
            make.left.equalToSuperview().inset(52)
        }
        
        
        let searchimg:UIImageView = UIImageView(image: UIImage(named: "head_search"))
        fieldView.addSubview(searchimg)
        
        searchimg.snp.makeConstraints { make in
            make.height.width.equalTo(16)
            make.left.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(9)
        }

        let soundimg:UIImageView = UIImageView(image: UIImage(named: "head_sound"))
        fieldView.addSubview(soundimg)
        
        soundimg.snp.makeConstraints { make in
            make.width.equalTo(16)
            make.height.equalTo(22)
            make.right.equalToSuperview().inset(10)
            make.centerY.equalTo(searchimg)
        }
        
        let fieldlb:UILabel = creatLabel(CGRect.zero, "超值大赢家", fontRegular(14), Main_TextColor)
        fieldView.addSubview(fieldlb)
        
        fieldlb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(searchimg.snp.right).offset(10)
            make.centerY.equalTo(searchimg)
        }
        
        ViewRadius(fieldView, 17)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFacelogin))
        loginimg?.addGestureRecognizer(tap)
    }
    
    @objc func showFacelogin(){
        //人脸识别
        let ctrl = FaceRecognitionCtrl()
        ctrl.faceRecognitionSuccess = { [weak self] in
            faceCheck = false
            
            self?.moneyBtn.show()
            self?.incomeBtn.show()

            self?.incomeMoneyBtn.show()
            self?.expenditureMoneyBtn.show()
        }
        self.navigationController?.pushViewController(ctrl, animated: true)

        ctrl.authenticateWithFaceID()
    }
    
    
    //MARK: - 用户信息
    func addHeadInfoView(){
        headView.backgroundColor = Main_Color
        contentView.insertSubview(headView, at: 0)
        
        userBtn = UIButton()
        userBtn?.imageView?.contentMode = .scaleAspectFill
        headView.addSubview(userBtn!)
        userBtn?.addTarget(self, action: #selector(addImage), for: .touchUpInside)
               
        if let avatar = loadUserImage(fileName: "usericon.png") {
            userBtn?.setImage(avatar, for: .normal)
        } else {
            userBtn?.setImage(UIImage(named: "user_default"), for: .normal)
        }
        
        var timeStr = "上午好"
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        if hour >= 14 && hour <= 18 {
            timeStr = "下午好"
        } else if hour >= 11 && hour <= 14{
            timeStr = "中午好"
        } else if hour >= 5 && hour <= 11{
            timeStr = "早上好"
        }else{
            timeStr = "晚上好"
        }
        
        nameBtn = creatButton(CGRect.zero, String(format: "%@，**%@",timeStr, String(myUser!.myName.suffix(1))), fontSemibold(18), .white, .clear, self, #selector(changeName))
        headView.addSubview(nameBtn!)
        
        let time:String = getCurrentTimeString(dateFormat: "yyyy/MM/dd HH:mm:ss")
        
        let infolb:UILabel = UILabel()
        infolb.font = fontRegular(10)
        infolb.text = "上次登录:\(time)"
        infolb.textColor = .white
        headView.addSubview(infolb)
        
        let licaiimg:UIImage = UIImage(named: "my_manage") ?? UIImage()
        let high:CGFloat = SCREEN_WDITH * (licaiimg.size.height/licaiimg.size.width)
        
        manageimg.image = licaiimg
        contentView.addSubview(manageimg)

        
        headView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(160 + navigationHeight)
        }
       
        userBtn?.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20 + navigationHeight)
        }
        
        nameBtn?.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(userBtn!.snp.right).offset(15)
            make.top.equalTo(userBtn!).offset(10)
        }
        
        infolb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(nameBtn!)
            make.top.equalTo(nameBtn!.snp.bottom).offset(2)
        }
        
        manageimg.snp.makeConstraints { make in
            make.height.equalTo(high)
            make.left.right.equalToSuperview()
            make.top.equalTo(headView.snp.bottom).offset(-50)
        }
        ViewRadius(userBtn!, 30)
    }
    
    //MARK: - 我的账户
    func addMyAccountView(){
        let img:UIImage = UIImage(named: "my_daiban") ?? UIImage()
        let high:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
        
        let daibanImg:UIImageView = UIImageView()
        daibanImg.image = img
        contentView.addSubview(daibanImg)
        
        daibanImg.snp.makeConstraints { make in
            make.height.equalTo(high)
            make.left.right.equalToSuperview()
            make.top.equalTo(manageimg.snp.bottom)
        }
        
        accountView.backgroundColor = .white
        contentView.addSubview(accountView)
        
        accountView.snp.makeConstraints { make in
            make.height.equalTo(170)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(daibanImg.snp.bottom).offset(20)
        }
        
        let titles:Array<String> = ["\(myUser!.myCards)","\(myUser!.myWorks)","my_money_btn","my_game_btn"]
        let details:Array<String> = ["我的账户","我的权益","我的积分","我的游戏"]
        let wide:CGFloat = (SCREEN_WDITH - 30)/4.0
        
        for (i,str) in details.enumerated() {
            let detaillb:UILabel = creatLabel(CGRect.zero, str, fontRegular(13), Main_TextColor)
            detaillb.textAlignment = .center
            accountView.addSubview(detaillb)
            
            detaillb.snp.makeConstraints { make in
                make.width.equalTo(wide)
                make.height.equalTo(14)
                make.left.equalToSuperview().offset(wide * Double(i))
                make.top.equalToSuperview().offset(65)
            }
            
            if i == 0 {
                cardsBtn = creatButton(CGRect.zero, titles[i], fontRegular(24), Main_TextColor, .clear, self, #selector(setCards))
                accountView.addSubview(cardsBtn!)
                
                cardsBtn!.snp.makeConstraints { make in
                    make.width.equalTo(wide)
                    make.height.equalTo(40)
                    make.centerX.equalTo(detaillb)
                    make.bottom.equalTo(detaillb.snp.top).offset(-7)
                }
            }else if(i == 1){
                quanyiBtn = creatButton(CGRect.zero, titles[i], fontRegular(24), Main_TextColor, .clear, self, #selector(setCards))
                accountView.addSubview(quanyiBtn!)
                
                quanyiBtn!.snp.makeConstraints { make in
                    make.width.equalTo(wide)
                    make.height.equalTo(40)
                    make.centerX.equalTo(detaillb)
                    make.bottom.equalTo(detaillb.snp.top).offset(-7)
                }
            }else{
                let imgbtn:UIImageView = UIImageView()
                imgbtn.image = UIImage(named: titles[i])
                accountView.addSubview(imgbtn)
                
                imgbtn.snp.makeConstraints { make in
                    make.height.width.equalTo(44)
                    make.centerX.equalTo(detaillb)
                    make.centerY.equalTo(cardsBtn!)
                }
            }
        }
        
        let managerView:UIView = UIView()
        managerView.backgroundColor = HXColor(0xf9f9f9)
        accountView.addSubview(managerView)
        
        managerView.snp.makeConstraints { make in
            make.height.equalTo(46)
            make.bottom.equalToSuperview().offset(-18)
            make.left.right.equalToSuperview().inset(7)
        }
        
        let managerimg:UIImageView = UIImageView(image: UIImage(named: "my_manager_default"))
        managerView.addSubview(managerimg)
        
        managerimg.snp.makeConstraints { make in
            make.height.width.equalTo(34)
            make.top.bottom.equalToSuperview().inset(6)
            make.left.equalToSuperview().inset(15)
        }
        
        managerlb = creatLabel(CGRect.zero, "哈吉米", fontSemibold(16), Main_TextColor)
        managerView.addSubview(managerlb!)
        
        managerlb!.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.left.equalTo(managerimg.snp.right).offset(15)
        }
        
        let rightImageV:UIImageView = UIImageView(image: UIImage(named: "my_right"))
        managerView.addSubview(rightImageV)
        
        rightImageV.snp.makeConstraints { make in
            make.width.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        
        let detaillb:UILabel = creatLabel(CGRect.zero, "我的客户经理", fontRegular(15), Main_detailColor)
        managerView.addSubview(detaillb)
        detaillb.snp.makeConstraints { make in
            make.right.equalTo(rightImageV.snp.left).offset(-3)
            make.centerY.equalToSuperview()
        }
        
        self.view.layoutIfNeeded()
        
        setupViewWithRoundedCornersAndShadow(
            accountView,
            radius: 10.0,
            corners: [.topLeft, .topRight , .bottomLeft,.bottomRight], // 示例: 左上+右下圆角
            borderWidth: 0,
            borderColor: .white,
            shadowColor: .lightGray, // 浅灰色阴影
            shadowRadius: 10,         // 柔和扩散效果
            shadowOpacity: 0.2       // 浅色透明度
        )
        
        ViewRadius(managerView, 4)
    }
    
    //MARK: - 我的资产
    func addBillOverView(){
        var titlelb:UILabel = creatLabel(CGRect.zero, "我的资产", fontSemibold(18), Main_TextColor)
        contentView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(accountView.snp.bottom).offset(8)
            make.height.equalTo(42)
        }
        
        showImage.image = UIImage(named: "caifu_hide")
        showImage.contentMode = .scaleAspectFill
        contentView.addSubview(showImage)
        
        showImage.snp.makeConstraints { make in
            make.centerY.equalTo(titlelb)
            make.left.equalTo(titlelb.snp.right).offset(10)
            make.height.equalTo(14)
            make.width.equalTo(21)
        }
        
        let showBtn:UIButton = UIButton()
        showBtn.backgroundColor = .clear
        showBtn.addTarget(self, action: #selector(showMoney(button:)), for: .touchUpInside)
        showBtn.isSelected = false
        contentView.addSubview(showBtn)
        
        showBtn.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.left.centerY.equalTo(showImage)
        }
        
        let rightImage:UIImageView = UIImageView(image: UIImage(named: "my_refresh")?.withRenderingMode(.alwaysTemplate))
        rightImage.tintColor = .black
        contentView.addSubview(rightImage)
        
        rightImage.snp.makeConstraints { make in
            make.centerY.equalTo(titlelb)
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(25)
        }
        
        timelb = creatLabel(CGRect.zero, getCurrentTimeString(dateFormat: "yyyy/MM/dd HH:mm:ss"), fontRegular(12), Main_detailColor)
        contentView.addSubview(timelb!)
        
        timelb!.snp.makeConstraints { make in
            make.centerY.equalTo(titlelb)
            make.right.equalTo(rightImage.snp.left).offset(-5)
            make.height.equalTo(14)
        }
        
        let bgimage:UIImage = UIImage(named: "my_money_bg") ?? UIImage()
        let high:CGFloat = bgimage.size.height/bgimage.size.width * (SCREEN_WDITH - 30)
        
        billView.image = bgimage
        contentView.addSubview(billView)
        
        billView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(titlelb.snp.bottom)
            make.height.equalTo(high)
        }
        
        titlelb = creatLabel(CGRect.zero, "资产", fontRegular(14), Main_detailColor)
        billView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(22)
            make.height.equalTo(14)
        }
        
        var rightImageV:UIImageView = UIImageView(image: UIImage(named: "my_right"))
        billView.addSubview(rightImageV)
        
        rightImageV.snp.makeConstraints { make in
            make.width.height.equalTo(14)
            make.centerY.equalTo(titlelb)
            make.left.equalTo(titlelb.snp.right).offset(5)
        }
        
        
        let moneyimg:UIImageView = UIImageView(image: UIImage(named: "my_money_title"))
        billView.addSubview(moneyimg)
        
        moneyimg.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.width.equalTo(48)
            make.centerY.equalTo(titlelb)
            make.left.equalTo(rightImageV.snp.right).offset(5)
        }
        
        rightImageV = UIImageView(image: UIImage(named: "my_right"))
        billView.addSubview(rightImageV)
        
        rightImageV.snp.makeConstraints { make in
            make.width.height.equalTo(14)
            make.centerY.equalTo(titlelb)
            make.right.equalToSuperview().offset(-15)
        }
        
        titlelb = creatLabel(CGRect.zero, "昨日收益", fontRegular(14), Main_detailColor)
        billView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.right.equalTo(rightImageV.snp.left).offset(-2)
            make.centerY.equalTo(moneyimg)
            make.height.equalTo(14)
        }
        
        moneyBtn.text =  String(format: "¥ %@", getNumberFormatter(myUser?.myBalance ?? 0.00))
        moneyBtn.isSecureText = false
        moneyBtn.font = fontNumber(25)
        moneyBtn.textAlignment = .left
        billView.addSubview(moneyBtn)
        
        incomeBtn.text =  String(format: "¥ %@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        incomeBtn.isSecureText = false
        incomeBtn.font = fontNumber(25)
        incomeBtn.textAlignment = .right
        billView.addSubview(incomeBtn)
        
        incomeBtn.setPosition(position: .right)
        
        moneyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(35)
            make.top.equalTo(titlelb.snp.bottom).offset(13)
        }
        
        incomeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.top.equalTo(moneyBtn)
        }
        
        self.view.layoutIfNeeded()
        
        setupViewWithRoundedCornersAndShadow(
            billView,
            radius: 10.0,
            corners: [.topLeft, .topRight , .bottomLeft,.bottomRight], // 示例: 左上+右下圆角
            borderWidth: 0,
            borderColor: .white,
            shadowColor: .lightGray, // 浅灰色阴影
            shadowRadius: 10,         // 柔和扩散效果
            shadowOpacity: 0.2       // 浅色透明度
        )
    }
    
    //MARK: - 本月收支
    func addMonthView(){
        var titlelb:UILabel = creatLabel(CGRect.zero, "本月收支", fontSemibold(18), Main_TextColor)
        contentView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(billView.snp.bottom).offset(8)
            make.height.equalTo(42)
        }
        
        let bgimage:UIImage = UIImage(named: "my_money_bg") ?? UIImage()
        let high:CGFloat = bgimage.size.height/bgimage.size.width * (SCREEN_WDITH - 30)
        
        monthView.image = bgimage
        contentView.addSubview(monthView)
        
        monthView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(titlelb.snp.bottom)
            make.height.equalTo(high)
        }
        
        titlelb = creatLabel(CGRect.zero, "收入", fontRegular(14), Main_detailColor)
        monthView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(22)
            make.height.equalTo(14)
        }
        
        titlelb = creatLabel(CGRect.zero, "支出", fontRegular(14), Main_detailColor)
        monthView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(22)
            make.height.equalTo(14)
        }
        
        incomeMoneyBtn.text = String(format: "¥ %@", getNumberFormatter(myUser?.myMonthIncome ?? 0.00))
        incomeMoneyBtn.isSecureText = false
        incomeMoneyBtn.font = fontNumber(25)
        incomeMoneyBtn.textAlignment = .left
        monthView.addSubview(incomeMoneyBtn)
        
        expenditureMoneyBtn.text =  String(format: "¥ %@", getNumberFormatter(getIncome(aomunt: myUser!.myMonthCost)))
        expenditureMoneyBtn.isSecureText = false
        expenditureMoneyBtn.font = fontNumber(25)
        expenditureMoneyBtn.textAlignment = .right
        monthView.addSubview(expenditureMoneyBtn)
        
        expenditureMoneyBtn.setPosition(position: .right)
        monthView.addSubview(percentageLineView)
        
        incomeMoneyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(35)
            make.top.equalTo(titlelb.snp.bottom).offset(13)
        }
        
        expenditureMoneyBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.top.equalTo(incomeMoneyBtn)
        }

        percentageLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(5)
        }
        
        self.view.layoutIfNeeded()
        
        setupViewWithRoundedCornersAndShadow(
            monthView,
            radius: 10.0,
            corners: [.topLeft, .topRight , .bottomLeft,.bottomRight], // 示例: 左上+右下圆角
            borderWidth: 0,
            borderColor: .white,
            shadowColor: .lightGray, // 浅灰色阴影
            shadowRadius: 10,         // 柔和扩散效果
            shadowOpacity: 0.2       // 浅色透明度
        )
        uploadPercentageLineView()
    }
    
    func uploadPercentageLineView(){
        if myUser?.myMonthCost == 0.0 {
            percentageLineView.updateRatio(0.0)
        }else{
            let ratio:CGFloat =  (myUser?.myMonthCost ?? 0.0) / ((myUser?.myMonthCost ?? 0.0) + (myUser?.myMonthIncome ?? 0.0))
            percentageLineView.updateRatio(ratio)
        }
    }
    
    //MARK: - 网点
    func addBranchView(){
        banklb = creatLabel(CGRect.zero, "新加坡机场支行", fontSemibold(16), Main_TextColor)
        banklb?.numberOfLines = 0
        branchView?.addSubview(banklb!)
        
        banklb!.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(18)
        }
        
        let rightimg:UIImageView = UIImageView(image: UIImage(named: "my_right_black") ?? UIImage())
        branchView?.addSubview(rightimg)
        
        rightimg.snp.makeConstraints { make in
            make.height.width.equalTo(12)
            make.left.equalTo(banklb!.snp.right).offset(2)
            make.centerY.equalTo(banklb!)
        }
        
        distancelb = creatLabel(CGRect.zero, "距离 10km", fontRegular(12), Main_TextColor)
        branchView?.addSubview(distancelb!)
        
        distancelb!.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-46)
        }
        
        let nearbylb:UILabel = creatLabel(CGRect.zero, " 离你最近  ", fontRegular(12), Main_TextColor)
        nearbylb.backgroundColor = .white
        nearbylb.textAlignment = .center
        branchView?.addSubview(nearbylb)
        
        nearbylb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.equalTo(distancelb!.snp.right).offset(5)
            make.centerY.equalTo(distancelb!)
        }
        
        locBanklb = creatLabel(CGRect.zero, "中国北京机场***********************************商铺单元", fontRegular(14), Main_detailColor)
        locBanklb!.numberOfLines = 2
        branchView?.addSubview(locBanklb!)
        
        locBanklb!.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.top.equalTo(banklb!.snp.bottom).offset(10)
        }
        
        ViewRadius(nearbylb, 4)
    }
    
    //MARK: - 底部图片
    func addBottomView(){
        var y:CGFloat = 8

        let titles:Array<String> = ["我的网点","更多服务"]
        let details:Array<String> = ["查看网点 就近办理",""]

        
        let images:Array = ["my_loc_card","my_bottom"]
        
        for (i, icon) in images.enumerated() {
            let titlelb:UILabel = creatLabel(CGRect.zero, titles[i], fontSemibold(18), Main_TextColor)
            titlelb.textAlignment = .left
            contentView.addSubview(titlelb)
            
            
            let rightImageV:UIImageView = UIImageView(image: UIImage(named: "my_right"))
            contentView.addSubview(rightImageV)
            
            let detaillb:UILabel = creatLabel(CGRect.zero, details[i], fontRegular(14), Main_detailColor)
            detaillb.textAlignment = .right
            contentView.addSubview(detaillb)
            
            if details[i].count == 0 {
                detaillb.isHidden = true
                rightImageV.isHidden = true
            }
            
            let image:UIImage = UIImage(named: icon) ?? UIImage()
            
            let imageV:UIImageView = UIImageView()
            imageV.image = image
            
            let high:CGFloat = (SCREEN_WDITH - 30) * (image.size.height/image.size.width)
            contentView.addSubview(imageV)
            
            titlelb.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(monthView.snp.bottom).offset(y)
                make.height.equalTo(42)
            }
            
            rightImageV.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.centerY.equalTo(titlelb)
                make.width.height.equalTo(14)
            }
            
            detaillb.snp.makeConstraints { make in
                make.right.equalTo(rightImageV.snp.left)
                make.centerY.equalTo(titlelb)
            }
    
            imageV.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset((i == images.count - 1) ? 0:15)
                make.top.equalTo(titlelb.snp.bottom)
                make.height.equalTo(high)
            }

            if i == 0 {
                branchView = imageV
            }
            y+=(high + 50)
        }
        
        let bottomView:UIView = UIView()
        bottomView.backgroundColor = Main_backgroundColor
        contentView.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalTo(200)
            make.top.equalTo(monthView.snp.bottom).offset(y - 10)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomView.snp.bottom).offset(-150)
        }
    }
    
    @objc func setCards(){
        
    }
    
    @objc func changeMyMoney(){
        let ctrl:MyAmountCtrl = MyAmountCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func showMoney(button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected {
            showImage.image = UIImage(named: "caifu_hide")
        }else{
            showImage.image = UIImage(named: "caifu_show")
        }
        incomeMoneyBtn.isSecureText = button.isSelected
        expenditureMoneyBtn.isSecureText = button.isSelected
        
        moneyBtn.isSecureText = button.isSelected
        incomeBtn.isSecureText = button.isSelected
    }
    
    @objc func changeMonthIncome(){
        let ctrl:TradeRecordListCtrl = TradeRecordListCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func changeMyExpenses(){
        let ctrl:TradeRecordListCtrl = TradeRecordListCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
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
        
        if progress >= 1 {
            fieldView.backgroundColor = Main_backgroundColor
            
            serviceimg!.tintColor = Main_TextColor
            msgimg!.tintColor = Main_TextColor
            loginimg!.tintColor = Main_TextColor
            versionimg!.tintColor = Main_TextColor
        }else{
            
            serviceimg!.tintColor = .white
            msgimg!.tintColor = .white
            loginimg!.tintColor = .white
            versionimg!.tintColor = .white
            
            fieldView.backgroundColor = .white
        }
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
