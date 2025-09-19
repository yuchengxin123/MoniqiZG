//
//  Config.swift
//  swiftTest
//
//  Created by ycx on 2022/8/29.
//

import Foundation
import UIKit

let httpUrl = "https://fhd2.w-dian.cn/"


let API_getToken = "cloud/api/checkToken"
let API_getTime = "cloud/api/ttdskskfja"

//语言
let LANGUAGES_CN = "zh-Hans-CN"
let LANGUAGES_EN = "en"

let SCREEN_WDITH = UIScreen.main.bounds.width
let SCREEN_HEIGTH = UIScreen.main.bounds.height

//导航栏高度
let navigationHeight = (statusBarHeight + 44.0)
//tabbar高度
let tabBarHeight = (statusBarHeight >= 44.0 ? 83.0 : 49.0)
//顶部的安全距离
let topSafeAreaHeight = (statusBarHeight - 20.0)
//键盘高度
let CustomKeyboardHeight = 230 + bottomSafeAreaHeight

let WaterMark:WatermarkOverlay = {
    let watermark = WatermarkOverlay(frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
    watermark.tag = 9999
    return watermark
}()

let rootCtrl = RootContainerController.init()

//底部的安全距离
var bottomSafeAreaHeight : CGFloat {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
    } else {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
}

var keyWindow: UIWindow? {
    if #available(iOS 13.0, *) {
        // 获取当前活动的 UIWindowScene
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene } // 转换为 UIWindowScene
            .flatMap { $0.windows }              // 获取所有 UIWindow
            .first { $0.isKeyWindow }            // 找到 isKeyWindow 为 true 的窗口
    } else {
        // iOS 13 以下使用传统方式
        return UIApplication.shared.keyWindow
    }
}
////热门卡号列表
var hotBank:[Dictionary<String,Any>] = []
////卡号列表
var bankList:[Dictionary<String,Any>] = []

var bankSection:[[[String: Any]]] = []

//我的卡片
var myCardList:[CardModel] = []
//我的交易记录
var myTradeList:[TransferModel] = []

//是否进行人脸识别
var faceCheck = true

let transferTags = ["工资","生活费","还信用卡","还贷款","月房租","还钱给","借钱给"]

//名字库
let firstNames = ["李", "王", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴",
                  "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗",
                  "梁", "宋", "郑", "谢", "韩", "唐", "冯", "于", "董", "萧",
                  "程", "曹", "袁", "邓", "许", "傅", "沈", "曾", "彭", "吕",
                  "苏", "卢", "蒋", "蔡", "贾", "丁", "魏", "薛", "叶", "阎",
                  "余", "潘", "杜", "戴", "夏", "锺", "汪", "田", "任", "姜",
                  "范", "方", "石", "姚", "谭", "廖", "邹", "熊", "金", "陆",
                  "郝", "孔", "白", "崔", "康", "毛", "邱", "秦", "江", "史",
                  "顾", "侯", "邵", "孟", "龙", "万", "段", "雷", "钱", "汤",
                  "尹", "黎", "易", "常", "武", "乔", "贺", "赖", "龚", "文",
                  "庞", "樊", "兰", "殷", "施", "陶", "洪", "翟", "安", "颜",
                  "倪", "严", "牛", "温", "芦", "季", "俞", "章", "鲁", "葛",
                  "伍", "韦", "申", "尤", "毕", "聂", "丛", "焦", "向", "柳",
                  "邢", "路", "岳", "齐", "沿", "梅", "莫", "庄", "辛", "管",
                  "祝", "左", "涂", "谷", "祁", "时", "舒", "耿", "牟", "卜",
                  "路", "詹", "关", "苗", "凌", "费", "纪", "靳", "盛", "童"]
let lastNames =  ["伟", "芳", "娜", "敏", "丽", "强", "磊", "军", "洋", "婷",
                  "静", "杰", "娟", "艳", "勇", "超", "萍", "鹏", "琳", "健",
                  "丹", "波", "华", "明", "刚", "佳", "玲", "伟", "秀英", "秀兰",
                  "燕", "艳", "敏", "静", "丽", "娟", "艳", "霞", "秀兰", "文",
                  "英", "慧", "颖", "雪", "洁", "玉", "婷", "莹", "倩", "君",
                  "文", "明", "建", "平", "涛", "辉", "强", "军", "杰", "斌",
                  "鹏", "浩", "宇", "飞", "超", "鑫", "亮", "凯", "伟", "博",
                  "帅", "龙", "阳", "帅", "威", "帅", "聪", "乐", "鑫", "磊",
                  "洋", "勇", "刚", "健", "杰", "峰", "毅", "宁", "栋", "彬",
                  "旭", "晨", "睿", "哲", "轩", "泽", "然", "皓", "宇", "航",
                  "扬", "坤", "寅", "舜", "禹", "舜", "尧", "禹", "启", "承",
                  "熙", "然", "佑", "宸", "睿", "昕", "晗", "昊", "晟", "昱",
                  "昭", "朗", "胤", "弘", "翰", "玮", "琛", "珅", "琦", "琨",
                  "琰", "珏", "玺", "璇", "璐", "玥", "珂", "珊", "琳", "琪",
                  "瑶", "莹", "瑾", "璇", "妍", "婕", "姝", "娴", "婉", "婵",
                  "欣妍", "紫怡", "紫璇", "云", "佳怡", "佳慧","诗", "晨", "宇",
                  "婷", "俊", "鑫", "爽", "亮", "婷", "成"]

//我的卡片
let MyCards = "MyCards"
//交易记录
let MyTradeRecord = "MyTradeRecord"

let KWindow = MoniqiZG.keyWindow
//通知
//语言更新
let ChangeLanguageNotificationName = "changeLanguageNotifi"

//更新头像
let changeUserIconNotificationName = "changeUserIcon"

//更新我的余额
let changeMyBalanceNotificationName = "changeMyBalance"

//更新我的收入
let changeMyIncomeNotificationName = "changeMyIncome"

//更新转账记录
//let changeMyTransferNotificationName = "changeMyTransfer"

//添加卡片
let addMyCardNotificationName = "addMyCardNotificationName"


let Main_TextColor:UIColor = HXColor(0x222222)

let Color333333:UIColor = HXColor(0x333333)

let Main_normalColor:UIColor = HXColor(0x8a8a8a)

let Main_backgroundColor:UIColor = HXColor(0xf4f4f4)

let tabbar_Color:UIColor = HXColor(0xfaf9fa)

let Main_LineColor:UIColor = HXColor(0xe5e5e5)

let Main_Color:UIColor = HXColor(0xdf2d46)

let Main_detailColor:UIColor = HXColor(0x666666)

let ColorF5F5F5:UIColor = HXColor(0xF5F5F5)

let fieldPlaceholderColor:UIColor = HXColor(0x929292)

let LightColor:UIColor = HXColor(0xFDF1DB)

let MyDetailColor:UIColor = HXColor(0x808080)

let defaultLineColor:UIColor = HXColor(0xefefef)

let MoneyColor:UIColor = HXColor(0xe02d47)

let fieldHigh = 46.0
let fieldFont = fontMedium(14)
let fieldPlaceholderFont = fontRegular(15)

//获取本地语言
public func LocalizedString(_ key:String) -> String {
    return LanguageManager.localizedStringForKey(key);
}

public func getWebImage(_ path:String) -> UIImage {
    if let path = Bundle.main.path(forResource: path, ofType: "webp"),
       let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
       let image = UIImage(data: data){
        return image
    }else{
        return UIImage()
    }
}

//状态栏高度
let statusBarHeight:CGFloat = {
   if #available(iOS 13.0, *) {
       let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
       let frame = scene?.statusBarManager?.statusBarFrame
       return frame?.height ?? 0
    } else {
       return UIApplication.shared.statusBarFrame.size.height
    }
}()


//颜色
public func MLColor(_ red:CGFloat,_ green:CGFloat,_ blue:CGFloat,_ alpha:CGFloat) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha);
}

public func HXColor(_ rgbValue:NSInteger,_ alpha:Double = 1.0) -> UIColor {
    return UIColor(red: (CGFloat)((rgbValue & 0xFF0000) >> 16)/255.0, green: (CGFloat)((rgbValue & 0xFF00) >> 8)/255.0, blue: (CGFloat)(rgbValue & 0xFF)/255.0, alpha: alpha);
}

public func RGBCOLOR(_ red:CGFloat,_ green:CGFloat,_ blue:CGFloat) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1);
}


public func addLayer(_ color:CGColor ,_ view:UIView , _ radius:CGFloat , _ superView:UIView){
    let layer = CALayer.init()
    layer.frame = view.frame
    layer.cornerRadius = radius
    layer.backgroundColor = color
    layer.shadowColor = color
    layer.shadowRadius = radius;
    layer.shadowOpacity = 1;
    layer.shadowOffset = CGSize(width: 0, height: 0)
    superView.layer.insertSublayer(layer, at: 0)
}

public func addGradientLayerWithframe(_ frame:CGRect,_ colors:Array<CGColor>,locations:Array<NSNumber> = [NSNumber(value: 0), NSNumber(value: 1.0)]) -> CAGradientLayer{
    let gl:CAGradientLayer = CAGradientLayer.init()
    gl.frame = frame
    gl.startPoint = CGPointMake(0.5, 0)
    gl.endPoint = CGPointMake(0.5, 1)
    gl.colors = colors
    gl.locations = [NSNumber(value: 0), NSNumber(value: 1.0)]
    return gl
}


//字体
public func fontMedium(_ fontSize:CGFloat) -> UIFont{
    let font:UIFont = UIFont.init(name: "PingFangSC-Medium", size: fontSize)!
    return font
}

public func fontRegular(_ fontSize:CGFloat) -> UIFont{
    let font:UIFont = UIFont.init(name: "PingFangSC-Regular", size: fontSize)!
    return font
}

public func fontSemibold(_ fontSize:CGFloat) -> UIFont{
    let font:UIFont = UIFont.init(name: "PingFangSC-Semibold", size: fontSize)!
    return font
}

public func fontLight(_ fontSize:CGFloat) -> UIFont{
    let font:UIFont = UIFont.init(name: "PingFangSC-Light", size: fontSize)!
    return font
}


//UIFont.systemFont(ofSize: 20, weight: .medium)

//数字字体
public func fontNumber(_ fontSize:CGFloat,_ weight:UIFont.Weight = .medium) -> UIFont{
//    let font:UIFont =  UIFont.systemFont(ofSize: fontSize, weight: weight)
//    "DINPro-Medium"
    //MenkNarinStdExTig
    let font:UIFont = UIFont.init(name: "DINPro-Medium", size: fontSize)!
    return font
}

//ZhuoYueYouHeiApp
public func fontZhuoYueYouHei(_ fontSize:CGFloat) -> UIFont{
    let font:UIFont = UIFont.init(name: "ZhuoYueYouHeiApp", size: fontSize)!
    return font
}

//数字转换
public func getNumberFormatter(_ number:Double, _ digits:Int = 2) -> String{
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = digits
    formatter.maximumFractionDigits = digits
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: NSNumber(value: number)) ?? "0.00"
}

//获取本地字体信息
public func getAllFontName(){
    for familyName in UIFont.familyNames {
        print("Family: \(familyName)")
        for name in UIFont.fontNames(forFamilyName: familyName) {
            print("  Font: \(name)")
        }
    }
}

//获取当前时间
//"MM.dd HH:mm"
func getCurrentTimeString(dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = dateFormat
    return formatter.string(from: Date())
}

//时间格式转化 "2025-08-08 00:00:00"  // 输出: "2025年08月08日"
func formatDateStringFlexible(_ dateString: String) -> String {
    let dateFormats = [
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd",
        "yyyy/MM/dd HH:mm:ss",
        "yyyy/MM/dd"
    ]
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "yyyy年MM月dd日"
    outputFormatter.locale = Locale(identifier: "zh_CN")
    
    for format in dateFormats {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = format
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
    }
    return dateString
}


//手动布局快捷创建基本控件
public func creatTable(_ delegate:(any UITableViewDelegate),_ dataSource:(any UITableViewDataSource)) -> UITableView {
    let tableView:UITableView = UITableView.init(frame: CGRectZero, style: .plain)
    tableView.isScrollEnabled = false
    tableView.delegate = delegate
    tableView.dataSource = dataSource
    tableView.separatorStyle = .none
    return tableView
}

public func creatLabel(_ frame:CGRect , _ title:String , _ font:UIFont, _ textColor:UIColor) -> UILabel {
    let lb = UILabel.init(frame: frame)
    lb.text = title
    lb.textColor = textColor
    lb.font = font
    lb.numberOfLines = 0
    return lb
}

public func creatButton(_ frame:CGRect , _ title:String , _ font:UIFont, _ textColor:UIColor ,_ backGroundColor:UIColor , _ target:Any? ,_ sel:Selector) -> UIButton {
    
    let btn = UIButton.init(frame: frame)
    btn.addTarget(target, action: sel, for: UIControl.Event.touchUpInside)
    btn.setTitle(title, for: UIControl.State.normal)
    btn.backgroundColor = backGroundColor
    btn.setTitleColor(textColor, for: UIControl.State.normal)
    btn.titleLabel?.font = font
    return btn
}

public func createField(_ frame:CGRect , _ placeholder:String , _ font:UIFont, _ textColor:UIColor , _ rightView:UIView?, _ leftView:UIView?) -> UITextField {
    
    let field = UITextField.init(frame: frame)
    field.font = font
    field.textColor = textColor
    field.backgroundColor = UIColor.white
    field.returnKeyType = .done
    field.leftViewMode = .always
    field.rightViewMode = .always
    
    let str:NSMutableAttributedString = NSMutableAttributedString.init(string: placeholder, attributes: [NSAttributedString.Key.font:font , NSAttributedString.Key.foregroundColor:fieldPlaceholderColor])
    field.attributedPlaceholder = str
    
    if let view = leftView {
        field.leftView = view
    }else{
        let emptyView = UIView.init(frame: CGRect(x: 0, y: 0, width: 15, height: fieldHigh))
        field.leftView = emptyView
    }

    if let view = rightView {
        field.rightView = view
    }else{
        let emptyView = UIView.init(frame: CGRect(x: 0, y: 0, width: 15, height: fieldHigh))
        field.rightView = emptyView
    }

    return field
}

///获取子字符串的位置信息
public func getRange(_ bigString:String , _ smallString:String) -> NSRange{
    let range: Range = bigString.range(of: smallString)!
    let location = bigString.distance(from: bigString.startIndex, to: range.lowerBound)
    return NSMakeRange(location, smallString.count)
}

public func sizeHigh(_ font:UIFont , _ MaxWide:CGFloat , _ text:String) -> CGFloat{
    let size = CGSize(width: MaxWide, height: CGFloat(MAXFLOAT))
    let paragraphStyle = NSMutableParagraphStyle()

//    paragraphStyle.lineSpacing = lineSpace
    
    paragraphStyle.lineBreakMode = .byWordWrapping
    
    paragraphStyle.lineBreakMode = .byWordWrapping;

    let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()], context:nil)
    
    return rect.size.height + 3
}

public func sizeWide(_ font:UIFont , _ text:String) -> CGFloat{
    
    let size = CGSize(width: CGFloat(MAXFLOAT), height: 50)
    let paragraphStyle = NSMutableParagraphStyle()

//    paragraphStyle.lineSpacing = lineSpace
    
    paragraphStyle.lineBreakMode = .byWordWrapping
    
    paragraphStyle.lineBreakMode = .byWordWrapping;

    let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()], context:nil)
    
    return rect.size.width + 3
}

//圆角和加边框
public func ViewBorderRadius(_ view:UIView , _ radius:CGFloat , _ Width:CGFloat , _ Color:UIColor){
    view.layer.masksToBounds = true
    view.layer.cornerRadius = radius
    view.layer.borderWidth = Width
    view.layer.borderColor = Color.cgColor
}

//圆角
public func ViewRadius(_ view:UIView , _ radius:CGFloat){
    view.layer.masksToBounds = true
    view.layer.cornerRadius = radius
}

//圆角
public func setRadius(_ view:UIView , _ radius:CGFloat, _ maskedCorners:CACornerMask){
    view.layer.cornerRadius = radius
    view.layer.masksToBounds = true
    view.layer.maskedCorners = maskedCorners
}



//设置指定圆角和加边框
public func SetCornersAndBorder(_ view: UIView, radius: CGFloat,corners: UIRectCorner,borderWidth: CGFloat = 0,borderColor: UIColor = .clear) {
    
    let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners,cornerRadii: CGSize(width: radius, height: radius))
    
    // 设置圆角蒙层
    let maskLayer = CAShapeLayer()
    maskLayer.frame = view.bounds
    maskLayer.path = path.cgPath
    view.layer.mask = maskLayer
    
    // 如果需要边框，单独再加一个 CAShapeLayer
    if borderWidth > 0 {
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = view.bounds
        view.layer.addSublayer(borderLayer)
    }
}

/// 设置圆角、边框及四周阴影
/// - Parameters:
///   - view: 目标视图
///   - radius: 圆角半径
///   - corners: 指定圆角位置
///   - borderWidth: 边框宽度 (默认0)
///   - borderColor: 边框颜色 (默认透明)
///   - shadowColor: 阴影颜色
///   - shadowRadius: 阴影模糊半径
///   - shadowOpacity: 阴影透明度 (0~1)
func setupViewWithRoundedCornersAndShadow(
    _ view: UIView,
    radius: CGFloat,
    corners: UIRectCorner = [.topLeft, .topRight , .bottomLeft, .bottomRight],
    borderWidth: CGFloat = 0,
    borderColor: UIColor = .clear,
    shadowColor: UIColor,
    shadowRadius: CGFloat,
    shadowOpacity: Float
) {
    // 1. 创建圆角路径 (用于边框和阴影)
    let path = UIBezierPath(
        roundedRect: view.bounds,
        byRoundingCorners: corners,
        cornerRadii: CGSize(width: radius, height: radius)
    )
    
    // 2. 设置圆角遮罩 (裁剪视图内容)
    let maskLayer = CAShapeLayer()
    maskLayer.path = path.cgPath
    view.layer.mask = maskLayer
    
    // 3. 添加边框图层
    if borderWidth > 0 {
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = borderWidth
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = view.bounds
        view.layer.addSublayer(borderLayer)
    }
    
    // 4. 设置四周阴影 (添加到父视图)
    let shadowLayer = CALayer()
    shadowLayer.frame = view.frame
    shadowLayer.shadowPath = path.cgPath // 关键: 使阴影匹配圆角形状
    shadowLayer.shadowColor = shadowColor.cgColor
    shadowLayer.shadowRadius = shadowRadius
    shadowLayer.shadowOpacity = shadowOpacity
    shadowLayer.shadowOffset = .zero // 四周阴影的关键!
    view.superview?.layer.insertSublayer(shadowLayer, below: view.layer)
}

//移除图片背景颜色
public func removeBackgroundColor(from image: UIImage,
                           targetColor: UIColor,
                           tolerance: CGFloat = 0.1) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let data = context.data else { return nil }

    let pixelBuffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)

    // 提取目标背景色的 RGB
    var rBG: CGFloat = 0, gBG: CGFloat = 0, bBG: CGFloat = 0, aBG: CGFloat = 0
    targetColor.getRed(&rBG, green: &gBG, blue: &bBG, alpha: &aBG)

    for y in 0..<height {
        for x in 0..<width {
            let offset = (y * bytesPerRow) + (x * bytesPerPixel)
            let r = CGFloat(pixelBuffer[offset]) / 255.0
            let g = CGFloat(pixelBuffer[offset + 1]) / 255.0
            let b = CGFloat(pixelBuffer[offset + 2]) / 255.0

            // 颜色容差判断
            let dr = abs(r - rBG)
            let dg = abs(g - gBG)
            let db = abs(b - bBG)

            if dr < tolerance && dg < tolerance && db < tolerance {
                pixelBuffer[offset + 3] = 0 // alpha 设置为 0（透明）
            }
        }
    }

    guard let outputCGImage = context.makeImage() else { return nil }
    return UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
}

// MARK: -  随机流水号
func generateRandom16DigitString() -> String {
    let characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<16).map { _ in
        characters.randomElement()!
    })
}

// MARK: -  随机商户单号
func generateRandomMerchantNumber() -> String {
    let characters = "0123456789"
    let str:String = String((0..<13).map { _ in
        characters.randomElement()!
    })
    return String(format: "%@%@", getCurrentTimeString(dateFormat: "yyyyMMdd"),str)
}


// MARK: - 随机金额
func randomAmount(min: Int = 1, max: Int = 99999) -> String {
    let amount = Int.random(in: min...max)
    return String(format: "%.02f", Double(amount)) // 转换为两位小数金额
}

// MARK: - 昨日收益
func getIncome(aomunt: Double) -> Double {
    return aomunt * 0.0325 / 360.0
}

// MARK: - 随机银行卡号
func randomBankCardNumber() -> Dictionary<String,Any> {
    if hotBank.count == 0 {
        return [:]
    }
    let index = Int.random(in: 0...(hotBank.count-1))
    
    let prefix:String = String(format: "%@", hotBank[index]["matchValue"] as! CVarArg) // 一些银行的卡号前缀
    let suffix = (0..<10).map { _ in String(Int.random(in: 0...9)) }.joined()
    let fullCardNumber = prefix + suffix
    
    // 每四位数字加一个空格
    let cardNumberWithSpaces = fullCardNumber.enumerated().map { (index, char) -> String in
        if index > 0 && index % 4 == 0 {
            return " \(char)"
        }
        return String(char)
    }.joined()
    
    return ["card":cardNumberWithSpaces,"hotBank":hotBank[index]]
}

// MARK: - 每四位数字加一个空格
func insertPhoneSpace(number:String ,show:Bool ,addSpace:Bool = true) -> String {
    
    var spaceNumber:String = number
    
    if show == false {
        spaceNumber = spaceNumber.enumerated().map { (index, char) -> String in
            if (index >= 3) && (index < spaceNumber.count - 4){
                return "*"
            }
            return String(char)
        }.joined()
    }

    if addSpace == true {
        spaceNumber = spaceNumber.enumerated().map { (index, char) -> String in
            if index == 3 {
                return " \(char)"
            }
            if (index - 7) % 4 == 0 {
                return " \(char)"
            }
            return String(char)
        }.joined()
    }

    return spaceNumber
}

// MARK: - 随机中文名字
func randomChineseName() -> String {
    let firstName = firstNames.randomElement()!
    let lastName = lastNames.randomElement()!
    return firstName + lastName
}

// MARK: - 随机时间字符串
func randomDate(from startYear: Int, to endYear: Int) -> String {
    // 生成起始日期
    let startDate = Calendar.current.date(from: DateComponents(year: startYear, month: 1, day: 1))!
    
    // 设置结束日期为当前时间
    let endDate = Date() // 当前时间

    // 生成随机的时间戳
    let randomTimeInterval = TimeInterval.random(in: startDate.timeIntervalSince1970...endDate.timeIntervalSince1970)
    let randomDate = Date(timeIntervalSince1970: randomTimeInterval)
    
    // 格式化时间为字符串
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: randomDate)
}

// MARK: - 金额转换中文单位
func getChineseMoney(str: String) -> String {
    let money: Double = Double(str) ?? 0.0
    
    switch money {
    case 100..<1_000:
        return "｜百 "
    case 1_000..<10_000:
        return "｜千 "
    case 10_000..<100_000:
        return "｜万 "
    case 100_000..<1_000_000:
        return "｜十万 "
    case 1_000_000..<10_000_000:
        return "｜百万 "
    case 10_000_000..<100_000_000:
        return "｜千万 "
    case 100_000_000..<1_000_000_000:
        return "｜亿 "
    case 1_000_000_000..<10_000_000_000:
        return "｜十亿 "
    default:
        return "｜百亿 "
    }
}

// MARK: - 设置前后指定位数 数字变为*号
func maskDigits(_ text: String, front: Int = 4, back: Int = 4) -> String {
    var chars = Array(text)
    
    var frontCount = front
    let backCount = chars.count - back
    
    if backCount < frontCount {
        return ""
    }
    
    // 先处理前 N 位
    for i in front..<backCount {
        if chars[i].isNumber {
            if frontCount < backCount {
                chars[i] = "*"
                frontCount += 1
            }
        }
    }

    return String(chars)
}

// MARK: - 激活会员
func upgradeVIP(isUpgrade:Bool){
    
    let fieldview:BasicFieldView = BasicFieldView.init(frame: KWindow?.bounds ?? CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
    fieldview.setContent(str: "填写激活码")
    fieldview.type = .integerType
    KWindow?.addSubview(fieldview)
    
    fieldview.changeContent = { text in
        
        UserManager.shared.checkPermissions(token: text,isUpgrade: isUpgrade)
    }
}


//MARK: - 银行列表按首字母分组排序
func bankBuildSectionData(bankList: [[String: Any]], commonList: [[String: Any]]) -> [[[String: Any]]] {
    // 1. 先按首字母分组
    var grouped: [String: [[String: Any]]] = [:]
    for item in bankList {
        let name = item["bankName"] as? String ?? ""
        let key = name.firstPinyinLetter
        grouped[key, default: []].append(item)
    }
    
    // 2. 对每个分组内排序
    for key in grouped.keys {
        grouped[key]?.sort {
            let lhs = ($0["bankName"] as? String ?? "")
            let rhs = ($1["bankName"] as? String ?? "")
            return lhs.firstPinyinLetter < rhs.firstPinyinLetter
        }
    }
    
    // 3. 构造 sections 和 data
    var sections: [String] = []
    var data: [[[String: Any]]] = []
    
    // 插入常用分组
    if !commonList.isEmpty {
        sections.append("常用")
        data.append(commonList)
    }
    
    // 其它 A-Z 分组
    let sortedKeys = grouped.keys.sorted()
    for key in sortedKeys {
        sections.append(key)
        data.append(grouped[key] ?? [])
    }
    
    return data
}
