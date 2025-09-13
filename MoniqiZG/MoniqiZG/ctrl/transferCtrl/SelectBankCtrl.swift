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

class SelectBankCtrl: BaseCtrl,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var onTap: ((Dictionary<String,Any>) -> Void)?
    
    private var didSetupCorner = false
    let cardImageV:UIImageView = UIImageView()
    
    private let disposeBag = DisposeBag()
    
    private let CardTable = UITableView()
    private let CardDatas = BehaviorRelay<[Dictionary<String,Any>]>(value: [])
    
    private var displayedData: [[String: Any]] = [] // 当前显示的数据
    private let batchSize = 20 // 每次加载的数据量
    private var currentIndex = 0 // 当前加载到的索引
    
    
    private var listArray:Array<Dictionary<String,Any>> = []
    
    private lazy var cardCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.register(BankIconCell.self, forCellWithReuseIdentifier: "BankIconCell")
        return cv
    }()
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicScrollView.delegate = self
        basicScrollView.bounces = false
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor
        
        listArray = hotBank

        addHeadView()
    }

    override func setupUI() {
        super.setupUI()
        
        addView()
        
        loadInitialData()
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "选择银行", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    func addView(){
        let img:UIImage = UIImage(named:"selectbankhead") ?? UIImage()
        
        let high:CGFloat = img.size.height/img.size.width * SCREEN_WDITH
        
        let headView:UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: high + 95.0 * 4 + 30))
        headView.backgroundColor = Main_backgroundColor
        
        
        let headimg:UIImageView = UIImageView()
        headimg.image = img
        headView.addSubview(headimg)
        
        headView.addSubview(cardCollectionView)
        
        headimg.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(high)
        }
        
        cardCollectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headimg.snp.bottom)
        }
        
        CardTable.register(BankCell.self, forCellReuseIdentifier: "BankCell")
        CardTable.separatorStyle = .none
        CardTable.backgroundColor = .white
        CardTable.rowHeight = 50 // 设置固定高度
        CardTable.tableHeaderView = headView
        view.addSubview(CardTable)

        CardTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(navigationHeight)
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
        CardTable.rx.didScroll
            .subscribe(onNext: { [weak self] in
                self?.checkForMoreData()
            })
            .disposed(by: disposeBag)
        
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
    
    private func loadInitialData() {
        // 初始加载第一批数据
        loadMoreData()
    }
    
    private func loadMoreData() {
        guard currentIndex < bankList.count else { return }
        
        let endIndex = min(currentIndex + batchSize, bankList.count)
        let newData = Array(bankList[currentIndex..<endIndex])
        
        displayedData.append(contentsOf: newData)
        CardDatas.accept(displayedData)
        
        currentIndex = endIndex
    }
    
    private func checkForMoreData() {
        let offsetY = CardTable.contentOffset.y
        let contentHeight = CardTable.contentSize.height
        let frameHeight = CardTable.frame.size.height
        
        // 当滚动到底部时加载更多数据
        if offsetY > contentHeight - frameHeight - 100 {
            loadMoreData()
        }
    }
    
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BankIconCell", for: indexPath) as? BankIconCell else {
            return UICollectionViewCell()
        }
        cell.addData(_data: listArray[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(SCREEN_WDITH/4.0, 95.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        let model:Dictionary<String,Any> = listArray[indexPath.row]
        print("model=\(model)")
        if self.onTap != nil {
            self.onTap!(model)
        }
        self.navigationController?.popViewController(animated: true)
    }
}


class BankIconCell: UICollectionViewCell {
    let titlelb:UILabel = UILabel()
    let icon:UIImageView = UIImageView()
    var model:Dictionary<String,Any>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(icon)
        
        titlelb.font = fontMedium(12)
        titlelb.textColor = Main_TextColor
        titlelb.textAlignment = .center
        titlelb.numberOfLines = 0
        addSubview(titlelb)
        
        icon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(10)
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
        
        titlelb.font = fontMedium(14)
        titlelb.textColor = Main_TextColor
        contentView.addSubview(titlelb)
        
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(1)
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
