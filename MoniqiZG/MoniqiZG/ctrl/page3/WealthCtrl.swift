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
    let wealthlb:UILabel = UILabel()
    let rightimg:UIImageView = UIImageView(image: UIImage(named: "my_right")?.withRenderingMode(.alwaysTemplate))
    let searchimg:UIImageView = UIImageView(image: UIImage(named: "main_search")?.withRenderingMode(.alwaysTemplate))
    var moneyWidth:CGFloat = 15
    let mymoneylb:UILabel = creatLabel(CGRect.zero, "总资产(元)", fontRegular(15), HXColor(0x585757))
    //账户总览
    let billView:UIImageView = UIImageView()
    let showImage:UIImageView = UIImageView()
    var moneyBtn:SecureLoadingLabel = SecureLoadingLabel()
    var incomeBtn:SecureLoadingLabel = SecureLoadingLabel()
    
    let bottomView:UIView = UIView()
    let loopView = AutoLoopCustomView(direction: .vertical)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        addTopView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let number:String = String(format: "%@", getNumberFormatter(myUser!.myBalance))
        
        let richText = NSAttributedString.makeAttributedString(components: [
            .init(text: String(number.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
            .init(text: String(number.suffix(2)), color: Main_TextColor, font: fontNumber(20))
        ])
        self.moneyBtn.attributedText = richText
        
        
        let incomeNumber:String = String(format: "%@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        
        let incomerichText = NSAttributedString.makeAttributedString(components: [
            .init(text: String(incomeNumber.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
            .init(text: String(incomeNumber.suffix(2)), color: Main_TextColor, font: fontNumber(20))
        ])
        self.incomeBtn.attributedText = incomerichText
    }
    
    override func setupUI() {
        super.setupUI()
        
        addView()
        addBottom()
        NotificationCenter.default.addObserver(self, selector: #selector(changeMyBalanceNotification(noti:)), name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeMyIncomeNotification(noti:)), name: NSNotification.Name(rawValue: changeMyIncomeNotificationName), object: nil)
    }
    
    @objc func changeMyBalanceNotification(noti:NSNotification){
        let str:String = (noti.object ?? "") as! String
        let number:String = String(format: "%@", getNumberFormatter(Double(str) ?? 0.00))
        
        let richText = NSAttributedString.makeAttributedString(components: [
            .init(text: String(number.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
            .init(text: String(number.suffix(2)), color: Main_TextColor, font: fontNumber(20))
        ])
        self.moneyBtn.attributedText = richText
        
        
        let incomeNumber:String = String(format: "%@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
        
        let incomerichText = NSAttributedString.makeAttributedString(components: [
            .init(text: String(number.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
            .init(text: String(number.suffix(2)), color: Main_TextColor, font: fontNumber(20))
        ])
        self.incomeBtn.attributedText = incomerichText
    }
    
    @objc func changeMyIncomeNotification(noti:NSNotification){
        let str:String = (noti.object ?? "") as! String
        let number:String = String(format: "%@", getNumberFormatter(Double(str) ?? 0.00))
        
        let richText = NSAttributedString.makeAttributedString(components: [
            .init(text: String(number.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
            .init(text: String(number.suffix(2)), color: Main_TextColor, font: fontNumber(20))
        ])
        self.incomeBtn.attributedText = richText
    }
    
    func addBottom(){
        view.addSubview(bottomView)
        bottomView.backgroundColor = .white
        bottomView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.left.right.bottom.equalToSuperview()
        }
        
        let line:UIView = UIView()
        bottomView.addSubview(line)
        line.backgroundColor = HXColor(0xc1c1c1)
        
        
        bottomView.addSubview(loopView)
        
        
        let topline:UIView = UIView()
        topline.backgroundColor = defaultLineColor
        bottomView.addSubview(topline)
        
        topline.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        line.snp.makeConstraints { make in
            make.height.equalTo(4)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.equalTo(30)
        }
        
        loopView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        ViewRadius(line, 2)
        loopView.layoutIfNeeded()
        
        let titles:Array<Array<String>> = [["创业指数 ","2379.82 +1.96%","恒生指数 ","24906.81 +0.19%"],
                                           ["上证指数 ","3647.55 +0.34%","深证指数 ","11291.43 +1.46%"],
                                           ["创业指数 ","2379.82 +1.96%","恒生指数 ","24906.81 +0.19%"],
                                           ["上证指数 ","3647.55 +0.34%","深证指数 ","11291.43 +1.46%"]]
        
        var customViews: [UIView] = []
        
        for array in titles {
            let item = createBottomLable(array)
            customViews.append(item)
        }
        loopView.configure(with:customViews)
        
    }
    
    func createBottomLable(_ titles:Array<String>) -> UIView {
        let view:UIView = UIView()
        let leftLabel = UILabel()
        let rightLabel = UILabel()
        

        view.addSubview(leftLabel)

        view.addSubview(rightLabel)
        
        // 布局
        leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15) // 左边距 15
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-15) // 父视图一半 - 15
        }
        
        rightLabel.snp.makeConstraints { make in
            // 水平居中，再往右移 15
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5).offset(-15)
        }
        
        let leftText = NSAttributedString.makeAttributedString(components: [
            .init(text: titles[0], color: Main_TextColor, font: fontRegular(14)),
            .init(text: titles[1], color: HXColor(0xf43939), font: fontRegular(14))
        ])
        
        leftLabel.attributedText = leftText
        
        // 右侧富文本
        let rightText = NSAttributedString.makeAttributedString(components: [
            .init(text: titles[2], color: Main_TextColor, font: fontRegular(14)),
            .init(text: titles[3], color: HXColor(0xf43939), font: fontRegular(14))
        ])
        rightLabel.attributedText = rightText
        
        return view
    }
    
    func addTopView(){
        basicScrollView.delegate = self
        basicScrollView.bounces = false
        
        view.addSubview(tabbar)
        tabbar.backgroundColor = .white.withAlphaComponent(0.0)
        
        tabbar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        
        let icon:UIImageView = UIImageView()
        icon.image = UIImage(named: "caifukefu")
        tabbar.addSubview(icon)

        wealthlb.font = fontRegular(14)
        wealthlb.textColor = .white
        wealthlb.text = "按策略挑选更高收益的偏股基金"
        tabbar.addSubview(wealthlb)
        
        rightimg.tintColor = .white.withAlphaComponent(0.4)
        tabbar.addSubview(rightimg)
        
        searchimg.tintColor = .white
        tabbar.addSubview(searchimg)
        
        
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(26)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalTo(tabbar).offset(-10)
        }
        
        wealthlb.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalTo(icon.snp.right).offset(5)
            make.centerY.equalTo(icon)
        }
        
        rightimg.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.left.equalTo(wealthlb.snp.right).offset(2)
            make.centerY.equalTo(icon)
        }
        
        searchimg.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(icon)
        }
        
        ViewRadius(icon, 13)
    }
    
    func addView(){
        let images:Array = ["caifu3","caifu4","caifu5","caifu6","caifu7","caifu8"]
        
        var image:UIImage = UIImage(named: "caifu1") ?? UIImage()
        var high = SCREEN_WDITH * (image.size.height/image.size.width)
        let headImage:UIImageView = UIImageView(image: image)
        let bgview:UIView = UIView()
        
        contentView.addSubview(headImage)
        
        headImage.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(high)
        }
        
        contentView.addSubview(billView)
        billView.isUserInteractionEnabled = true
        billView.backgroundColor = .white

        image = UIImage(named: "caifu2") ?? UIImage()
        high = (SCREEN_WDITH - 30) * (image.size.height/image.size.width)
        
        billView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(headImage.snp.bottom).offset(-70)
            make.height.equalTo(high)
        }
        billView.image = image


        
        
        var y:CGFloat = 15
        
        for (i, icon) in images.enumerated() {
            let image:UIImage = UIImage(named: icon) ?? UIImage()
            
            let imageV:UIImageView = UIImageView()
            imageV.image = image
            

            var high = (SCREEN_WDITH - 30) * (image.size.height/image.size.width)
                
            contentView.addSubview(imageV)
            
            if i == 0 {
                high = SCREEN_WDITH * (image.size.height/image.size.width)
            }
            
            imageV.snp.makeConstraints { make in
                if i == 0 {
                    make.left.right.equalToSuperview()
                }else{
                    make.left.right.equalToSuperview().inset(15)
                }
                
                make.top.equalTo(billView.snp.bottom).offset(y)
                make.height.equalTo(high)
            }
            y+=(high + 15)
            
            
            if i == images.count - 1 {
                contentView.snp.makeConstraints { make in
                    make.bottom.equalTo(imageV.snp.bottom).offset(60)
                }
                
            }
        }
        
        bgview.backgroundColor = .white
        contentView.insertSubview(bgview, at: 0)
        
        bgview.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headImage.snp.bottom).offset(-30)
            make.bottom.equalTo(billView).offset(15)
        }
        
        self.view.layoutIfNeeded()
        let gl:CAGradientLayer = addGradientLayerWithframe(bgview.bounds,[Main_backgroundColor.cgColor,UIColor.white.cgColor])
        bgview.layer.insertSublayer(gl, at: 0)
        
        setupViewWithRoundedCornersAndShadow(
            billView,
            radius: 10,
            corners: [.topLeft, .topRight , .bottomLeft , .bottomRight], // 示例: 左上+右下圆角
            shadowColor: .lightGray, // 浅灰色阴影
            shadowRadius: 10,         // 柔和扩散效果
            shadowOpacity: 0.2       // 浅色透明度
        )
        
        addBillContentView()
    }
    
    func addBillContentView(){

//        moneyBtn.addTarget(self, action: #selector(changeMyMoney), for: .touchUpInside)
        moneyBtn.textAlignment = .left
        moneyBtn.font = fontNumber(23)
        billView.addSubview(moneyBtn)
        
        
        showImage.image = UIImage(named: "hideMoney1")
        billView.addSubview(showImage)
        
        let showBtn:UIButton = UIButton()
        showBtn.backgroundColor = .clear
        showBtn.addTarget(self, action: #selector(showMoney(button:)), for: .touchUpInside)
        showBtn.isSelected = true
        billView.addSubview(showBtn)
        
        
        incomeBtn.isSecureText = true
        incomeBtn.font = fontNumber(23)
        incomeBtn.text = String(format: "¥ %@", getNumberFormatter(getIncome(aomunt: myUser!.myBalance)))
//        incomeBtn.addTarget(self, action: #selector(changeMyIncome), for: .touchUpInside)
        incomeBtn.textAlignment = .right
        billView.addSubview(incomeBtn)
        
        billView.addSubview(mymoneylb)
        
        let rightimg:UIImageView = UIImageView(image: UIImage(named: "my_right")?.withRenderingMode(.alwaysTemplate))
        rightimg.tintColor = HXColor(0x585757)
        billView.addSubview(rightimg)
        
        let incomelb = creatLabel(CGRect.zero, "昨日收益", fontRegular(15), HXColor(0x585757))
        billView.addSubview(incomelb)
        
        
        moneyBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(25)
            make.height.equalTo(30)
        }
        
        incomeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(moneyBtn)
            make.height.equalTo(30)
        }
        
        mymoneylb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(moneyBtn.snp.bottom).offset(15)
            make.height.equalTo(25)
        }
        
        rightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(mymoneylb)
            make.height.equalTo(25)
            make.width.equalTo(20)
        }
        
        incomelb.snp.makeConstraints { make in
            make.right.equalTo(rightimg.snp.left)
            make.centerY.equalTo(rightimg)
            make.height.equalTo(25)
        }
        
        showImage.snp.makeConstraints { make in
            make.top.equalTo(moneyBtn).offset(2)
            make.left.equalTo(mymoneylb.snp.right).offset(5)
            make.height.equalTo(14)
            make.width.equalTo(22)
        }
        
        showBtn.snp.makeConstraints { make in
            make.height.width.equalTo(60)
            make.left.centerY.equalTo(showImage)
        }
        
        ViewRadius(billView, 10)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var str:String = String(format: "%@", getNumberFormatter(myUser?.myBalance ?? 0.00))
            
            var richText = NSAttributedString.makeAttributedString(components: [
                .init(text: String(str.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
                .init(text: String(str.suffix(2)), color: Main_TextColor, font: fontNumber(20))
            ])
            
            self.moneyBtn.attributedText = richText
            self.moneyBtn.isSecureText = true
            
            str = String(format: "%@", getNumberFormatter(myUser?.myIncome ?? 0.00))
            
            richText = NSAttributedString.makeAttributedString(components: [
                .init(text: String(str.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
                .init(text: String(str.suffix(2)), color: Main_TextColor, font: fontNumber(20))
            ])
            
            self.incomeBtn.attributedText =  richText
            self.incomeBtn.isSecureText = true
        }
        
    }
    
    @objc func changeMyIncome(){
        let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        fieldview.setContent(str: "昨日收益")
        fieldview.type = .revenueType
        KWindow?.addSubview(fieldview)
        
        fieldview.changeContent = { text in
            let str:String = String(format: "%@", getNumberFormatter(Double(text) ?? 0.00))
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: String(str.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
                .init(text: String(str.suffix(2)), color: Main_TextColor, font: fontNumber(20))
            ])
            self.incomeBtn.attributedText = richText
            
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
            
            let richText = NSAttributedString.makeAttributedString(components: [
                .init(text: String(str.dropLast(2)), color: Main_TextColor, font: fontNumber(28)),
                .init(text: String(str.suffix(2)), color: Main_TextColor, font: fontNumber(20))
            ])
            self.moneyBtn.attributedText = richText
            
            myUser?.myBalance = Double(text) ?? 0.00
            UserManager.shared.update { user in
                user.myBalance = Double(text) ?? 0.00
            }
            //通知更新
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: text)
        }
    }
    
    @objc func showMoney(button:UIButton){
        button.isSelected = !button.isSelected
        if button.isSelected {
            showImage.image = UIImage(named: "hideMoney1")
        }else{
            showImage.image = UIImage(named: "showMoney1")
        }
        moneyBtn.isSecureText = button.isSelected
        incomeBtn.isSecureText = button.isSelected
        
        showImage.snp.remakeConstraints { make in
            if moneyBtn.isSecureText {
                make.top.equalTo(moneyBtn).offset(2)
                make.left.equalTo(mymoneylb.snp.right).offset(5)
            }else{
                make.top.equalTo(moneyBtn).offset(5)
                make.left.equalTo(moneyBtn.snp.right).offset(5)
            }
            make.height.equalTo(14)
            make.width.equalTo(22)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let offsetY = scrollView.contentOffset.y
        
        let progress = min(max(offsetY / navigationHeight, 0), 1)

        tabbar.backgroundColor = .white.withAlphaComponent(min(max(progress, 0), 1))
        
        if progress >= 1 {
            wealthlb.textColor = Main_TextColor
            searchimg.tintColor = Main_TextColor
            rightimg.tintColor = Main_TextColor
        }else{
            wealthlb.textColor = .white
            searchimg.tintColor = .white
            rightimg.tintColor = .white.withAlphaComponent(0.4)
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
