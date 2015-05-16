//
//  HttpController.swift
//  DBFM
//
//  Created by John Huang on 2015/5/13.
//  Copyright (c) 2015年 JohnHuang. All rights reserved.
//

import UIKit

class HttpController: NSObject {
    
    var delegate: HttpProtocol?
    
    func onSearch(url: String) {
        Alamofire.manager.request(.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, error) -> Void in
            self.delegate?.didRecieveResults(data!)
        }
    }
}

// 定義Http協議
protocol HttpProtocol {
    // 定義一個方法，接收一個參數:AnyObject
    func didRecieveResults(result: AnyObject)
}




















