//
//  TransferWaitCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/20.
//


import UIKit
import SnapKit

class TransferWaitCtrl: BaseCtrl {
    
    private var didSetupCorner = false
    
    var oldModel:TransferModel?
    let successView:UIView = UIView()
    var transferFail:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        
        addHeadView()
        addView()
    }
 
    func addHeadView(){
        let headView:UIView = UIView()
        headView.backgroundColor = .white
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
    }

    func scheduleLocalNotification() {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM月dd日 HH:mm"
        outputFormatter.locale = Locale(identifier: "zh_CN")
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date:Date = inputFormatter.date(from: oldModel!.bigtime) ?? Date()
        
        let time:String = outputFormatter.string(from: date)
       
        let card:String = String((oldModel!.payCard.replacingOccurrences(of: " ", with: "")).suffix(4))
        
        let payamount:String = getNumberFormatter(oldModel!.amount)
        
        let user:String = oldModel!.partner.name
        
        let balance:String = getNumberFormatter(myUser?.myBalance ?? 0.0)
        
        let content = UNMutableNotificationContent()
        content.title = "招商银行"
        content.body = (self.transferFail == false) ? String(format: "【招商银行】您账户%@于%@转账汇款人民币%@，余额%@，收款人：%@，请以收款人实际入账为准", card,time,payamount,balance,user) : String(format: "【招商银行】您账户%@于%@转账汇款人民币%@，交易失败：%@", card,time,payamount,user)
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // 1 秒后触发
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "localTest", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加通知失败: \(error)")
            } else {
                print("本地通知已安排")
            }
        }
    }
    
    
    func addView(){
        let countdownView = CountdownCircleView(frame: CGRect(x: SCREEN_WDITH/2.0 - 65, y: navigationHeight + 60, width: 130, height: 130))
        countdownView.rotationPeriod = 1.0   // 1秒一圈
        contentView.addSubview(countdownView)
        
        //随机等待时间
        let randomNumber = Int.random(in: 0..<5)
        countdownView.onFinished = { index in
            if index == randomNumber {
                print("转账完成randomNumber=\(randomNumber)")
                self.successView.isHidden = false
                self.scheduleLocalNotification()
            }
        }
        countdownView.start()
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "正等待对方银行返回结果...", fontRegular(18), HXColor(0x333333))
        titlelb.textAlignment = .center
        contentView.addSubview(titlelb)
        
        let detaillb:UILabel = creatLabel(CGRect.zero, "结果返回前，请不要重复提交", fontRegular(14), HXColor(0xff8420))
        detaillb.textAlignment = .center
        contentView.addSubview(detaillb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(220 + navigationHeight)
        }
        
        detaillb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(titlelb.snp.bottom).offset(5)
        }
        
        
        successView.backgroundColor = .white
        successView.isHidden = true
        contentView.addSubview(successView)
        
        successView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(navigationHeight)
            make.height.equalTo(SCREEN_HEIGTH - navigationHeight)
        }
        
        let img:UIImage = UIImage(named: (self.transferFail == true) ? "transfer_fail":"transfer_successful") ?? UIImage()
        let high:CGFloat = img.size.height/img.size.width * 80
        
        let successimg:UIImageView = UIImageView()
        successimg.image = img
        successView.addSubview(successimg)
        
        successimg.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(high)
            make.width.equalTo(80)
        }
        
        let statuslb:UILabel = creatLabel(CGRect.zero, (self.transferFail == true) ? "转账失败":"转账成功", fontRegular(18), Main_TextColor)
        statuslb.textAlignment = .center
        statuslb.numberOfLines = 0
        successView.addSubview(statuslb)
        
        let timeStr:String = (self.transferFail == true) ? myUser!.transferFailHint : "\(myUser!.transferArrivalTime)，实际时间取决于对方银行"
        
        let timelb:UILabel = creatLabel(CGRect.zero, timeStr, fontRegular(14), Main_detailColor)
        timelb.textAlignment = .center
        successView.addSubview(timelb)
        
        
        if self.transferFail == true {
            let centerBtn:UIButton = creatButton(CGRect.zero, "联系客服", fontRegular(16), HXColor(0x5995ef), .white, self, #selector(contactCustomerService))
            successView.addSubview(centerBtn)
            
            let sureBtn:UIButton = creatButton(CGRect.zero, "返回转账首页", fontRegular(16), HXColor(0x565656), .white, self, #selector(closeCtrl))
            successView.addSubview(sureBtn)
            
            let remindBtn:UIButton = creatButton(CGRect.zero, "修改转账信息", fontRegular(16), .white, HXColor(0x565656), self, #selector(gotoTransfer))
            successView.addSubview(remindBtn)
            
            statuslb.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(successimg.snp.bottom).offset(25)
                make.centerX.equalToSuperview()
            }
            
            timelb.snp.makeConstraints { make in
                make.top.equalTo(statuslb.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }
            
            centerBtn.snp.makeConstraints { make in
                make.top.equalTo(timelb.snp.bottom)
                make.centerX.equalToSuperview()
                make.height.equalTo(40)
            }
            
            remindBtn.snp.makeConstraints { make in
                make.top.width.height.equalTo(sureBtn)
                make.right.equalToSuperview().inset(20)
                make.height.equalTo(40)
            }
            
            sureBtn.snp.makeConstraints { make in
                make.top.equalTo(centerBtn.snp.bottom).offset(100)
                make.width.equalTo(SCREEN_WDITH/2.0 - 20 - 7)
                make.height.equalTo(40)
                make.left.equalToSuperview().inset(20)
            }
            
            ViewRadius(remindBtn, 20)
            ViewBorderRadius(sureBtn, 20, 0.5, HXColor(0x565656))
            
        }else{
            let centerBtn:UIButton = creatButton(CGRect.zero, "丨 继续转账 丨", fontRegular(12), HXColor(0x5995ef), .white, self, #selector(gotoTransfer))
            successView.addSubview(centerBtn)
            
            let leftBtn:UIButton = creatButton(CGRect.zero, " 转账记录 ", fontRegular(12), HXColor(0x5995ef), .white, self, #selector(gotoTransferlist))
            successView.addSubview(leftBtn)
            
            let rightBtn:UIButton = creatButton(CGRect.zero, " 账户总览 ", fontRegular(12), HXColor(0x5995ef), .white, self, #selector(gotoMyAmountCtrl))
            successView.addSubview(rightBtn)
            
            let faqimg:UIImage = UIImage(named: "transfer_faq") ?? UIImage()
            let faqhigh:CGFloat = faqimg.size.height/faqimg.size.width * SCREEN_WDITH
            
            let faqimgView:UIImageView = UIImageView()
            faqimgView.image = faqimg
            successView.addSubview(faqimgView)
            
            
            
            let sureBtn:UIButton = creatButton(CGRect.zero, "完成", fontRegular(16), HXColor(0x565656), .white, self, #selector(closeCtrl))
            successView.addSubview(sureBtn)
            
            statuslb.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(15)
                make.top.equalTo(successimg.snp.bottom).offset(25)
                make.centerX.equalToSuperview()
            }
            
            timelb.snp.makeConstraints { make in
                make.top.equalTo(statuslb.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }
            
            centerBtn.snp.makeConstraints { make in
                make.top.equalTo(timelb.snp.bottom)
                make.centerX.equalToSuperview()
                make.height.equalTo(40)
            }
            
            leftBtn.snp.makeConstraints { make in
                make.top.height.equalTo(centerBtn)
                make.right.equalTo(centerBtn.snp.left)
            }
            
            rightBtn.snp.makeConstraints { make in
                make.top.height.equalTo(centerBtn)
                make.left.equalTo(centerBtn.snp.right)
            }
            
            faqimgView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(centerBtn.snp.bottom).offset(45)
                make.height.equalTo(faqhigh)
            }
            
            sureBtn.snp.makeConstraints { make in
                make.top.equalTo(centerBtn.snp.bottom).offset(290)
                make.width.equalTo(SCREEN_WDITH/2.0 - 20 - 7)
                make.height.equalTo(40)
                make.left.equalToSuperview().inset(20)
            }
            
            let remindBtn:UIButton = creatButton(CGRect.zero, "通知收款人", fontRegular(16), .white, HXColor(0x565656), self, #selector(pushRemindCtrl))
            successView.addSubview(remindBtn)
            
            let wide:CGFloat = SCREEN_WDITH/2.0 - 20 - 7 + 7
            
            let remindImg:UIImage = UIImage(named: "transfer_success_remind") ?? UIImage()
            let high:CGFloat = remindImg.size.height/remindImg.size.width * wide
            
            let remindImgView:UIImageView = UIImageView(image: remindImg)
            successView.addSubview(remindImgView)
            
            remindBtn.snp.makeConstraints { make in
                make.top.width.height.equalTo(sureBtn)
                make.right.equalToSuperview().inset(20)
                make.height.equalTo(40)
            }
            
            remindImgView.snp.makeConstraints { make in
                make.bottom.equalTo(remindBtn.snp.top).offset(-15)
                make.left.equalTo(remindBtn)
                make.height.equalTo(high)
                make.width.equalTo(wide)
            }
            
            ViewRadius(remindBtn, 20)
            ViewBorderRadius(sureBtn, 20, 0.5, HXColor(0x565656))
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(successView.snp.bottom)
        }
    }
    
    @objc func contactCustomerService(){
        
    }
    
    @objc func gotoTransfer(){
        let ctrl:TradeCtrl = TradeCtrl()
        ctrl.oldModel = self.oldModel?.partner
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func gotoTransferlist(){
        let ctrl:TransferListCtrl = TransferListCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func closeCtrl(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func pushRemindCtrl(){
        let ctrl:RemindPayeeUserCtrl = RemindPayeeUserCtrl()
        ctrl.oldModel = self.oldModel
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func gotoMyAmountCtrl(){
        let ctrl:MyAmountCtrl = MyAmountCtrl()
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
