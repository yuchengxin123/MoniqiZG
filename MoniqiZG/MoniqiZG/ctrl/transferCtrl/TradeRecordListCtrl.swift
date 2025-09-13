//
//  TradeRecordListCtrl.swift
//  MoniqiZG
//
//  Created by apple on 2025/8/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TradeRecordListCtrl: BaseCtrl, UITableViewDataSource, UITableViewDelegate {
    
    private var didSetupCorner = false
    private let myRecordTable = UITableView(frame: .zero, style: .grouped)
    private var monthSections: [MonthSection] = []
    
    private let monthlb = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Main_backgroundColor
        addHeadView()
    }
 
    @objc override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        //MARK: - 重新计算所有流水可用余额
        myTradeList.sortAndCalculateBalance(initialBalance: myUser!.myBalance)
        
        monthSections = myTradeList.groupedByMonthAndDay()
        myRecordTable.reloadData()
    }
    
    override func setupUI() {
        super.setupUI()
        contentView.backgroundColor = Main_backgroundColor
        
        //MARK: - 重新计算所有流水可用余额
//        myTradeList.sortAndCalculateBalance(initialBalance: myUser!.myBalance)
//        
//        monthSections = myTradeList.groupedByMonthAndDay()
        // 原来写在 viewDidLoad 的 UI 代码，挪到这里
        addView()
    }
    
    @objc func gotoEditCtrl(){
        if myCardList.count == 0 {
            KWindow?.makeToast("请添加银行卡号", .center, .information)
            return
        }
        
        let ctlr:TradeRecordEditingCtrl = TradeRecordEditingCtrl()
        self.navigationController?.pushViewController(ctlr, animated: true)
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
        
        let infoImg:UIImageView = UIImageView(image: UIImage(named: "main_search")?.withRenderingMode(.alwaysTemplate))
        infoImg.tintColor = .black
        headView.addSubview(infoImg)
        
        infoImg.snp.makeConstraints { make in
            make.right.equalTo(rightImg.snp.left).offset(-20)
            make.centerY.equalTo(leftImg)
            make.height.width.equalTo(30)
        }
        
        let leftButton:UIButton = UIButton()
        leftButton.backgroundColor = .clear
        leftButton.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let rightButton:UIButton = UIButton()
        rightButton.backgroundColor = .clear
        rightButton.addTarget(self, action: #selector(gotoEditCtrl), for: .touchUpInside)
        headView.addSubview(rightButton)
        
        rightButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "收支", fontRegular(17), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.centerY.equalTo(leftImg)
        }
    }
    
    
    func addView(){
        
        monthlb.text = "2025.08"
        monthlb.font = fontRegular(14)
        monthlb.textColor = Main_TextColor
        view.addSubview(monthlb)
        
        let firstImg:UIImageView = UIImageView()
        firstImg.image = UIImage(named: "trade_bottom")
        view.addSubview(firstImg)
        
        let banklb:UILabel = creatLabel(CGRect.zero, "银行卡", fontRegular(14), Main_TextColor)
        view.addSubview(banklb)
        
        let twoImg:UIImageView = UIImageView()
        twoImg.image = UIImage(named: "trade_bottom")
        view.addSubview(twoImg)
        
        let moneylb:UILabel = creatLabel(CGRect.zero, "按金额", fontRegular(14), Main_TextColor)
        view.addSubview(moneylb)
        
        let filterlb:UILabel = creatLabel(CGRect.zero, "筛选", fontRegular(14), Main_TextColor)
        view.addSubview(filterlb)
        
        myRecordTable.register(TradeRecordCell.self, forCellReuseIdentifier: "TradeRecordCell")
        myRecordTable.separatorStyle = .none
        myRecordTable.backgroundColor = Main_backgroundColor
        myRecordTable.rowHeight = 70 // 设置固定高度
        myRecordTable.dataSource = self
        myRecordTable.delegate = self
        myRecordTable.showsHorizontalScrollIndicator = false
        myRecordTable.showsVerticalScrollIndicator = false
        myRecordTable.sectionHeaderHeight = 40
        myRecordTable.sectionFooterHeight = 0
        view.addSubview(myRecordTable)
        
        monthlb.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(navigationHeight+10)
        }
        
        firstImg.snp.makeConstraints { make in
            make.left.equalTo(monthlb.snp.right).offset(5)
            make.width.equalTo(10)
            make.height.equalTo(7)
            make.centerY.equalTo(monthlb)
        }
        
        banklb.snp.makeConstraints { make in
            make.left.equalTo(firstImg.snp.right).offset(20)
            make.height.equalTo(30)
            make.centerY.equalTo(monthlb)
        }
        
        twoImg.snp.makeConstraints { make in
            make.left.equalTo(banklb.snp.right).offset(5)
            make.width.equalTo(10)
            make.height.equalTo(7)
            make.centerY.equalTo(monthlb)
        }
        
        moneylb.snp.makeConstraints { make in
            make.left.equalTo(twoImg.snp.right).offset(20)
            make.height.equalTo(30)
            make.centerY.equalTo(monthlb)
        }
        
        filterlb.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(30)
            make.centerY.equalTo(monthlb)
        }
        
        
        myRecordTable.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(monthlb.snp.bottom).offset(5)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return monthSections.reduce(0) { $0 + $1.days.count }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (monthIdx, dayIdx) = indexForSection(section)
        return monthSections[monthIdx].days[dayIdx].records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (monthIdx, dayIdx) = indexForSection(indexPath.section)
        let model = monthSections[monthIdx].days[dayIdx].records[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradeRecordCell", for: indexPath) as! TradeRecordCell
        cell.addTransferModel(_data: model)
        
        //每个月分组最后一个
        if dayIdx == monthSections[monthIdx].days.count - 1 ,
           indexPath.row == monthSections[monthIdx].days[dayIdx].records.count - 1{
            cell.setRadius(true)
        }else{
            cell.setRadius(false)
        }
        
        cell.onTap = {
            print("点击查看 \(indexPath.row)")
            
            let ctrl:TradeRecordDetailCtrl = TradeRecordDetailCtrl()
            ctrl.model = model
            ctrl.enableLazyLoad = true
            self.navigationController?.pushViewController(ctrl, animated: true)
        }

        cell.onLongPress = {
            print("长按编辑 \(indexPath.row)")
            let ctrl:TradeRecordEditingCtrl = TradeRecordEditingCtrl()
            ctrl.oldModel = model
            self.navigationController?.pushViewController(ctrl, animated: true)
        }
        return cell
    }
    
    // 日期头部
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (monthIdx, dayIdx) = indexForSection(section)
        let day = monthSections[monthIdx].days[dayIdx]
        
        if dayIdx == 0 { // 说明是这个月的第一个日期，要加月份大头
            let container = UIView()
            container.backgroundColor = Main_backgroundColor
            
            let monthView = MonthHeaderView(frame: CGRect(x: 0, y: 10, width: tableView.bounds.width, height: 140))
            monthView.configure(month: monthSections[monthIdx])
            container.addSubview(monthView)
            
            let dayView = DayHeaderView(frame: CGRect(x: 0, y: 150, width: tableView.bounds.width, height: 40))
            dayView.configure(date: day.displayDate)
            container.addSubview(dayView)
            
            return container
        } else {
            let dayView = DayHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
            dayView.configure(date: day.displayDate)
            return dayView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let (_, dayIdx) = indexForSection(section)
        return dayIdx == 0 ? 190 : 40
    }
    
    
    // 月份之间的间隔
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let (monthIdx, dayIdx) = indexForSection(section)
        let lastDay = monthSections[monthIdx].days.count - 1
        return dayIdx == lastDay ? 20 : 0.01
    }
    
    // 辅助：把扁平 section 映射回 month/day
    private func indexForSection(_ section: Int) -> (Int, Int) {
        var count = 0
        for (i, month) in monthSections.enumerated() {
            for (j, _) in month.days.enumerated() {
                if count == section { return (i, j) }
                count += 1
            }
        }
        return (0, 0)
    }
    
    // 滚动时更新顶部时间
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = myRecordTable.indexPathsForVisibleRows?.first {
            let (monthIdx, _) = indexForSection(indexPath.section)
            let yearMonth = monthSections[monthIdx].yearMonth
            // "2025-08"
            self.monthlb.text = yearMonth.replacingOccurrences(of: "-", with: ".")
        }
    }
    
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
}


class TradeRecordCell: UITableViewCell {
    let headImage = UIImageView()
    let titlelb = UILabel()
    let detaillb = UILabel()
    let moneylb = UILabel()
    let marklb = UILabel()
    let amountlb = UILabel()
    let bgView = UIView()
    var transferModel:TransferModel?
    private var isBottomRadius: Bool = false
    
    var onTap: (() -> Void)?
    var onLongPress: (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setRadius(false) // 复用时重置，防止串样式
    }
    
    func setRadius(_ isRadius: Bool = false) {
        isBottomRadius = isRadius
        applyCorners()
    }

    private func applyCorners() {
        if isBottomRadius {
            bgView.layer.cornerRadius = 10
            bgView.layer.masksToBounds = true
            bgView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // 关键：清除圆角设置
            bgView.layer.cornerRadius = 0
            bgView.layer.masksToBounds = false
            bgView.layer.maskedCorners = []
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        backgroundColor = Main_backgroundColor
        self.createCellUI()
        setupGestures()
    }
    
    private func setupGestures() {
        // 点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)

        // 长按
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        contentView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleTap() {
        onTap?()
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPress?()
        }
    }

    func createCellUI(){
        bgView.backgroundColor = .white
        contentView.addSubview(bgView)
        
        bgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
        
        bgView.addSubview(headImage)
        
        titlelb.textColor = Main_TextColor
        titlelb.font = fontRegular(14)
        titlelb.text = ""
        bgView.addSubview(titlelb)
        
        detaillb.textColor = fieldPlaceholderColor
        detaillb.font = fontRegular(12)
        detaillb.text = ""
        bgView.addSubview(detaillb)
        
        moneylb.textColor = Main_TextColor
        moneylb.font = fontNumber(16)
        moneylb.text = ""
        moneylb.textAlignment = .right
        bgView.addSubview(moneylb)
        
        amountlb.textColor = fieldPlaceholderColor
        amountlb.font = fontNumber(12)
        amountlb.text = ""
        amountlb.textAlignment = .right
        bgView.addSubview(amountlb)
        
        
        marklb.textColor = HXColor(0xffc68e)
        marklb.font = fontRegular(10)
        marklb.text = "未入账"
        marklb.textAlignment = .center
        bgView.addSubview(marklb)
        marklb.isHidden = true
        
        ViewBorderRadius(marklb, 6, 1, HXColor(0xffc68e))
        
        
        headImage.snp.makeConstraints { make in
            make.height.width.equalTo(15)
            make.left.top.equalToSuperview().offset(15)
        }
        
        titlelb.snp.makeConstraints { make in
            make.centerY.equalTo(headImage)
            make.left.equalTo(headImage.snp.right).offset(15)
            make.height.equalTo(15)
        }
        
        moneylb.snp.makeConstraints { make in
            make.centerY.equalTo(titlelb)
            make.height.equalTo(18)
            make.right.equalToSuperview().offset(-15)
        }
        
        marklb.snp.makeConstraints { make in
            make.centerY.equalTo(moneylb)
            make.right.equalTo(moneylb.snp.left).offset(10)
            make.height.equalTo(15)
        }

        detaillb.snp.makeConstraints { make in
            make.top.equalTo(titlelb.snp.bottom).offset(10)
            make.left.equalTo(titlelb)
            make.height.equalTo(15)
        }
        
        amountlb.snp.makeConstraints { make in
            make.height.equalTo(detaillb)
            make.centerY.equalTo(detaillb)
            make.right.equalToSuperview().offset(-15)
        }
    }
    

    func addTransferModel(_data:TransferModel) {
        transferModel = _data
        
        headImage.image = UIImage(named: getBankTransactionIcon(type: _data.tradeType))
        
        var title:String = "转账"
        switch _data.tradeType {
        case TransactionChildType.typeTransfer200.type,
            TransactionChildType.typeTransfer201.type,
            TransactionChildType.typeTransfer101.type,
            TransactionChildType.typeTransfer102.type:
            title = "转账-\(_data.partner.name)(\(_data.partner.lastCard))"
            amountlb.text = String(format: "余额:¥%@",getNumberFormatter(_data.calculatedBalance))
        default :
            title = _data.remind
            amountlb.text = ""
        }
        titlelb.text = title
        
        if myCardList.count > 0 {
            let model:CardModel = myCardList.first!
            
            let startIndex = _data.bigtime.index(_data.bigtime.startIndex, offsetBy: 11)
            let endIndex = _data.bigtime.index(startIndex, offsetBy: 5)
            
            detaillb.text = String(format: "%@%@ %@",model.type,model.lastCard,String(_data.bigtime[startIndex..<endIndex]))
        }
        
        moneylb.text = String(format: "%@¥%.02f",(_data.isIncome ? "+":"-"),_data.amount)
        
        amountlb.text = String(format: "余额:¥%@",getNumberFormatter(_data.calculatedBalance))
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
