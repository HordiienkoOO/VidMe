//
//  File.swift
//  VidMe
//
//  Created by cahebu4 on 04.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import UIKit

class NewViewController : UITableViewController {
    
    //MARK: Properties
    private var newVideos : [Video]!
    private var loadingVideos = false
    static private var _offset = 0
    var offset : Int {
        return NewViewController._offset
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        newVideos = getVideosList(from: Constants.newListURL, with: 0, and: "")
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newVideos.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "NewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VideoCell else {
            fatalError("Cannot Create NewCell")
        }        
        
        cell.video = Video.init(url: newVideos[indexPath.row].url,
                                thumbnailURL: newVideos[indexPath.row].thumbnailURL,
                                width: newVideos[indexPath.row].width,
                                height: newVideos[indexPath.row].height,
                                videoInfo: newVideos[indexPath.row].info,
                                userInfo: newVideos[indexPath.row].userInfo)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = self.newVideos[indexPath.row]
        return CGFloat(1.1 * Double(UIScreen.main.bounds.width)*Double(video.height)/Double(video.width))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectedVideoViewController.set(selected: newVideos[indexPath.row])
        performSegue(withIdentifier: "showNewVideo", sender: self)
        
    }
    
    
    @objc private func refresh(sender: AnyObject) {
        
        let newVideos = getVideosList(from: Constants.newListURL, with: 9999, and: "")
        for video in newVideos {
            if video != self.newVideos[0] {
                self.newVideos.insert(video, at: 0)
            } else {
                break
            }
        }
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMoreVideos()
        }
    }
    
    
    func loadMoreVideos() {
        if (!loadingVideos) {
            self.loadingVideos = true
            self.tableView.tableFooterView?.isHidden = false
            
            let newVideos = getVideosList(from: Constants.featuredListURL, with: offset, and: "")
            for video in newVideos {
                if video != self.newVideos.last {
                    self.newVideos.append(video)
                }
            }
            self.loadingVideos = false
            self.tableView.tableFooterView?.isHidden = true
            self.tableView.reloadData()
        }
    }
        
    
    static func incOffset() {
        self._offset += Constants.videosLimit
    }

}
