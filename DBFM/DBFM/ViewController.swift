//
//  ViewController.swift
//  DBFM
//
//  Created by John Huang on 2015/5/9.
//  Copyright (c) 2015年 JohnHuang. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol,ChannelProtocol {
    // 歌曲列表
    @IBOutlet weak var tv: UITableView!
    // EkoImage組件,歌曲封面
    @IBOutlet weak var iv: EkoImage!
    // 背景
    @IBOutlet weak var bg: UIImageView!
    // 網路操作實例
    var eHttp: HttpController = HttpController()
    
    // 頻道歌曲數據
    var tableData:[JSON] = []
    
    // 頻道數據
    var channelData:[JSON] = []
    
    // 圖片緩存字典
    var imgCache = Dictionary<String,UIImage>()
    
    // 媒體播放器
    var audioPlayer: MPMoviePlayerController = MPMoviePlayerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iv.onRotation()
        // 設置背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        bg.addSubview(blurView)

        //
        self.tv.delegate = self
        self.tv.dataSource = self
        
        eHttp.delegate = self
        // 獲取頻道數據
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        // 獲取頻道為0的歌曲數據
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        // tableView背景透明
        tv.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // 設置返回數據行數
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    // 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "songCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! UITableViewCell
        
        // cell背景透明
        cell.backgroundColor = UIColor.clearColor()
        // 取得每一行數據
        let rowData:JSON = tableData[indexPath.row]
        
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        // 此行需保留，否則顯示縮圖會變成要點選列後才會出現
        cell.imageView?.image = UIImage(named: "thumb")
        // 圖片網址
        let url = rowData["picture"].string
//        Alamofire.manager.request(.GET, url!).response { (_, _, data, error) -> Void in
//            let img = UIImage(data: data! as! NSData)
//            cell.imageView?.image = img
//        }
        
        onGetCacheImage(url!, imgView: cell.imageView!)
        
        return cell
    }
    
    
    func didRecieveResults(result: AnyObject) {
//        println("==============")
//        println("result:\(result)")
        
        let json = JSON(result)
        
        if let channels = json["channels"].array{
            self.channelData = channels
        } else if let song = json["song"].array{
            self.tableData = song
            // 更新tv數據
            self.tv.reloadData()
            onSelectRow(0)
        }
    }
    
    func onChangeChannel(channel_id: String) {
        let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelVC:ChannelViewController = segue.destinationViewController as! ChannelViewController
        channelVC.delegate = self
        channelVC.channelData = self.channelData
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onSelectRow(indexPath.row)
    }
    
    // 選中哪一行
    func onSelectRow(index: Int) {
        // 構建一個indexPath
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        // 選中的效果
        tv.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        // 獲取行數據
        let rowData: JSON = tableData[index] as JSON
        // 獲取圖片地址
        let imgUrl = rowData["picture"].string
        // 設置方面及背景
        onSetImage(imgUrl!)
        
        // 播放音樂
        var url:String = rowData["url"].string!
        onSetAudio(url)
    }
    
    // 設置歌曲封面及背景
    func onSetImage(url:String) {
        // 原先邏輯
//        Alamofire.manager.request(Method.GET, url).response { (_, _, data, error) -> Void in
//            let img = UIImage(data: data as! NSData)
//            self.iv.image = img
//            self.bg.image = img
//        }
        
        // 加入緩存方法後
        onGetCacheImage(url, imgView: self.iv)
        onGetCacheImage(url, imgView: self.bg)
    }
    
    
    func onGetCacheImage(url: String,imgView: UIImageView) {
        let image = self.imgCache[url] as UIImage?
        if image == nil {
            Alamofire.manager.request(Method.GET, url).response({ (_, _, data, error) -> Void in
                let img = UIImage(data: data as! NSData)
                imgView.image = img
                self.imgCache[url] = img
            })
        } else {
            imgView.image = image!
        }
    }
    
    // 播放音樂
    func onSetAudio(url:String) {
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


}

