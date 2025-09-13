//
//  model.swift
//  ZDSwift
//
//  Created by ycx on 2023/3/22.
//

import Foundation

/// 用于数组类型推断 SafeModel 元素类型
protocol SafeModelArrayProtocol {
    static var elementType: SafeModel.Type { get }
}

extension Array: SafeModelArrayProtocol where Element: SafeModel {
    static var elementType: SafeModel.Type { Element.self }
}

@objcMembers
class SafeModel: NSObject {
    required override init() {
        super.init()
    }

    /// 快速赋值字典
    required convenience init(_ dict: [String: Any]) {
        self.init()
        setValuesForKeys(dict)
    }

    /// 安全处理未定义字段
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        // 忽略未定义字段，防崩溃
    }

    /// 自动处理 NSNull、类型不一致、子模型、数组模型
    override func setValue(_ value: Any?, forKey key: String) {
        let mirror = Mirror(reflecting: self)

        guard let child = mirror.children.first(where: { $0.label == key }) else {
            super.setValue(value, forKey: key)
            return
        }

        // 1. nil / NSNull 处理
        if value == nil || value is NSNull {
            switch child.value {
            case is String: super.setValue("", forKey: key)
            case is Int:    super.setValue(0, forKey: key)
            case is Double: super.setValue(0.0, forKey: key)
            case is Bool:   super.setValue(false, forKey: key)
            default:        super.setValue(nil, forKey: key)
            }
            return
        }

        // 2. 已经是 SafeModel → 直接赋值
        if let model = value as? SafeModel,
           child.value is SafeModel? {
            super.setValue(model, forKey: key)
            return
        }

        // 3. 字典 → SafeModel
        if let dict = value as? [String: Any],
           let modelType = type(of: child.value) as? SafeModel.Type {
            let model = modelType.init(dict)
            super.setValue(model, forKey: key)
            return
        }

        // 4. 已经是 [SafeModel] → 直接赋值
        if let models = value as? [SafeModel],
           child.value is [SafeModel] {
            super.setValue(models, forKey: key)
            return
        }

        // 5. 数组字典 → [SafeModel]
        if let array = value as? [[String: Any]],
           let arrayType = type(of: child.value) as? SafeModelArrayProtocol.Type {
            let elementType = arrayType.elementType
            let models = array.map { elementType.init($0) }
            super.setValue(models, forKey: key)
            return
        }

        // 6. 基础类型兼容（String/Int/Double/Bool）
        switch child.value {
        case is String:
            super.setValue("\(value!)", forKey: key)
        case is Int:
            let intValue = (value as? Int) ?? Int("\(value!)") ?? 0
            super.setValue(intValue, forKey: key)
        case is Double:
            let doubleValue = (value as? Double) ?? Double("\(value!)") ?? 0.0
            super.setValue(doubleValue, forKey: key)
        case is Bool:
            if let boolValue = value as? Bool {
                super.setValue(boolValue, forKey: key)
            } else if let str = value as? String {
                super.setValue((str as NSString).boolValue, forKey: key) // "true"/"false"/"1"/"0"
            } else {
                super.setValue(false, forKey: key)
            }
        default:
            super.setValue(value, forKey: key)
        }
    }
}

// MARK: - 泛型扩展
extension SafeModel {
    /// 单个模型
    class func model<T: SafeModel>(from dict: [String: Any], as type: T.Type) -> T {
        return T(dict)
    }

    /// 模型数组
    class func modelArray<T: SafeModel>(from array: [[String: Any]], as type: T.Type) -> [T] {
        return array.map { T($0) }
    }

    /// 转换成字典（递归处理子模型/数组）
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.label {
                switch child.value {
                case let model as SafeModel:
                    dict[key] = model.toDictionary()
                case let models as [SafeModel]:
                    dict[key] = models.map { $0.toDictionary() }
                default:
                    dict[key] = child.value
                }
            }
        }
        return dict
    }

    // MARK: - 通用数组存储

    /// 存储数组到 UserDefaults
    class func saveArray<T: SafeModel>(_ models: [T], forKey key: String) {
        let dictArray = models.map { $0.toDictionary() }
        UserDefaults.standard.set(dictArray, forKey: key)
        UserDefaults.standard.synchronize()
    }

    /// 从 UserDefaults 读取数组
    class func loadArray<T: SafeModel>(forKey key: String, as type: T.Type) -> [T] {
        guard let array = UserDefaults.standard.array(forKey: key) as? [[String: Any]] else {
            return []
        }
        return T.modelArray(from: array, as: type)
    }

    // MARK: - 文件存储（更适合大数据）

    /// 存储数组到文件（Documents 下）
    class func saveArrayToFile<T: SafeModel>(_ models: [T], fileName: String) {
        let dictArray = models.map { $0.toDictionary() }
        if let data = try? JSONSerialization.data(withJSONObject: dictArray, options: []) {
            let url = fileURL(fileName)
            try? data.write(to: url)
        }
    }

    /// 从文件读取数组
    class func loadArrayFromFile<T: SafeModel>(fileName: String, as type: T.Type) -> [T] {
        let url = fileURL(fileName)
        guard let data = try? Data(contentsOf: url),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return T.modelArray(from: array, as: type)
    }

    /// 获取存储路径
    private class func fileURL(_ fileName: String) -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
    }
}

struct MonthSection {
    let yearMonth: String       // "2025-08"
    let displayMonth: String    // "8月"
    var income: Double
    var expense: Double
    var days: [DaySection]
}

struct DaySection {
    let date: String            // "2025-08-23"
    let displayDate: String     // "今天"/"昨天"/"08.23"
    var records: [TransferModel]
}

struct TransferMonthSection {
    var yearMonth: String       // 2025-08
    var displayTitle: String    // 本月 / 8月 / 2024年12月
    var income: Double
    var expense: Double
    var records: [TransferModel]
}

//MARK: - 转账交易记录
class TransferModel: SafeModel {
    //收入否 默认支出
    @objc var isIncome: Bool = false
    //交易金额
    @objc var amount: Double = 0.0
    //付款银行
    @objc var payBank: String = "招商银行"
    //付款银行卡号
    @objc var payCard: String = "1111 2222 3333 4444"
    //交易时间
    @objc var bigtime: String = "2025-08-08 00:00:00"
    @objc var smalltime: String = "08.08 00:00"
    //流水号 16位
    @objc var serialNumber: String = "X784AM20033G5VPA"
    //商业单号
    @objc var merchantNumber: String = ""
    //留言-备注-也可能是随机数据的标题
    @objc var remind: String = "附言"
    
    //交易类型-0.转账给他人 2.餐饮 3.车费 等
    var tradeType: Int = TransactionChildType.typeTransfer200.type
    
    //交易方式-1 财付通 支付宝 美团 抖音支付 京东支付 一网通支付
    @objc var tradeStyle: Int = 0
    
    //交易地区
    @objc var area: String = "美国"
    //收款方式 1.card 2.支付宝 3.微信
    @objc var receiveType: Int = 1
    //临时余额
    @objc var calculatedBalance: Double = 0
//    @objc var tradeResult: Int
    //如果是转账交易 则有以下属性
    @objc var partner:TransferPartner = TransferPartner()
}


struct PartnerSection {
    var header: String       // 比如 "A"
    var items: [TransferPartner]
}


//MARK: - 转账伙伴
class TransferPartner: SafeModel {
    //姓名
    @objc var name: String = "测试"
    //卡号
    @objc var card: String = "1111 2222 3333 4444"
    //尾号
    @objc var lastCard: String = "4444"
    //银行图片 cardIconInt
    @objc var icon: String = "bank_type_7"
    //银行
    @objc var bankName: String = "深圳招商银行"
    //卡名称 -借记卡，千山卡，千山卡(银联卡)，绿卡银联标准卡 等等
    @objc var cardName: String = "中国旅游卡"
    //卡种/-借记卡/储蓄卡/信用卡
    @objc var cardType: String = "借记卡"
}



class CardModel: SafeModel {
    //姓名
    @objc var name: String = "测试"
    //卡号
    @objc var card: String = "1111 2222 3333 4444"
    //尾号
    @objc var lastCard: String = "4444"
    //银行图片
    @objc var icon: String = "zhaoshang_card_1"
    //开户行 天津银行
    @objc var bank: String = "深圳招商银行"
    //卡类型
    @objc var type: String = "储蓄卡"
    //卡分类 "Ⅰ类" "Ⅱ类" "Ⅲ类"
    @objc var leave: String = "Ⅰ类"
}

// MARK: - 交易ICON
func getBankTransactionIcon(type: Int?) -> String {
    guard let type = type else { return "" }
    
    switch type {
    case TransactionChildType.typeTransfer200.type,
         TransactionChildType.typeTransfer201.type,
         TransactionChildType.typeTransfer101.type,
         TransactionChildType.typeTransfer102.type,
         TransactionChildType.typeTransfer103.type,
         TransactionChildType.typeTransfer104.type,
         TransactionChildType.typeTransfer105.type:
        return "trade_type_1"
        
    case TransactionChildType.typeTransfer212.type:
        return "trade_type_2"
    case TransactionChildType.typeTransfer213.type:
        return "trade_type_3"
    case TransactionChildType.typeTransfer214.type:
        return "trade_type_4"
    case TransactionChildType.typeTransfer215.type:
        return "trade_type_5"
    case TransactionChildType.typeTransfer216.type:
        return "trade_type_6"
    case TransactionChildType.typeTransfer217.type:
        return "trade_type_7"
    case TransactionChildType.typeTransfer218.type:
        return "trade_type_8"
    case TransactionChildType.typeTransfer219.type:
        return "trade_type_9"
    case TransactionChildType.typeTransfer220.type:
        return "trade_type_10"
    case TransactionChildType.typeTransfer221.type:
        return "trade_type_11"
    case TransactionChildType.typeTransfer222.type:
        return "trade_type_12"
    case TransactionChildType.typeTransfer108.type:
        return "trade_type_13"
    case TransactionChildType.typeTransfer109.type:
        return "trade_type_14"
        
    default:
        return "trade_type_1"
    }
}

// MARK: - 交易头部icon
func getTransactionIcon(type: Int) -> String {
    switch type {
    case 101,102,200,201,215:
        return "cmb_icon_dh"
    case 109,213,214,216,217,218,219,220,221,222:
        return "icon_transfer_zfb"
    case 103,104,105 :
        return "icon_withdrawal_zfb"
    case 108 :
        return "cmb_icon_jx"
    default:
        return ""//212取现
    }
}


// MARK: - 交易分类
func getTransactionClassType(type: Int) -> String {
    switch type {
    case 101 :
        return "他人转入"
    case 102,103,104,105,201:
        return "转账给自己"
    case 108 :
        return "投资收益"
    case 109 :
        return "退款"
    case 200 :
        return "转账给他人"
    case 212 :
        return "现金"
    case 213 :
        return "其他投资"//京东金融
    case 214 :
        return "出行"
    case 215 :
        return "手续费"
    case 216 :
        return "购物"
    case 217 :
        return "还款"
    case 218 :
        return "休闲娱乐"
    case 219 :
        return "红包"
    case 220 :
        return "餐饮"
    case 221 :
        return "充值缴费"
    case 222 :
        return "其他支出"
    default:
        return ""
    }
}


// MARK: - 银行交易类型
func getBankTransactionType(type: Int?) -> String {
    guard let type = type else { return "" }
    
    switch type {
    case TransactionChildType.typeTransfer200.type,
         TransactionChildType.typeTransfer201.type:
        return "转账汇款"
        
    case TransactionChildType.typeTransfer212.type:
        return "柜台取现"
    case TransactionChildType.typeTransfer213.type:
        return "银联快捷支付"
    case TransactionChildType.typeTransfer214.type:
        return "一网通支付"
    case TransactionChildType.typeTransfer215.type:
        return "FEEG"
    case TransactionChildType.typeTransfer217.type:
//        TransactionChildType.typeTransfer216.type,
//         TransactionChildType.typeTransfer218.type,
//         TransactionChildType.typeTransfer219.type,
//         TransactionChildType.typeTransfer220.type,
//         TransactionChildType.typeTransfer221.type,
//         TransactionChildType.typeTransfer222.type:
        return "网联协议支付"
        
    case TransactionChildType.typeTransfer101.type,
         TransactionChildType.typeTransfer102.type:
        return "汇入汇款"
    case TransactionChildType.typeTransfer103.type:
        return "网联付款交易"
    case TransactionChildType.typeTransfer104.type,
         TransactionChildType.typeTransfer105.type:
        return "银联代付"
    case TransactionChildType.typeTransfer108.type:
        return "账户结息"
    case TransactionChildType.typeTransfer109.type:
        return "网联退款"
        
    default:
        return "消费"
    }
}

// 交易子类型 图标icon_transaction_flow_type_
enum TransactionChildType: Int {
    // 支出 //银行交易类型
    case typeTransfer200 = 200 // 转账汇款-转给他人
    case typeTransfer201 = 201 // 转账汇款-转给自己
    case typeTransfer212 = 212 // 取现
    case typeTransfer213 = 213 // 京东金融
    case typeTransfer214 = 214 // 交通出行
    case typeTransfer215 = 215 // 短信扣费
    case typeTransfer216 = 216 // 购物
    case typeTransfer217 = 217 // 还款/抖音月付等等
    case typeTransfer218 = 218 // 猫眼
    case typeTransfer219 = 219 // 各种红包消费
    case typeTransfer220 = 220 // 餐饮-
    case typeTransfer221 = 221 // 充值
    case typeTransfer222 = 222 // 奶茶店消费 其他-
    
    // 收入
    case typeTransfer101 = 101 // 别人转给我
    case typeTransfer102 = 102 // 自己转自己
    case typeTransfer103 = 103 // 微信提现
    case typeTransfer104 = 104 // 微信商户提现
    case typeTransfer105 = 105 // 支付宝提现
    case typeTransfer106 = 106 // 支付宝商户提现
    case typeTransfer108 = 108 // 结息
    case typeTransfer109 = 109 // 退款
    
    var type: Int {
        return self.rawValue
    }
}
