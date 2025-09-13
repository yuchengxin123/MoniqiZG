//
//  AddCardCtrl.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/16.
//

import UIKit
import CoreLocation
import SnapKit

class AddCardCtrl: BaseCtrl,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    private var didSetupCorner = false
    
    private var cardField:UITextField?
    private var bankField:UITextField?

    private let typeArray:Array<String> = ["储蓄卡","信用卡"]
    private let leaveArray:Array<String> = ["Ⅰ类","Ⅱ类","Ⅲ类"]
    
    private var typeIndex:Int = 0
    private var leaveIndex:Int = 0
    
    var oldModel:CardModel?
    var index:Int = 0
    
    private lazy var typeCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(typeButtonCell.self, forCellWithReuseIdentifier: "typecell")
        return cv
    }()
    
    private lazy var leaveCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(typeButtonCell.self, forCellWithReuseIdentifier: "leavecell")
        return cv
    }()
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = .white
        view.backgroundColor = .white
        addTap = true
        addTopView()
    }

    override func setupUI() {
        super.setupUI()
        addView()
    }
    
    func addTopView(){
        let headView:UIView = UIView()
        headView.backgroundColor = .white
        view.addSubview(headView)
        
        headView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(navigationHeight)
        }

        let img:UIImage = UIImage(named:"zhuanzhang_head") ?? UIImage()
        
        let high:CGFloat = img.size.height/img.size.width * (SCREEN_WDITH)
        
        let headimg:UIImageView = UIImageView()
        headimg.image = img
        headView.addSubview(headimg)

        headimg.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(high)
        }
        
        let button:UIButton = UIButton()
        button.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        headView.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        let titlelb:UILabel = creatLabel(CGRect.zero, "银行卡", fontRegular(19), Main_TextColor)
        titlelb.textAlignment = .center
        headView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-7)
        }
    }
    
    func addView(){
        //navigationHeight
        var leftView:UIView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 80, height: 48)
        leftView.backgroundColor = .white
        
        var leftlb:UILabel = creatLabel(CGRect(x: 15, y: 0, width: 65, height: 48), "卡号：", fontRegular(16), Main_TextColor)
        leftView.addSubview(leftlb)
        
        cardField = createField(CGRect.zero, "卡号", fontRegular(16), Main_TextColor, nil, leftView)
        cardField?.enableBankCardFormat()
        cardField?.keyboardType = .numberPad
        contentView.addSubview(cardField!)
        
        leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 80, height: 48)
        leftView.backgroundColor = .white
        
        leftlb = creatLabel(CGRect(x: 15, y: 0, width: 65, height: 48), "开户行：", fontRegular(16), Main_TextColor)
        leftView.addSubview(leftlb)
        
        bankField = createField(CGRect.zero, "城市名+支行名", fontRegular(16), Main_TextColor, nil, leftView)
        contentView.addSubview(bankField!)
        
        
        let typelb:UILabel = creatLabel(CGRect.zero, "卡类型:", fontRegular(16), Main_TextColor)
        contentView.addSubview(typelb)
        
        let leavelb:UILabel = creatLabel(CGRect.zero, "卡分类:", fontRegular(16), Main_TextColor)
        contentView.addSubview(leavelb)
        
        let sumbitButton:UIButton = creatButton(CGRect.zero, "提交", fontMedium(18), .white, Main_Color, self, #selector(isOpenVIPAction))
        contentView.addSubview(sumbitButton)
        

        
        contentView.addSubview(typeCollectionView)
        
        contentView.addSubview(leaveCollectionView)
        
        cardField!.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.top.equalToSuperview().offset(navigationHeight + 30)
        }
        
        bankField!.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.top.equalTo(cardField!.snp.bottom).offset(15)
        }
        
        typelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(48)
            make.width.equalTo(80)
            make.top.equalTo(bankField!.snp.bottom).offset(15)
        }
        
        leavelb.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(48)
            make.width.equalTo(80)
            make.top.equalTo(typelb.snp.bottom).offset(15)
        }
        
        typeCollectionView.snp.makeConstraints { make in
            make.left.equalTo(typelb.snp.right)
            make.right.equalToSuperview()
            make.height.equalTo(48)
            make.top.equalTo(typelb)
        }
        
        leaveCollectionView.snp.makeConstraints { make in
            make.left.equalTo(leavelb.snp.right)
            make.right.equalToSuperview()
            make.height.equalTo(48)
            make.top.equalTo(leavelb)
        }
        
        sumbitButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(48)
            make.width.equalTo((oldModel != nil) ? (SCREEN_WDITH/2.0-25) : (SCREEN_WDITH - 30))
            make.top.equalTo(leavelb.snp.bottom).offset(15)
        }
        
        if oldModel != nil {
            let deleteBtn:UIButton = creatButton(CGRect.zero, "删除", fontMedium(18), .white, Main_Color, self, #selector(deleteCard))
            contentView.addSubview(deleteBtn)
            
            deleteBtn.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.top.height.width.equalTo(sumbitButton)
            }
            
            cardField?.text = oldModel?.card
            bankField?.text = oldModel?.bank
            
            ViewRadius(deleteBtn, 24)
        }
 
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(sumbitButton.snp.bottom).offset(20)
        }
        
        
        ViewBorderRadius(cardField!, 24, 1, HXColor(0x6e6e6e))
        
        ViewBorderRadius(bankField!, 24, 1, HXColor(0x6e6e6e))
        
        ViewRadius(sumbitButton, 24)
    }
    
    //MARK: - 验证可用的功能
    @objc func isOpenVIPAction(){
        //水印版本不受限制 可以用
        if myUser!.vip_level == .typeNoAction {
            addCard()
            isShowWater()
        }else{
            //非水印版本 要考虑使用该功能要求的最低会员等级 以及 有效期
            YcxHttpManager.getTimestamp() { msg,data,code  in
                if code == 1{

                    let currentTime:TimeInterval = TimeInterval(data)
                    
                    print("本地时间--\((Date().timeIntervalSince1970))\n服务器时间--\(currentTime)")
                    
                    //没过期
                    if myUser!.expiredDate > currentTime {
                        // 只能改余额
                        if myUser!.vip_level == .typeVip{
                            KWindow?.makeToast("需要升级会员", .center, .information)
                        }else if myUser!.vip_level == .typeSVip || myUser!.vip_level == .typeAll{
                            self.addCard()
                        }
                        
                    }else{
                        //全部能用但是变成水印版本
                        self.addCard()
                        self.isShowWater()
                    }
                }else{
                    KWindow?.makeToast(msg, .center, .fail)
                }
            }
        }
    }
    
    
    @objc func deleteCard(){
        KWindow?.makeToast("删除成功", .center, .success)
        myCardList.remove(at: index)
        
//        //先确定那个页面需要通知更新
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: addMyCardNotificationName), object: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    

    func addCard(){
        
        if ((cardField!.text?.isEmpty) != nil && cardField!.text!.count >= 10) ,
           ((bankField!.text?.isEmpty) != nil) {
            let model:CardModel = CardModel()
            model.card = cardField!.text!
            model.bank = bankField!.text!
            model.leave = leaveArray[leaveIndex]
            model.type = typeArray[typeIndex]
            model.name = myUser?.myName ?? "小招"
            
            //确定卡号与图片的联系
            model.icon = "zhaoshang"
            
            model.lastCard = String((cardField!.text!.replacingOccurrences(of: " ", with: "")).suffix(4))
            
            if oldModel != nil {
                myCardList[index] = model
            }else{
                myCardList.append(model)
            }
            
            CardModel.saveArray(myCardList, forKey: MyCards)
            
//            //先确定那个页面需要通知更新
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: addMyCardNotificationName), object: nil)
            
            KWindow?.makeToast((oldModel != nil) ? "修改成功" : "添加成功", .center, .information)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == typeCollectionView {
            return typeArray.count
        } else {
            return leaveArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == typeCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typecell", for: indexPath) as? typeButtonCell else {
                return UICollectionViewCell()
            }
            
            cell.titlelb.text = typeArray[indexPath.row]
            
            if typeIndex == indexPath.row {
                cell.backgroundColor = Main_Color
            }else{
                cell.backgroundColor = Main_detailColor.withAlphaComponent(0.6)
            }
            
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "leavecell", for: indexPath) as? typeButtonCell else {
                return UICollectionViewCell()
            }
            
            if leaveIndex == indexPath.row {
                cell.backgroundColor = Main_Color
            }else{
                cell.backgroundColor = Main_detailColor.withAlphaComponent(0.6)
            }
            
            cell.titlelb.text = leaveArray[indexPath.row]
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(80, 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) -> Void {
        if collectionView == typeCollectionView {
            typeIndex = indexPath.row
        } else {
            leaveIndex = indexPath.row
        }
        collectionView.reloadData()
    }
    
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        // 避免重复添加多次
        guard !didSetupCorner else { return }
        didSetupCorner = true
    }
}

class typeButtonCell: UICollectionViewCell {
    let titlelb:UILabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Main_detailColor
        
        titlelb.font = fontRegular(14)
        titlelb.textColor = Main_backgroundColor
        titlelb.textAlignment = .center
        contentView.addSubview(titlelb)
        
        titlelb.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        ViewRadius(self,frame.size.height/2.0)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
