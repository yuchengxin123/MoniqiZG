//
//  CommunityCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/28.
//

import UIKit
import SnapKit
import YPImagePicker

class CardCtrl: BaseCtrl,UIScrollViewDelegate {
    
    private var didSetupCorner = false
    let tabbar:UIView = UIView()
    let fieldView:UIView = UIView()
    
    var serviceimg:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicScrollView.delegate = self
        basicScrollView.bounces = false
        
        self.addTopView()
    }
    
    
    override func setupUI() {
        super.setupUI()
        // 原来写在 viewDidLoad 的 UI 代码，挪到这里
        self.addView()
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
        
        tabbar.addSubview(fieldView)
        fieldView.backgroundColor = Main_backgroundColor
   
        fieldView.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.right.equalTo(serviceimg!.snp.left).offset(-5)
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
        var y:CGFloat = navigationHeight
        
        let headimgs:Array<String> = ["card_head","card_btns","card_banner_title"]
        
        for (i, icon) in headimgs.enumerated() {
            let image:UIImage = UIImage(named: icon) ?? UIImage()
            
            let imageV:UIImageView = UIImageView()
            imageV.image = image
            
            let high:CGFloat = (i==2 ? (SCREEN_WDITH - 30) : SCREEN_WDITH) * (image.size.height/image.size.width)
            contentView.addSubview(imageV)
            
            imageV.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(i==2 ? 15:0)
                make.top.equalToSuperview().offset(y)
                make.height.equalTo(high)
            }
            
            y+=high
        }
        
        let carouselhigh:CGFloat = (SCREEN_WDITH - 30) * (274.0/1072)
        
        //banner
        let imgs:Array<String> = ["card_banner1","card_banner2","card_banner3"]
        
        let carousel = ImagePageView()
        contentView.addSubview(carousel)
        carousel.showPage(true)
        
        carousel.snp.makeConstraints { make in
            make.height.equalTo(carouselhigh)
            make.top.equalToSuperview().offset(y + 8)
            make.left.right.equalToSuperview().inset(15)
        }
        
        y+=(carouselhigh + 8)
        
        self.view.layoutIfNeeded()
        
        carousel.configure(with: imgs)
        ViewRadius(carousel, 4)
        
        
        //财富精选
        let titles:Array<String> = ["热卡精彩","权益领取","特惠在身边",
                                    "分期生活","特色专区"]
        
        let images:Array = ["card_img1","card_img2","card_img3","card_img4","card_img5"]
        
        for (i, icon) in images.enumerated() {
            let titlelb:UILabel = creatLabel(CGRect.zero, titles[i], fontSemibold(18), Main_TextColor)
            titlelb.textAlignment = .left
            contentView.addSubview(titlelb)
            
            
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

            imageV.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(titlelb.snp.bottom)
                make.height.equalTo(high)
            }
            
            if i == 0 {
                let rightImageV:UIImageView = UIImageView(image: UIImage(named: "my_right"))
                contentView.addSubview(rightImageV)
                
                let detaillb:UILabel = creatLabel(CGRect.zero, "更多", fontRegular(14), Main_detailColor)
                detaillb.textAlignment = .right
                contentView.addSubview(detaillb)
                
                rightImageV.snp.makeConstraints { make in
                    make.right.equalToSuperview().inset(15)
                    make.centerY.equalTo(titlelb)
                    make.width.height.equalTo(22)
                }
                
                detaillb.snp.makeConstraints { make in
                    make.right.equalTo(rightImageV.snp.left).offset(3)
                    make.centerY.equalTo(titlelb)
                }
            }

            y+=(high + 50)
        }
        
        let bottomView:UIView = UIView()
        bottomView.backgroundColor = Main_backgroundColor
        contentView.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(y + 20)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomView.snp.bottom)
        }
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
