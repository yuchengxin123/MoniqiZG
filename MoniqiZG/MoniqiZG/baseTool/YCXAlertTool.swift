//
//  YCXAlertTool.swift
//  ZDSwift
//
//  Created by ycx on 2023/3/31.
//

import UIKit
import Foundation


enum ZDYActionStyle {
    case Center
    case Bottom
}


class YCXAlertTool: NSObject {
    
    /// 快速创建系统AlertController：包括Alert 和 ActionSheet，带颜色
    /// - Parameters:
    ///   - title: 标题文字
    ///   - message: 消息体文字
    ///   - actionTitles: 可选择点击的按钮文字（不包括取消）
    ///   - cancelTitle: 取消按钮文字
    ///   - style: 类型：Alert 或者 ActionSheet
    ///   - actionStyles: 按钮颜色类型（与actionTitles长度一致生效）
    ///   - completion: 完成点击按钮之后的回调（取消按钮的index 为 0 ，其他按钮的index从上往下依次为 1、2、3...）
    static func YCX_showSysAlert(title:String, message:String, actionTitles:Array<String>, cancelTitle:String, style:UIAlertController.Style, actionStyles:Array<UIAlertAction.Style>=[], completion: @escaping ((_ index: Int) -> ())) {
        
        let vc = MoniqiZG.keyWindow?.rootViewController
        vc?.dismiss(animated: false)

        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title.count == 0 ? nil : title, message:message.count == 0 ? nil : message , preferredStyle: style)
            for i in 0 ..< actionTitles.count {
                let action = UIAlertAction(title: actionTitles[i], style: actionTitles.count == actionStyles.count ? actionStyles[i]: .default) { action in
                    completion(i+1)
                }
                alertController.addAction(action)
            }
            if (!cancelTitle.isEmpty) {
                let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                    completion(0)
                }
                alertController.addAction(cancel)
            }
            vc?.present(alertController, animated: true, completion: nil)
        }
    }
}


class YCXAlertView: UIView {
    /// 快速创建自定义alert
    /// - Parameters:
    ///   - title: 标题文字
    ///   - message: 消息体文字
    ///   - actionTitles: 可选择点击的按钮文字（不包括取消）
    ///   - cancelTitle: 取消按钮文字
    ///   - style: 类型：Bottom 或者 Center
    ///   - myCompletion: 完成点击按钮之后的回调（取消按钮的index 为 0 ，其他按钮的index从上往下依次为 1、2、3...）
    
    var myCompletion: ((_ index: Int) -> ())? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    static func YCX_showBankAlert(title:String, message:NSAttributedString, completion: @escaping ((_ index: Int) -> ())) {
        let window:UIWindow = MoniqiZG.keyWindow ?? UIWindow.init()

        let view =  window.viewWithTag(10001)
        view?.removeFromSuperview()
        
        let bgView:YCXAlertView = YCXAlertView.init(frame: window.bounds)
        bgView.myCompletion = completion
        bgView.backgroundColor = UIColor.init(white: 0x000000, alpha: 0.3)
        bgView.tag = 10001
        window.addSubview(bgView)
        
        var y = 20.0
        
        let btnView:UIView = UIView.init(frame: CGRect(x: 15, y: 0, width: SCREEN_WDITH - 30, height: 130.0))
        btnView.backgroundColor = .white
        bgView.addSubview(btnView)
        
        if title.count > 0 {
            let titleHigh = sizeHigh(fontMedium(18), btnView.frame.width - 20.0, title)
            
            let titlelb = creatLabel(CGRect(x: 10, y: y, width: btnView.frame.width - 20.0, height: titleHigh), title, fontMedium(18), Main_TextColor)
            titlelb.textAlignment = .center
            btnView.addSubview(titlelb)
            y = y + titleHigh + 5.0
        }
        
        let high:CGFloat = message.height(constrainedToWidth: SCREEN_WDITH - 60)
        
        let messagelb = creatLabel(CGRect(x: 10, y: y, width: btnView.frame.width - 20.0, height: high), "", fontRegular(15), Main_TextColor)
        messagelb.attributedText = message
        messagelb.numberOfLines = 0
        messagelb.textAlignment = .center
        btnView.addSubview(messagelb)
        
        y = y + high + 20.0
        
        let line = UIView.init(frame: CGRect(x: 0, y: y, width: btnView.frame.width, height: 0.5))
        line.backgroundColor = defaultLineColor
        btnView.addSubview(line)
        
        y+=0.5
        
        let btn = creatButton(CGRect(x: 0, y: y, width: btnView.frame.width/2.0, height: 60.0), "取消", fontRegular(15), Main_TextColor, .clear, bgView, #selector(cancleAlert))
        btnView.addSubview(btn)
        
        let surebtn = creatButton(CGRect(x: btnView.frame.width/2.0, y: y, width: btnView.frame.width/2.0, height: 60), "确认", fontRegular(15), HXColor(0x6697e0), .clear, bgView, #selector(sureAlert))
        btnView.addSubview(surebtn)
        
        let verticalline = UIView.init(frame: CGRect(x: btnView.frame.width/2.0, y: y , width: 0.5, height: 60.0))
        verticalline.backgroundColor = defaultLineColor
        btnView.addSubview(verticalline)
        
        y+=60.0
        
        btnView.frame = CGRect(x: 15, y: SCREEN_HEIGTH/2.0 - y/2.0, width: SCREEN_WDITH - 30.0, height: y)
        ViewRadius(btnView, 8)
    }
    
    @objc func sureAlert(){
        if self.myCompletion != nil{
            self.myCompletion!(1)
        }
        self.cancleAlert()
    }
    
    @objc func cancleAlert(){
        self.removeFromSuperview()
    }
    
}
