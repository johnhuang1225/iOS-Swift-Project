//
//  EkoButton.swift
//  DBFM
//
//  Created by John Huang on 2015/5/19.
//  Copyright (c) 2015年 JohnHuang. All rights reserved.
//

import UIKit

class EkoButton: UIButton {
    
    var isPlay:Bool = true
    let imgPlay:UIImage = UIImage(named: "play")!
    let imgPause:UIImage = UIImage(named: "pause")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onClick() {
        isPlay = !isPlay
        if isPlay {
            self.setImage(imgPause, forState: UIControlState.Normal)
        } else {
            self.setImage(imgPlay, forState: UIControlState.Normal)
        }
    }
    
    // 給外部調用
    func onPlay() {
        isPlay = true
        self.setImage(imgPause, forState: UIControlState.Normal)
    }
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
