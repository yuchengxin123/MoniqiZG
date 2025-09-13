//
//  TradeRecordDetailCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/26.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TradeRecordDetailCtrl: BaseCtrl, UITableViewDataSource, UITableViewDelegate {
    
    private var didSetupCorner = false
    private let headTable = UITableView()
    private var headArray:Array<Array<String>> = []
    var model:TransferModel?
    let bottomCard:UIView = UIView()
    
    private var tradeArray:Array<Dictionary<String,Any>> = [
        ["icon":"1","title":"财付通"],["icon":"2","title":"支付宝"],["icon":"0","title":"美团"],["icon":"0","title":"抖音支付"],
        ["icon":"5","title":"京东支付"],["icon":"6","title":"一网通支付"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor
        
        addHeadView()
    }
    
    override func setupUI() {
        super.setupUI()
        
        //gray_right 右边 camera
        
        getHeadArray()
        addView()
    }
    
    func getHeadArray(){
        let detail:String = getBankTransactionType(type: model!.tradeType)
        
        switch model!.tradeType {
        case TransactionChildType.typeTransfer200.type,
            TransactionChildType.typeTransfer201.type:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["收款银行",model!.partner.bankName])
            headArray.append(["收款账户",maskDigits(model!.partner.card)])
            if model!.remind.count > 0 {
                headArray.append(["转账附言",model!.remind])
            }
            if detail.count > 0 {
                headArray.append(["银行交易类型",detail])
            }
        case TransactionChildType.typeTransfer101.type,
            TransactionChildType.typeTransfer102.type:
            let card:String = "一卡通 \(maskDigits(model!.partner.card))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["付款银行",model!.payBank])
            headArray.append(["付款账户",maskDigits(model!.payCard)])
            if model!.remind.count > 0 {
                headArray.append(["转账附言",model!.remind])
            }
            if detail.count > 0 {
                headArray.append(["银行交易类型",detail])
            }
        case TransactionChildType.typeTransfer103.type:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["付款账户","11*******91"])
            headArray.append(["付款银行","财付通"])
            headArray.append(["交易摘要","微信零钱提现"])
            headArray.append(["银行交易类型",detail])
        case TransactionChildType.typeTransfer108.type,
            TransactionChildType.typeTransfer212.type,
            TransactionChildType.typeTransfer215.type:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["银行交易类型",detail])
        case TransactionChildType.typeTransfer104.type:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["付款账户","24*****33"])
            headArray.append(["付款银行","中国银联成员机构"])
            headArray.append(["交易摘要","财付通转账"])
            headArray.append(["交易备注","财付通转账"])
            headArray.append(["银行交易类型",detail])
        case TransactionChildType.typeTransfer105.type:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["付款账户","2088************0156"])
            headArray.append(["付款银行","中国银联成员机构"])
            headArray.append(["交易备注","\(myUser!.myName)支付宝余额提现"])
            headArray.append(["银行交易类型",detail])
        case TransactionChildType.typeTransfer214.type:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["交易渠道",tradeArray[model!.tradeStyle]["title"] as! String,"icon_channels_\(model!.tradeStyle)"])
            headArray.append(["国家或地区","中国"])
            headArray.append(["银行交易类型",detail])
            headArray.append(["商户单号",model!.merchantNumber])
        case TransactionChildType.typeTransfer217.type:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["交易渠道",tradeArray[model!.tradeStyle]["title"] as! String,"icon_channels_\(model!.tradeStyle)"])
            headArray.append(["银行交易类型",detail])
        default:
            let card:String = "一卡通 \(maskDigits(model!.payCard))"
            headArray.append(["交易卡号",card])
            headArray.append(["交易时间",model!.bigtime])
            headArray.append(["交易渠道",tradeArray[model!.tradeStyle]["title"] as! String,"icon_channels_\(model!.tradeStyle)"])
            headArray.append(["国家或地区","中国"])
            headArray.append(["银行交易类型",detail])
        }
//     TransactionChildType.typeTransfer109.type,
//        TransactionChildType.typeTransfer213.type,
//        TransactionChildType.typeTransfer216.type,
//        TransactionChildType.typeTransfer217.type,
//        TransactionChildType.typeTransfer218.type,
//        TransactionChildType.typeTransfer219.type:
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "交易详情", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    func addView(){
        contentView.addSubview(headTable)
        

        headTable.register(TradeRecordDetailCell.self, forCellReuseIdentifier: "headCell")
        headTable.separatorStyle = .none
        headTable.rowHeight = 40 // 设置固定高度
        headTable.dataSource = self
        headTable.delegate = self
        headTable.sectionFooterHeight = 10
        headTable.isScrollEnabled = false
        headTable.backgroundColor = .white

        
        headTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(navigationHeight + 5)
            make.height.equalTo(Double(headArray.count) * 40.0 + 160)
        }
        
        // 禁止系统自动调整 contentInset（特别是在有 navigationController 时）
        headTable.contentInsetAdjustmentBehavior = .never
        headTable.contentInset = UIEdgeInsets.zero
        // iOS 15+ 需要设置这个来移除 section header 顶部间距
        if #available(iOS 15.0, *) {
            headTable.sectionHeaderTopPadding = 0
        }
        
        addBottomCard()

        ViewRadius(headTable, 10)
        
    }
    
    func addBottomCard(){
        let img:UIImage = UIImage(named: "recordDetail_info") ?? UIImage()
        let high:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
        let centerimg:UIImageView = UIImageView(image: img)
        contentView.addSubview(centerimg)
        
        centerimg.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headTable.snp.bottom)
            make.height.equalTo(high)
        }
        
        
        bottomCard.backgroundColor = .white
        contentView.addSubview(bottomCard)
        
        bottomCard.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(centerimg.snp.bottom)
            make.height.equalTo(40*5 + 25)
        }
        
        let titles:Array<String> = ["分类","所属账本","不计入本月收支","备注","记录点什么"]
        
        var y:CGFloat = 20
        
        for (i,str) in titles.enumerated() {
            let leftlb:UILabel = creatLabel(CGRect.zero, str, fontRegular(14), fieldPlaceholderColor)
            bottomCard.addSubview(leftlb)
            
            leftlb.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.top.equalToSuperview().offset(y)
                make.height.equalTo(20)
            }
            
            
            if i <= 1 {
                let rightimg:UIImageView = UIImageView()
                rightimg.image = UIImage(named: "gray_right")
                bottomCard.addSubview(rightimg)
                
                rightimg.snp.makeConstraints { make in
                    make.right.equalToSuperview().offset(-18)
                    make.centerY.equalTo(leftlb)
                    make.width.equalTo(8)
                    make.height.equalTo(15)
                }
                
                let rightlb:UILabel = creatLabel(CGRect.zero, getTransactionClassType(type: model!.tradeType), fontRegular(14), fieldPlaceholderColor)
                bottomCard.addSubview(rightlb)
                
                rightlb.snp.makeConstraints { make in
                    make.right.equalTo(rightimg.snp.left).offset(-15)
                    make.centerY.equalTo(leftlb)
                    make.height.equalTo(20)
                }
                
                if i==0 {
                    let typeimg:UIImageView = UIImageView()
                    typeimg.image = UIImage(named: getBankTransactionIcon(type: model?.tradeType))
                    bottomCard.addSubview(typeimg)
                    
                    typeimg.snp.makeConstraints { make in
                        make.right.equalTo(rightlb.snp.left).offset(-10)
                        make.centerY.equalTo(leftlb)
                        make.height.width.equalTo(14)
                    }
                    rightlb.textColor = Main_TextColor
                }else{
                    rightlb.text = "请选择"
                }

            }else{
                if i==2 {

                    
                    let customSwitch = CustomSwitch()
//                    customSwitch.scale = 2.0               // 调整大小
                    customSwitch.onTintColor = Main_Color // 开启时颜色
                    customSwitch.offTintColor = HXColor(0xe6e6e6)      // 关闭时颜色
//                    customSwitch.thumbImage = UIImage(named: "thumb_icon") // 替换滑块图片
                    customSwitch.thumbShadowEnabled = true // 是否显示阴影
                    customSwitch.isOn = false              // 初始状态

                    customSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
                    bottomCard.addSubview(customSwitch)
                    
                    customSwitch.snp.makeConstraints { make in
                        make.right.equalToSuperview().offset(-15)
                        make.centerY.equalTo(leftlb)
                        make.height.equalTo(25)
                        make.width.equalTo(50)
                    }
                    
                }else if(i==4){
                    let rightimg:UIImageView = UIImageView()
                    rightimg.image = UIImage(named: "camera")
                    bottomCard.addSubview(rightimg)
                    
                    rightimg.snp.makeConstraints { make in
                        make.right.equalToSuperview().offset(-15)
                        make.centerY.equalTo(leftlb)
                        make.width.equalTo(21.0)
                        make.height.equalTo(16.5)
                    }
                }
            }
            y += 40
        }
        
        let bottomline:UIView = UIView()
        bottomline.backgroundColor = defaultLineColor
        bottomCard.addSubview(bottomline)
        
        bottomline.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(1)
        }
        
        ViewRadius(bottomCard, 10)
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(bottomCard.snp.bottom).offset(20)
        }
    }
    
    @objc func switchChanged(_ sender: CustomSwitch) {
        print("当前状态: \(sender.isOn)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let array:Array = headArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "headCell", for: indexPath) as! TradeRecordDetailCell
        cell.leftlb.text = array[0]
        cell.rightlb.text = array[1]
        if array.count == 3 {
            cell.headImage.isHidden = false
            cell.headImage.image = UIImage(named: array.last ?? "")
        }else{
            cell.headImage.isHidden = true
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .white
        return container;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         
        return (model?.tradeType == TransactionChildType.typeTransfer212.type) ? 120 : 150
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .white

        //cmb_icon_dh 转账
        //icon_transfer_zfb 支出
        //icon_withdrawal_zfb 收入
        //transfer_info
        //icon_consumption_bank 银行消费
        let imgStr:String = getTransactionIcon(type: model!.tradeType)
        var title:String = ""
        
        switch model!.tradeType {
        case TransactionChildType.typeTransfer200.type,
            TransactionChildType.typeTransfer201.type,
            TransactionChildType.typeTransfer101.type,
            TransactionChildType.typeTransfer102.type:
            title = model!.partner.name
        case TransactionChildType.typeTransfer103.type:
            title = myUser!.myName
        case TransactionChildType.typeTransfer212.type:
            title = ""//212 取现 没有图片和标题
        default:
            title = model!.remind
        }
        
        var y:CGFloat = 25
        var wide:CGFloat = 0
        
        if imgStr.count > 0 {
            wide = sizeWide(fontRegular(14), title)

            let titlelb:UILabel = creatLabel(CGRect(x: SCREEN_WDITH/2.0 - (wide + 26)/2.0 - 15 + 26, y: y, width: wide, height: 20),title, fontRegular(14), fieldPlaceholderColor)
            titlelb.textAlignment = .center
            container.addSubview(titlelb)
            
            let titleimg:UIImageView = UIImageView(image: UIImage(named: imgStr))
            container.addSubview(titleimg)
            titleimg.frame = CGRect(x: titlelb.frame.origin.x - 26, y: y, width: 20, height: 20)

            y = y + 20 + 20
        }
        
        let richText:String = String(format: "%@ ¥ %.02f", (model!.isIncome ? "+" : "-"),model!.amount)
        wide = sizeWide(fontMedium(30),richText)
        
        let consumptionlb:UILabel = creatLabel(CGRect(x: SCREEN_WDITH/2.0 - (wide + 20)/2.0 - 15, y: y, width: wide, height: 30), richText, fontMedium(30), Main_TextColor)
        container.addSubview(consumptionlb)
        
        let infoimg:UIImageView = UIImageView(image: UIImage(named: "transfer_info"))
        infoimg.frame = CGRect(x: consumptionlb.frame.origin.x + wide + 10, y: y + 6, width: 18, height: 18)
        container.addSubview(infoimg)
        
        y = y + 30 + 8
        
        let balancelb:UILabel =  creatLabel(CGRect(x: 0, y: y, width: SCREEN_WDITH - 30, height: 20), String(format: "余额 ¥ %0.2f", model!.calculatedBalance), fontRegular(14), fieldPlaceholderColor)
        balancelb.textAlignment = .center
        container.addSubview(balancelb)
        balancelb.isHidden = true
        return container;
 
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
}


class TradeRecordDetailCell: UITableViewCell {
    let headImage = UIImageView()
    let leftlb = UILabel()
    let rightlb = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        backgroundColor = .white
        self.createCellUI()
    }

    func createCellUI(){
        leftlb.font = fontRegular(14)
        leftlb.textColor = fieldPlaceholderColor
        contentView.addSubview(leftlb)
        
        
        rightlb.font = fontRegular(14)
        rightlb.textColor = Main_TextColor
        contentView.addSubview(rightlb)
        
        headImage.isHidden = true
        contentView.addSubview(headImage)
        
        leftlb.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        
        rightlb.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(15)
            make.height.equalTo(20)
        }
        
        headImage.snp.makeConstraints { make in
            make.right.equalTo(rightlb.snp.left).offset(-2)
            make.width.height.equalTo(15)
            make.centerY.equalTo(rightlb)
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
