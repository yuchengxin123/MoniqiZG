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
        searchimg!.tintColor = .black
        
        searchimg!.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().inset(8)
        }

        scanimg = UIImageView(image: UIImage(named: "main_scan")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(scanimg!)
        scanimg!.tintColor = .black
        
        scanimg!.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(fieldView)
        }
        
        msgimg = UIImageView(image: UIImage(named: "main_msg_balck")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(msgimg!)
        msgimg!.tintColor = .black
        
        msgimg!.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(fieldView)
        }
        
        serviceimg = UIImageView(image: UIImage(named: "main_kehu")?.withRenderingMode(.alwaysTemplate))
        tabbar.addSubview(serviceimg!)
        serviceimg!.tintColor = .black
        
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
