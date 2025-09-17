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
    
    private let userIcon:UIImageView = UIImageView()
    private let userCards:UILabel = UILabel()
    private let userRightimg:UIImageView = UIImageView()
    
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "转账汇款", fontRegular(19), Main_TextColor)
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
        
        let high:CGFloat = img.size.height/img.size.width * (SCREEN_WDITH - 30)
        
        contentView.addSubview(cardImageV)
        cardImageV.image = img
        cardImageV.isUserInteractionEnabled = true

        cardImageV.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(high)
            make.top.equalToSuperview().offset(navigationHeight)
        }
        
        let transferButton:UIButton = UIButton()
        transferButton.tag = 100
        transferButton.addTarget(self, action: #selector(gotoTransfer(button:)), for: .touchUpInside)
        cardImageV.addSubview(transferButton)
        
        let phoneButton:UIButton = UIButton()
        phoneButton.tag = 101
        phoneButton.addTarget(self, action: #selector(gotoTransfer(button:)), for: .touchUpInside)
        cardImageV.addSubview(phoneButton)
        
        let transferListButton:UIButton = UIButton()
        transferListButton.addTarget(self, action: #selector(showAllRecord), for: .touchUpInside)
        cardImageV.addSubview(transferListButton)
        
        transferButton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(high - 40)
            make.width.equalTo(SCREEN_WDITH/3.0 - 10)
        }
        
        phoneButton.snp.makeConstraints { make in
            make.top.equalTo(transferButton)
            make.left.equalTo(transferButton.snp.right)
            make.height.equalTo(high - 40)
            make.width.equalTo(SCREEN_WDITH/3.0 - 10)
        }
        
        transferListButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(SCREEN_WDITH/2.0)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        
        addMyCardView()
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(transferTable.snp.bottom).offset(20)
        }
        
        setupViewWithRoundedCornersAndShadow(
            cardImageV,
            radius: 10.0,
            corners: [.topLeft, .topRight , .bottomLeft,.bottomRight], // 示例: 左上+右下圆角
            borderWidth: 0,
            borderColor: .white,
            shadowColor: .lightGray, // 浅灰色阴影
            shadowRadius: 10,         // 柔和扩散效果
            shadowOpacity: 0.2       // 浅色透明度
        )
    }
    
    func addMyCardView(){
        allBtn = creatButton(CGRect.zero, "全部", fontRegular(14), HXColor(0x6697e0), .white, self, #selector(showAllPartner))
        contentView.addSubview(allBtn)
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "常用收款人", fontMedium(16), Main_TextColor)
        contentView.addSubview(titlelb)
        
        let line:UIView = UIView()
        line.backgroundColor = Main_detailColor
        contentView.addSubview(line)
        
        if let avatar = loadUserImage(fileName: "usericon.png") {
            userIcon.image = avatar
        } else {
            userIcon.image = UIImage(named: "user_default")
        }
        contentView.addSubview(userIcon)
        
        
        userCards.text = "我的账户(\(myCardDatas.value.count))"
        userCards.font = fontRegular(12)
        userCards.textColor = Main_TextColor
        userCards.backgroundColor = .white
        contentView.addSubview(userCards)
        
        
        userRightimg.image = UIImage(named: "user_botttom")
        contentView.addSubview(userRightimg)
        
        let btn:UIButton = UIButton()
        btn.addTarget(self, action: #selector(showMyCard), for: .touchUpInside)
        contentView.addSubview(btn)
        
        myCardTable.register(cardCell.self, forCellReuseIdentifier: "myCardCell")
        myCardTable.separatorStyle = .none
        myCardTable.backgroundColor = .white
        myCardTable.rowHeight = 70 // 设置固定高度
        contentView.addSubview(myCardTable)
        myCardTable.isScrollEnabled = false
        
        
        allBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(24)
            make.top.equalTo(cardImageV.snp.bottom).offset(20)
        }
        
        titlelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(24)
            make.centerY.equalTo(allBtn)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(titlelb.snp.bottom).offset(15)
        }
        
        userIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(40)
            make.top.equalTo(line.snp.bottom).offset(15)
        }
        
        userCards.snp.makeConstraints { make in
            make.left.equalTo(userIcon.snp.right).offset(15)
            make.height.equalTo(24)
            make.centerY.equalTo(userIcon)
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
            make.centerY.equalTo(titlelb)
        }
        
        myCardTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
            make.top.equalTo(userIcon.snp.bottom).offset(20)
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
        
        
        ViewRadius(userIcon, 20)
    }
    
    @objc func showMyCard(){
        isShowCard = !isShowCard
        
        
        userRightimg.image = UIImage(named: isShowCard ? "user_top" : "user_bottom")
        
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
    
    @objc func gotoTransfer(button:UIButton){
        if myCardDatas.value.count > 0 {
            let ctrl:TradeCtrl = TradeCtrl()
            ctrl.enableLazyLoad = true
            ctrl.isIncome = true
            self.navigationController?.pushViewController(ctrl, animated: true)
        }else{
            KWindow?.makeToast("未绑定银行卡", .center, .information)
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
    var handelOrderAction: ((String) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        contentView.backgroundColor = HXColor(0xfafafa)
        self.createCellUI()
    }

    func createCellUI(){
        contentView.addSubview(headImage)
        
        titlelb.textColor = HXColor(0xa3a3a3)
        titlelb.font = fontRegular(14)
        titlelb.text = "尾号 9999 长城电子借记卡"
        contentView.addSubview(titlelb)
        
        
        detaillb.textColor = HXColor(0x613000)
        detaillb.font = fontRegular(12)
        detaillb.text = "  个人养老金  "
        detaillb.backgroundColor = HXColor(0xf2e6d2)
        detaillb.textAlignment = .center
        contentView.addSubview(detaillb)
        
        
        headImage.snp.makeConstraints { make in
            make.height.width.equalTo(34)
            make.left.equalToSuperview().offset(50)
            make.centerY.equalToSuperview()
        }
        
        titlelb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerY.equalTo(headImage)
            make.left.equalTo(headImage.snp.right).offset(20)
        }
        
        detaillb.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        
        ViewRadius(detaillb, 2)
        
        detaillb.isHidden = true
    }
    
    func addData(_data:CardModel) {
        model = _data
        titlelb.text = ("尾号 \(_data.lastCard) \(_data.bank)")
        headImage.image = UIImage(named: _data.icon)
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
