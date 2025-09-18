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

class TransferCtrl: BaseCtrl,UIScrollViewDelegate {
    
    private var didSetupCorner = false
    let cardImageV:UIImageView = UIImageView()
    
    private let disposeBag = DisposeBag()
    
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
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = .white
        addHeadView()
    }

    override func setupUI() {
        super.setupUI()
        addView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myCardDatas.accept(myCardList)
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "转账汇款", fontMedium(18), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    func addView(){
        let img:UIImage = UIImage(named:"zhuanzhang") ?? UIImage()
        
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
            make.bottom.equalTo(myCardTable.snp.bottom)
        }
        
        self.view.layoutIfNeeded()
        
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
        line.backgroundColor = defaultLineColor
        contentView.addSubview(line)
        
        if let avatar = loadUserImage(fileName: "usericon.png") {
            userIcon.image = avatar
        } else {
            userIcon.image = UIImage(named: "user_icon_default")
        }
        contentView.addSubview(userIcon)
        
        
        userCards.text = "我的账户(\(myCardDatas.value.count))"
        userCards.font = fontMedium(16)
        userCards.textColor = Main_TextColor
        userCards.backgroundColor = .white
        contentView.addSubview(userCards)
        
        
        userRightimg.image = UIImage(named: "user_bottom")
        contentView.addSubview(userRightimg)
        
        let btn:UIButton = UIButton()
        btn.addTarget(self, action: #selector(showMyCard), for: .touchUpInside)
        contentView.addSubview(btn)
        
        myCardTable.register(cardCell.self, forCellReuseIdentifier: "myCardCell")
        myCardTable.separatorStyle = .none
        myCardTable.backgroundColor = .white
        myCardTable.rowHeight = 50 // 设置固定高度
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
            make.height.equalTo(0.5)
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
            make.width.height.equalTo(24)
            make.centerY.equalTo(userCards)
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
                cell.showDetaillb(show: index == 1 )
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
                make.height.equalTo(Double(myCardDatas.value.count) * 50.0)
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
        
        titlelb.textColor = HXColor(0x777777)
        titlelb.font = fontRegular(14)
        titlelb.text = "尾号 9999 长城电子借记卡"
        contentView.addSubview(titlelb)
        
        
        detaillb.textColor = HXColor(0x643405)
        detaillb.font = fontRegular(12)
        detaillb.text = "  个人养老金  "
        detaillb.backgroundColor = HXColor(0xf2e6d2)
        contentView.addSubview(detaillb)
        
        
        headImage.snp.makeConstraints { make in
            make.height.width.equalTo(34)
            make.left.equalToSuperview().offset(40)
            make.centerY.equalToSuperview()
        }
        
        titlelb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerY.equalTo(headImage)
            make.left.equalTo(headImage.snp.right).offset(20)
        }
        
        detaillb.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        
        ViewRadius(detaillb, 2)
        ViewRadius(headImage, 17)
        
        detaillb.isHidden = true
    }
    
    func addData(_data:CardModel) {
        model = _data
        titlelb.text = ("尾号 \(_data.lastCard) \(_data.bank)")
        headImage.image = UIImage(named: _data.icon)
    }
    
    func showDetaillb(show:Bool) {
        detaillb.isHidden = !show
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
