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
    
    // 計時器
    var timer:NSTimer?
    // 時間標籤
    @IBOutlet weak var playTime: UILabel!
    
    @IBOutlet weak var progress: UIImageView!
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnPlay: EkoButton!
    @IBOutlet weak var btnPre: UIButton!
    // 記錄當前播放歌曲
    var currIndex:Int = 0
    
    // 播放按鈕順序
    @IBOutlet weak var btnOrder: OrderButton!
    
    
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
        
        // 監聽按鈕事件
        btnPlay.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPre.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnOrder.addTarget(self, action: "onOrder:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // 播放結束通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playFinish", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)
        
    }
    // 用來判斷歌曲是播放完畢自然結束還是手動結束。true為播放完畢自然結束
    var isAutoFinish:Bool = true
    
    // 手動結束的三種狀況。1:點擊上一首、下一首，2:選擇頻道列表，3:點擊了歌曲列表中的某一行
    func playFinish() {
        if isAutoFinish {
            switch(btnOrder.order){
            case 1:
                // 順序播放
                currIndex++
                if currIndex > tableData.count - 1 {
                    currIndex = 0
                }
                onSelectRow(currIndex)
            case 2:
                // 隨機播放
                currIndex = random() % tableData.count
                onSelectRow(currIndex)
            case 3:
                // 單曲循環
                onSelectRow(currIndex)
            default:
                "default"
            }
        } else {
            isAutoFinish = true
        }
    }
    
    func onOrder(btn: OrderButton) {
        var message:String = ""
        switch(btn.order) {
        case 1:message = "順序播放"
        case 2:message = "隨機播放"
        case 3:message = "單曲循環"
        default:message = "你逗我的吧"
        }
        self.view.makeToast(message: message, duration: 0.5, position: "center")
    }
    
    func onPlay(btn: EkoButton) {
        if btn.isPlay {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
    }
    
    func onClick(btn: UIButton) {
        isAutoFinish = false
        if btn == btnNext {
            currIndex++
            if currIndex > self.tableData.count - 1{
                currIndex = 0
            }
        } else {
            currIndex--
            if currIndex < 0 {
                currIndex = self.tableData.count - 1
            }
        }
        onSelectRow(currIndex)
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
            isAutoFinish = false
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
        isAutoFinish = false
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
        
        btnPlay.onPlay()
        
        // 首先停掉計時器
        timer?.invalidate()
        playTime.text = "00:00"
        // 啟動計時器
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        isAutoFinish = true
    }
    
    // 計時器更新方法
    func onUpdate() {
        let c = audioPlayer.currentPlaybackTime
        if c > 0.0 {
            // 歌曲總時間
            let t = audioPlayer.duration
            // 計算百分比
            let pro:CGFloat = CGFloat(c/t)
            // 按照百分比顯示進度條的寬度
            progress.frame.size.width = view.frame.size.width * pro
            
            
            
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all / 60)
            var time:String = ""
            if f < 10 {
                time = "0\(f):"
            } else {
                time = "\(f):"
            }
            
            if m < 10 {
                time += "0\(m)"
            } else {
                time += "\(m)"
            }
            playTime.text = time
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


}

