//
//  transferCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/15.
//

import UIKit
import CoreLocation
import SnapKit
import RxSwift
import RxCocoa
import SwipeCellKit

class TransferCtrl: BaseCtrl,UIScrollViewDelegate,SwipeTableViewCellDelegate {
    
    private var didSetupCorner = false
    let cardImageV:UIImageView = UIImageView()
    
    private let disposeBag = DisposeBag()
    private let transferTable = UITableView()
    private let datas = BehaviorRelay<[TransferPartner]>(value: [])
    
    private let myCardTable = UITableView()
    private let myCardDatas = BehaviorRelay<[CardModel]>(value: [])
    
    private let myuserView:UIView = UIView()
    private let userIcon:UIImageView = UIImageView()
    private let userName:UILabel = UILabel()
    private let userCards:UILabel = UILabel()
    private let userRightimg:UIImageView = UIImageView()
    
    private let userLine:UIView = UIView()
    private var isShowCard = false
    private var allBtn:UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicScrollView.delegate = self
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        addHeadView()
    }

    override func setupUI() {
        super.setupUI()
        addView()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(changeMyTransfer), name: NSNotification.Name(rawValue: changeMyTransferNotificationName), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let myPartnerList = myTradeList.uniquePartnersForTransfer200And201()
        datas.accept(myPartnerList)
        myCardDatas.accept(myCardList)
        
        transferTable.snp.updateConstraints { make in
            make.height.equalTo(Double(datas.value.count) * 70.0 - 1)
        }
    }
    
//    @objc func changeMyTransfer(){
//        datas.accept(myPartnerList)
//        
//        transferTable.snp.updateConstraints { make in
//            make.height.equalTo(Double(datas.value.count) * 70.0 - 1)
//        }
//    }
    
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "转账", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    func addView(){
        let img:UIImage = UIImage(named:"zhuanzhang1") ?? UIImage()
        
        let high:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
        
        contentView.addSubview(cardImageV)
        cardImageV.image = img
        cardImageV.isUserInteractionEnabled = true

        cardImageV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(high)
            make.top.equalToSuperview().offset(navigationHeight)
        }
        
        let showCardButton:UIButton = UIButton()
        cardImageV.addSubview(showCardButton)
        showCardButton.isSelected = false
        showCardButton.addTarget(self, action: #selector(showCard(button:)), for: .touchUpInside)
        
        let transferButton:UIButton = UIButton()
        transferButton.addTarget(self, action: #selector(gotoTransfer), for: .touchUpInside)
        cardImageV.addSubview(transferButton)
        
        let transferListButton:UIButton = UIButton()
        transferListButton.addTarget(self, action: #selector(showAllRecord), for: .touchUpInside)
        cardImageV.addSubview(transferListButton)
        
        showCardButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.height.equalTo(80)
            make.top.equalToSuperview().offset(180)
        }
        
        transferButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(80)
            make.width.height.equalTo(100)
        }
        
        transferListButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.height.equalTo(80)
            make.top.equalToSuperview().offset(180)
        }
        
        addMyCardView()
        
        transferTable.register(cardCell.self, forCellReuseIdentifier: "cardCell")
        transferTable.separatorStyle = .none
        transferTable.backgroundColor = .white
        transferTable.rowHeight = 70 // 设置固定高度
        contentView.addSubview(transferTable)
        transferTable.isScrollEnabled = false
//        transferTable.rx.setDelegate(self).disposed(by: disposeBag)
        
        transferTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(myuserView.snp.bottom).offset(1)
            make.height.equalTo(Double(datas.value.count) * 70.0 - 1)
        }
        
        
        // 先绑定数据源
        datas
            .bind(to: transferTable.rx.items(cellIdentifier: "cardCell", cellType: cardCell.self)) { index, model, cell in
                guard let model = model as? TransferPartner else { return }
                cell.addTransferModel(_data: model)
                cell.delegate = self   // 🔑 关键
            }
            .disposed(by: disposeBag)
        
        Observable.zip(transferTable.rx.itemSelected, transferTable.rx.modelSelected(TransferPartner.self))
            .subscribe(onNext: { [weak self] indexPath, model in
                self?.transferTable.deselectRow(at: indexPath, animated: true)
                guard let model = model as? TransferPartner else { return }
                
                let ctrl:TradeCtrl = TradeCtrl()
                ctrl.oldModel = model
                self?.navigationController?.pushViewController(ctrl, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(transferTable.snp.bottom).offset(20)
        }
    }
    
    func addMyCardView(){
        myuserView.backgroundColor = .white
        contentView.addSubview(myuserView)
        myuserView.isUserInteractionEnabled = true
        myuserView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(cardImageV.snp.bottom)
        }
        
        allBtn = creatButton(CGRect.zero, "  全部 \(datas.value.count)  ", fontRegular(14), HXColor(0x6697e0), Main_backgroundColor, self, #selector(showAllPartner))
        myuserView.addSubview(allBtn)
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "最近转账伙伴", fontMedium(18), Main_TextColor)
        myuserView.addSubview(titlelb)
        
        if let avatar = loadUserImage(fileName: "usericon.png") {
            userIcon.image = avatar
        } else {
            userIcon.image = UIImage(named: "user_default")
        }
        myuserView.addSubview(userIcon)
        
        userName.text = myUser?.myName ?? "小招"
        userName.font = fontRegular(16)
        userName.textColor = Main_TextColor
        myuserView.addSubview(userName)
        
        userCards.text = "\(myCardDatas.value.count)"
        userCards.font = fontRegular(12)
        userCards.textColor = fieldPlaceholderColor
        userCards.backgroundColor = Main_backgroundColor
        userCards.textAlignment = .center
        myuserView.addSubview(userCards)
        
        let shareCardlb:UILabel = UILabel()
        shareCardlb.text = "  分享卡号  "
        shareCardlb.font = fontRegular(12)
        shareCardlb.textColor = Main_TextColor
        myuserView.addSubview(shareCardlb)
        
        userRightimg.image = UIImage(named: "user_botttom")
        myuserView.addSubview(userRightimg)
        
        let btn:UIButton = UIButton()
        btn.addTarget(self, action: #selector(showMyCard), for: .touchUpInside)
        myuserView.addSubview(btn)
        
        myCardTable.register(cardCell.self, forCellReuseIdentifier: "myCardCell")
        myCardTable.separatorStyle = .none
        myCardTable.backgroundColor = .white
        myCardTable.rowHeight = 70 // 设置固定高度
        myuserView.addSubview(myCardTable)
        myCardTable.isScrollEnabled = false
        
        userLine.backgroundColor = HXColor(0xf3f3f3)
        myuserView.addSubview(userLine)
        
        allBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(24)
            make.top.equalTo(cardImageV.snp.bottom)
        }
        
        titlelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(18)
            make.centerY.equalTo(allBtn)
        }
        
        userIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.width.equalTo(40)
            make.top.equalTo(titlelb.snp.bottom).offset(35)
        }
        
        userName.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(15)
            make.height.equalTo(20)
            make.centerY.equalTo(userIcon)
        }
        
        userCards.snp.makeConstraints { make in
            make.left.equalTo(userName.snp.right).offset(15)
            make.height.width.equalTo(24)
            make.centerY.equalTo(userName)
        }
        
        shareCardlb.snp.makeConstraints { make in
            make.left.equalTo(userCards.snp.right).offset(15)
            make.height.equalTo(20)
            make.centerY.equalTo(userCards)
        }
        
        btn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalTo(userIcon)
            make.height.equalTo(40)
        }
        
        userRightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(8)
            make.width.equalTo(15)
            make.centerY.equalTo(shareCardlb)
        }
        
        myCardTable.snp.makeConstraints { make in
            make.left.equalTo(userName)
            make.right.equalToSuperview()
            make.height.equalTo(0)
            make.top.equalTo(userIcon.snp.bottom).offset(20)
        }
        
        userLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(70)
            make.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(userIcon.snp.bottom).offset(15)
        }
        
        // 先绑定数据源
        myCardDatas
            .bind(to: myCardTable.rx.items(cellIdentifier: "myCardCell", cellType: cardCell.self)) { index, model, cell in
                guard let model = model as? CardModel else { return }
                cell.addData(_data: model)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(myCardTable.rx.itemSelected, myCardTable.rx.modelSelected(CardModel.self))
            .subscribe(onNext: { [weak self] indexPath, model in
                self?.myCardTable.deselectRow(at: indexPath, animated: true)
                guard let model = model as? CardModel else { return }
                
                print("点击了 cell: \(model)")

            })
            .disposed(by: disposeBag)
        
        myuserView.snp.makeConstraints { make in
            make.bottom.equalTo(myCardTable.snp.bottom).offset(10)
        }
        
        myuserView.layoutIfNeeded()
        
        ViewRadius(allBtn, 12)
        ViewRadius(userIcon, 20)
        ViewRadius(userCards, 12)
        ViewBorderRadius(shareCardlb, 10, 0.5, HXColor(0x6e6e6e))
    }
    
    @objc func showMyCard(){
        isShowCard = !isShowCard
        
        userLine.isHidden = isShowCard
        
        userRightimg.image = UIImage(named: isShowCard ? "user_top" : "user_botttom")
        
        myCardTable.snp.updateConstraints { make in
            if isShowCard == true {
                make.height.equalTo(Double(myCardDatas.value.count) * 70.0)
            }else{
                make.height.equalTo(0)
            }
        }
    }
    
    @objc func showAllPartner(){
        let ctrl:MyPartnerCtrl = MyPartnerCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func showAllRecord(){
        let ctrl:TransferListCtrl = TransferListCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func gotoTransfer(){
        if myCardDatas.value.count > 0 {
            let ctrl:TradeCtrl = TradeCtrl()
            ctrl.enableLazyLoad = true
            ctrl.isIncome = true
            self.navigationController?.pushViewController(ctrl, animated: true)
        }else{
            KWindow?.makeToast("未绑定银行卡", .center, .information)
        }

    }
    
    @objc func showCard(button:UIButton){
        button.isSelected = !button.isSelected
        
        var str:String = "zhuanzhang1"
        if button.isSelected == true {
            str = "zhuanzhang2"
        }else{
            str = "zhuanzhang1"
        }
        
        let img:UIImage = UIImage(named:str) ?? UIImage()
        
        let high:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
        cardImageV.image = img
        cardImageV.snp.updateConstraints { make in
            make.height.equalTo(high)
        }
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    
    //MARK: -  右侧划动操作
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        // 删除按钮
        let deleteAction = SwipeAction(style: .destructive, title: "删除") { action, indexPath in
            print("点击删除 \(indexPath.row)")
            self.handleDeleteAction(at: indexPath)
        }
        deleteAction.backgroundColor = HXColor(0xe7504c)
        deleteAction.textColor = .white
        deleteAction.font = fontMedium(14)
        deleteAction.hidesWhenSelected = true
        
        // 编辑按钮
        let editAction = SwipeAction(style: .default, title: "查看") { action, indexPath in
            print("点击查看 \(indexPath.row)")
            self.handleCheckAction(at: indexPath)
        }
        editAction.backgroundColor = HXColor(0x5995ef)
        editAction.textColor = .white
        editAction.font = fontMedium(14)
        editAction.hidesWhenSelected = true
        
        return [deleteAction, editAction]
    }
    
    // 自定义按钮的宽度
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none   // 禁止全屏滑动触发
        options.maximumButtonWidth = 50 // 最大按钮宽度
        options.minimumButtonWidth = 50  // 最小按钮宽度
        options.buttonVerticalAlignment = .center
        return options
    }

    private func handleCheckAction(at indexPath: IndexPath) {
        // 这里你需要从 datas 中移除对应的数据
        // 假设 datas 是一个 BehaviorRelay<[Any]>
        let currentData = datas.value
        let model:TransferPartner = currentData[indexPath.row]

        let ctrl:TradeCtrl = TradeCtrl()
        ctrl.oldModel = model
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    private func handleDeleteAction(at indexPath: IndexPath) {
        // 这里你需要从 datas 中移除对应的数据
        var myPartnerList = datas.value
        let model:TransferPartner = myPartnerList[indexPath.row]
        myPartnerList.remove(at: indexPath.row)
        
        datas.accept(myPartnerList)
        
        //删除对应转账流水
        myTradeList.removeAllTransactionsOfUser(of: model)
        allBtn.setTitle("  全部 \(datas.value.count)  ", for: .normal)
    }
}

//MARK: - 卡片
class cardCell: SwipeTableViewCell {
    let headImage = UIImageView()
    let titlelb = UILabel()
    let detaillb = UILabel()
    var model:CardModel?
    var transferModel:TransferPartner?
    var isbig:Bool = true
    var handelOrderAction: ((String) -> Void)?
    let topline:UIView = UIView()
    let creditCardlb:UILabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        contentView.backgroundColor = .white
        self.createCellUI()
    }

    func createCellUI(){
        contentView.addSubview(headImage)
        
        titlelb.textColor = Main_TextColor
        titlelb.font = fontRegular(14)
        titlelb.text = "测试"
        contentView.addSubview(titlelb)
        
        creditCardlb.textColor = HXColor(0xc94753)
        creditCardlb.font = fontRegular(10)
        creditCardlb.text = " 信用卡 "
        creditCardlb.backgroundColor = HXColor(0xf7e5db)
        contentView.addSubview(creditCardlb)
        creditCardlb.isHidden = true
        
        detaillb.textColor = Main_detailColor
        detaillb.font = fontRegular(12)
        detaillb.text = "尾号(9999)"
        contentView.addSubview(detaillb)
        
        
        topline.backgroundColor = HXColor(0xf3f3f3)
        contentView.addSubview(topline)
        
        topline.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(70)
            make.right.equalToSuperview()
        }
        
        headImage.snp.makeConstraints { make in
            if isbig == true {
                make.height.width.equalTo(40)
            }else{
                make.height.width.equalTo(34)
            }
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        titlelb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(70)
            make.right.equalToSuperview()
        }
        
        creditCardlb.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.centerY.equalTo(titlelb)
            make.left.equalTo(titlelb).offset(5)
        }

        detaillb.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.bottom.equalToSuperview().offset(-15)
            make.left.right.equalTo(titlelb)
        }
        
        ViewRadius(creditCardlb, 2)
    }

    func addTransferModel(_data:TransferPartner) {
        transferModel = _data
        titlelb.text = _data.name
        detaillb.text =  "\(_data.bankName) (\(_data.lastCard))"
        headImage.image = UIImage(named: _data.icon)
  
        topline.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(70)
        }
        
        headImage.snp.updateConstraints { make in
            make.height.width.equalTo(40)
        }
    }
    
    
    func addData(_data:CardModel) {
        model = _data
        titlelb.text = _data.name
        detaillb.text = ("尾号 (\(_data.lastCard))")
        headImage.image = UIImage(named: _data.icon)
        
        creditCardlb.isHidden = _data.type != "信用卡"
        
        topline.snp.updateConstraints { make in
            make.left.equalToSuperview()
        }
        
        headImage.snp.updateConstraints { make in
            make.height.width.equalTo(30)
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
