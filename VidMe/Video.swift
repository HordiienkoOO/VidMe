//
//  Video.swift
//  VidMe
//
//  Created by cahebu4 on 04.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

//import Foundation

struct Video : Equatable {
    
    var url : String
    var thumbnailURL : String
    var width : Int
    var height : Int
    var info : VideoInfo
    var userInfo : UserInfo
    
    init() {
        self.url = ""
        self.thumbnailURL = ""
        self.width = 0
        self.height = 0
        self.info = VideoInfo(title: "", likes: 0, views: 0, datePublishing: "")
        self.userInfo = UserInfo(userName: "", avatarURL: "", followers: 0)
    }
    
    
    init(url: String, thumbnailURL: String, width: Int, height: Int, videoInfo: VideoInfo, userInfo: UserInfo) {
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.width = width
        self.height = height
        self.info = videoInfo
        self.userInfo = userInfo
    }
    
    static func ==(v1: Video, v2: Video) -> Bool {
        return v1.url == v2.url
    }
    
    struct VideoInfo {
        var title : String
        var likes : Int
        var views : Int
        var datePublishing : String
        
        init(title: String, likes: Int, views: Int, datePublishing: String) {
            self.title = title
            self.likes = likes
            self.views = views
            self.datePublishing = datePublishing
        }
    }
    
    struct UserInfo {
        var userName : String
        var avatarURL : String
        var followers : Int
        
        init(userName: String, avatarURL: String, followers: Int) {
            self.userName = userName
            self.avatarURL = avatarURL
            self.followers = followers
        }
    }
    
}

