//
//  TransferDetailCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/18.
//

import UIKit
import SnapKit

class TransferDetailCtrl: BaseCtrl {
    
    private var didSetupCorner = false
    var model:TransferModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor
        
        addHeadView()
        addView()
    }
 
    override func setupUI() {
        super.setupUI()
        addView()
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
      
        let rightImg:UIImageView = UIImageView(image: UIImage(named: "more_black"))
        headView.addSubview(rightImg)
        
        rightImg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalTo(leftImg)
            make.width.equalTo(19)
            make.height.equalTo(4)
        }
        
        let infoImg:UIImageView = UIImageView(image: UIImage(named: "face_right"))
        headView.addSubview(infoImg)
        
        infoImg.snp.makeConstraints { make in
            make.right.equalTo(rightImg.snp.left).offset(-20)
            make.centerY.equalTo(leftImg)
            make.height.width.equalTo(22)
        }
        
        let leftButton:UIButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "转账记录查询", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    
    func addView(){
        //标题
        let headView:UIView = UIView()
        headView.backgroundColor = .white
        contentView.addSubview(headView)
        
        headView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(170)
            make.top.equalTo(navigationHeight)
        }
        
        let namelb:UILabel = creatLabel(CGRect.zero, "转给\(self.model?.partner.name ?? "")", fontRegular(18), Main_TextColor)
        namelb.textAlignment = .center
        headView.addSubview(namelb)
        
        let moneylb:UILabel = creatLabel(CGRect.zero, "- ¥ \(self.model?.amount ?? 0.00)", fontNumber(36), Main_TextColor)
        moneylb.textAlignment = .center
        headView.addSubview(moneylb)
        
        namelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(40)
        }
        
        moneylb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(namelb.snp.bottom).offset(20)
        }
        
        //转账信息
        var paycard:String = model!.payCard
        if paycard.count > 8 {
            paycard = maskDigits(paycard)
        }
        
        let titles:Array<String> = ["收款账户","收款银行","付款账户","转账附言","转账渠道","转账方式"]
        let details:Array<String> = [model!.partner.card,model!.partner.bankName,paycard,model!.remind,"手机银行","电子银行转账"]
        
        let centerView:UIView = UIView()
        centerView.backgroundColor = .white
        contentView.addSubview(centerView)
        
        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(38.0 * Double(titles.count) + 20)
            make.top.equalTo(headView.snp.bottom).offset(10)
        }
        
        var y:CGFloat = 10 + 10
        
        for (i,str) in titles.enumerated() {
            let leftlb:UILabel = creatLabel(CGRect.zero, str, fontRegular(14), fieldPlaceholderColor)
            centerView.addSubview(leftlb)
            
            let rightlb:UILabel = creatLabel(CGRect.zero, details[i], fontRegular(14), Main_TextColor)
            centerView.addSubview(rightlb)
            
            leftlb.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(15)
                make.height.equalTo(18)
                make.top.equalToSuperview().offset(y)
            }
            
            rightlb.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.top.height.equalTo(leftlb)
            }
            y+=38
        }
        
        //转账状态
        let statusView:UIView = UIView()
        statusView.backgroundColor = .white
        contentView.addSubview(statusView)
        
        statusView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.top.equalTo(centerView.snp.bottom).offset(10)
        }
        
        let rotView:UIView = UIView()
        rotView.backgroundColor = HXColor(0x2fb85f)
        statusView.addSubview(rotView)
        
        let statuslb:UILabel = creatLabel(CGRect.zero, "转账完成", fontRegular(16), HXColor(0x2fb85f))
        statusView.addSubview(statuslb)
        
        let timelb:UILabel = creatLabel(CGRect.zero, model!.bigtime, fontRegular(14), fieldPlaceholderColor)
        statusView.addSubview(timelb)
        
        var rightimg:UIImageView = UIImageView()
        rightimg.image = UIImage(named: "gray_right")
        statusView.addSubview(rightimg)
        
        let progresslb:UILabel = creatLabel(CGRect.zero, "进度查询", fontRegular(16), fieldPlaceholderColor)
        statusView.addSubview(progresslb)
        
        rightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        progresslb.snp.makeConstraints { make in
            make.right.equalTo(rightimg.snp.left).offset(-10)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        rotView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.width.equalTo(10)
            make.centerY.equalToSuperview().offset(-13)
        }
        
        statuslb.snp.makeConstraints { make in
            make.left.equalTo(rotView.snp.right).offset(5)
            make.height.equalTo(20)
            make.centerY.equalTo(rotView)
        }
        
        timelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.centerY.equalToSuperview().offset(13)
        }
        
        ViewRadius(rotView, 5)
        
        let noticeBtn:UIButton = UIButton()
        noticeBtn.addTarget(self, action: #selector(noticeUser), for: .touchUpInside)
        noticeBtn.backgroundColor = .white
        contentView.addSubview(noticeBtn)
        
        noticeBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(statusView.snp.bottom).offset(10)
        }
        
        let noticelb:UILabel = creatLabel(CGRect.zero, "通知收款人", fontRegular(16), HXColor(0x6697e0))
        noticeBtn.addSubview(noticelb)
        noticelb.isUserInteractionEnabled = true
        
        rightimg = UIImageView()
        rightimg.image = UIImage(named: "gray_right")
        noticeBtn.addSubview(rightimg)
        
        noticelb.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        rightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        let recordBtn:UIButton = UIButton()
        recordBtn.addTarget(self, action: #selector(gotoRecordList), for: .touchUpInside)
        recordBtn.backgroundColor = .white
        contentView.addSubview(recordBtn)
        
        recordBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalTo(noticeBtn.snp.bottom).offset(10)
        }
        
        let recordlb:UILabel = creatLabel(CGRect.zero, "查看和TA的转账记录", fontRegular(16), Main_TextColor)
        recordBtn.addSubview(recordlb)
        recordlb.isUserInteractionEnabled = true
        
        rightimg = UIImageView()
        rightimg.image = UIImage(named: "gray_right")
        recordBtn.addSubview(rightimg)
        
        recordlb.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        rightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        let transferBtn:UIButton = creatButton(CGRect.zero, "再转一笔", fontRegular(16), .white, Main_Color,self, #selector(gotoTransfer))
        contentView.addSubview(transferBtn)
        
        transferBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(44)
            make.top.equalTo(recordBtn.snp.bottom).offset(20)
        }
        
        
        let img:UIImage = UIImage(named: "transfer_record_bottom") ?? UIImage()
        let imghigh:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
        
        let bottomimg:UIImageView = UIImageView()
        bottomimg.image = img
        contentView.addSubview(bottomimg)
        
        bottomimg.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(imghigh)
            make.top.equalTo(transferBtn.snp.bottom)
        }
        
        ViewRadius(transferBtn, 22)
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomimg.snp.bottom).offset(20)
        }
    }
    
    @objc func noticeUser(){
        let ctrl:RemindPayeeUserCtrl = RemindPayeeUserCtrl()
        ctrl.oldModel = self.model
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func gotoRecordList(){
        
    }
    
    @objc func gotoTransfer(){
        let ctrl:TradeCtrl = TradeCtrl()
        ctrl.oldModel = self.model?.partner
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

