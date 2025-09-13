//
//  Untitled.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/21.
//

import UIKit
import SnapKit

class RemindPayeeUserCtrl: BaseCtrl,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate  {
    
    private var didSetupCorner = false

    var oldModel:TransferModel?
    private let typeArray:Array<Dictionary<String,String>> = [
        ["icon":"remind_default0","text":"电子回单","ps":"此电子回单仅供参考，请以收方账户实际入账为准。款项已到对方银行，预计10秒内到账，实际时间取决于对方银行。"],
        ["icon":"remind_bg2","text":"节日祝福","ps":"年年顺意、岁岁欢愉、平安喜乐！"],
        ["icon":"remind_bg3","text":"生意兴隆","ps":"生意兴隆，财源广进！"],
        ["icon":"remind_bg4","text":"健康祝福","ps":"愿你闪闪发光，亦要平安健康。"],
        ["icon":"remind_bg5","text":"享受生活","ps":"平凡的日子也要过得有滋有味~"],
        ["icon":"remind_bg6","text":"尽情消费","ps":"你的小心愿，我来买单！"],
        ["icon":"remind_bg7","text":"生日祝福","ps":"纪念此刻，祝你快乐，不止生日！"],
        ["icon":"remind_bg8","text":"新婚祝福","ps":"祝新婚快乐、白首永偕、幸福美满！"],
        ["icon":"remind_bg9","text":"周岁祝福","ps":"有幸见证成长，祝福宝贝周岁快乐！"],
        ["icon":"remind_bg10","text":"心情祝福","ps":"享受美好瞬间，愿你快乐每一天！"],
        ["icon":"remind_bg11","text":"学业祝福","ps":"愿你全力以赴，满载而归！"],
    ]
    
    private var typeIndex:Int = 0
    let sendImageView:UIImageView = UIImageView()
    var firstHigh:CGFloat = 100
    var otherHigh:CGFloat = 100
    var messageBtn:UIButton?
    let messageImg:UIButton = UIButton()
    let sealImg:UIImageView = UIImageView()
    let detailView:UIView = UIView()
    let detailOtherView:UIView = UIView()
    
    //HXColor(0x8b7469)
    let PSlb:UILabel = creatLabel(CGRect.zero, "", fontRegular(11), Main_TextColor)
    var remindField:UITextField?
    
    private lazy var typeCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(remindCell.self, forCellWithReuseIdentifier: "remindCell")
        return cv
    }()
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor
        
        addHeadView()

    }
 
    override func setupUI() {
        super.setupUI()
        
        addView()
        
        addDetailView()
        addDetailOtherView()
        
        detailView.isHidden = false
        detailOtherView.isHidden = true
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
        
        
        let leftButton:UIButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "通知收款人", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }

    
    
    func addView(){
        let img:UIImage = UIImage(named: "remind_default2") ?? UIImage()
        
        let high:CGFloat = img.size.height/img.size.width * (SCREEN_WDITH - 80)
        
        sendImageView.image = img
        view.addSubview(sendImageView)
        sendImageView.isUserInteractionEnabled = true
        
        let seal_Img:UIImage = UIImage(named: "remind_default1") ?? UIImage()
        let sealhigh:CGFloat = seal_Img.size.height/seal_Img.size.width * (SCREEN_WDITH/2.0-50)
        sealImg.image = seal_Img
        
        sendImageView.addSubview(sealImg)
        
        detailView.backgroundColor = .clear
        sendImageView.addSubview(detailView)
        
        detailOtherView.backgroundColor = .clear
        sendImageView.addSubview(detailOtherView)
        detailOtherView.isHidden = true
        
        let bottomView:UIView = UIView()
        bottomView.backgroundColor = .white
        bottomView.isUserInteractionEnabled = true
        view.addSubview(bottomView)
        
        view.addSubview(typeCollectionView)
        
        messageBtn = creatButton(CGRect.zero, "显示转账附言", fontRegular(10), Main_TextColor, .clear, self, #selector(selectMessage))
        messageBtn?.isSelected = false
        view.addSubview(messageBtn!)
        
        messageImg.addTarget(self, action: #selector(selectMessage), for: .touchUpInside)
        messageImg.setImage(UIImage(named: "message_unselect"), for: .normal)
        view.addSubview(messageImg)

        sendImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.centerY.equalToSuperview().offset(-50)
            make.height.equalTo(high)
        }
        
        sealImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(SCREEN_WDITH/2.0-60)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(SCREEN_WDITH/2.0-50)
            make.height.equalTo(sealhigh)
        }
        
        detailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        detailOtherView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(60 + bottomSafeAreaHeight)
            make.bottom.equalToSuperview()
        }
        
        typeCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(85)
            make.bottom.equalTo(bottomView.snp.top).offset(-20)
        }
        
        messageImg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.height.width.equalTo(20)
            make.bottom.equalTo(typeCollectionView.snp.top).offset(-15)
        }
        
        messageBtn!.snp.makeConstraints { make in
            make.right.equalTo(messageImg.snp.left).offset(-5)
            make.height.equalTo(30)
            make.centerY.equalTo(messageImg)
        }
        
        
        let bottomimg:UIImage = UIImage(named: "share_bottom") ?? UIImage()
        
        let bottomimghigh:CGFloat = bottomimg.size.height/bottomimg.size.width * (SCREEN_WDITH)
        
        let bottomImage:UIImageView = UIImageView()
        bottomImage.image = bottomimg
        bottomImage.isUserInteractionEnabled = true
       
        bottomView.addSubview(bottomImage)
        
        
        bottomImage.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(bottomimghigh)
        }
        
        
        let btnW:CGFloat = SCREEN_WDITH/3.0
        for i in [0,1,2] {
            let btn:UIButton = UIButton()
            bottomView.addSubview(btn)
            btn.addTarget(self, action: #selector(isOpenVIPAction(button:)), for: .touchUpInside)
            btn.tag = 100 + i
            
            btn.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(btnW * Double(i))
                make.width.equalTo(btnW)
                make.top.bottom.equalToSuperview()
            }
        }
        
        showMessage(false)
        
        ViewRadius(sendImageView, 4)
    }
    
    func addDetailView(){
        let titlelb:UILabel = creatLabel(CGRect.zero, "转出成功!", fontMedium(18), Main_TextColor)
        titlelb.textAlignment = .center
        detailView.addSubview(titlelb)
        
        let detaillb:UILabel = creatLabel(CGRect.zero, typeArray[0]["ps"]!, fontRegular(12), Main_detailColor)
        detaillb.textAlignment = .center
        detaillb.numberOfLines = 0
        detailView.addSubview(detaillb)
        
        let line:UIView = UIView()
        line.backgroundColor = HXColor(0xf7f7f7)
        detailView.addSubview(line)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(25)
            make.height.equalTo(20)
        }
        
        detaillb.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(titlelb.snp.bottom).offset(10)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(detaillb.snp.bottom).offset(20)
        }
        
        //付款卡号
        var paycard:String = oldModel!.payCard
        if paycard.count > 8 {
            paycard = maskDigits(paycard)
        }
        
        //收款卡号
        var card:String = oldModel!.partner.card
        if card.count > 8 {
            card = maskDigits(card)
        }
        
        let titles:Array<String> = ["收款方户名","收款方账号","收款方银行","转账金额","付款方户名","付款方账号","转账留言","转账流水号","交易时间"]
        let details:Array<String> = [oldModel!.partner.name,card,
                                     oldModel!.partner.bankName,
                                     String(format: "%.02f元", oldModel!.amount),myUser!.myName,
                                     paycard,oldModel!.remind,oldModel!.serialNumber,
                                     formatDateStringFlexible(oldModel!.bigtime)]
        
        var y:CGFloat = 15
        
        for (i,str) in titles.enumerated() {
            let leftlb:UILabel = creatLabel(CGRect.zero, str, fontRegular(14), fieldPlaceholderColor)
            detailView.addSubview(leftlb)
            
            let rightlb:UILabel = creatLabel(CGRect.zero, details[i], fontRegular(14), HXColor(0x555555))
            detailView.addSubview(rightlb)
            
            leftlb.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(20)
                make.height.equalTo(20)
                make.top.equalTo(line.snp.bottom).offset(y)
            }
            
            rightlb.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(20)
                make.top.height.equalTo(leftlb)
            }
            y+=25
        }
    }
    
    func addDetailOtherView(){
        detailOtherView.isUserInteractionEnabled = true
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "\(myUser!.myName)向您转账", fontRegular(14), .white)
        titlelb.textAlignment = .center
        detailOtherView.addSubview(titlelb)
        
        let detaillb:UILabel = creatLabel(CGRect.zero, String(format: "¥ %.02f", oldModel!.amount), fontRegular(40), .white)
        detaillb.textAlignment = .center
        detailOtherView.addSubview(detaillb)
        
        let paymentDetailslb:UILabel = creatLabel(CGRect.zero, "收款卡号：\(oldModel!.partner.bankName) (\(oldModel!.partner.lastCard)", fontNumber(12), .white.withAlphaComponent(0.8))
        paymentDetailslb.textAlignment = .center
        detailOtherView.addSubview(paymentDetailslb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(20)
        }
        
        detaillb.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(titlelb.snp.bottom).offset(12)
        }
        
        paymentDetailslb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(detaillb.snp.bottom).offset(10)
        }
        
        let bgimg:UIImageView = UIImageView()
        bgimg.backgroundColor = .white.withAlphaComponent(0.2)
//        bgimg.image = UIImage(named: "")
        detailOtherView.addSubview(bgimg)
        
        let bgTitlelb:UILabel = creatLabel(CGRect.zero, "亲爱的\(oldModel!.partner.name)", fontRegular(12), Main_TextColor)
        detailOtherView.addSubview(bgTitlelb)
        
        let editimg:UIImageView = UIImageView()
        editimg.image = UIImage(named: "remindPayee_edit")
        detailOtherView.addSubview(editimg)
        
        remindField = createField(CGRect.zero, "", fontRegular(14), Main_TextColor, UIView(), UIView())
        remindField?.text = typeArray[typeIndex]["ps"]
        remindField?.backgroundColor = .clear
        remindField?.delegate = self
        
        detailOtherView.addSubview(remindField!)
        
        let myNamelb:UILabel = creatLabel(CGRect.zero, myUser!.myName, fontRegular(12), Main_TextColor)
        myNamelb.textAlignment = .right
        detailOtherView.addSubview(myNamelb)
        
        //HXColor(0x8b7469)
        let timelb:UILabel = creatLabel(CGRect.zero, formatDateStringFlexible(oldModel!.bigtime), fontRegular(11), Main_TextColor)
        timelb.textAlignment = .right
        detailOtherView.addSubview(timelb)
        
        //HXColor(0x8b7469)
        let seriallb:UILabel = creatLabel(CGRect.zero, "转账流水号 \(oldModel!.serialNumber)", fontRegular(11), Main_TextColor)
        seriallb.textAlignment = .right
        detailOtherView.addSubview(seriallb)
        
        PSlb.text = "转账附言 \(oldModel!.remind)"
        PSlb.textAlignment = .right
        detailOtherView.addSubview(PSlb)
//        PSlb.isHidden = true
        
        PSlb.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(0)
        }
        
        seriallb.snp.makeConstraints { make in
            make.right.equalTo(PSlb)
            make.bottom.equalTo(PSlb.snp.top).offset(-1)
        }
        
        timelb.snp.makeConstraints { make in
            make.right.equalTo(PSlb)
            make.bottom.equalTo(seriallb.snp.top).offset(-1)
        }
        
        myNamelb.snp.makeConstraints { make in
            make.right.equalTo(PSlb)
            make.bottom.equalTo(timelb.snp.top).offset(-2)
        }
        //34 45
        editimg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(16)
            make.width.equalTo(12)
            make.bottom.equalTo(myNamelb.snp.top).offset(-3)
        }
        
        remindField!.snp.makeConstraints { make in
            make.right.equalTo(PSlb)
            make.left.equalTo(editimg.snp.right).offset(10)
            make.centerY.equalTo(editimg)
            make.height.equalTo(28)
        }
        
        bgTitlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(editimg.snp.top).offset(-5)
        }
        
        bgimg.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(5)
            make.top.equalTo(bgTitlelb).offset(-15)
        }
        
        self.view.layoutIfNeeded()
        
        ViewRadius(detailOtherView, 10)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.endEditing(true)
        return true
    }
    
    //MARK: - 验证可用的功能
    @objc func isOpenVIPAction(button:UIButton){
        //水印版本不受限制 可以用
        if myUser!.vip_level == .typeNoAction {
//            self.share(button: button)
            KWindow?.makeToast("需要升级会员", .center, .information)
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
                            self.share(button: button)
                        }
                        
                    }else{
                        //全部能用但是变成水印版本
//                        self.share(button: button)
                        KWindow?.makeToast("需要升级会员", .center, .information)
                        self.isShowWater()
                    }
                }else{
                    KWindow?.makeToast(msg, .center, .fail)
                }
            }
        }
    }
    
    
    @objc func share(button:UIButton){
        if let image = sendImageView.snapshot() {
            // 用 image 去分享或保存
            switch (button.tag - 100){
            case 0,1:
                let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                
                // iPad 需要设置弹出位置（否则崩溃）
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                self.navigationController?.present(activityVC, animated: true, completion: nil)
            default:
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                KWindow?.makeToast("保存成功", .center, .information)
                print("保存本地")
            }
        }
    }
    
    
    @objc func shareRecord(){
        
    }
    
    @objc func selectMessage(){
        messageBtn!.isSelected = !messageBtn!.isSelected
        messageImg.setImage(UIImage(named: messageBtn!.isSelected==true ? "message_select":"message_unselect"), for: .normal)
        
        PSlb.snp.updateConstraints { make in
            make.height.equalTo(messageBtn!.isSelected==true ? 12:0)
        }
    }
    
    @objc func showMessage(_ isshow:Bool){
        sealImg.isHidden = isshow
        messageBtn!.isHidden = !isshow
        messageImg.isHidden = messageBtn!.isHidden
        
        detailView.isHidden = isshow
        detailOtherView.isHidden = !isshow
    }
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "remindCell", for: indexPath) as? remindCell else {
            return UICollectionViewCell()
        }
        
        cell.uploadDic(typeArray[indexPath.row],isselect: (indexPath.row == typeIndex ?true:false),isFirst: (indexPath.row == 0 ?true:false))
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(61.5 + 4, 81 + 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        typeIndex = indexPath.row
        
        var img:UIImage = UIImage(named: "remind_default2") ?? UIImage()
       
        if indexPath.row != 0 {
            img = UIImage(named: typeArray[indexPath.row]["icon"]!) ?? UIImage()
        }
        
        let high:CGFloat = img.size.height/img.size.width * (SCREEN_WDITH - 80)
        sendImageView.image = img
        
        sendImageView.snp.updateConstraints { make in
            make.height.equalTo(high)
        }
        collectionView.reloadData()
        
        showMessage((typeIndex==0 ? false : true))
        
        remindField?.text = typeArray[typeIndex]["ps"]
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
}


class remindCell: UICollectionViewCell {
    let titlelb:UILabel = UILabel()
    let headImage:UIImageView = UIImageView()
    var data:Dictionary<String,String>?
    var select:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Main_backgroundColor
        //#5f9fff
        contentView.addSubview(headImage)
        headImage.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(2)
            make.bottom.equalToSuperview().offset(-2)
        }
        
        titlelb.font = fontRegular(12)
        titlelb.textColor = .white
        titlelb.textAlignment = .center
        titlelb.backgroundColor = .black.withAlphaComponent(0.5)
        contentView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.bottom.right.left.equalToSuperview().inset(2)
        }
        
        ViewBorderRadius(self, 5, 2, .clear)
        
        self.layoutIfNeeded()
        
        ViewRadius(headImage, 5)
        SetCornersAndBorder(titlelb, radius: 5, corners: [.bottomRight,.bottomLeft])
    }
    
    
    func uploadDic(_ dic:Dictionary<String,String>,isselect:Bool = false,isFirst:Bool = false){
        data = dic
        
        headImage.image = UIImage(named: dic["icon"]!) ?? UIImage()
        titlelb.text = dic["text"]
        
        self.layer.borderColor = isselect == true ? HXColor(0x5f9fff).cgColor : UIColor.clear.cgColor
        
        headImage.snp.updateConstraints { make in
            if isFirst == true {
                make.bottom.equalToSuperview().offset(-20)
            }else{
                make.bottom.equalToSuperview().offset(-2)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
