//
//  VIPCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/9/2.
//

import UIKit

class VIPCtrl: BaseCtrl {
    
    private var didSetupCorner = false
    
    var transferTimeBtn:UIButton?
    var transferFailBtn:UIButton?
    var pointsBtn:UIButton?//积分
    let customSwitch = CustomSwitch()
    let timelb = creatLabel(CGRect.zero, "未激活", fontRegular(14), Main_TextColor)
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        addHeadView()
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
        
        let leftButton:UIButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        var titles:Array<String> = ["自定义转账到达时间","自定义转账失败原因","余额负数"]

        
        let details:Array<Any> = [myUser!.transferArrivalTime,myUser!.transferFailHint,myUser!.isCut]
        
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
            rightimg.image = UIImage(named: "my_right")
            contentView.addSubview(rightimg)
            
            rightimg.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-15)
                make.centerY.equalTo(leftlb)
                make.width.height.equalTo(22)
            }
            
            switch i {
            case 0:
                transferTimeBtn = creatButton(CGRect.zero, details[i] as! String, fontRegular(12), fieldPlaceholderColor, .clear, self, #selector(isOpenVIPAction(button:)))
                transferTimeBtn?.tag = 1000
                transferTimeBtn?.titleLabel?.numberOfLines = 0
                contentView.addSubview(transferTimeBtn!)
                
                transferTimeBtn!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-5)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(50)
                    make.left.equalTo(leftlb.snp.right).offset(5)
                }
                
                transferTimeBtn!.contentHorizontalAlignment = .right  // 文字右对齐
            case 1:
                transferFailBtn = creatButton(CGRect.zero, details[i] as! String, fontRegular(12), fieldPlaceholderColor, .clear, self, #selector(isOpenVIPAction(button:)))
                transferFailBtn?.tag = 1001
                transferFailBtn?.titleLabel?.numberOfLines = 0
                contentView.addSubview(transferFailBtn!)
                
                transferFailBtn!.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-5)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(50)
                    make.left.equalTo(leftlb.snp.right).offset(5)
                }
                
                transferFailBtn!.contentHorizontalAlignment = .right  // 文字右对齐
            default:
                customSwitch.onTintColor = Main_Color // 开启时颜色
                customSwitch.offTintColor = HXColor(0xe6e6e6)      // 关闭时颜色
                customSwitch.thumbShadowEnabled = true // 是否显示阴影
                customSwitch.isOn = details[i] as! Bool              // 初始状态

                customSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
                contentView.addSubview(customSwitch)
                
                customSwitch.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-15)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(25)
                    make.width.equalTo(50)
                }
            }
            y += 50
        }
        
        
        let icon:UIImageView = UIImageView(image: UIImage(named: "zhaoshang"))
        contentView.addSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(y + 20)
        }
        
        let currentVersion:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
       
        let versionlb:UILabel = creatLabel(CGRect.zero, "版本\(currentVersion)", fontRegular(14), Main_TextColor)
        contentView.addSubview(versionlb)
        
        versionlb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(20)
        }
        
        var vipTypeStr:String = myUser!.vip_level.vipTypeStr
        
        if myUser!.vip_time != .typeNotActivated{
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let timeStr:String = dateFormatter.string(from: Date(timeIntervalSince1970: myUser!.expiredDate))
            vipTypeStr = "\(vipTypeStr)-到期时间-\(timeStr)"
        }else{
            vipTypeStr = "未激活"
        }
        
        timelb.text = vipTypeStr
        timelb.numberOfLines = 0
        timelb.textAlignment = .center
        contentView.addSubview(timelb)
        
        timelb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(versionlb.snp.bottom).offset(20)
        }
        
        titles = ["续费","升级到全功能"]
        if myUser?.vip_level == .typeAll {
            titles = ["续费"]
        }
        
        let stackView:UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(timelb.snp.bottom).offset(30)
            make.height.equalTo(48)
            make.left.right.equalToSuperview().inset(15)
        }
        
        
        for (i,str) in titles.enumerated() {
            let btn:UIButton = creatButton(CGRect.zero, str, fontRegular(16), .white, Main_Color, self, #selector(openVIP(button:)))
            btn.tag = 100 + i
            stackView.addArrangedSubview(btn)
            ViewRadius(btn, 24)
        }
        
        let exitBtn:UIButton = creatButton(CGRect.zero, "退出登录", fontRegular(16), .white, Main_Color, self, #selector(exitAcount))
        contentView.addSubview(exitBtn)
        
        exitBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(SCREEN_HEIGTH - tabBarHeight - 10)
        }
        
        ViewRadius(exitBtn, 24)
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(exitBtn.snp.bottom).offset(20)
        }
    }
    
    @objc func switchChanged(_ sender: CustomSwitch) {
        print("当前状态: \(sender.isOn)")
        
        myUser?.isCut = sender.isOn
        UserManager.shared.update { user in
            user.isCut = sender.isOn
        }
    }
    
    //MARK: - 退出登录 重启人脸识别
    @objc func exitAcount(){
        faceCheck = true
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 输入激活码
    @objc func openVIP(button:UIButton){
        
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "微信容易被封，购买激活码请联系qq")
        fieldview.showCopyNumber()
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            //激活码
            UserManager.shared.checkPermissions(token: text, isUpgrade: (button.tag == 101)) {
                if myUser?.vip_level != .typeNoAction && myUser?.vip_time != .typeNotActivated{
                    rootCtrl.switchToTab(index: 0)
                    //已激活
                    WaterMark.removeFromSuperview()
                    
                    var vipTypeStr:String = myUser!.vip_level.vipTypeStr
                    
                    if myUser!.vip_time != .typeNotActivated{
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        let timeStr:String = dateFormatter.string(from: Date(timeIntervalSince1970: myUser!.expiredDate))
                        vipTypeStr = "\(vipTypeStr)-到期时间-\(timeStr)"
                    }else{
                        vipTypeStr = "未激活"
                    }
                    
                    self.timelb.text = vipTypeStr
                }
            }
        }
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
//                            KWindow?.makeToast("需要升级会员", .center, .information)
//                        }else if myUser!.vip_level == .typeSVip || myUser!.vip_level == .typeAll{
//                            self.changeAllInfo(tag: button.tag)
//                        }
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
    
    //MARK: - 修改自定义转账到达时间
    @objc func changeTransferTimeTitle(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "自定义转账到达时间")
        fieldview.setKeyboardType(type: .default)
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            
            self.transferTimeBtn?.setTitle(text, for: .normal)
            
            myUser?.transferArrivalTime = text
            UserManager.shared.update { user in
                user.transferArrivalTime = text
            }
        }
    }
    
    //MARK: - 修改自定义转账失败原因
    @objc func changeTransferFailTitle(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "自定义转账失败原因")
        fieldview.setKeyboardType(type: .default)
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in

            self.transferFailBtn?.setTitle(text, for: .normal)
            
            myUser?.transferFailHint = text
            UserManager.shared.update { user in
                user.transferFailHint = text
            }
        }
    }
    
    func changeAllInfo(tag:Int){
        switch tag {
        case 1000:
            self.changeTransferTimeTitle()
        default:
            self.changeTransferFailTitle()
        }
    }
}
