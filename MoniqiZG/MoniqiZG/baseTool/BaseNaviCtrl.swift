//
//  BaseNaviCtrl.swift
//  swiftTest
//
//  Created by ycx on 2022/8/26.
//

import UIKit

class BaseNaviCtrl: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
