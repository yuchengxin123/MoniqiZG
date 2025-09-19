//
//  AppDelegate.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/28.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        requestNotificationPermission()
        requestNetworkPermission()
        
        myUser = UserManager.shared.loadUser()
        UserManager.shared.saveUser()
        //捕获oc异常--运行时发生的错误 比如数组越界、字典插入 nil、KVC 错误等
        NSSetUncaughtExceptionHandler { exception in
            //异常捕获
        }
        //捕获系统 Signal 比如野指针、空指针访问、非法内存写入
        setupSignalHandlers()
        
        getAllFontName()
        
        // 清除角标
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)

        let navi = BaseNaviCtrl.init(rootViewController: rootCtrl)
        self.window?.rootViewController = navi
        self.window?.makeKeyAndVisible()
        
        showAds()
        
        loadBankList()
        
        //交易记录
        myTradeList = TransferModel.loadArray(forKey: MyTradeRecord, as: TransferModel.self)
        //转账伙伴
       // myPartnerList = TransferPartner.loadArray(forKey: MyTransferPartnerCards, as: TransferPartner.self)
        //我的卡
        myCardList = [CardModel(),CardModel()]
        //CardModel.loadArray(forKey: MyCards, as: CardModel.self)
        
        
        return true
    }
    
    
    func showAds(){
        let ads:RandomAdsView = RandomAdsView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WDITH, height: SCREEN_HEIGTH))
        KWindow?.addSubview(ads)
        ads.startCountdown()
    }
    
    func loadBankList(){
        DispatchQueue.main.async {
            guard let url = Bundle.main.url(forResource: "bank_list", withExtension: "json") else {
                print("❌ 没有找到 bank_list.json")
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                // 解析成字典
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    bankList = (jsonObject["bankList"] as? [[String: Any]] ?? [])
                    hotBank = (jsonObject["hotBank"] as? [[String: Any]] ?? [])
                    bankSection = bankBuildSectionData(bankList: bankList, commonList: hotBank)
                } else {
                    print("❌ JSON 不是字典格式")
                }
            } catch {
                print("❌ 解析失败: \(error)")
            }
        }
    }
    
    // App 在前台时收到通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list]) // iOS 14+ 用 .banner
    }
    
    // 用户点击通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("用户点击了通知: \(response.notification.request.identifier)")
        UIApplication.shared.applicationIconBadgeNumber = 0 // 清除角标
        completionHandler()
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { granted, error in
            if granted {
                print("通知权限已授权")
                UNUserNotificationCenter.current().delegate = self
            } else {
                print("通知权限被拒绝")
            }
        }
    }
    
    func requestNetworkPermission(){
        YcxHttpManager.getTimestamp() { msg,data,code  in
            
        }
    }
}


func setupSignalHandlers() {
    signal(SIGABRT) { signal in handleSignal(signal) }
    signal(SIGILL)  { signal in handleSignal(signal) }
    signal(SIGSEGV) { signal in handleSignal(signal) }
    signal(SIGFPE)  { signal in handleSignal(signal) }
    signal(SIGBUS)  { signal in handleSignal(signal) }
    signal(SIGPIPE) { signal in handleSignal(signal) }
}

func handleSignal(_ signal: Int32) {
    let reason = "Signal \(signal) was raised."
    let exception = NSException(name: NSExceptionName(rawValue: "SignalException"),
                                reason: reason,
                                userInfo: nil)
    //异常上报
    exit(signal)
}
