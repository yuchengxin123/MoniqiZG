//
//  MyPartnerCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/9/1.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources


extension PartnerSection: SectionModelType {
    typealias Item = TransferPartner
    
    init(original: PartnerSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class MyPartnerCtrl: BaseCtrl, UITableViewDelegate {
    private var didSetupCorner = false
    var isIncome:Bool = false
    let topImageView:UIImageView = UIImageView()
    
    private let transferBag = DisposeBag()
    private let transferTable = UITableView(frame: CGRect.zero, style: .grouped)
    private let datas = BehaviorRelay<[TransferPartner]>(value: [])
    
    private let myCardBag = DisposeBag()
    private let myCardTable = UITableView()
    private let myCardDatas = BehaviorRelay<[CardModel]>(value: [])
    
    // 保存当前分组数据
    private var currentSections: [PartnerSection] = []
    
    private let myuserView:UIView = UIView()
    private let userIcon:UIImageView = UIImageView()
    private let userName:UILabel = UILabel()
    private let userCards:UILabel = UILabel()
    private let userRightimg:UIImageView = UIImageView()
    
    private var isShowCard = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        addHeadView()
    }
 
    
    override func setupUI() {
        super.setupUI()
        contentView.backgroundColor = Main_backgroundColor
        // 生成分组数据
        let myPartnerList = myTradeList.uniquePartnersForTransfer200And201()
        datas.accept(myPartnerList)
        myCardDatas.accept(myCardList)
        
        addView()
    }
    
    // MARK: - 工具方法：按拼音首字母分组
    func groupPartnersByInitial(_ partners: [TransferPartner]) -> [PartnerSection] {
        func pinyinFirstLetter(_ str: String) -> String {
            let mutableString = NSMutableString(string: str) as CFMutableString
            CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
            CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
            let pinyin = mutableString as String
            let first = pinyin.trimmingCharacters(in: .whitespaces).uppercased().first ?? "#"
            return String(first)
        }
        
        var dict: [String: [TransferPartner]] = [:]
        for p in partners {
            let initial = pinyinFirstLetter(p.name)
            if initial >= "A" && initial <= "Z" {
                dict[initial, default: []].append(p)
            } else {
                dict["#", default: []].append(p)
            }
        }
        
        // 按字母顺序排序，# 放最后
        let keys = dict.keys.sorted { lhs, rhs in
            if lhs == "#" { return false }
            if rhs == "#" { return true }
            return lhs < rhs
        }
        
        return keys.map { key in
            PartnerSection(header: key, items: dict[key] ?? [])
        }
    }
    
    
    @objc func gotoEditCtrl(){

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
      
        
        
        let leftButton:UIButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let rightButton:UIButton = creatButton(CGRect.zero, "批量删除", fontRegular(14), Main_TextColor, .clear, self, #selector(gotoEditCtrl))
        rightButton.backgroundColor = .clear
        rightButton.isEnabled = false
        headView.addSubview(rightButton)
        
        rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(leftButton)
            make.centerY.equalTo(leftImg)
        }
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "我的转账伙伴", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    
    func addView(){
        let img:UIImage = (isIncome ? UIImage(named: "partner_head_2") : UIImage(named: "partner_head_1")) ?? UIImage()
        
        let high:CGFloat = img.size.height / img.size.width * SCREEN_WDITH
        
        topImageView.image = img
        contentView.addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(high)
            make.top.equalToSuperview().offset(navigationHeight)
        }

        for index in 0...1 {
            let btn:UIButton = UIButton()
            btn.tag = 100 + index
            btn.addTarget(self, action: #selector(changelist(button:)), for: .touchUpInside)
            contentView.addSubview(btn)
            
            btn.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(navigationHeight)
                make.height.equalTo(40)
                make.width.equalTo(SCREEN_WDITH/2.0 - 15)
                make.left.equalToSuperview().offset((SCREEN_WDITH/2.0 - 15.0)*Double(index) + 15)
            }
        }
        
        if isIncome == false {
            addMyCardView()
        }
        
        
        transferTable.register(cardCell.self, forCellReuseIdentifier: "cardCell")
        transferTable.separatorStyle = .none
        transferTable.backgroundColor = .white
        transferTable.rowHeight = 70 // 设置固定高度
        transferTable.sectionHeaderHeight = 30
        transferTable.sectionFooterHeight = 0

        transferTable.isScrollEnabled = false
        
        // 禁止系统自动调整 contentInset（特别是在有 navigationController 时）
        transferTable.contentInsetAdjustmentBehavior = .never
        transferTable.contentInset = UIEdgeInsets.zero
        // iOS 15+ 需要设置这个来移除 section header 顶部间距
        if #available(iOS 15.0, *) {
            transferTable.sectionHeaderTopPadding = 0
        }
        contentView.addSubview(transferTable)
        
        transferTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            if isIncome == true {
                make.top.equalTo(topImageView.snp.bottom)
            }else{
                make.top.equalTo(myuserView.snp.bottom).offset(1)
            }
            make.height.equalTo(1)
        }
        

        // 数据源
        let dataSource = RxTableViewSectionedReloadDataSource<PartnerSection>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! cardCell
              //  cell.addTransferModel(_data: item)
                return cell
            }
        )
        
        // ✅ 绑定 myPartnerList → 分组 → tableView
        //.map 相当于先映射数据做做处理后返回新的数据格式 在通过bind 绑定
        datas
            .map { self.groupPartnersByInitial($0) }
            .do(onNext: { [weak self] sections in
                self?.currentSections = sections   // ✅ 保存最新的分组
                
                let rowHeight = 70.0
                let headerHeight = 30.0
                let totalHeight = Double(self?.datas.value.count ?? 0) * rowHeight
                                 + Double(sections.count) * headerHeight
                
                // 延迟更新约束，保证第 0 组 header 布局完成
                DispatchQueue.main.async {
                    self?.transferTable.snp.updateConstraints { make in
                        make.height.equalTo(totalHeight)
                    }
                    self?.transferTable.reloadData()
                }
            })
            .bind(to: transferTable.rx.items(dataSource: dataSource))
            .disposed(by: transferBag)
        
        // 点击事件
        transferTable.rx.modelSelected(TransferPartner.self)
            .subscribe(onNext: { [weak self] model in
                let ctrl = TradeCtrl()
                ctrl.oldModel = model
                ctrl.isIncome = self?.isIncome ?? false
                self?.navigationController?.pushViewController(ctrl, animated: true)
            })
            .disposed(by: transferBag)
        
        // 设置 delegate
        transferTable.rx.setDelegate(self).disposed(by: transferBag)
        
        let remindlb:UILabel = creatLabel(CGRect.zero, "说明：\n1、“转入”转账伙伴是您近期收到转账的（部分）付款账户信息，您可以通过“左滑”操作删除这些转账伙伴。", fontRegular(12), fieldPlaceholderColor)
        remindlb.numberOfLines = 0
        contentView.addSubview(remindlb)
        
        remindlb.snp.makeConstraints { make in
            make.top.equalTo(transferTable.snp.bottom).offset(50)
            make.left.right.equalToSuperview().inset(15)
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(remindlb.snp.bottom).offset(20)
        }
        
    }
    
    func addMyCardView(){
        myuserView.backgroundColor = .white
        contentView.addSubview(myuserView)
        myuserView.isUserInteractionEnabled = true
        myuserView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom)
        }
        
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
        
        
        userIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.width.equalTo(40)
            make.top.equalToSuperview().offset(30)
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
        
        
        btn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalTo(userIcon)
            make.height.equalTo(40)
        }
        
        userRightimg.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(8)
            make.width.equalTo(15)
            make.centerY.equalTo(userName)
        }
        
        myCardTable.snp.makeConstraints { make in
            make.left.equalTo(userName)
            make.right.equalToSuperview()
            make.height.equalTo(0)
            make.top.equalTo(userIcon.snp.bottom).offset(20)
        }
        
        
        // 先绑定数据源
        myCardDatas
            .bind(to: myCardTable.rx.items(cellIdentifier: "myCardCell", cellType: cardCell.self)) { index, model, cell in
                guard let model = model as? CardModel else { return }
                cell.addData(_data: model)
            }
            .disposed(by: myCardBag)
        
        Observable.zip(myCardTable.rx.itemSelected, myCardTable.rx.modelSelected(CardModel.self))
            .subscribe(onNext: { [weak self] indexPath, model in
                self?.myCardTable.deselectRow(at: indexPath, animated: true)
                guard let model = model as? CardModel else { return }
                
                print("点击了 cell: \(model)")

            })
            .disposed(by: myCardBag)
        
        myuserView.snp.makeConstraints { make in
            make.bottom.equalTo(myCardTable.snp.bottom).offset(10)
        }
        
        myuserView.layoutIfNeeded()
        
        ViewRadius(userIcon, 20)
        ViewRadius(userCards, 12)
    }
    
    @objc func showMyCard(){
        isShowCard = !isShowCard

        userRightimg.image = UIImage(named: isShowCard ? "user_top" : "user_botttom")
        
        myCardTable.snp.updateConstraints { make in
            if isShowCard == true {
                make.height.equalTo(Double(myCardDatas.value.count) * 70.0)
            }else{
                make.height.equalTo(0)
            }
        }
    }
    
    @objc func changelist(button:UIButton){
        let ctrl:MyPartnerCtrl = MyPartnerCtrl()
        ctrl.enableLazyLoad = true
        ctrl.isIncome = (button.tag != 100)
        pushAndCloseCtrl(ctrl)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    // Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = Main_backgroundColor
        let headerTitle = currentSections[section].header   // ✅ 对应的 A / B / C ...
        
        let titlelb:UILabel = creatLabel(CGRect.init(x: 15, y: 5, width: SCREEN_WDITH - 30, height: 25), headerTitle, fontMedium(14), fieldPlaceholderColor)
        container.addSubview(titlelb)
        return container
    }
}
