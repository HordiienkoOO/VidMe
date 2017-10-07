//
//  VideoCell.swift
//  VidMe
//
//  Created by cahebu4 on 06.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    
    //MARK: Properties
    private var thumbnail : UIImageView!
    private var title : UILabel!
    private var likes : UILabel!
    var video : Video! {
        didSet {
            drawItems()
            
            let queue = DispatchQueue.global(qos: .utility)
            queue.async {
                if let data = try? Data(contentsOf: URL(string: self.video.thumbnailURL)!) {
                    DispatchQueue.main.async {
                        self.thumbnail.image = UIImage(data: data)
                    }
                }
            }
            
            self.title.text = video.info.title
            switch video.info.likes {
            case 1:
                self.likes.text = "1 like"
            default:
                self.likes.text = "\(video.info.likes) likes"
            }
            
        }
    }
    
    
    private func drawItems() {
        
        clearItems()
        let screenWidth = UIScreen.main.bounds.width
        let playerHeight = CGFloat(video.height)*screenWidth/CGFloat(video.width)
        
        //MARK: Draving thumbnail frame
        self.thumbnail = UIImageView()
        self.thumbnail.frame = CGRect(x: 0, y: 0, width: screenWidth, height: playerHeight)
        self.thumbnail.tag = 1001
        self.contentView.addSubview(self.thumbnail)
        
        //MARK: Draving title frame
        self.title = UILabel()
        self.title.frame = CGRect(x: 8, y: playerHeight, width: 0.75*screenWidth-8, height: 0.1*playerHeight-2)
        self.title.tag = 1002
        self.contentView.addSubview(self.title)
        
        //MARK: Draving likes count frame
        self.likes = UILabel()
        self.likes.frame = CGRect(x: 0.75*screenWidth+8, y: playerHeight, width: 0.25*screenWidth-16, height: 0.1*playerHeight-2)
        self.likes.textAlignment = .right
        self.likes.tag = 1003
        self.contentView.addSubview(self.likes)
        
        //MARK: Changing font size because of different devices
        self.title.font = self.title.font.withSize(0.08*playerHeight)
        self.likes.font = self.likes.font.withSize(0.08*playerHeight)
    }
    
    private func clearItems() {
        if let viewWithTag = self.contentView.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.contentView.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.contentView.viewWithTag(1003) {
            viewWithTag.removeFromSuperview()
        }
    }
    
}
