//
//  languageManager.swift
//  ZDSwift
//
//  Created by ycx on 2022/10/10.
//

import Foundation
import UIKit
class LanguageManager{
    let userLanguage = "userLanguage"
    let tableName = "Localizable"
    let httpDic = [LANGUAGES_CN:"zh-cn",LANGUAGES_EN:"en-us"]
    var bundle: Bundle?
    var currentLanguage:String?
    
    //单例
    static let LanguageMg = {
        let mg = LanguageManager.init()
        //初始化budle
        mg.changeBundle(mg.language())
        return mg
    }()

    //设置语言
    static func setUserlanguage(_ language:String) -> Void {
        if LanguageMg.currentLanguage == language{
            return
        }
        LanguageMg.currentLanguage = language;
        //保存语言到本地
        UserDefaults.standard.set(language, forKey: LanguageMg.userLanguage)
        
        //改变获取文案的budle
        LanguageMg.changeBundle(language)

        //更新区号列表
        
        //通知更新页面
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChangeLanguageNotificationName), object: nil)
    }
    
    func changeBundle(_ language:String) -> Void {
        let mainBundle = Foundation.Bundle.main
        if let path = mainBundle.path(forResource: self.languageFormat(language), ofType: "lproj"){
            self.bundle = Foundation.Bundle(path: path)
         }
    }
    
    //获取语言
    func language() -> String {
        if let language =  UserDefaults.standard.object(forKey: self.userLanguage) as? String{
            return language
        }else{
            let language = Locale.preferredLanguages.first ?? LANGUAGES_EN
            if self.httpDic.keys.contains(language){
                return language
            }else{
                return LANGUAGES_EN
            }
        }
    }
    
    func languageFormat(_ language:String) -> String {
        if language.contains("zh-Hans"){
            return "zh-Hans";
        }else if language.contains("zh-Hant"){
            return "zh-Hans";
        }else{
            //字符串查找
            if language.contains("-"){
                let ary:[String] = language.components(separatedBy: "-")
                if ary.count > 1 {
                    return ary.first ?? language
                }
            }
        }
        return language;
    }
    
    
    //获取当前语种下的内容
    static func localizedStringForKey(_ key:String) -> String {
        //先初始化语言
        if(LanguageMg.currentLanguage == nil) {
            LanguageMg.currentLanguage = LanguageMg.language()
        }
        //本地存储的语言字段 要转化成系统.lproj文件对应的字段
      //  let language = LanguageMg.languageFormat(LanguageMg.currentLanguage ?? "")

        return LanguageMg.bundle!.localizedString(forKey: key, value: "", table: LanguageMg.tableName)
    }
    
    //图片多语言处理 有2种处理方案，第一种就是和文字一样，根据语言或者对应路径下的图片文件夹，然后用获取文字的方式，获取图片名字，或者用下面这种方法，图片命名的时候加上语言后缀，获取的时候调用此方法，在图片名后面加上语言后缀来显示图片
    static func localizedImageWithName(_ name:String) -> UIImage {
        return UIImage()
    }
    
    //获取请求参数语言
    static func HttpLanguage() -> String {
        return LanguageMg.httpDic[LanguageMg.language()]!
    }
}
