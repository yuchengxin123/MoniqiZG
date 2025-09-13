//
//  BaseCtrl.swift
//  swiftTest
//
//  Created by ycx on 2022/8/26.
//

import UIKit

class BaseCtrl: UIViewController {
    var basicScrollView:UIScrollView!
    var addTap:Bool?
    var contentView: UIView!
    var tap:UITapGestureRecognizer?
    // 新增
    var enableLazyLoad: Bool = false   // 是否开启菊花加载再显示UI
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
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
        createScrollView()
        
        if enableLazyLoad {
            KWindow?.makeToastActivity(.center)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                KWindow?.hideToastActivity()
                self.setupUI()   // 开始加载页面 UI
            }
        } else {
            setupUI()
        }
    }
    
    /// 子类重写这个方法写布局
    @objc func setupUI() {
        // 默认空实现，子类 override
    }
    
    func createScrollView(){
        basicScrollView = UIScrollView()
        basicScrollView.showsVerticalScrollIndicator = false
        basicScrollView.showsHorizontalScrollIndicator = false
        basicScrollView.backgroundColor = .white
        view.addSubview(basicScrollView)

        basicScrollView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView = UIView()
        contentView.backgroundColor = .white
        basicScrollView.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            // Height will be determined by content
        }
        
        //禁用系统对 ScrollView 的自动 contentInset 调整行为
        if #available(iOS 11.0, *) {
            basicScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    //自定义导航栏的按钮
    func loadNaviBtn(){
        // 容器 view，扩大点击范围
        let container = UIView()
        container.backgroundColor = .clear
        self.view.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(navigationHeight - 52) // 原来是 -42，向上扩10
            make.width.height.equalTo(60) // 原来按钮是 40，加上下左右各 10
        }

        let btn = UIButton()
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        container.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40) // 原来尺寸
        }
    }

    @objc func loadNavBackButton() {
        
        self.navigationController?.popViewController(animated: true)

    }
    @objc func loadNaviBtnWithImage(_ image:UIImage) {
        let container = UIView()
        container.backgroundColor = .clear
        self.view.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(navigationHeight - 52) // 原来是 -42，向上扩10
            make.width.height.equalTo(60) // 原来按钮是 40，加上下左右各 10
        }

        let btn = UIButton()
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        container.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40) // 原来尺寸
        }
    }
    //标题
    func setTitle(_ title:String){
        let lb = UILabel()
        lb.text = title
        lb.font = fontMedium(16)
        lb.textColor = Main_TextColor
        lb.textAlignment = .left
        view.addSubview(lb)
        lb.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(60)
            make.height.equalTo(44)
        }
    }
    
    //文字右侧按钮
    func loadRightBtn(_ title:String){
        let width = NSString(string: title).size(withAttributes: [.font: fontRegular(13)]).width + 5
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = fontRegular(13)
        btn.setTitleColor(Main_TextColor, for: .normal)
        btn.addTarget(self, action: #selector(loadNavRightButton), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(2)
            make.width.equalTo(width)
            make.height.equalTo(40)
        }
    }

    @objc func loadNavRightButton() {
        

    }
    
    //带图的返回按钮
    func loadBackBtnWithImage(_ image:UIImage){
        let container = UIView()
        container.backgroundColor = .clear
        self.view.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(navigationHeight - 52) // 原来是 -42，向上扩10
            make.width.height.equalTo(60) // 原来按钮是 40，加上下左右各 10
        }

        let btn = UIButton()
        btn.setImage(image, for: .normal)
        btn.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        container.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40) // 原来尺寸
        }
    }
    
    @objc func clickBackButton() {
        
        self.dismiss(animated: true) {
            
        }
    }
    
    //没有导航栏的返回按钮
    func loadBackBtn(){
        let container = UIView()
        container.backgroundColor = .clear
        self.view.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(navigationHeight - 52) // 原来是 -42，向上扩10
            make.width.height.equalTo(60) // 原来按钮是 40，加上下左右各 10
        }

        let btn = UIButton()
        btn.setImage(UIImage.init(named: "back"), for: .normal)
        btn.addTarget(self, action: #selector(loadNavBackButton), for: .touchUpInside)
        container.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40) // 原来尺寸
        }
    }
    
    func touchedView(){
        
    }
    //MARK: - push并且关闭当前
    func pushAndCloseCtrl(_ ctrl:BaseCtrl) {
        guard let navigationController = self.navigationController else { return }
        // 获取当前viewControllers并移除A
        var newViewControllers = navigationController.viewControllers
        if let index = newViewControllers.firstIndex(of: self) {
            newViewControllers.remove(at: index)
        }
        // 添加B到数组末尾
        newViewControllers.append(ctrl)
        // 使用无动画方式设置新的viewControllers栈
        navigationController.setViewControllers(newViewControllers, animated: true)
    }
    
    
    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("currentCtrl == \(type(of: self))")
        
        //MARK: - 验证会员是否到期
//        isShowWater()
        
        if addTap == true {
            let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapEvent))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
        }
    }
    
    func isShowWater(){
        var showWater:Bool = true

        //获取服务器时间 计算是否到期
        //不是未激活且不是水印版本 才需要计算时间
        if (myUser?.vip_level != .typeNoAction) && (myUser?.vip_time != .typeNotActivated){

            YcxHttpManager.getTimestamp() { msg,data,code  in
                
                if code == 1{
                    let currentTime:TimeInterval = TimeInterval(data)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  
                    print("服务器时间--\(currentTime)\n到期时间--\(myUser!.expiredDate)\n中文格式--\(formatter.string(from: Date(timeIntervalSince1970: myUser!.expiredDate)))")
                   
                    if myUser!.expiredDate > currentTime {
                        showWater = false
                    }
                    if showWater {
                        KWindow?.addSubview(WaterMark)
                    }
                }else{
                    if showWater {
                        KWindow?.addSubview(WaterMark)
                    }
                }
            }
        }else{
            if showWater {
                KWindow?.addSubview(WaterMark)
            }
        }
    }
    
    
    @objc func tapEvent(_ tap:UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
        touchedView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
