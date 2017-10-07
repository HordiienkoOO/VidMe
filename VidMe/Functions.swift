//
//  Functions.swift
//  VidMe
//
//  Created by cahebu4 on 05.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import Foundation
		
func getVideosList(from stringURL : String, with offset: Int, and token: String) -> [Video] {
    
    var _url = stringURL
    _url.append("?limit=\(Constants.videosLimit)&offset=\(offset)")
    if stringURL == Constants.feedListURL { _url.append("&token=\(token)") }
    let url = URL(string: _url)!
    var videos = Array(repeating: Video(), count: 0)
    
    URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
        
        if let data = data, let parsedData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            let videosWithInfo = parsedData!["videos"] as! [[String: Any]]
            
            for video in videosWithInfo {
                let videoURL = video["embed_url"] as! String
                let thumbnailURL = video["thumbnail_url"] as! String
                let width = video["width"] as! Int
                let height = video["height"] as! Int
                
                let title = video["title"] as! String
                let likes = video["likes_count"] as! Int
                let views = video["view_count"] as! Int
                let datePublishing = video["date_published"] as! String
                
                let user = video["user"] as! [String: Any]
                
                let userName = user["username"] as! String
                let userAvatarURL = user["avatar_url"] as! String
                let userFollovers = user["follower_count"] as! Int

                
                videos.append(Video(url: videoURL,
                                    thumbnailURL: thumbnailURL,
                                    width: width,
                                    height: height,
                                    videoInfo: Video.VideoInfo.init(title: title,
                                                                    likes: likes,
                                                                    views: views,
                                                                    datePublishing: datePublishing),
                                    userInfo: Video.UserInfo.init(userName: userName,
                                                                  avatarURL: userAvatarURL,
                                                                  followers: userFollovers)))
            }
        }
    }).resume()
    sleep(Constants.avgTimeForResponse)
    
    switch (stringURL, offset) {
        case (_, 9999): break
        case (Constants.featuredListURL, _):
            FeaturedViewController.incOffset()
        case (Constants.newListURL, _):
            NewViewController.incOffset()
        default:
            FeedViewController.incOffset()
    }
    
    return videos
}




