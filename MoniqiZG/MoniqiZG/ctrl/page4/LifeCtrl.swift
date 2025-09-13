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
    
    var locButton:UIButton?
    var searchimg:UIImageView?
    var serviceimg:UIImageView?
    var msgimg:UIImageView?
    var titlePage:UILabel = creatLabel(CGRect.zero, "星巴克笔笔立减2元起", fontRegular(14), .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = Main_backgroundColor
        addTopView()
    }
    
    override func setupUI() {
        super.setupUI()
        addView()
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
        tabbar.addSubview(fieldView)
        
        fieldView.addSubview(titlePage)
        
        fieldView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.width.equalTo(SCREEN_WDITH - 195)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(80)
        }
        
        searchimg = UIImageView(image: UIImage(named: "main_search")?.withRenderingMode(.alwaysTemplate))
        fieldView.addSubview(searchimg!)
        searchimg!.tintColor = .white
        
        searchimg!.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().inset(8)
        }
        
        locButton = UIButton()
        locButton?.addTarget(self, action: #selector(changeLocation), for: .touchUpInside)
        tabbar.addSubview(locButton!)
        
        locButton!.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(fieldView)
        }
        
        msgimg = UIImageView(image: UIImage(named: "order")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(msgimg!)
        msgimg!.tintColor = .white
        
        msgimg!.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(fieldView)
        }
        
        serviceimg = UIImageView(image: UIImage(named: "face_black")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(serviceimg!)
        serviceimg!.tintColor = .white
        
        serviceimg!.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.right.equalTo(msgimg!.snp.left).offset(-20)
            make.centerY.equalTo(fieldView)
        }
        
        titlePage.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.bottom.equalToSuperview()
            make.left.equalTo(searchimg!.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
        }

        self.view.layoutIfNeeded()
        
        locButton?.setImageTitleLayout(
            image: UIImage(named: "loc_bottom_white"),
            title: "北京",
            font: fontRegular(16),
            spacing: 2,
            position: .right
        )
        ViewBorderRadius(fieldView, 17, 0.8, UIColor.white.withAlphaComponent(0.2))
        locButton?.setTitleColor(.white, for: .normal)
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
        
        
        let lifeImgs:Array<String> = ["life2","life_featured_bg","life3","life_movie_bg","life4","life5","life_car_bg","life_more_1","life_more_2","life_more_3","life_more_4","life_more_5","life_more_6"]
        
        let carImgs:Array<String> = ["car1","car2","car3"]
        
        let featureImgs:Array<String> = ["feature1","feature2"]
        
        var y:CGFloat = carouselhigh - 50
        
        for (i,img) in lifeImgs.enumerated() {
            let img:UIImage = UIImage(named:img) ?? UIImage()
            
            var high:CGFloat = img.size.height/img.size.width * (SCREEN_WDITH - 30)
            
            if i >= 7 {
                high = img.size.height/img.size.width * SCREEN_WDITH
            }
            
            let imageV:UIImageView = UIImageView()
            imageV.image = img
            contentView.addSubview(imageV)
            
            imageV.snp.makeConstraints { make in
                if( i >= 7){
                    make.left.right.equalToSuperview()
                    make.height.equalTo(high)
                }else{
                    make.left.right.equalToSuperview().inset(15)
                    make.height.equalTo(high)
                }
                make.top.equalToSuperview().offset(y)
            }
            
            if i >= 7 {
                y = y + high
            }else{
                y = y + high + 15
            }
            
            imageV.layoutIfNeeded()
            ViewRadius(imageV, 10)
            
            if i == 1 {
                addImagePageView(imageV, featureImgs)
            }
            
            if i == 3 {
                var x:CGFloat = 5
                let movies:Array<String> = ["movie1","movie2","movie3","movie4"]
                imageV.isUserInteractionEnabled = true
                
                let scrollview = UIScrollView()
                imageV.addSubview(scrollview)
                
                scrollview.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(5)
                    make.bottom.equalToSuperview().offset(-20)
                    make.right.equalToSuperview()
                    make.height.equalTo(230)
                }
                
                scrollview.layoutIfNeeded()

                for img in movies {
                    let img:UIImage = UIImage(named:img) ?? UIImage()
                    let wide:CGFloat = img.size.width/img.size.height * 230
                    
                    let imageV:UIImageView = UIImageView()
                    imageV.image = img
                    scrollview.addSubview(imageV)
                    
                    imageV.snp.makeConstraints { make in
                        make.left.equalToSuperview().offset(x)
                        make.height.equalTo(230)
                        make.width.equalTo(wide)
                        make.top.equalToSuperview()
                    }
                    
                    x+=wide
                }
                scrollview.isScrollEnabled = true
                scrollview.contentSize = CGSizeMake(x, 230)
                scrollview.showsVerticalScrollIndicator = false
                scrollview.showsHorizontalScrollIndicator = false
            }
            
            if i == 6 {
                addImagePageView(imageV, carImgs)
            }
            
            if i == lifeImgs.count - 1 {
                contentView.snp.makeConstraints { make in
                    make.bottom.equalTo(imageV.snp.bottom).offset(20)
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
    
    func addImagePageView(_ superVivw:UIView,_ imgs:Array<String>){
        let carouselhigh:CGFloat = (SCREEN_WDITH/2.0 - 35) * (682.0/474.0)
        
        let carousel = ImagePageView()
        superVivw.addSubview(carousel)
        
        carousel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(62)
            make.height.equalTo(carouselhigh)
            make.width.equalTo(SCREEN_WDITH/2.0 - 35)
        }
        carousel.layoutIfNeeded()
        
        carousel.showPage(true,full: true)
        carousel.configure(with: imgs)
    }
    
    
    @objc func changeLocation(){
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let offsetY = scrollView.contentOffset.y
        
        let progress = min(max(offsetY / navigationHeight, 0), 1)

        tabbar.backgroundColor = .white.withAlphaComponent(min(max(progress, 0), 1))
        
        if progress >= 1 {
            titlePage.textColor = Main_TextColor.withAlphaComponent(0.2)
            fieldView.layer.borderColor = Main_TextColor.withAlphaComponent(0.2).cgColor
            
            searchimg!.tintColor = Main_TextColor.withAlphaComponent(0.2)
            serviceimg!.tintColor = Main_TextColor
            msgimg!.tintColor = Main_TextColor
            locButton!.setTitleColor(Main_TextColor, for: .normal)
            locButton?.setImage(UIImage(named: "loc_bottom_gray"), for: .normal)
        }else{
            titlePage.textColor = .white
            fieldView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            
            searchimg!.tintColor = .white
            serviceimg!.tintColor = .white
            msgimg!.tintColor = .white
            locButton!.setTitleColor(.white, for: .normal)
            locButton?.setImage(UIImage(named: "loc_bottom_white"), for: .normal)
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
