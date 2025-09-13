//
//  main.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/28.
//

import UIKit
import CoreLocation
import SnapKit


class MainCtrl: BaseCtrl,UIScrollViewDelegate {
    
    private var didSetupCorner = false
    let tabbar:UIView = UIView()
    let fieldView:UIView = UIView()
    
    var scanimg:UIImageView?
    var searchimg:UIImageView?
    var serviceimg:UIImageView?
    var msgimg:UIImageView?
    
    let titlePage = TextPageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicScrollView.delegate = self
        basicScrollView.bounces = false
        
        self.addTopView()
    }
    
    
    //MARK: - 首页 第一次延迟展示水印 等广告结束
    override func isShowWater(){
        var showWater:Bool = true

        //获取服务器时间 计算是否到期
        if (myUser?.vip_level != .typeNoAction) && (myUser?.vip_time != .typeNotActivated){

            YcxHttpManager.getTimestamp() { msg,data,code  in
                if code == 1{
                    let currentTime:TimeInterval = TimeInterval(data)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  
                    print("服务器时间--\(currentTime)\n到期时间--\(myUser!.expiredDate)\n中文格式--\(formatter.string(from: Date(timeIntervalSince1970: myUser!.expiredDate)))")
                   
                    if myUser!.expiredDate > currentTime {
                        showWater = false
                    }
                    if showWater {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            KWindow?.addSubview(WaterMark)
                        }
                    }
                }else{
                    if showWater {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            KWindow?.addSubview(WaterMark)
                        }
                    }
                }
            }
        }else{
            if showWater {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    KWindow?.addSubview(WaterMark)
                }
            }
        }
    }
    
    override func setupUI() {
        super.setupUI()
        // 原来写在 viewDidLoad 的 UI 代码，挪到这里
        
        
//        let items = [
//            CarouselItem(image: UIImage(named: "tuijian-banner-2-1")!, title: "图片一"),
//            CarouselItem(image: UIImage(named: "tuijian-banner-2-2")!, title: "图片二"),
//            CarouselItem(image: UIImage(named: "tuijian-banner-2-3")!, title: "图片三"),
//            CarouselItem(image: UIImage(named: "tuijian-banner-2-4")!, title: "图片四")
//        ]
//        
//        let carousel = CarouselView(items: items)
//        view.addSubview(carousel)
//        
//        carousel.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.height.equalTo(240)
//            make.width.equalToSuperview()
//        }
        self.addView()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name:NSNotification.Name(rawValue: ChangeLanguageNotificationName), object: nil)
        
//        scheduleLocalNotification()
       
        //首次启动 警告
        if myUser?.isFirst == true {
            myUser?.isFirst = false
            UserManager.shared.update { user in
                user.isFirst = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                let remindView:FirstRmindView = FirstRmindView(frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
                KWindow?.addSubview(remindView)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let offsetY = scrollView.contentOffset.y
        
        let progress = min(max(offsetY / navigationHeight, 0), 1)

        tabbar.backgroundColor = .white.withAlphaComponent(min(max(progress, 0), 1))
        
        if progress >= 1 {
            titlePage.changeTextColor(Main_TextColor.withAlphaComponent(0.2))
            fieldView.layer.borderColor = Main_TextColor.withAlphaComponent(0.2).cgColor
            
            searchimg!.tintColor = Main_TextColor.withAlphaComponent(0.2)
            serviceimg!.tintColor = Main_TextColor
            msgimg!.tintColor = Main_TextColor
            scanimg!.tintColor = Main_TextColor
        }else{
            titlePage.changeTextColor(.white)
            fieldView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            
            searchimg!.tintColor = .white
            serviceimg!.tintColor = .white
            msgimg!.tintColor = .white
            scanimg!.tintColor = .white
        }
    }
    
    func addTopView(){
        view.addSubview(tabbar)
        tabbar.backgroundColor = .white.withAlphaComponent(0.0)
        
        tabbar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        
        tabbar.addSubview(fieldView)
        
        fieldView.addSubview(titlePage)
        fieldView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.width.equalTo(SCREEN_WDITH - 170)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(55)
        }
        
        searchimg = UIImageView(image: UIImage(named: "main_search")?.withRenderingMode(.alwaysTemplate))
        fieldView.addSubview(searchimg!)
        searchimg!.tintColor = .white
        
        searchimg!.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().inset(8)
        }

        scanimg = UIImageView(image: UIImage(named: "main_scan")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(scanimg!)
        scanimg!.tintColor = .white
        
        scanimg!.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(fieldView)
        }
        
        msgimg = UIImageView(image: UIImage(named: "main_msg_balck")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(msgimg!)
        msgimg!.tintColor = .white
        
        msgimg!.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(fieldView)
        }
        
        serviceimg = UIImageView(image: UIImage(named: "main_kehu")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(serviceimg!)
        serviceimg!.tintColor = .white
        
        serviceimg!.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.right.equalTo(msgimg!.snp.left).offset(-20)
            make.centerY.equalTo(fieldView)
        }
        
        let titles:Array<String> = ["银证转账","数币开通有礼"]
        
        titlePage.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.bottom.equalToSuperview()
            make.left.equalTo(searchimg!.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
        }

        self.view.layoutIfNeeded()
        
        titlePage.configure(with: titles)
        
        ViewBorderRadius(fieldView, 17, 0.8, UIColor.white.withAlphaComponent(0.2))
    }
    
    func addView(){
        var y:CGFloat = 0
        
        //head
        var iconStr:String = "main_head_1"
        
        let time:Int = Int(getCurrentTimeString(dateFormat: "dd")) ?? 0
        
        switch time {
        case 1..<16:
            iconStr = "main_head_1"
        case 16..<30:
            iconStr = "main_head_2"
        default:
            iconStr = "main_head_1"
        }
        
        let randomimage:UIImage = UIImage(named: iconStr) ?? UIImage()
        
        let randomImageV:UIImageView = UIImageView()
        randomImageV.image = randomimage
        
        let randomimageHigh:CGFloat = SCREEN_WDITH * (randomimage.size.height/randomimage.size.width)
        
        contentView.addSubview(randomImageV)
        
        randomImageV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(y)
            make.height.equalTo(randomimageHigh)
        }
        
        y = randomimageHigh
        //按钮区
        var image:UIImage = UIImage(named: "main_btns") ?? UIImage()
        
        var imageV:UIImageView = UIImageView()
        imageV.image = image
        
        var high:CGFloat = SCREEN_WDITH * (image.size.height/image.size.width)
        
        contentView.addSubview(imageV)
        
        imageV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(y)
            make.height.equalTo(high)
        }
        y+=high
        
        let carouselhigh:CGFloat = (SCREEN_WDITH - 30) * (274.0/1072)
        high = (SCREEN_WDITH - 30) * (210.0/1072)
        
        let bannerView:UIView = UIView()
        bannerView.backgroundColor = .white
        contentView.addSubview(bannerView)
        
        bannerView.snp.makeConstraints { make in
            make.height.equalTo(carouselhigh + high)
            make.width.equalTo(SCREEN_WDITH - 30)
            make.top.equalToSuperview().offset(y)
            make.left.equalToSuperview().offset(15)
        }
       
        
        image = UIImage(named: "main_banner_title") ?? UIImage()
        imageV = UIImageView()
        imageV.image = image
        bannerView.addSubview(imageV)
        
        imageV.snp.makeConstraints { make in
            make.height.equalTo(high)
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        //banner
        let imgs:Array<String> = ["main_banner1","main_banner2","main_banner3","main_banner4","main_banner5","main_banner6"]
        
        let carousel = ImagePageView()
        bannerView.addSubview(carousel)
        carousel.showPage(true)

        let bannertitles:Array<String> = ["盘前提示｜2025中国文化旅游产业博览会将举办，机构称旅游市场延续高景气",
                                    "5个月涨了70%多！创业板三年来再上3000点，这些股票带指数“飞呀飞”",
                                    "财经早班车｜商务部发声，全力稳住外贸基本盘"]
        
        
        let bannerTitle:TextPageView = TextPageView()
        imageV.addSubview(bannerTitle)
        
        bannerTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(20)
            make.left.equalToSuperview().inset(80)
            make.right.equalToSuperview().inset(60)
        }
        
        carousel.snp.makeConstraints { make in
            make.height.equalTo(carouselhigh)
            make.top.equalTo(imageV.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        y+=(high + carouselhigh)
        
        self.view.layoutIfNeeded()
        
        carousel.configure(with: imgs)
        
        bannerTitle.configure(with: bannertitles)
        bannerTitle.changeTextColor(Main_TextColor)
        bannerTitle.changeNumberOfLines(0)
        
        ViewRadius(bannerView, 4)
        
        
        //财富精选
        let titles:Array<String> = ["财富精选","热门活动","跨境服务",
                                    "热议话题","我的网点","个人养老金",
                                    "特色服务","消保学堂"]
        let details:Array<String> = ["精选产品 速来查看","精选好礼 等你来拿","全球签证 跨境易行",
                                     "更多话题 邀您参与","查看网点 就近办理","生活要好 备老要早",
                                     "","保护权益 防范风险"]

        
        let images:Array = ["main1","main2","main3","main4","main5","main6","main7","main8"]
        
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
                rightImageV.isHidden = true
            }
            
            
            let image:UIImage = UIImage(named: icon) ?? UIImage()
            
            let imageV:UIImageView = UIImageView()
            imageV.image = image
            
            let high:CGFloat = (SCREEN_WDITH - 30) * (image.size.height/image.size.width)
            contentView.addSubview(imageV)
            
            titlelb.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalToSuperview().offset(y + 4)
                make.height.equalTo(46)
            }
            
            rightImageV.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.centerY.equalTo(titlelb)
                make.width.height.equalTo(22)
            }
            
            detaillb.snp.makeConstraints { make in
                make.right.equalTo(rightImageV.snp.left).offset(3)
                make.centerY.equalTo(titlelb)
            }
    
            imageV.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(titlelb.snp.bottom)
                make.height.equalTo(high)
            }

            y+=(high + 50)
            
            //特色服务
            if i == 6 {
                let moreImage:UIImage = UIImage(named: "main7-1") ?? UIImage()
                
                let moreHigh:CGFloat = (SCREEN_WDITH - 30) * (moreImage.size.height/moreImage.size.width)
                
                let moreImageV:UIImageView = UIImageView()
                moreImageV.image = moreImage
                contentView.addSubview(moreImageV)
                
                moreImageV.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(15)
                    make.top.equalTo(imageV.snp.bottom).offset(8)
                    make.height.equalTo(moreHigh)
                }
                y+=(moreHigh + 8)
            }
        }
        
        image = UIImage(named: "main_bottom") ?? UIImage()
        high = SCREEN_WDITH * (image.size.height/image.size.width)
        
        let bottomImg:UIImageView = UIImageView(image:image)
        contentView.addSubview(bottomImg)
        
        bottomImg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(y + 20)
            make.left.right.equalToSuperview()
            make.height.equalTo(high)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomImg.snp.bottom)
        }
        
//        let transferBtn:UIButton = UIButton()
//        transferBtn.addTarget(self, action: #selector(gotoTransfer), for: .touchUpInside)
//        contentView.addSubview(transferBtn)
//        
//        let amountBtn:UIButton = UIButton()
//        amountBtn.addTarget(self, action: #selector(gotoMyAmount), for: .touchUpInside)
//        contentView.addSubview(amountBtn)
//        
//        let recordBtn:UIButton = UIButton()
//        recordBtn.addTarget(self, action: #selector(gotoRecordList), for: .touchUpInside)
//        contentView.addSubview(recordBtn)
//        
//        let wide:CGFloat = SCREEN_WDITH/4.0
//        
//        transferBtn.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-wide)
//            make.top.equalToSuperview().offset(navigationHeight)
//            make.width.equalTo(wide)
//            make.height.equalTo(80)
//        }
//        
//        amountBtn.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.top.equalToSuperview().offset(navigationHeight)
//            make.width.equalTo(wide)
//            make.height.equalTo(80)
//        }
//        
//        recordBtn.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(SCREEN_WDITH/5.0)
//            make.top.equalToSuperview().offset(randomimageHigh)
//            make.width.equalTo(SCREEN_WDITH/5.0)
//            make.height.equalTo(80)
//        }
    }
    
    
    @objc func gotoTransfer(){
        let ctrl:TransferCtrl = TransferCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func gotoMyAmount(){
        print("我的余额")
        let ctrl:MyAmountCtrl = MyAmountCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func gotoRecordList(){
        print("我的交易")
        let ctrl:TradeRecordListCtrl = TradeRecordListCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
}
