//
//  SelectBankCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/18.
//

import UIKit
import CoreLocation
import SnapKit
import RxSwift
import RxCocoa

class SelectBankCtrl: BaseCtrl {
    
    var onTap: ((Dictionary<String,Any>) -> Void)?
    
    private var didSetupCorner = false
    let cardImageV:UIImageView = UIImageView()
    
    private let disposeBag = DisposeBag()
    
    private let CardTable = UITableView(frame: CGRect.zero, style: .grouped)
    private let CardDatas = BehaviorRelay<[Dictionary<String,Any>]>(value: [])
    
//    private var displayedData: [[String: Any]] = [] // 当前显示的数据
//    private let batchSize = 20 // 每次加载的数据量
//    private var currentIndex = 0 // 当前加载到的索引
    
    
    private var listArray:Array<Dictionary<String,Any>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        addHeadView()
    }

    override func setupUI() {
        super.setupUI()
        
        addView()
        
//        loadInitialData()
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
        
        
        let leftButton:UIButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "选择所属银行", fontMedium(18), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    func addView(){
        let img:UIImage = UIImage(named:"transfer_field") ?? UIImage()
        
        let high:CGFloat = img.size.height/img.size.width * (SCREEN_WDITH - 30)
        
        let headimg:UIImageView = UIImageView()
        headimg.image = img
        contentView.addSubview(headimg)
        
        headimg.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(navigationHeight+2)
            make.height.equalTo(high)
        }
        
        CardTable.register(BankCell.self, forCellReuseIdentifier: "BankCell")
        CardTable.separatorStyle = .none
        CardTable.backgroundColor = .white
        CardTable.rowHeight = 50 // 设置固定高度
        CardTable.sectionHeaderHeight = 35
        CardTable.sectionFooterHeight = 0
        view.addSubview(CardTable)

        CardTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headimg.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        CardTable.backgroundColor = .white
        
        
        // 先绑定数据源
        CardDatas
            .bind(to: CardTable.rx.items(cellIdentifier: "BankCell", cellType: BankCell.self)) { index, model, cell in
                cell.addData(_data: model)
            }
            .disposed(by: disposeBag)
        
        // 监听滚动事件，实现无限滚动
//        CardTable.rx.didScroll
//            .subscribe(onNext: { [weak self] in
//                self?.checkForMoreData()
//            })
//            .disposed(by: disposeBag)
        
        Observable.zip(CardTable.rx.itemSelected, CardTable.rx.modelSelected([String:Any].self))
            .subscribe(onNext: { [weak self] indexPath, model in
                self?.CardTable.deselectRow(at: indexPath, animated: true)
                print("转账: \(model)")
                if self?.onTap != nil {
                    self?.onTap!(model)
                }
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
    }
    
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
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
}


class BankCell: UITableViewCell {
    let icon = UIImageView()
    let titlelb = UILabel()
    var model:Dictionary<String,Any>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.createCellUI()
    }

    func createCellUI(){
        contentView.backgroundColor = .white
        
        contentView.addSubview(icon)
        
        let line:UIView = UIView()
        line.backgroundColor = defaultLineColor
        contentView.addSubview(line)
        
        titlelb.font = fontRegular(16)
        titlelb.textColor = Main_TextColor
        contentView.addSubview(titlelb)
        
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
            make.left.equalToSuperview().offset(15)
        }
        
        titlelb.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(15)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        line.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(1)
        }
    }

    
    func addData(_data:Dictionary<String,Any>,_isbig:Bool = true) {
        model = _data
         
        titlelb.text = _data["bankName"] as? String
        
        icon.image = UIImage(named: "bank_type_\(_data["cardIconInt"] ?? "")") ?? UIImage()
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
