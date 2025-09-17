//
//  common.swift
//  ZDSwift
//
//  Created by ycx on 2022/10/9.
//

import Foundation
import UIKit


///config的文件目录
let filepath_config = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!


//let currentVersion = {
//    var currentVersion:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
////    currentVersion = currentVersion.replacingOccurrences(of: ".", with: "")
//    print("版本---\(currentVersion)")
//    return currentVersion
//}

var myUser:User?


struct User: Codable {
    //是否首次启动
    var isFirst: Bool = true
    // VIP 等级
    var vip_level: VipTypeBean = .typeNoAction
    // VIP 类型
    var vip_time: VipExpiredTimeBean = .typeNotActivated
    // VIP 到期时间
    var expiredDate: TimeInterval = 0

    //我的昵称
    var nickname: String = "昵称"
    //真实名字
    var myName: String = "招"
    //我的余额
    var myBalance: Double = 0
    //我的收入
    var myIncome: Double = 0
    //我的银行卡数量
    var myCards: Int = 0
    //我的待办
    var myWorks: Int = 0
    //我的卡券
    var myCoupons: Int = 0
    //我的积分
    var myPoints: Int = 0
    //当月支出
    var myMonthCost: Double = 0.00
    //当月收入
    var myMonthIncome: Double = 0.00
    //信用卡花费
    var creditCardSpending: Double = 0.00
    //信用卡账单日
    var billingDate: String = "08-16"
    //贷款额度
    var loanAmount: Int = 30
    //年利率
    var annualInterestRate: Double = 3.05
    //医保
    var medicalInsurance: Double = 0.00
    //公积金
    var providentFund: Double = 0.00
    //五险一金更新时间
    var providentUpdateTime: String = "08-16"
    //手机号
    var phone: String = "13278943216"
    
    
    var token: String = ""
    //首页图片
    var imgIndex: String = ""
    //社区页图片
    var imgCommunity: String = ""
    //财富页图片
    var imgWealthBg: String = ""
    //生活页图片
    var imgLifeBg: String = ""
    //我的页面 底部图片
    var imgMineBot: String = ""
    //启动页
    var imgLauncher: String = ""
    //预计1-2个工作日到账
    var transferArrivalTime: String = "预计10秒内到账"
    //转账失败原因
    var transferFailHint: String = "因状态异常已被限制交易，请处理异常或更换付款卡"
    //是否余额负数
    var isCut: Bool = false
}

class UserManager {
    static let shared = UserManager()

    private let filePath: URL
    private(set) var user: User

    private init() {
        let docPath = filepath_config
        filePath = docPath.appendingPathComponent("User_Info/user.json")

        if let data = try? Data(contentsOf: filePath),
           let decoded = try? JSONDecoder().decode(User.self, from: data) {
            self.user = decoded
        } else {
            self.user = User()
            saveUser()
        }
    }

    func update(_ updateBlock: (inout User) -> Void) {
        updateBlock(&user)
        saveUser()
    }

    func saveUser() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(user) {
            try? FileManager.default.createDirectory(at: filePath.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: filePath)
        }
    }

    func reset() {
        self.user = User()
        saveUser()
    }
    
    func loadUser() -> User? {
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(User.self, from: data)
    }
    
    func checkPermissions(token: String,isUpgrade: Bool,call: (() -> Void)? = nil){
        
        KWindow?.makeToastActivity(.center)
        
        YcxHttpManager.requestPost(url: API_getToken,page:0, params:["token":token,"client":"iOS"] as? Dictionary<String, Any>) { msg,data,code  in
            
            KWindow?.hideToastActivity()
            if code == 1{
                print("api=%@,data = %@",data,API_getToken)
                
                let vipType = data["vipType"] as? Int ?? 0
                let vipExpiredTime = data["vipExpiredTime"] as? Int ?? 0
                
                // 检查是否为有效的过期时间类型
                if !VipExpiredTimeBean.isValidCode(vipExpiredTime) {
                    //AppLog.e("isExpireTimestamp 非法的过期时间类型：\(vipExpiredTime)")
                    KWindow?.makeToast("非法的过期时间类型", .center, .fail)
                    return
                }
                if !VipTypeBean.isValidCode(vipType) {
                    //AppLog.e("isExpireTimestamp 非法的过期时间类型：\(vipExpiredTime)")
                    KWindow?.makeToast("非法的会员类型", .center, .fail)
                    return
                }
                
                //激活会员后 重新获取服务器时间
                YcxHttpManager.getTimestamp() { msg,data,code  in
                    if code == 1{
                        let currentTime:TimeInterval = TimeInterval(data)
                        
                        print("本地时间--\((Date().timeIntervalSince1970))\n服务器时间--\(currentTime)")
                        
                        //重置会员时间
                        setExpireTimestamp(
                            currentTime:currentTime,
                            vipType: vipType,
                            vipExpiredTime: vipExpiredTime,
                            isUpgrade: isUpgrade,
                            call: call
                        )
                        
                    }else{
                        KWindow?.makeToast(msg, .center, .fail)
                    }
                }
            }else{
                KWindow?.makeToast(msg, .center, .fail)
            }

        } failCall: { err, data in
            KWindow?.makeToast(err, .center, .fail)
        }
    }
}

public func saveUserImage(_ image: UIImage, fileName: String) {
    // 图片保存目录：Documents/User_Info/Images
    let imageDir = filepath_config.appendingPathComponent("User_Info/Images")
    let fileURL = imageDir.appendingPathComponent(fileName)

    do {
        try FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
        if let data = image.pngData() {
            try data.write(to: fileURL)
            print("✅ 图片保存成功: \(fileURL)")
        }
    } catch {
        print("❌ 保存图片失败: \(error)")
    }
}

public func loadUserImage(fileName: String) -> UIImage? {
    let fileURL = filepath_config.appendingPathComponent("User_Info/Images/\(fileName)")
    return UIImage(contentsOfFile: fileURL.path)
}

// MARK: - 清除所有本地记录
public func cleanAllRecord(){
    
    //重置用户信息
    UserManager.shared.reset()
    myUser = UserManager.shared.user
    
    //交易记录
    myTradeList = []
    TransferModel.saveArray(myTradeList, forKey: MyTradeRecord)
    
    //转账伙伴
//    myPartnerList = []
//    TransferPartner.saveArray(myPartnerList, forKey: MyTransferPartnerCards)
    
    //我的卡
    myCardList = []
    CardModel.saveArray(myCardList, forKey: MyCards)
}

// MARK: - 清除流水记录
public func cleanAllTransfer(){
    //交易记录
    myTradeList = []
    TransferModel.saveArray(myTradeList, forKey: MyTradeRecord)
}

//MARK: - vip激活后 设置过期时间
public func setExpireTimestamp(currentTime:TimeInterval,
                               vipType: Int,
                                vipExpiredTime: Int,
                                isUpgrade: Bool = false,
                                call: (() -> Void)? = nil) {
    
    let vipExpiredTimeBean = VipExpiredTimeBean.fromCode(vipExpiredTime)
    var calendar = Calendar.current

    calendar.timeZone = TimeZone.current
    var dateComponents = DateComponents()

    // 添加时间间隔
    switch vipExpiredTimeBean.unit {
    case .year:
        dateComponents.year = vipExpiredTimeBean.duration
    case .month:
        dateComponents.month = vipExpiredTimeBean.duration
    case .day:
        dateComponents.day = vipExpiredTimeBean.duration
    case .hour:
        dateComponents.hour = vipExpiredTimeBean.duration
    case .minute:
        dateComponents.minute = vipExpiredTimeBean.duration
    case .second:
        dateComponents.second = vipExpiredTimeBean.duration
    default:
        dateComponents.day = vipExpiredTimeBean.duration
    }
    
    //MARK: - 这里要改
    //当前时间 -- 需要获取服务器的
    let currentDate = Date(timeIntervalSince1970: currentTime)
    
    //过期时间 -- 通过服务器时间计算过期时间
    let expiredDate:Date = calendar.date(byAdding: dateComponents, to: currentDate) ?? Date()

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    // 调试日志
    print("isExpireTimestamp 设置VIP类型: \(vipExpiredTimeBean), 添加的到期时间: \(formatter.string(from: expiredDate))")

    // 升级会员
    if isUpgrade {
        if vipType == myUser!.vip_level.vipType {
            KWindow?.makeToast("当前激活码类型错误-\(vipType)", .center, .fail)
            return
        }
        
        if vipType == VipTypeBean.typeVip.vipType {
            // 测试版升级到普通会员 由于功能不齐全 需要清除流水
            cleanAllTransfer()
        }
        
        if vipType >  myUser!.vip_level.vipType{
            // MARK: - 设置会员有效期
            myUser?.expiredDate = expiredDate.timeIntervalSince1970
            myUser?.vip_time = VipExpiredTimeBean.fromCode(vipExpiredTime)
            myUser?.vip_level = VipTypeBean.fromType(vipType)
            
            UserManager.shared.update { user in
                user.expiredDate = expiredDate.timeIntervalSince1970
                user.vip_time = VipExpiredTimeBean.fromCode(vipExpiredTime)
                user.vip_level = VipTypeBean.fromType(vipType)
            }
        }else{
            KWindow?.makeToast("当前激活码类型错误-\(vipType)", .center, .fail)
            return
        }
    }
    // 会员续费
    else {
        if vipType != myUser!.vip_level.vipType {
            KWindow?.makeToast("当前续费激活码类型错误-\(vipType)", .center, .fail)
            return
        }
        if vipType == VipTypeBean.typeNoAction.vipType {
            // 清除流水
            cleanAllTransfer()
            // MARK: - 设置会员有效期
            myUser?.expiredDate = expiredDate.timeIntervalSince1970
            myUser?.vip_time = VipExpiredTimeBean.fromCode(vipExpiredTime)
            myUser?.vip_level = VipTypeBean.fromType(vipType)
            
            UserManager.shared.update { user in
                user.expiredDate = expiredDate.timeIntervalSince1970
                user.vip_time = VipExpiredTimeBean.fromCode(vipExpiredTime)
                user.vip_level = VipTypeBean.fromType(vipType)
            }
        } else {
            //之前的到期时间
            let baseTime:TimeInterval = (myUser!.expiredDate > currentTime) ? myUser!.expiredDate : currentTime
            
            //之前的有效期
            let baseDate = Date(timeIntervalSince1970: baseTime)
            
            // 以之前的时间戳 计算 新的到期时间
            guard let newExpiredDate = calendar.date(byAdding: dateComponents, to: baseDate) else {
                // 处理计算失败的情况
                KWindow?.makeToast("有效期异常", .center, .fail)
                return
            }
            
            let newExpiredTimestamp = newExpiredDate.timeIntervalSince1970
            
            print("会员续费:原来时间 \(formatter.string(from: Date(timeIntervalSince1970: myUser!.expiredDate))), 新的到期时间: \(formatter.string(from: newExpiredDate))")
            
            // MARK: - 设置会员有效期
            myUser?.expiredDate = newExpiredTimestamp
            myUser?.vip_time = VipExpiredTimeBean.fromCode(vipExpiredTime)
            myUser?.vip_level = VipTypeBean.fromType(vipType)
            
            UserManager.shared.update { user in
                user.expiredDate = newExpiredTimestamp
                user.vip_time = VipExpiredTimeBean.fromCode(vipExpiredTime)
                user.vip_level = VipTypeBean.fromType(vipType)
            }
        }
    }

    //更新vip后通知
    call?()
}

// MARK: - 功能版本
enum VipTypeBean: Int,Codable  {
    case typeNoAction = 0//水印版本
    case typeVip = 10//可以改个人信息的内容
    case typeSVip = 20//额外改流水 转账
    case typeAll = 30//额外打印流水
    
    var vipType: Int {
        return self.rawValue
    }
    
    var vipTypeStr: String {
        switch self {
        case .typeNoAction: return "未激活"
        case .typeVip: return "普通会员"
        case .typeSVip: return "超级会员"
        case .typeAll: return "全功能版本"
        }
    }
    
    static func fromType(_ type: Int) -> VipTypeBean {
        return VipTypeBean(rawValue: type) ?? .typeNoAction
    }
    
    static func isValidCode(_ code: Int) -> Bool {
        return VipTypeBean(rawValue: code) != nil
    }
}

/**
 * vip类型
 */
enum VipExpiredTimeBean: Int,Codable  {
    case typeNotActivated = -1        // 未激活
    case typeTest = 100               // 测试卡 1分钟
    case typeHour = 110               // 小时卡-暂不对外开放
    case typeTryOut = 111             // 网店试用版-10分钟
    case typeDay = 120                // 天卡
    case typeWeek = 130               // 周卡
    case typeMonth = 140              // 月卡
    case typeQuarter = 150            // ✅ 新增：季度卡
    case typeYear = 160               // 年卡
    case typeLifetime = 170           // ✅ 新增：终身卡（暂定100年）
    
    var code: Int {
        return self.rawValue
    }
    
    var duration: Int {
        switch self {
        case .typeNotActivated: return 0
        case .typeTest: return 1
        case .typeHour: return 1
        case .typeTryOut: return 10
        case .typeDay: return 1
        case .typeWeek: return 1
        case .typeMonth: return 1
        case .typeQuarter: return 3
        case .typeYear: return 1
        case .typeLifetime: return 100
        }
    }
    
    var unit: Calendar.Component {
        switch self {
        case .typeNotActivated: return .month
        case .typeTest: return .minute
        case .typeHour: return .hour
        case .typeTryOut: return .minute
        case .typeDay: return .day
        case .typeWeek: return .weekOfYear
        case .typeMonth: return .month
        case .typeQuarter: return .month
        case .typeYear: return .year
        case .typeLifetime: return .year
        }
    }
    
    static func fromCode(_ code: Int? = nil) -> VipExpiredTimeBean {
        guard let code = code else {
            return .typeNotActivated
        }
        return VipExpiredTimeBean(rawValue: code) ?? .typeNotActivated
    }
    
    static func isValidCode(_ code: Int) -> Bool {
        return VipExpiredTimeBean(rawValue: code) != nil
    }
}
