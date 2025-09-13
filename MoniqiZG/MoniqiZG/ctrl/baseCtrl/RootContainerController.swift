//
//  Untitled.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/28.
//

import UIKit
import SnapKit

class RootContainerController: UIViewController {

    // 自定义 tabbar（你可以自由实现 UI、交互等）
    private let tabBarView = CustomTabBarView()
    
    // 内容容器
    private let contentContainerView = UIView()
    
    // 当前展示的 VC
    private var currentChildVC: UIViewController?
    
    // 所有子页面
    private var _childViewControllers: [BaseCtrl] = [
        MainCtrl(),
        CardCtrl(),
        WealthCtrl(),
        LifeCtrl(),
        MyCtrl()
    ]

    var childViewControllersList: [BaseCtrl] {
        get { _childViewControllers }
        set { _childViewControllers = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupTabBarAction()
        switchToTab(index: 0)
    }
    
    private func setupLayout() {
        view.addSubview(contentContainerView)
        view.addSubview(tabBarView)
        
        tabBarView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(tabBarHeight)
        }
        
        contentContainerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(tabBarView.snp.top)
        }
    }

    private func setupTabBarAction() {
        tabBarView.onTabSelected = { [weak self] index in
            self?.switchToTab(index: index)
        }
    }

    func switchToTab(index: Int) {
        // 确保索引在有效范围内
        guard index >= 0 && index < _childViewControllers.count else {
            print("索引超出范围: \(index)")
            return
        }
        
        let newVC = _childViewControllers[index]
        if currentChildVC == newVC { return }
        
        // 移除当前VC
        currentChildVC?.willMove(toParent: nil)
        currentChildVC?.view.removeFromSuperview()
        currentChildVC?.removeFromParent()
        
        // 添加新VC
        addChild(newVC)
        contentContainerView.addSubview(newVC.view)
        newVC.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        newVC.didMove(toParent: self)
        currentChildVC = newVC
        
        // 更新 tabbar 选中状态
        updateTabBarSelection(index: index)
    }
    
    // MARK: - 公共方法：获取当前选中的索引
    func currentSelectedIndex() -> Int? {
        guard let currentVC = currentChildVC,
              let index = _childViewControllers.firstIndex(where: { $0 == currentVC }) else {
            return nil
        }
        return index
    }
    
    // MARK: - 私有方法：更新 TabBar 选中状态
    private func updateTabBarSelection(index: Int) {
        // 这里需要修改 CustomTabBarView 来支持外部设置选中状态
        // 首先在 CustomTabBarView 中添加一个公共方法：
        tabBarView.selectTab(at: index)
    }
}


