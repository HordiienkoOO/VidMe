//
//  SelectedVideoViewController.swift
//  VidMe
//
//  Created by cahebu4 on 06.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import UIKit

class SelectedVideoViewController : UIViewController {
    
    //MARK: Properties
    private var player : UIWebView!
    private var videoTitle : UILabel!
    private var likes : UILabel!
    private var views : UILabel!
    private var date : UILabel!
    private var avatar : UIImageView!
    private var username : UILabel!
    private var followers : UILabel!
    static private var selectedVideo : Video!
    var video : Video {
        return SelectedVideoViewController.selectedVideo
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawItems()
        prepareViewController()
    }
    

    func prepareViewController() {        
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
            DispatchQueue.main.async {
                self.player.loadRequest(URLRequest(url: URL(string: self.video.url)!))
                self.player.goForward()
                let data = try? Data(contentsOf: URL(string: self.video.userInfo.avatarURL)!)
                self.avatar.image = UIImage(data: data!)
            }
        }
        
        self.videoTitle.text = video.info.title
        self.views.text = "Viewed: \(self.video.info.views) times"
        self.username.text = self.video.userInfo.userName
        self.followers.text = "\(self.video.userInfo.followers) followers"
        
        let date = self.video.info.datePublishing.components(separatedBy: " ")
        let time = date[1].components(separatedBy: ":")[0] + ":" + date[1].components(separatedBy: ":")[1]
        self.date.text = "Date of Publishing: \(date[0]) at \(time)"
        
        switch video.info.likes {
        case 1:
            self.likes.text = "1 like"
        default:
            self.likes.text = "\(video.info.likes) likes"
        }
    }
    
    
    func drawItems() { 
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeigth = UIScreen.main.bounds.height - (self.tabBarController?.tabBar.frame.height)!
        let playerHeight = CGFloat(video.height)*screenWidth/CGFloat(video.width)
        let barsHeigth = (self.tabBarController?.tabBar.frame.size.height)! + (self.navigationController?.navigationBar.frame.size.height)!
        let marginLeft: CGFloat = 8
        let labelHeigth = 0.1*playerHeight
        
        //MARK: Drawing video player frame
        self.player = UIWebView()
        self.player.frame = CGRect(x: 0, y: 0, width: screenWidth, height: playerHeight)
        self.view.addSubview(player)
 
        var tempHeigth = playerHeight + 2
        
        //MARK: Drawing video title frame
        self.videoTitle = UILabel()
        setUp(label: videoTitle, text: "Title", x: marginLeft, y: tempHeigth, width: 0.75*screenWidth-8, heigth: labelHeigth-2)
        let tempWidth = self.videoTitle.frame.size.width+8
        
        //MARK: Drawing video likes frame
        self.likes = UILabel()
        setUp(label: likes, text: "likes", x: tempWidth, y: tempHeigth, width: screenWidth-tempWidth-8, heigth: labelHeigth-2)
        tempHeigth += 12 + labelHeigth
        
        //MARK: Drawing views count frame
        self.views = UILabel()
        setUp(label: views, text: "views", x: marginLeft, y: tempHeigth, width: screenWidth-16, heigth: labelHeigth)
        tempHeigth += labelHeigth+2
        
        //MARK: Drawing date of publishing frame
        self.date = UILabel()
        setUp(label: date, text: "date", x: marginLeft, y: tempHeigth, width: screenWidth-16, heigth: labelHeigth)
        tempHeigth += labelHeigth+15
        
        let imageHeigth = screenHeigth-tempHeigth-barsHeigth-30
        let imageWidth = 0.75*imageHeigth
        
        //MARK: Drawing user's avatar frame
        self.avatar = UIImageView()
        self.avatar.frame = CGRect(x: marginLeft, y: tempHeigth, width: imageWidth, height: imageHeigth)
        self.view.addSubview(self.avatar)        
        tempHeigth += 1/3.0 * imageHeigth
        
        //MARK: Drawing user's information
        let someLabel = UILabel()
        setUp(label: someLabel, text: "Author:", x: imageWidth+marginLeft, y: tempHeigth, width: screenWidth-imageWidth-2*marginLeft, heigth: labelHeigth)
        tempHeigth+=labelHeigth
        
        self.username = UILabel()
        setUp(label: username, text: "username", x: imageWidth+marginLeft, y: tempHeigth, width: screenWidth-imageWidth-2*marginLeft, heigth: labelHeigth)
        tempHeigth+=labelHeigth
        
        self.followers = UILabel()
        setUp(label: followers, text: "followers", x: imageWidth+marginLeft, y: tempHeigth, width: screenWidth-imageWidth-2*marginLeft, heigth: labelHeigth)
    }
    
    private func setUp(label : UILabel, text: String, x: CGFloat, y: CGFloat, width: CGFloat, heigth: CGFloat) -> Void {
        label.frame = CGRect(x: x, y: y, width: width, height: heigth)
        label.text = text
        label.font = label.font.withSize(0.8*heigth)
        switch text {
            case "likes": label.textAlignment = .right
            case "Author:", "username", "followers": label.textAlignment = .center
            default: break
        }
        
        self.view.addSubview(label)
    }
    
    
    static func set(selected video: Video) {
        self.selectedVideo = video
    }
    
}
