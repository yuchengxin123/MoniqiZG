//
//  FaceRecognitionView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/8.
//

import UIKit
import LocalAuthentication
import Foundation

class FaceRecognitionView: UIView {
    
    var faceRecognitionSuccess:(() -> Void)?
    var timelb:UILabel?
    var ctrl:BaseCtrl?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        self.backgroundColor = .white
        
        let rightImage:UIImageView = UIImageView(frame: CGRect(x: SCREEN_WDITH - 35, y: navigationHeight - 22, width: 20, height: 20))
        rightImage.image = UIImage(named: "face_right")
        addSubview(rightImage)
        
        let userImage:UIImageView = UIImageView(frame: CGRect(x: SCREEN_WDITH/2.0 - 45, y: navigationHeight + 20, width: 90, height: 90))
        userImage.image = UIImage(named: "face_default")
        addSubview(userImage)
        ViewRadius(userImage, 40)
        
        
        var timeStr = "上午好"
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        if hour >= 14 && hour <= 18 {
            timeStr = "下午好"
        } else if hour >= 11 && hour <= 14{
            timeStr = "中午好"
        } else if hour >= 5 && hour <= 11{
            timeStr = "早上好"
        }else{
            timeStr = "晚上好"
        }
        
        timelb = creatLabel(CGRect(x: 0, y: navigationHeight + 150, width: SCREEN_WDITH, height: 40), String(format: "%@，%@", myUser?.nickname ?? "",timeStr), fontRegular(25), Main_TextColor)
        timelb!.textAlignment = .center
        addSubview(timelb!)
        
        let facebtn:UIButton = UIButton(frame: CGRect(x: SCREEN_WDITH/2.0 - 25, y: navigationHeight + 250, width: 50, height: 50))
        facebtn.setImage(UIImage(named: "face_btn"), for: .normal)
        facebtn.addTarget(self, action: #selector(authenticateWithFaceID), for: .touchUpInside)
        addSubview(facebtn)
        
        let detaillb:UILabel = creatLabel(CGRect(x: 0, y: navigationHeight + 320, width: SCREEN_WDITH, height: 20), "点击进行面容ID登录", fontRegular(14), Main_TextColor)
        detaillb.textAlignment = .center
        addSubview(detaillb)
        
        let morelb:UILabel = creatLabel(CGRect(x: 0, y: navigationHeight + 375, width: SCREEN_WDITH, height: 25), "更多选项", fontRegular(16), Main_TextColor)
        morelb.textAlignment = .center
        addSubview(morelb)
    }
    
    
    @objc func authenticateWithFaceID() {
        var timeStr = "上午好"
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        if hour >= 14 && hour <= 18 {
            timeStr = "下午好"
        } else if hour >= 11 && hour <= 14{
            timeStr = "中午好"
        } else if hour >= 5 && hour <= 11{
            timeStr = "早上好"
        }else{
            timeStr = "晚上好"
        }
        
        timelb?.text = String(format: "%@，%@", myUser?.nickname ?? "",timeStr)
        
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "请使用 Face ID 验证身份") { success, authError in
                DispatchQueue.main.async {
                    if success {
                        print("Face ID 验证通过")
                    } else {
                        print("验证失败：\(authError?.localizedDescription ?? "")")
                        //请重试
                    }
                    //不管成功还是失败
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if self.faceRecognitionSuccess != nil {
                            self.faceRecognitionSuccess?()
                        }
                    }
                }
            }
        } else {
            print("设备不支持 Face ID：\(error?.localizedDescription ?? "")")
            showLocationPermissionAlert()
        }
    }
    
    func showLocationPermissionAlert() {
        // 创建 alert controller
        let alert = UIAlertController(
            title: "需要开启人脸识别",
            message: "人脸识别用于支付验证以及个人信息查看",
            preferredStyle: .alert
        )
        
        // 取消按钮
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel
        )
        alert.addAction(cancelAction)
        
        // 确定按钮 - 打开设置
        let settingsAction = UIAlertAction(
            title: "确认",
            style: .default
        ) { [weak self] _ in
            self?.openAppSettings()
        }
        alert.addAction(settingsAction)
        
        // 显示 alert
        self.ctrl?.navigationController?.present(alert, animated: true)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                print("打开设置: \(success ? "成功" : "失败")")
            }
        }
    }
}
