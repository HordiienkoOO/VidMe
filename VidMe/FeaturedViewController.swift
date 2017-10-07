//
//  FeaturedViewController.swift
//  VidMe
//
//  Created by cahebu4 on 04.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import UIKit

class FeaturedViewController : UITableViewController {
    
    //MARK: Properties
    private var featuredVideos : [Video]!
    private var loadingVideos = false
    static private var _offset = 0
    var offset : Int {
        return FeaturedViewController._offset
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        featuredVideos = getVideosList(from: Constants.featuredListURL, with: offset, and: "")
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.featuredVideos.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FeaturedCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VideoCell else {
            fatalError("Cannot create FeaturedCell")
        }
        
        cell.video = Video.init(url: featuredVideos[indexPath.row].url,
                                thumbnailURL: featuredVideos[indexPath.row].thumbnailURL,
                                width: featuredVideos[indexPath.row].width,
                                height: featuredVideos[indexPath.row].height,
                                videoInfo: featuredVideos[indexPath.row].info,
                                userInfo: featuredVideos[indexPath.row].userInfo)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = self.featuredVideos[indexPath.row]
        return 1.1 * UIScreen.main.bounds.width * CGFloat(video.height) / CGFloat(video.width)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        SelectedVideoViewController.set(selected: featuredVideos[indexPath.row])
        performSegue(withIdentifier: "showFeaturedVideo", sender: self)

    }
    
    
    @objc private func refresh(sender: AnyObject) {
        
        let newVideos = getVideosList(from: Constants.featuredListURL, with: 9999, and: "")
        for video in newVideos {
            if video != featuredVideos[0] {
                featuredVideos.insert(video, at: 0)
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
                if video != featuredVideos.last {
                    featuredVideos.append(video)
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

