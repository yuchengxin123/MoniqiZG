//
//  wealthCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/28.
//

import UIKit
import SnapKit

class WealthCtrl: BaseCtrl,UIScrollViewDelegate {
    
    private var didSetupCorner = false
    let tabbar:UIView = UIView()
    let fieldView:UIView = UIView()
    
    var serviceimg:UIImageView?
    var shopimg:UIImageView?
    
    let wealthlb:UILabel = UILabel()

    var moneyWidth:CGFloat = 15
    let mymoneylb:UILabel = creatLabel(CGRect.zero, "总资产(折算人民币元)", fontRegular(12), .white)
    //账户总览
    let billView:UIImageView = UIImageView()
    let showImage:UIImageView = UIImageView()
    var moneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    var incomeBtn:SecureLoadingLabel = SecureLoadingLabel()
    
    let loopView = AutoLoopCustomView(direction: .vertical)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTopView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let number:String = String(format: "%@", getNumberFormatter(myUser!.myBalance))
        self.moneyBtn.text = number
        
        let incomeNumber:String = String(format: "%@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        self.incomeBtn.text = incomeNumber
    }
    
    override func setupUI() {
        super.setupUI()
        
        addView()
        NotificationCenter.default.addObserver(self, selector: #selector(changeMyBalanceNotification(noti:)), name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeMyIncomeNotification(noti:)), name: NSNotification.Name(rawValue: changeMyIncomeNotificationName), object: nil)
    }
    
    @objc func changeMyBalanceNotification(noti:NSNotification){
        let str:String = (noti.object ?? "") as! String
        let number:String = String(format: "%@", getNumberFormatter(Double(str) ?? 0.00))
        self.moneyBtn.text = number
        
        let incomeNumber:String = String(format: "%@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        self.incomeBtn.text = incomeNumber
    }
    
    @objc func changeMyIncomeNotification(noti:NSNotification){
        let str:String = (noti.object ?? "") as! String
        let number:String = String(format: "%@", getNumberFormatter(Double(str) ?? 0.00))

        self.incomeBtn.text = number
    }
    
    
    func addTopView(){
        view.addSubview(tabbar)
        tabbar.backgroundColor = .white
        
        tabbar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        
        serviceimg = UIImageView(image: UIImage(named: "head_kf1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(serviceimg!)
        serviceimg!.tintColor = .black
        
        serviceimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview()
        }
        
        shopimg = UIImageView(image: UIImage(named: "head_shop")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(shopimg!)
        shopimg!.tintColor = .black
        
        shopimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.right.equalTo(serviceimg!.snp.left).offset(-5)
            make.bottom.equalToSuperview()
        }
        
        tabbar.addSubview(fieldView)
        fieldView.backgroundColor = Main_backgroundColor
   
        fieldView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.right.equalTo(shopimg!.snp.left).offset(-5)
            make.centerY.equalTo(serviceimg!)
            make.left.equalToSuperview().inset(15)
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
    }
    
    func addView(){
        var y:CGFloat = navigationHeight + 15
        
        
        let imgbg:UIImage = UIImage(named: "caifu_money_bg") ?? UIImage()
        
        var high:CGFloat = (SCREEN_WDITH - 30) * (imgbg.size.height/imgbg.size.width)
        
        billView.image = imgbg
        contentView.addSubview(billView)
        
        billView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(y)
            make.height.equalTo(high)
        }
        y+=high
        
        
        //按钮区
        let image:UIImage = UIImage(named: "caifu_btns") ?? UIImage()
        
        let btnsimageV:UIImageView = UIImageView()
        btnsimageV.image = image
        
        high = SCREEN_WDITH * (image.size.height/image.size.width)
        
        contentView.addSubview(btnsimageV)
        
        btnsimageV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(y)
            make.height.equalTo(high)
        }
        y+=high
        
        //MARK: - 标题
        contentView.addSubview(loopView)
        loopView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(y + 10)
            make.left.right.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        
        let rightImageV:UIImageView = UIImageView(image: UIImage(named: "my_right"))
        contentView.addSubview(rightImageV)
        
        rightImageV.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(loopView)
            make.width.height.equalTo(22)
        }
        loopView.layoutIfNeeded()
   
        let looptitles:Array<Array<String>> = [
            ["深证指数","13005.77","81.64   0.63%","1"],
            ["上证指数","3860.50","-10.10   -0.26%","0"],
            ["创业指板","3066.18","45.76   1.52%","1"],
            ["上证50","2962.62","-5.92   -0.20%","0"],
            ["沪深300","4533.06","11.06   0.24%","1"],
            ["中小100","7940.33","60.16   0.76%","1"],
            ["深证指数","13005.77","81.64   0.63%","1"],
            ["上证指数","3860.50","-10.10   -0.26%","0"]]
        
        var customViews: [UIView] = []
        
        for array in looptitles {
            let item = createBottomLable(array)
            customViews.append(item)
        }
        loopView.configure(with:customViews)
        
        y+=50
        
        //MARK: - banner
        high = (SCREEN_WDITH - 30) * (612.0/1076.0)
        
        let imgs:Array<String> = ["caifu_banner1","caifu_banner2","caifu_banner3","caifu_banner4"]
        
        let carousel = ImagePageView()
        contentView.addSubview(carousel)
        carousel.showPage(true)

        
        carousel.snp.makeConstraints { make in
            make.height.equalTo(high)
            make.width.equalTo(SCREEN_WDITH - 30)
            make.top.equalToSuperview().offset(y)
            make.left.equalToSuperview().offset(15)
        }
        
        y+=(high + 20)
        
        self.view.layoutIfNeeded()
        
        carousel.configure(with: imgs)
        
        ViewRadius(carousel, 4)
        
        
        //财富精选
        let titles:Array<String> = ["按期理财","热门主题","轻松配置“四笔钱”",
                                    "热议活动","机构观点","资讯"]

        
        let images:Array = ["caifu1","caifu2","caifu3","caifu4","caifu5","caifu6"]
        
        for (i, icon) in images.enumerated() {
            let titlelb:UILabel = creatLabel(CGRect.zero, titles[i], fontSemibold(18), Main_TextColor)
            titlelb.textAlignment = .left
            contentView.addSubview(titlelb)
            
            
            let rightImageV:UIImageView = UIImageView(image: UIImage(named: "my_right"))
            contentView.addSubview(rightImageV)
            
            
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
            

    
            imageV.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(titlelb.snp.bottom)
                make.height.equalTo(high)
            }

            y+=(high + 50)
            

            if i != 0 {
                let detaillb:UILabel = creatLabel(CGRect.zero, "更多", fontRegular(14), Main_detailColor)
                detaillb.textAlignment = .right
                contentView.addSubview(detaillb)
                
                detaillb.snp.makeConstraints { make in
                    make.right.equalTo(rightImageV.snp.left).offset(3)
                    make.centerY.equalTo(titlelb)
                }
            }
            
            //特色服务
            if i == 1 || i == 5 {
                let moreImage:UIImage = UIImage(named: "\(icon)-1") ?? UIImage()
                
                let moreHigh:CGFloat = (SCREEN_WDITH - 30) * (moreImage.size.height/moreImage.size.width)
                
                let moreImageV:UIImageView = UIImageView()
                moreImageV.image = moreImage
                contentView.addSubview(moreImageV)
                
                moreImageV.snp.makeConstraints { make in
                    make.left.right.equalToSuperview().inset(15)
                    make.top.equalTo(imageV.snp.bottom).offset(8)
                    make.height.equalTo(moreHigh)
                }
                y+=moreHigh
            }
            
            if i == 0 {
                let high:CGFloat = (SCREEN_WDITH - 30) * (275.0/1075)
                
                let imgs:Array<String> = ["caifu_center1","caifu_center2","caifu_center3","caifu_center4","caifu_center5"]
                
                let carousel = ImagePageView()
                contentView.addSubview(carousel)
                carousel.showPage(true)
     
                carousel.snp.makeConstraints { make in
                    make.height.equalTo(high)
                    make.width.equalTo(SCREEN_WDITH - 30)
                    make.top.equalTo(imageV.snp.bottom).offset(10)
                    make.left.equalToSuperview().offset(15)
                }
                
                self.view.layoutIfNeeded()
                
                carousel.configure(with: imgs)
                
                y+=(high + 15)
            }
        }
        
        let bottomView:UIView = UIView()
        bottomView.backgroundColor = Main_backgroundColor
        contentView.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalTo(100)
            make.top.equalToSuperview().offset(y)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomView.snp.bottom).offset(-50)
        }
        
        addBillContentView()
    }
    
    func addBillContentView(){
        billView.isUserInteractionEnabled = true

        moneyBtn.textAlignment = .left
        moneyBtn.textColor = .white
        moneyBtn.font = fontNumber(30)
        billView.addSubview(moneyBtn)
        
        
        showImage.image = UIImage(named: "caifu_hide")
        billView.addSubview(showImage)
        
        let showBtn:UIButton = UIButton()
        showBtn.backgroundColor = .clear
        showBtn.addTarget(self, action: #selector(showMoney(button:)), for: .touchUpInside)
        showBtn.isSelected = true
        billView.addSubview(showBtn)
        
        incomeBtn.isSecureText = true
        incomeBtn.textColor = .white
        incomeBtn.font = fontNumber(30)
        incomeBtn.text = getNumberFormatter(getIncome(aomunt: myUser!.myBalance))
        incomeBtn.textAlignment = .right
        billView.addSubview(incomeBtn)
        
        billView.addSubview(mymoneylb)
        
        let rightimg:UIImageView = UIImageView(image: UIImage(named: "right_white"))
        billView.addSubview(rightimg)
        
        let incomelb = creatLabel(CGRect.zero, "昨日收益(元)", fontRegular(12), .white)
        billView.addSubview(incomelb)
        
        
        moneyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(mymoneylb.snp.bottom).offset(15)
            make.height.equalTo(30)
        }
        
        
        mymoneylb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(25)
            make.height.equalTo(25)
        }
        
        rightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(moneyBtn).offset(-5)
            make.width.height.equalTo(20)
        }
        
        incomelb.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(mymoneylb)
            make.height.equalTo(25)
        }
        
        showImage.snp.makeConstraints { make in
            make.centerY.equalTo(mymoneylb)
            make.left.equalTo(mymoneylb.snp.right).offset(10)
            make.height.equalTo(14)
            make.width.equalTo(21)
        }
        
        showBtn.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.left.centerY.equalTo(showImage)
        }
        
        incomeBtn.snp.makeConstraints { make in
            make.right.equalTo(rightimg.snp.left)
            make.centerY.equalTo(moneyBtn)
            make.height.equalTo(30)
        }
        
        ViewRadius(billView, 10)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var str:String = String(format: "%@", getNumberFormatter(myUser?.myBalance ?? 0.00))
            
            self.moneyBtn.text = str
            self.moneyBtn.isSecureText = true
            
            str = String(format: "%@", getNumberFormatter(myUser?.myIncome ?? 0.00))
            
            self.incomeBtn.text =  str
            self.incomeBtn.isSecureText = true
        }
        
    }
    
    func createBottomLable(_ titles:Array<String>) -> UIView {
        
        let view:UIView = UIView()

        let leftTitle = creatLabel(CGRect.zero, titles[0], fontRegular(14), Main_TextColor)
        
        let leftNumber = creatLabel(CGRect.zero, titles[1], fontRegular(14), (titles[3] == "0") ? HXColor(0x007f57):Main_Color)
        
        let img:UIImageView = UIImageView(image: UIImage(named: (titles[3] == "0") ? "caifu_down":"caifu_top"))
        
        let rightTitle = creatLabel(CGRect.zero, titles[2], fontRegular(14), (titles[3] == "0") ? HXColor(0x007f57):Main_Color)
        
        rightTitle.textAlignment = .right
        

        view.addSubview(leftTitle)
        view.addSubview(leftNumber)
        view.addSubview(rightTitle)
        view.addSubview(img)
        // 布局
        leftTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15) // 左边距 15
            make.centerY.equalToSuperview()
        }
        
        leftNumber.snp.makeConstraints { make in
            make.left.equalTo(leftTitle.snp.right).offset(15) // 左边距 15
            make.centerY.equalToSuperview()
        }
        
        rightTitle.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15) // 右边距 15
            make.centerY.equalToSuperview()
        }
        
        img.snp.makeConstraints { make in
            // 水平居中，再往右移 15
            make.width.equalTo(8)
            make.height.equalTo(12)
            make.left.equalTo(leftNumber.snp.right).offset(5) // 左边距 15
            make.centerY.equalTo(leftTitle)
        }
        
        return view
    }
    
    @objc func changeMyIncome(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "昨日收益")
        fieldview.type = .revenueType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            let str:String = String(format: "%@", getNumberFormatter(Double(text) ?? 0.00))
            
            self.incomeBtn.text = str
            
            myUser?.myIncome = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.myIncome = Double(text) ?? 0.00
            }
            //通知更新
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyIncomeNotificationName), object: text)
        }
    }
    
    @objc func changeMyMoney(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "总资产")
        fieldview.type = .amountType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            let str:String = String(format: "%@", getNumberFormatter(Double(text) ?? 0.00))
            
            self.moneyBtn.text = str
            
            myUser?.myBalance = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.myBalance = Double(text) ?? 0.00
            }
            //通知更新
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: text)
        }
    }
    
    //MARK: - 展示余额
    @objc func showMoney(button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected {
            showImage.image = UIImage(named: "caifu_hide")
        }else{
            showImage.image = UIImage(named: "caifu_show")
        }
        moneyBtn.isSecureText = button.isSelected
        incomeBtn.isSecureText = button.isSelected
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
