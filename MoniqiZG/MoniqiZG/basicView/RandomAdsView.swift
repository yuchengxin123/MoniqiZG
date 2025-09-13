//
//  RandomAdsView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/29.
//

import UIKit


class RandomAdsView: UIView {
    
    private var timer: Timer?
    private var second: Int = 2
    private var timeBtn: UIButton?
    
    var action:(()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let img:UIImageView = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: String(format: "ad_%d", Int.random(in: 1...3)))
        addSubview(img)
 
        timeBtn = creatButton(CGRect.zero, "  跳过 \(second)s  ", fontRegular(14), .white, .black.withAlphaComponent(0.3), self, #selector(dismiss))
        addSubview(timeBtn!)
        
        img.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        timeBtn!.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.top.equalToSuperview().offset(navigationHeight - 32)
            make.height.equalTo(32)
        }
        
        ViewRadius(timeBtn!, 16)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            
            self!.second-=1
            self?.timeBtn?.setTitle(String(format: "  跳过 %ds  ", self?.second ?? 0), for: .normal)
            
            if self!.second == 0 {
                self?.dismiss()
            }
            
        }
    }
    
    @objc func dismiss() {
        action?()
        timer?.invalidate()
        timer = nil
        self.removeFromSuperview()
    }
    

    deinit {
        
    }
}
