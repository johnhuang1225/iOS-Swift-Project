 //
//  OrderButton.swift
//  DBFM
//
//  Created by John Huang on 2015/5/22.
//  Copyright (c) 2015年 JohnHuang. All rights reserved.
//

import UIKit

class OrderButton: UIButton {
    var order:Int = 1
    let order1:UIImage = UIImage(named: "order1")!
    let order2:UIImage = UIImage(named: "order2")!
    let order3:UIImage = UIImage(named: "order3")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onClick(sender:UIButton) {
        order++
        if order == 1 {
            self.setImage(order1, forState: UIControlState.Normal)
        } else if order == 2 {
            self.setImage(order2, forState: UIControlState.Normal)
        } else if order == 3 {
            self.setImage(order3, forState: UIControlState.Normal)
        } else if order > 3 {
            order = 1
            self.setImage(order1, forState: UIControlState.Normal)
        }
    }

}
