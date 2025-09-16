//
//  LifeCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/28.
//

import UIKit
import SnapKit

class LifeCtrl: BaseCtrl , UIScrollViewDelegate{
    
    private var didSetupCorner = false
    let tabbar:UIView = UIView()
    let fieldView:UIView = UIView()
    
    var locimg:UIImageView?
    var loclb:UILabel?
    var serviceimg:UIImageView?
    var msgimg:UIImageView?
    var versionimg:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicScrollView.delegate = self
        basicScrollView.bounces = false
        
        contentView.backgroundColor = .white
        addTopView()
    }
    
    override func setupUI() {
        super.setupUI()
        addView()
    }
    
    func addTopView(){
        view.addSubview(tabbar)
        tabbar.backgroundColor = .white.withAlphaComponent(0.0)
        
        tabbar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }
        
        serviceimg = UIImageView(image: UIImage(named: "head_kf1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(serviceimg!)
        serviceimg!.tintColor = .white
        
        serviceimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview()
        }
        
        loclb = creatLabel(CGRect.zero, "北京", fontSemibold(10), .white)
        loclb?.textAlignment = .center
        tabbar.addSubview(loclb!)
        
        loclb!.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-2)
        }
        
        locimg = UIImageView(image: UIImage(named: "head_loc1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(locimg!)
        locimg!.tintColor = .white
        locimg!.isUserInteractionEnabled = true
        
        locimg!.snp.makeConstraints { make in
            make.width.equalTo(18)
            make.height.equalTo(22)
            make.centerX.equalTo(loclb!)
            make.bottom.equalTo(loclb!.snp.top).offset(-3)
        }
        
        msgimg = UIImageView(image: UIImage(named: "head_scan1")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(msgimg!)
        msgimg!.tintColor = .white
        
        msgimg!.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.right.equalTo(serviceimg!.snp.left).offset(-3)
            make.centerY.equalTo(serviceimg!)
        }

        tabbar.addSubview(fieldView)
        fieldView.backgroundColor = .white
   
        fieldView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.right.equalTo(msgimg!.snp.left).offset(-5)
            make.centerY.equalTo(serviceimg!)
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
        
    }
    
    func addView(){
        //推荐2 banner
        let imgs:Array<String> = ["icon_life_banner_1","icon_life_banner_2","icon_life_banner_3","icon_life_banner_4","icon_life_banner_5"]
        let carouselhigh:CGFloat = SCREEN_WDITH * (756.0/1125.0)
        
        let carousel = ImagePageView()
        contentView.addSubview(carousel)
        
        carousel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(carouselhigh)
        }
        
        carousel.pageControl.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(-60) // 比如底部上移 100
            make.height.equalTo(20)
        }
        
        var y:CGFloat = carouselhigh - 40
        
        var image:UIImage = UIImage(named: "life2") ?? UIImage()
        var imageV:UIImageView = UIImageView()
        imageV.image = image
        
        var high:CGFloat = (SCREEN_WDITH - 30) * (image.size.height/image.size.width)
        contentView.addSubview(imageV)
        
        imageV.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(y)
            make.height.equalTo(high)
        }
        y+=(high + 15)
        
        self.view.layoutIfNeeded()
        
        setupViewWithRoundedCornersAndShadow(
            imageV,
            radius: 10.0,
            corners: [.topLeft, .topRight , .bottomLeft,.bottomRight], // 示例: 左上+右下圆角
            borderWidth: 0,
            borderColor: .white,
            shadowColor: .lightGray, // 浅灰色阴影
            shadowRadius: 10,         // 柔和扩散效果
            shadowOpacity: 0.2       // 浅色透明度
        )
        
        image = UIImage(named: "life3") ?? UIImage()
        imageV = UIImageView()
        imageV.image = image
        
        high = SCREEN_WDITH * (image.size.height/image.size.width)
        contentView.addSubview(imageV)
        
        imageV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(y)
            make.height.equalTo(high)
        }
        y+=high
        
        let titles:Array<String> = ["为您优选","话费充值"]

        let images:Array = ["life4","life5"]
        
        for (i, icon) in images.enumerated() {
            let titlelb:UILabel = creatLabel(CGRect.zero, titles[i], fontSemibold(18), Main_TextColor)
            titlelb.textAlignment = .left
            contentView.addSubview(titlelb)
            
            let image:UIImage = UIImage(named: icon) ?? UIImage()
            
            let imageV:UIImageView = UIImageView()
            imageV.image = image
            
            let high:CGFloat = (i == 0 ? (SCREEN_WDITH - 30) : SCREEN_WDITH) * (image.size.height/image.size.width)
            contentView.addSubview(imageV)
            
            titlelb.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.top.equalToSuperview().offset(y + 4)
                make.height.equalTo(46)
            }
    
            imageV.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(titlelb.snp.bottom)
                make.height.equalTo(high)
            }
            
            y+=(high + 50)
            
            if i == titles.count - 1 {
                contentView.snp.makeConstraints { make in
                    make.bottom.equalTo(imageV.snp.bottom).offset(50)
                }
            }
        }
        
        carousel.pageControl.selectedGradientColors = nil
        carousel.pageControl.normalSize = CGSize(width: 7, height: 7)
        carousel.pageControl.selectedSize = CGSize(width: 7, height: 7)
        carousel.pageControl.normalColor = .black.withAlphaComponent(0.1)
        carousel.pageControl.selectedColor = .white
        carousel.pageControl.spacing = 10
        
        self.view.layoutIfNeeded()
        carousel.showPage(false,full: true)
        carousel.configure(with: imgs)
    }

    @objc func changeLocation(){
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let offsetY = scrollView.contentOffset.y
        
        let progress = min(max(offsetY / navigationHeight, 0), 1)

        tabbar.backgroundColor = .white.withAlphaComponent(min(max(progress, 0), 1))
        
        if progress >= 1 {
            fieldView.backgroundColor = Main_backgroundColor
            
            serviceimg!.tintColor = Main_TextColor
            msgimg!.tintColor = Main_TextColor
            locimg!.tintColor = Main_TextColor
            loclb!.textColor = Main_TextColor
        }else{
            
            serviceimg!.tintColor = .white
            msgimg!.tintColor = .white
            locimg!.tintColor = .white
            loclb!.textColor = .white
            
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
