//
//  TransferSure.swift
//  MoniqiZG
//
//  Created by ycx on 2025/9/20.
//

import UIKit
import SnapKit
import LocalAuthentication
import Foundation

class TransferSubmit: BaseCtrl,UIGestureRecognizerDelegate{
    
    private var didSetupCorner = false
    var model:TransferModel?
    var transferFail:Bool = false
    let moneyView:UIView = UIView()
    let bottomView:UIView = UIView()
    var balance:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor
        addHeadView()
        
    }
    
    override func setupUI() {
        super.setupUI()
        
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
            make.width.height.equalTo(24)
        }
        
        let infoImg:UIImageView = UIImageView(image: UIImage(named: "face_right"))
        headView.addSubview(infoImg)
        
        infoImg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "确认信息", fontMedium(18), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    
    func addView(){
        let bannerView:UIView = UIView()
        bannerView.backgroundColor = HXColor(0xfef5f7)
        contentView.addSubview(bannerView)
        
        bannerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(navigationHeight+5)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let img:UIImageView = UIImageView()
        img.image = UIImage(named: "transfer_sumbit_remind")
        bannerView.addSubview(img)
        
        img.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        let sumbitText = NSAttributedString.makeAttributedString(components: [
            .init(text: "不要给陌生人转账，谨防电信网络诈骗！", color: Main_TextColor, font: fontRegular(14)),
            .init(text: "点击查看", color: blueColor, font: fontRegular(14))
        ])
        
        let lb:UILabel = creatLabel(CGRect.zero, "", fontRegular(14), Main_TextColor)
        lb.attributedText = sumbitText
        bannerView.addSubview(lb)
        
        lb.snp.makeConstraints { make in
            make.left.equalTo(img.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        moneyView.backgroundColor = .white
        contentView.addSubview(moneyView)
        
        
        bottomView.backgroundColor = .white
        contentView.addSubview(bottomView)
        
        moneyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(bannerView.snp.bottom)
//            make.height.equalTo(7*50 + 20 + 120)
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(moneyView.snp.bottom)
            make.height.equalTo(160)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomView)
        }
        
        addMoneyView()
        addBottomView()
    }
    
    func addMoneyView(){
        let titlelb:UILabel = creatLabel(CGRect.zero, "转账金额（人民币元）", fontRegular(18), Main_TextColor)
        moneyView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(40)
        }
        
        let moneylb:UILabel = creatLabel(CGRect.zero, getNumberFormatter(model!.amount),fontNumber(30) , Main_TextColor)
        moneyView.addSubview(moneylb)
        
        moneylb.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(titlelb.snp.bottom).offset(20)
        }
        
        let line:UIView = UIView()
        moneyView.addSubview(line)
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(moneylb.snp.bottom).offset(30)
        }
        
        var y:CGFloat = 0
        
        let titles:Array<String> = ["转账费用","转账方式","收款人名称","收款帐号","收款银行","付款帐号","安全工具"]
        let details:Array<String> = ["免费","实时",model?.partner.name ?? "",model?.partner.card ?? "",
                                     model?.partner.bankName ?? "",model?.payCard ?? "","手机交易码"]
        
        for (i,str) in titles.enumerated() {
            let leftlb:UILabel = creatLabel(CGRect.zero, str, fontRegular(14), Main_detailColor)
            moneyView.addSubview(leftlb)
            
            leftlb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalTo(line.snp.bottom).offset(y)
                make.height.equalTo(50)
                make.width.equalTo(120)
            }
            
            let rightlb:UILabel = creatLabel(CGRect.zero, details[i], fontSemibold(14), Main_TextColor)
            moneyView.addSubview(rightlb)
            
            rightlb.snp.makeConstraints { make in
                make.left.equalTo(leftlb.snp.right)
                make.top.height.equalTo(leftlb)
                make.right.equalToSuperview()
            }
            
            if i == 0 {
                rightlb.textColor = HXColor(0xdc0034)
            }
            
            y+=50
            
            if i == 1 || i == 5 {
                y+=10
            }
            
            if i == titles.count - 1 {
                moneyView.snp.makeConstraints { make in
                    make.bottom.equalTo(leftlb)
                }
            }
        }
    }
    
    func addBottomView(){
        let sumbitText = NSAttributedString.makeAttributedString(components: [
            .init(text: "各安全工具转账限额  ", color: HXColor(0x717171), font: fontRegular(14)),
            .init(text: "查看详情\n", color: blueColor, font: fontRegular(14)),
            .init(text: "开通手机盾，仅需6位密码，便捷安全转账。 ", color: HXColor(0x717171), font: fontRegular(14)),
            .init(text: "点击开通", color: blueColor, font: fontRegular(14))
        ])
        
        let lb:UILabel = creatLabel(CGRect.zero, "", fontRegular(14), Main_TextColor)
        lb.attributedText = sumbitText
        lb.numberOfLines = 0
        bottomView.addSubview(lb)
        
        lb.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(30)
        }
        
        let btn:UIButton = creatButton(CGRect.zero, "确认", fontMedium(18), .white, blueColor, self, #selector(handlTap))
        bottomView.addSubview(btn)
        
        btn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(lb.snp.bottom).offset(50)
            make.height.equalTo(48)
        }
        
        ViewRadius(btn, 4)
        
        // 2. 添加长按手势识别器
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1.0
        btn.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // 允许同时识别多个手势
    }
    
    //MARK: - 长按转账失败
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("按钮被长按")
            transferFail = true
            // 这里处理长按开始时的逻辑
            isOpenVIPAction()
        }
    }
    
    //MARK: - 单击转账成功
    @objc func handlTap() {
        transferFail = false
        isOpenVIPAction()
    }
    
    //MARK: - 验证可用的功能
    func isOpenVIPAction(){
        //水印版本不受限制 可以用
        if myUser!.vip_level == .typeNoAction {
            checkFaceRecognition()
            isShowWater()
        }else{
            //非水印版本 要考虑使用该功能要求的最低会员等级 以及 有效期
            YcxHttpManager.getTimestamp() { msg,data,code  in
                if code == 1{
                    let currentTime:TimeInterval = TimeInterval(data)
                    
                    print("本地时间--\((Date().timeIntervalSince1970))\n服务器时间--\(currentTime)")
                    
                    //没过期
                    if myUser!.expiredDate > currentTime {
                        // 只能改余额
                        if myUser!.vip_level == .typeVip{
                            KWindow?.makeToast("需要升级会员", .center, .information)
                        }else if myUser!.vip_level == .typeSVip || myUser!.vip_level == .typeAll{
                            self.checkFaceRecognition()
                        }
                        
                    }else{
                        //全部能用但是变成水印版本
                        self.checkFaceRecognition()
                        self.isShowWater()
                    }
                }else{
                    KWindow?.makeToast(msg, .center, .fail)
                }
            }
        }
    }
    
    //MARK: - 人脸识别
    func checkFaceRecognition(){
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "请使用 Face ID 验证身份") { success, authError in
                DispatchQueue.main.async {
                    
                    if success {
                        print("Face ID 验证通过")
                    } else {
                        print("验证失败：\(authError?.localizedDescription ?? "")")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let bigtime:String = getCurrentTimeString()
                        let smalltime:String = getCurrentTimeString(dateFormat: "MM.dd HH:mm")
                        
                        
                        //转账失败 不需要保存记录
                        if self.transferFail == true {
                            let ctrl:TransferWaitCtrl = TransferWaitCtrl()
                            ctrl.oldModel = self.model
                            ctrl.transferFail = self.transferFail
                            self.pushAndCloseCtrl(ctrl)
                           // self.navigationController?.pushViewController(ctrl, animated: true)
                            return
                        }
                        
                        myTradeList.append(self.model!)
                        
                        TransferModel.saveArray(myTradeList, forKey: MyTradeRecord)
                        
                        myUser?.myBalance = self.balance
                        
                        UserManager.shared.update { user in
                            user.myBalance = self.balance
                        }
                        
                        //通知余额更新
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: changeMyBalanceNotificationName), object: nil)

                        let ctrl:TransferWaitCtrl = TransferWaitCtrl()
                        ctrl.oldModel = self.model
                        ctrl.transferFail = self.transferFail
                        self.pushAndCloseCtrl(ctrl)
                        
                    }
                }
            }
        } else {
            print("设备不支持 Face ID：\(error?.localizedDescription ?? "")")
            showLocationPermissionAlert()
        }
    }
    
    func showLocationPermissionAlert() {
        // 创建 alert controller
        let alert = UIAlertController(
            title: "需要开启人脸识别",
            message: "人脸识别用于支付验证以及个人信息查看",
            preferredStyle: .alert
        )
        
        // 取消按钮
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel
        )
        alert.addAction(cancelAction)
        
        // 确定按钮 - 打开设置
        let settingsAction = UIAlertAction(
            title: "确认",
            style: .default
        ) { [weak self] _ in
            self?.openAppSettings()
        }
        alert.addAction(settingsAction)
        
        // 显示 alert
        self.navigationController?.present(alert, animated: true)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                print("打开设置: \(success ? "成功" : "失败")")
            }
        }
    }
}

