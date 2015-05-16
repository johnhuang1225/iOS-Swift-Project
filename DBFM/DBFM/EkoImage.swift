//
//  EkoImage.swift
//  DBFM
//
//  Created by John Huang on 2015/5/9.
//  Copyright (c) 2015年 JohnHuang. All rights reserved.
//

import UIKit

class EkoImage: UIImageView {
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 設置圓角
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.width/2
        
        // 邊框
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).CGColor
    }
    
    func onRotation() {
        // 動畫實例關鍵字
        var animation = CABasicAnimation(keyPath: "transform.rotation")
        // 初始值
        animation.fromValue = 0.0
        // 結束值
        animation.toValue = M_PI*2.0
        // 動畫執行時間
        animation.duration = 20
        // 動畫重複次數
        animation.repeatCount = 10000
        self.layer.addAnimation(animation, forKey: nil)
    }

}
