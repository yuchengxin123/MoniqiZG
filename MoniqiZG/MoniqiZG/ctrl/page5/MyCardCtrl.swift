//
//  MyCardCtrl.swift
//  MoniqiZG
//
//  Created by apple on 2025/8/17.
//
import UIKit
import CoreLocation
import SnapKit
import RxSwift
import RxCocoa

class MyCardCtrl: BaseCtrl {
    
    private var didSetupCorner = false
    
    private let datas = BehaviorRelay<[CardModel]>(value: [])
    private var tableView:UITableView = UITableView()
    private let cardtitle:UILabel = UILabel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        addTap = true;
        
        
        addHeadView()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(uploadMyCard(noti:)), name: NSNotification.Name(rawValue: addMyCardNotificationName), object: nil)
    }
    
    override func setupUI() {
        super.setupUI()
        addView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datas.accept(myCardList)
        cardtitle.text = "我的银行卡(\(datas.value.count)张)"
    }
    
//    @objc func uploadMyCard(noti:NSNotification){
//        datas.accept(myCardList)
//        cardtitle.text = "我的银行卡(\(datas.value.count)张)"
//    }
    
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "银行卡", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    func addView(){
        datas.accept(myCardList)
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(SCREEN_HEIGTH)
        }
        contentView.layoutIfNeeded()
        
        let rotView:UIView = UIView()
        rotView.backgroundColor = Main_Color
        contentView.addSubview(rotView)
        
        let headtitle:UILabel = UILabel()
        headtitle.text = "【每月可抽】体验功能抽纸巾、小招喵周边！"
        headtitle.font = fontRegular(14)
        headtitle.textColor = Main_TextColor
        contentView.addSubview(headtitle)
        
        cardtitle.font = fontMedium(16)
        cardtitle.textColor = Main_TextColor
        cardtitle.text = "我的银行卡(\(datas.value.count)张)"
        contentView.addSubview(cardtitle)
        
        let btn:UIButton = creatButton(CGRect.zero, "➕ 添加", fontMedium(12), Main_TextColor, .white, self, #selector(addCard))
        contentView.addSubview(btn)
        
        tableView.register(BigCardCell.self, forCellReuseIdentifier: "BigCardCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = Main_backgroundColor
        tableView.rowHeight = 210 // 设置固定高度
        contentView.addSubview(tableView)
        
        
        headtitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(35)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(navigationHeight + 10)
        }
        
        rotView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.width.height.equalTo(6)
            make.centerY.equalTo(headtitle)
        }
        
        cardtitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.top.equalTo(headtitle.snp.bottom).offset(25)
        }
        
        btn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(32)
            make.width.equalTo(80)
            make.centerY.equalTo(cardtitle)
        }
        
        tableView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(btn.snp.bottom).offset(5)
        }
        
        // 先绑定数据源
        datas
            .bind(to: tableView.rx.items(cellIdentifier: "BigCardCell", cellType: BigCardCell.self)) { index, model, cell in
                guard let model = model as? CardModel else { return }
                cell.addData(_data: model)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(CardModel.self))
            .subscribe(onNext: { [weak self] indexPath, model in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                //                guard let model = model as? OrderModel else { return }
                
                print("转账: \(model)")
            })
            .disposed(by: disposeBag)
        
        
        
        ViewBorderRadius(btn, 24, 1, Main_TextColor)
        ViewRadius(btn, 16)
        ViewRadius(rotView, 3)
    }
    
    @objc func addCard(){
        let ctlr:AddCardCtrl = AddCardCtrl()
        self.navigationController?.pushViewController(ctlr, animated: true)
    }
}
    
class BigCardCell: UITableViewCell {
    let headImage = UIImageView()
    let titlelb = UILabel()
    let detaillb = UILabel()
    var model:CardModel?
    let bigView:UIView = UIView()
    let bottomView:UIView = UIView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.createCellUI()
    }

    func createCellUI(){
        self.contentView.backgroundColor = Main_backgroundColor
        
        bigView.backgroundColor = .white
        contentView.addSubview(bigView)
        
        bigView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(6)
            make.width.equalTo(SCREEN_WDITH - 30)
            make.height.equalTo(200)
        }
//        headImage.contentMode = UIView.ContentMode.top
        bigView.addSubview(headImage)
        
        bigView.addSubview(bottomView)
        bottomView.backgroundColor = .white
        
        
        titlelb.textColor = Main_TextColor
        titlelb.font = fontMedium(18)
        titlelb.text = "**** 1111"
        bigView.addSubview(titlelb)
        
        detaillb.textColor = Main_TextColor
        detaillb.font = fontRegular(14)
        detaillb.text = "储蓄卡(I类)|深圳雅宝支行"
        bigView.addSubview(detaillb)
        
        
        headImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { make in
            make.height.equalTo(75)
            make.left.right.bottom.equalToSuperview()
        }
        
        titlelb.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(bottomView).offset(12)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
        }

        detaillb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(titlelb.snp.bottom).offset(2)
            make.left.right.equalTo(titlelb)
        }
        
        
        bigView.layoutIfNeeded()
        
        ViewRadius(bigView, 15)
        
//        setupViewWithRoundedCornersAndShadow(
//            bigView,
//            radius: 15,
//            corners: [.topLeft, .topRight , .bottomLeft , .bottomRight], // 示例: 左上+右下圆角
//            shadowColor: Main_backgroundColor, // 浅灰色阴影
//            shadowRadius: 15,         // 柔和扩散效果
//            shadowOpacity: 0.2       // 浅色透明度
//        )
    }

    
    func addData(_data:CardModel,_isbig:Bool = true) {
        model = _data
         
        titlelb.text = "**** \(_data.lastCard)"
        
        if _data.type == "储蓄卡" {
            headImage.image = UIImage(named: "zhaoshang_card_1")
            detaillb.text = "\(_data.type)(\(_data.leave)) | \(_data.bank)"
        }else{
            headImage.image = UIImage(named: "zhaoshang_card_2")
            detaillb.text = _data.type
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

