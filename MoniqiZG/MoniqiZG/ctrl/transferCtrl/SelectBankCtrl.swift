//
//  SelectBankCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/18.
//

import UIKit
import CoreLocation
import SnapKit

class SelectBankCtrl: BaseCtrl,UITableViewDelegate,UITableViewDataSource,IndexViewDelegate {
    
    var onTap: ((Dictionary<String,Any>) -> Void)?
    var isPhone:Bool = false
    private var didSetupCorner = false
    let cardImageV:UIImageView = UIImageView()
    private let CardTable = UITableView(frame: CGRect.zero, style: .plain)
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
        //
        let img:UIImage = UIImage(named:isPhone ? "transfer_field_phone" : "transfer_field") ?? UIImage()
        
        let high:CGFloat = img.size.height/img.size.width * (isPhone ? SCREEN_WDITH : (SCREEN_WDITH - 30))
        
        let headimg:UIImageView = UIImageView()
        headimg.image = img
        contentView.addSubview(headimg)
        
        headimg.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(isPhone ? 0 : 15)
            make.top.equalToSuperview().offset(navigationHeight+2)
            make.height.equalTo(high)
        }
        
        CardTable.register(BankCell.self, forCellReuseIdentifier: "BankCell")
        CardTable.separatorStyle = .none
        CardTable.backgroundColor = .white
        CardTable.rowHeight = 50 // 设置固定高度
        CardTable.sectionHeaderHeight = 35
        CardTable.sectionFooterHeight = 0.1
        CardTable.delegate = self
        CardTable.dataSource = self
        view.addSubview(CardTable)
        //禁用自动调整（推荐）
        CardTable.contentInsetAdjustmentBehavior = .never
        CardTable.contentInset = UIEdgeInsets.zero
        // iOS 15+ 需要设置这个来移除 section header 顶部间距
        if #available(iOS 15.0, *) {
            CardTable.sectionHeaderTopPadding = 0
        }
        CardTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headimg.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        CardTable.backgroundColor = .white
        
        let indexView = IndexView(titles: letterSection)
        indexView.delegate = self
        view.addSubview(indexView)
        
        indexView.snp.makeConstraints { make in
            make.centerY.equalTo(CardTable)
            make.right.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(18 * letterSection.count)
        }
        
        ViewRadius(headimg, 4)
    }
    
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankSection[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return bankSection.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return letterSection[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic:[String: Any] = bankSection[indexPath.section][indexPath.row]
        if self.onTap != nil {
            self.onTap!(dic)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dic:[String: Any] = bankSection[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankCell", for: indexPath) as! BankCell
        cell.addData(_data: dic)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = Main_backgroundColor
        
        let title:String = letterSection[section]
        let lb:UILabel = creatLabel(CGRect(x: 15, y: 10, width: SCREEN_WDITH - 30, height: 15), title, fontRegular(14), Main_TextColor)
        container.addSubview(lb)

        return container;
    }
    
    func indexView(_ indexView: IndexView, didSelect index: Int, title: String) {
        print("选中了 \(title) at index: \(index)")
        
        guard index < bankSection.count else { return }
        let section = index
        
        if bankSection[section].isEmpty {
            // 如果该 section 没有内容，可以选择滚动到 header
            let rect = CardTable.rectForHeader(inSection: index)
            CardTable.scrollRectToVisible(rect, animated: true)
        } else {
            // 滚动到该 section 的第一行
            CardTable.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
        }
    }
}


class BankCell: UITableViewCell {
    let icon = UIImageView()
    let titlelb = UILabel()
    let otherlb = UILabel()
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
        
        titlelb.font = fontRegular(15)
        titlelb.textColor = Main_TextColor
        contentView.addSubview(titlelb)
        
        otherlb.font = fontRegular(10)
        otherlb.textColor = .white
        otherlb.text = "其他"
        otherlb.textAlignment = .center
        otherlb.backgroundColor = HXColor(0x0066ef)
        contentView.addSubview(otherlb)
        
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
            make.left.equalToSuperview().offset(15)
        }
        
        titlelb.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(icon.snp.right).offset(15)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        otherlb.snp.makeConstraints { make in
            make.edges.equalTo(icon)
        }
        
        line.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(1)
        }
        
        ViewRadius(otherlb, 13)
        otherlb.isHidden = true
    }

    
    func addData(_data:Dictionary<String,Any>,_isbig:Bool = true) {
        model = _data
        titlelb.text = _data["bankName"] as? String
        
        let img = UIImage(named: "bank_type_\(_data["cardIconInt"] ?? "")")
        if img != nil {
            icon.image = img
            
            icon.isHidden = false
            otherlb.isHidden = true
        }else{
            icon.isHidden = true
            otherlb.isHidden = false
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
