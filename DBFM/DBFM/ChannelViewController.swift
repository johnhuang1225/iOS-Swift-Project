//
//  ChannelViewController.swift
//  DBFM
//
//  Created by John Huang on 2015/5/13.
//  Copyright (c) 2015年 JohnHuang. All rights reserved.
//

import UIKit

protocol ChannelProtocol {
    func onChangeChannel(channel_id: String)
}

class ChannelViewController: UIViewController,UITableViewDelegate {
    // 頻道列表
    @IBOutlet weak var tv: UITableView!
    
    var delegate:ChannelProtocol?
    
    // 頻道列表數據
    var channelData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.8
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 設置返回數據行數
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    //
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "channelCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! UITableViewCell
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        cell.textLabel?.text = rowData["name"].string
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowData:JSON = self.channelData[indexPath.row]
        let channel_id:String = rowData["channel_id"].stringValue
        delegate?.onChangeChannel(channel_id)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
