//
//  Untitled.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TransferListCtrl: BaseCtrl,UITableViewDelegate,UITableViewDataSource {
    
    private var didSetupCorner = false
    private let myTransferTable = UITableView(frame: .zero, style: .grouped)
    private var monthSections: [TransferMonthSection] = []
    
    let bottomimg:UIImage = UIImage(named: "jiaoyijilu_bottom") ?? UIImage()
    var bottomhigh:CGFloat = 0
    
    let topimg:UIImage = UIImage(named: "jiaoyijilu_head") ?? UIImage()
    var tophigh:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        contentView.backgroundColor = Main_backgroundColor
        basicScrollView.isScrollEnabled = true

        addHeadView()
    }
 
    override func setupUI() {
        super.setupUI()
        monthSections = myTradeList.groupedTransfersOnly()
        addView()
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
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "转账记录查询", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    
    func addView(){
        contentView.snp.makeConstraints { make in
            make.height.equalTo(SCREEN_HEIGTH)
        }
        
        bottomhigh = bottomimg.size.height/bottomimg.size.width * SCREEN_WDITH
        tophigh = topimg.size.height/topimg.size.width * SCREEN_WDITH
        
        myTransferTable.register(TransferCell.self, forCellReuseIdentifier: "TransferCell")
        myTransferTable.separatorStyle = .none
        myTransferTable.backgroundColor = .white
        myTransferTable.rowHeight = 70 // 设置固定高度
        myTransferTable.delegate = self
        myTransferTable.dataSource = self
        contentView.addSubview(myTransferTable)
        
        myTransferTable.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(navigationHeight)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ctrl:TransferDetailCtrl = TransferDetailCtrl()
        ctrl.model = monthSections[indexPath.section].records[indexPath.row]
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return monthSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthSections[section].records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = monthSections[indexPath.section].records[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransferCell", for: indexPath) as! TransferCell
        cell.addTransferModel(_data: model)
        return cell
    }
    
    // 日期头部
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerTitle = monthSections[section].displayTitle  // ✅ 对应的 A / B / C ...
        
        if section == 0 {

            let container = UIView()
            container.backgroundColor = Main_backgroundColor
            
            let img:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: tophigh))
            img.image = topimg
            container.addSubview(img)
            
            let titlelb:UILabel = creatLabel(CGRect.init(x: 15, y: tophigh, width: SCREEN_WDITH - 30, height: 25), headerTitle, fontMedium(14), fieldPlaceholderColor)
            container.addSubview(titlelb)
            
            let headImg:UIImageView = UIImageView()
            headImg.image = bottomimg
            return container
            
        } else {
            let container = UIView()
            container.backgroundColor = Main_backgroundColor
            
            let titlelb:UILabel = creatLabel(CGRect.init(x: 15, y: 5, width: SCREEN_WDITH - 30, height: 25), headerTitle, fontMedium(14), fieldPlaceholderColor)
            container.addSubview(titlelb)
            
            return container
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == monthSections.count - 1 {
            let headImg:UIImageView = UIImageView()
            headImg.image = bottomimg
            return headImg
        } else {
            let container = UIView()
            container.backgroundColor = Main_backgroundColor
            return container
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == (monthSections.count - 1)  ? bottomhigh : 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0  ? (tophigh + 30) : 30
    }
    
    @objc func gotoTransfer(){
        let ctrl:TransferDetailCtrl = TransferDetailCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    @objc func closeCtrl(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func gotoMyAmountCtrl(){
        let ctrl:MyAmountCtrl = MyAmountCtrl()
        ctrl.enableLazyLoad = true
        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
}


class TransferCell: UITableViewCell {
    let headImage = UIImageView()
    let titlelb = UILabel()
    let detaillb = UILabel()
    let moneylb = UILabel()
    var transferModel:TransferModel?
    let topline:UIView = UIView()
    
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
        titlelb.font = fontRegular(16)
        titlelb.text = ""
        contentView.addSubview(titlelb)
        
        detaillb.textColor = fieldPlaceholderColor
        detaillb.font = fontRegular(14)
        detaillb.text = ""
        contentView.addSubview(detaillb)
        
        moneylb.textColor = Main_TextColor
        moneylb.font = fontRegular(16)
        moneylb.text = ""
        moneylb.textAlignment = .right
        contentView.addSubview(moneylb)
        
        let rightlb:UILabel = creatLabel(CGRect.zero, "已汇出", fontRegular(14), fieldPlaceholderColor)
        rightlb.textAlignment = .right
        contentView.addSubview(rightlb)
        
        topline.backgroundColor = HXColor(0xf3f3f3)
        contentView.addSubview(topline)
        
        
        headImage.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        titlelb.snp.makeConstraints { make in
            make.top.equalTo(headImage).offset(-4)
            make.left.equalTo(headImage.snp.right).offset(15)
        }
        
        moneylb.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerY.equalTo(titlelb)
            make.right.equalToSuperview().offset(-15)
            make.leading.equalTo(titlelb.snp.trailing).offset(5)
        }
        

        detaillb.snp.makeConstraints { make in
            make.bottom.equalTo(headImage).offset(4)
            make.left.right.equalTo(titlelb)
        }
        
        rightlb.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.centerY.equalTo(detaillb)
            make.right.equalToSuperview().offset(-15)
        }
        
        topline.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
    }

    func addTransferModel(_data:TransferModel) {
        transferModel = _data
        titlelb.text = "\(_data.partner.name) (尾号\(_data.partner.lastCard))"
        detaillb.text =  "\(_data.smalltime)"
        moneylb.text = "-¥ \(_data.amount)"
        headImage.image = UIImage(named: _data.partner.icon)
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
