//
//  FaceRecognitionView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/8.
//

import UIKit
import LocalAuthentication
import Foundation

class FaceRecognitionCtrl: UIViewController {
    
    var faceRecognitionSuccess:(() -> Void)?
    var timelb:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        self.modalPresentationStyle = .fullScreen
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance.init()
            appearance.backgroundImage = UIImage.init()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        setupUI()
    }
    
    
    func setupUI(){
        
        let leftImage:UIImageView = UIImageView(frame: CGRect(x: 15, y: navigationHeight - 24, width: 24, height: 24))
        leftImage.image = UIImage(named: "back_blcak")
        view.addSubview(leftImage)
        
        let backbtn:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: navigationHeight, height: navigationHeight))
        view.addSubview(backbtn)
        backbtn.addTarget(self, action: #selector(faceback), for: .touchUpInside)
        
        
        let rightImage:UIImageView = UIImageView(frame: CGRect(x: SCREEN_WDITH - 39, y: navigationHeight - 24, width: 24, height: 24))
        rightImage.image = UIImage(named: "face_right")
        view.addSubview(rightImage)
        
        let userImage:UIImageView = UIImageView(frame: CGRect(x: SCREEN_WDITH/2.0 - 35, y: navigationHeight + 40, width: 70, height: 70))
        userImage.image = UIImage(named: "face_default")
        view.addSubview(userImage)
        
        timelb = creatLabel(CGRect(x: 0, y: navigationHeight + 130, width: SCREEN_WDITH, height: 40), String(format: "%@", myUser?.phone ?? "111****1111"), fontMedium(20), Main_TextColor)
        timelb!.textAlignment = .center
        view.addSubview(timelb!)
        
        let facebtn:UIButton = UIButton(frame: CGRect(x: SCREEN_WDITH/2.0 - 30, y: navigationHeight + 260, width: 60, height: 60))
        facebtn.setImage(UIImage(named: "face_btn"), for: .normal)
        facebtn.addTarget(self, action: #selector(authenticateWithFaceID), for: .touchUpInside)
        view.addSubview(facebtn)
        
        let detaillb:UILabel = creatLabel(CGRect(x: 0, y: navigationHeight + 365, width: SCREEN_WDITH, height: 20), "点击进行人脸登录", fontRegular(15), Main_TextColor)
        detaillb.textAlignment = .center
        view.addSubview(detaillb)
        
        let morelb:UILabel = creatLabel(CGRect(x: 0, y: SCREEN_HEIGTH - bottomSafeAreaHeight - 40, width: SCREEN_WDITH, height: 25), "更多", fontRegular(14), Main_detailColor)
        morelb.textAlignment = .center
        view.addSubview(morelb)
    }
    
    @objc func faceback(){
        print("退出登录")
    }
    
    @objc func authenticateWithFaceID() {

        timelb?.text = String(format: "%@", myUser?.phone ?? "111****1111")
        
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "请使用 Face ID 验证身份") { success, authError in
                DispatchQueue.main.async {
                    if success {
                        print("Face ID 验证通过")
                        //不管成功还是失败
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if self.faceRecognitionSuccess != nil {
                                self.faceRecognitionSuccess?()
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("验证失败：\(authError?.localizedDescription ?? "")")
                        //请重试
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
        self.navigationController?.present(alert, animated: true)
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
