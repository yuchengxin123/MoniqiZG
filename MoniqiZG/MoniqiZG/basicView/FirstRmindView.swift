//
//  FirstRmindView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/9/4.
//

import UIKit

class FirstRmindView: UIView {

    var timer: Timer?
    var timeBtn:UIButton?
    var count:Int = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black.withAlphaComponent(0.1)
        
        let str:String = "  本软件仅供学习，娱乐装x使用，禁止商业用途，违者后果自负!!!\n\(count)s  "
        timeBtn = creatButton(CGRect.zero, str, fontMedium(14), Main_TextColor, HXColor(0xe6e6e6), self, #selector(closeView))
        timeBtn?.isEnabled = false
        timeBtn?.titleLabel?.textAlignment = .center
        timeBtn?.titleLabel?.numberOfLines = 0
        addSubview(timeBtn!)
        
        let high:CGFloat = sizeHigh(fontMedium(14), 200, str) + 20
        
        timeBtn?.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(high)
        }
        
        ViewRadius(timeBtn!, 10)
        
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.beginTiming()
        }
    }
    
    func beginTiming(){
        count-=1
        if count <= 0 {
            timeBtn?.setTitle("本软件仅供学习，娱乐装x使用，禁止商业用途，违者后果自负!!!\n确认", for: .normal)
            timeBtn?.isEnabled = true
            timeBtn?.backgroundColor = Main_Color
            timeBtn?.setTitleColor(.white, for: .normal)
            timer?.invalidate()
        }else{
            timeBtn?.setTitle("本软件仅供学习，娱乐装x使用，禁止商业用途，违者后果自负!!!\n\(count)s", for: .normal)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    @objc func closeView(){
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
