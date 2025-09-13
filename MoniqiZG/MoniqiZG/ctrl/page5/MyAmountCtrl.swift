//
//  MyAmountCtrl.swift
//  MoniqiZG
//
//  Created by apple on 2025/8/17.
//

import UIKit
import SnapKit

class MyAmountCtrl: BaseCtrl,UIScrollViewDelegate{
    
    private var didSetupCorner = false
    let tabbar:UIView = UIView()
    let amountlb:SecureLoadingLabel = SecureLoadingLabel()//活钱
    let totallb:AnimatedNumberLabel = AnimatedNumberLabel()
    let monthAmountBtn:AnimatedNumberLabel = AnimatedNumberLabel()
    let cardamountlb:SecureLoadingLabel = SecureLoadingLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        basicScrollView.delegate = self
        addTap = true;
        addTopView()
    }
    
    override func setupUI() {
        super.setupUI()
        addView()
    }
    
    //导航栏
    func addTopView(){
        view.addSubview(tabbar)
        tabbar.backgroundColor = .clear
        
        tabbar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        
        let leftimg:UIImageView = UIImageView(image: UIImage(named: "back_white"))
        tabbar.addSubview(leftimg)
        
        leftimg.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().inset(7)
        }
        
        let rightimg:UIImageView = UIImageView(image: UIImage(named: "more_black_remove")?.withRenderingMode(.alwaysTemplate))
        rightimg.tintColor = .white
        tabbar.addSubview(rightimg)
        
        rightimg.snp.makeConstraints { make in
            make.width.equalTo(19)
            make.height.equalTo(4)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(leftimg)
        }
        
        let button:UIButton = UIButton()
        button.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        tabbar.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "账户总览", fontMedium(18), .white)
        titlelb.textAlignment = .center
        tabbar.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.right.equalToSuperview().inset(60)
            make.centerY.equalTo(leftimg)
        }
   
    }
    
    func addView(){
        let headView:UIView = UIView()
        headView.backgroundColor = HXColor(0x2e3650)
        contentView.addSubview(headView)
        
        let contentV:UIView = UIView()
        contentV.backgroundColor = Main_backgroundColor
        contentView.addSubview(contentV)
        
        let headimage:UIView = UIView()
        headimage.backgroundColor = HXColor(0x2e3650)
        contentView.addSubview(headimage)
        
        let xianjinView:UILabel = creatLabel(CGRect.zero, " 现金红包 ", fontRegular(12), .white)
        xianjinView.backgroundColor = Main_Color
        headimage.addSubview(xianjinView)
        
        
        let xianjinlb:UILabel = creatLabel(CGRect.zero, "2元现金红包，达标即可领取", fontRegular(15), .white)
        headimage.addSubview(xianjinlb)
        
        
        let smallCard:UIView = UIView()
        smallCard.backgroundColor = HXColor(0x4a516a)
        contentView.addSubview(smallCard)
        
        let bigCard:UIView = UIView()
        bigCard.backgroundColor = HXColor(0x626a87)
        contentView.addSubview(bigCard)
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "总资产", fontMedium(16) , .white)
        bigCard.addSubview(titlelb)
        
        let str:String = String(format: "%@", getNumberFormatter(myUser?.myBalance ?? 0.00))
        
        let richText = NSAttributedString.makeAttributedString(components: [
            .init(text: String(str.dropLast(2)), color: .white, font: fontNumber(28)),
            .init(text: String(str.suffix(2)), color: .white, font: fontNumber(20))
        ])
        // 右边小图标
        totallb.setRightImage(UIImage(named: "right_white"))
        totallb.attributedText = richText
        totallb.animationType = .rollingText
        bigCard.addSubview(totallb)
        
        let detaillb:UILabel = creatLabel(CGRect.zero, "查看收益", fontRegular(12), HXColor(0xd3d5dd))
        detaillb.backgroundColor = HXColor(0x6b738e)
        detaillb.textAlignment = .center
        bigCard.addSubview(detaillb)
        
        let monthlb:UILabel = creatLabel(CGRect.zero, "本月剩余应还", fontMedium(12) , HXColor(0xd9dbe0))
        smallCard.addSubview(monthlb)
        
        monthAmountBtn.text = String(format: "%@", getNumberFormatter(myUser?.myMonthCost ?? 0.00))
        monthAmountBtn.font = fontNumber(16)
        monthAmountBtn.textColor = HXColor(0xd9dbe0)
        monthAmountBtn.animationType = .rollingText
        monthAmountBtn.activityType = .medium
        smallCard.addSubview(monthAmountBtn)
        
        amountlb.text = String(format: "活钱 %@", getNumberFormatter(myUser?.myBalance ?? 0.00))
        amountlb.isSecureText = false
        amountlb.font = fontNumber(18)
        amountlb.textColor = HXColor(0x2c8fed)
        contentV.addSubview(amountlb)
        
        let cardview:UIView = UIView()
        cardview.backgroundColor = .white
        contentV.addSubview(cardview)
        
        let img:UIImage = UIImage(named: "zhijiekeyong") ?? UIImage()
        let wide:CGFloat = img.size.width/img.size.height * 16.0
        
        let cardleft:UIImageView = UIImageView()
        cardleft.image = img
        cardview.addSubview(cardleft)
        
        let cardright:UIImageView = UIImageView()
        cardright.image = UIImage(named: "right")
        cardview.addSubview(cardright)
        
        cardamountlb.text = String(format: "%@", getNumberFormatter(myUser?.myBalance ?? 0.00))
        cardamountlb.isSecureText = false
        cardamountlb.font = fontNumber(24)
        cardamountlb.textColor = .black
        cardview.addSubview(cardamountlb)
        
        
        headView.snp.makeConstraints { make in
            make.height.equalTo(navigationHeight + 340)
            make.left.top.right.equalToSuperview()
            make.top.equalToSuperview().offset(-100)
        }
        
        contentV.snp.makeConstraints { make in
            make.height.equalTo(135)
            make.left.right.equalToSuperview()
            make.top.equalTo(headView.snp.bottom).offset(-20)
        }
        
        headimage.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(navigationHeight + 15)
        }
        
        xianjinView.snp.makeConstraints { make in
            make.height.equalTo(12)
            make.left.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        
        xianjinlb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(xianjinView)
            make.left.equalTo(xianjinView.snp.right).offset(5)
        }
        
        bigCard.snp.makeConstraints { make in
            make.height.equalTo(145)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-130)
            make.top.equalTo(headimage.snp.bottom).offset(25)
        }
        
        smallCard.snp.makeConstraints { make in
            make.height.equalTo(110)
            make.width.equalTo(130)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalTo(bigCard)
        }
        
        titlelb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.left.right.equalToSuperview().inset(15)
        }
        
        totallb.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(titlelb.snp.bottom).offset(10)
        }
        
        detaillb.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(15)
            make.width.equalTo(75)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        monthlb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(25)
        }
        
        monthAmountBtn.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(monthlb.snp.bottom)
            make.left.equalTo(monthlb)
        }
        
        amountlb.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        cardview.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(amountlb.snp.bottom).offset(4)
            make.height.equalTo(60)
        }
        
        cardleft.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
            make.width.equalTo(wide)
        }
        //2.4
        cardright.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview().offset(-2)
            make.height.equalTo(19)
            make.width.equalTo(8)
        }

        cardamountlb.snp.makeConstraints { make in
            make.right.equalTo(cardright.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
        
        var y:CGFloat = navigationHeight + 335
        
        let imgs = ["myAmount-1", "myAmount-2"]
        
        
        for (i,img) in imgs.enumerated() {
            let img:UIImage = UIImage(named:img) ?? UIImage()
            
            let high:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
            
            let imageV:UIImageView = UIImageView()
            imageV.image = img
            contentView.addSubview(imageV)
            
            imageV.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(y)
                make.left.right.equalToSuperview()
                make.height.equalTo(high)
            }
            
            y = y + high
            
            if i == imgs.count - 1 {
                contentView.snp.makeConstraints { make in
                    make.bottom.equalTo(imageV.snp.bottom).offset(20)
                }
            }
        }
        
        
        ViewRadius(contentV, 20)
        ViewRadius(bigCard, 10)
        ViewRadius(smallCard, 10)
        ViewRadius(detaillb, 15)
        ViewRadius(cardview, 10)
        ViewRadius(xianjinView, 2)
        
        self.view.layoutIfNeeded()
        
        amountlb.setPosition(position: .center)
        cardamountlb.setPosition(position: .right)
        
        totallb.play()
        monthAmountBtn.play()
        amountlb.show()
        cardamountlb.show()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let offsetY = scrollView.contentOffset.y
        
        let progress = min(max(offsetY / navigationHeight, 0), 1)

        tabbar.backgroundColor = HXColor(0x3a4059).withAlphaComponent(min(max(progress, 0), 1))
    }
}
