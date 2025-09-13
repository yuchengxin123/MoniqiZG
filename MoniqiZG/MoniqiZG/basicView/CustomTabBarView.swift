//
//  CustomTabBarView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/5.
//
import UIKit

class CustomTabBarView: UIView {
    
    var onTabSelected: ((Int) -> Void)?
    var selectBtn:YcxImageTextButton?
    private let titles = ["首页", "社区", "财富", "生活", "我的"]
    private let images = ["cob_tab_home_default_normal", "cmb_reference_tab_default_normal", "cmb_tab_fortune_default_normal", "com_life_tab_default_normal", "cmb_icon_main_menu_mine"]
    //cmb_life_tab_default_selected
    private let selectimages = ["cmb_tab_home_default_selected", "cmb_reference_tab_default_selected", "cmb_tab_fortune_default_selected", "cmb_reference_tab_default_selected", "com_icon_main_menu_mined"]
    private var buttons: [YcxImageTextButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = tabbar_Color
    
        let line = UIView()
        line.backgroundColor = Main_LineColor
        addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        let wide:CGFloat = SCREEN_WDITH/CGFloat(images.count)
        
        for (i, title) in titles.enumerated() {
            let normalImage = getWebImage(images[i])
            let selectedImage = getWebImage(selectimages[i])

            let button = YcxImageTextButton()
            button.tag = 10000 + i
            button.normalImage = normalImage
            button.selectedImage = selectedImage
            button.normalTextColor = Main_normalColor
            button.selectedTextColor = Main_TextColor
            button.normalFont = fontRegular(10)
            button.selectedFont = fontRegular(10)
            button.imageSize = CGSize(width: 28, height: 28)
            button.title = title
            button.spacing = 6
            button.position = .top
            button.onTap = { [weak self] in
                self?.tabTapped(button)
            }
            button.isSelected = false
            buttons.append(button)
            addSubview(button)
            let left:CGFloat = wide * CGFloat(i)
            
            button.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(5)
                make.left.equalToSuperview().offset(left)
                make.width.equalTo(wide)
                make.height.equalTo(50)
            }
            // 默认选中第一个
            if i == 0 {
                button.isSelected = true
                selectBtn = button
            }
        }
        
        self.layoutIfNeeded()
    }

    @objc private func tabTapped(_ sender: YcxImageTextButton) {
        guard sender != selectBtn else { return }

        selectBtn?.isSelected = false
        sender.isSelected = true
        selectBtn = sender

        onTabSelected?(sender.tag - 10000)
    }
    
    // MARK: - 公共方法：外部设置选中标签
    func selectTab(at index: Int) {
        guard index >= 0 && index < buttons.count else {
            print("索引超出范围: \(index)")
            return
        }
        
        let targetButton = buttons[index]
        guard targetButton != selectBtn else { return }
        
        selectBtn?.isSelected = false
        targetButton.isSelected = true
        selectBtn = targetButton
    }
    
    // MARK: - 公共方法：获取当前选中索引
    func currentSelectedIndex() -> Int? {
        guard let selectBtn = selectBtn else { return nil }
        return selectBtn.tag - 10000
    }
}
