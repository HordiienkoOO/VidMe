//
//  FeedViewController.swift
//  VidMe
//
//  Created by cahebu4 on 07.05.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import UIKit

class FeedViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    private var loadingVideos = false
    private var refreshControl: UIRefreshControl!
    private var tableView : UITableView!
    private var logOutButton : UIButton!
    private var feedVideos : [Video]!
    private var logInView : UIView!
    private var username : UITextField!
    private var password : UITextField!
    private var logInButton : UIButton!
    private var token : String! {
        didSet {
            UserDefaults.standard.set(token, forKey: "AccessToken")
        }
    }
    static private var _offset = 0
    var offset : Int {
        return FeedViewController._offset
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!loggedIn()) { showLogInView() }
        else { prepareViewController() }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedVideos.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "FeedVideo"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VideoCell else {
            fatalError("Cannot create FeedCell")
        }
        
        cell.video = Video.init(url: feedVideos[indexPath.row].url,
                                thumbnailURL: feedVideos[indexPath.row].thumbnailURL,
                                width: feedVideos[indexPath.row].width,
                                height: feedVideos[indexPath.row].height,
                                videoInfo: feedVideos[indexPath.row].info,
                                userInfo: feedVideos[indexPath.row].userInfo)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let video = self.feedVideos[indexPath.row]
        return 1.1 * UIScreen.main.bounds.width * CGFloat(video.height) / CGFloat(video.width)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectedVideoViewController.set(selected: feedVideos[indexPath.row])
        performSegue(withIdentifier: "showFeedVideo", sender: self)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMoreVideos()
        }
    }
    
    
    @objc private func refresh(sender: AnyObject) -> Void {
        
        let newVideos = getVideosList(from: Constants.feedListURL, with: 9999, and: token)
        for video in newVideos {
            if video != feedVideos[0] {
                feedVideos.insert(video, at: 0)
            } else {
                break
            }
        }
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    func loadMoreVideos() -> Void {
        
        if (!loadingVideos) {
            self.loadingVideos = true
            self.tableView.tableFooterView?.isHidden = false
            
            let newVideos = getVideosList(from: Constants.feedListURL, with: offset, and: token)
            for video in newVideos {
                if video != feedVideos.last {
                    feedVideos.append(video)
                }
            }
            self.loadingVideos = false
            self.tableView.tableFooterView?.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    
    private func loggedIn() -> Bool {
        
        var logged = false
        if let tkn = UserDefaults.standard.string(forKey: "AccessToken") {
            
            self.token = tkn
            let request = NSMutableURLRequest(url: URL(string: Constants.checkTokenURL)!)
            request.httpMethod = "POST"
            request.addValue(tkn, forHTTPHeaderField: "AccessToken")
            
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                if let data = data {
                    let parsedJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                    logged = parsedJSON!["status"] as! Bool
                    
                }
            }).resume()
            sleep(2)
            
        }
        return logged
    }
  
    
    @objc private func logInTapped() -> Void {
        
        logInButton.isEnabled = false
        if ((username.text?.characters.count)! < 1 || (password.text?.characters.count)! < 1) { logInButton.isEnabled = true; return }
        
        let request = NSMutableURLRequest(url: URL(string: Constants.logInURL)!)
        let params = "username=\(username.text!)&password=\(password.text!)"
        request.httpMethod = "POST"
        request.httpBody = params.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                
                let status = json!["status"] as! Bool
                if status {
                    
                    let auth = json!["auth"]! as! [String : Any]
                    self.token = auth["token"] as! String
                    
                    DispatchQueue.main.async {
                        self.logInView.removeFromSuperview()
                        self.prepareViewController()
                    }
                    
                } else {
                    self.showAlert(message: json!["error"] as! String)
                    self.logInButton.isEnabled = true
                }
            }
        }).resume()
    }
    
    
    @objc private func logOutTapped(sender: UIButton) -> Void {
       
        let request = NSMutableURLRequest(url: URL(string: Constants.logOutURL)!)
        request.httpMethod = "POST"
        request.addValue(self.token, forHTTPHeaderField: "AccessToken")
        
        URLSession.shared.dataTask(with: request as URLRequest).resume()
        
        for i in 100...101 {
            if let viewWithTag = self.view.viewWithTag(i) {
                viewWithTag.removeFromSuperview()
            }
        }
        
        showLogInView()
    }
    
    
    private func prepareViewController() -> Void {
        
        self.feedVideos = getVideosList(from: Constants.feedListURL, with: self.offset, and: token)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeigth = UIScreen.main.bounds.height -
                (self.tabBarController?.tabBar.frame.height)! -
                (self.navigationController?.navigationBar.frame.height)! -
                (self.tabBarController?.tabBar.frame.height)!
        let logOutButtonHeigth = 0.07*screenHeigth
        
        self.tableView = UITableView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeigth-logOutButtonHeigth)
        self.tableView.register(VideoCell.self, forCellReuseIdentifier: "FeedVideo")
        self.tableView.tag = 100
        self.view.addSubview(self.tableView)
        
        self.logOutButton = UIButton()
        setUp(button: self.logOutButton, text: "Log Out", bgColor: .black, x: 0, y: screenHeigth-logOutButtonHeigth, width: screenWidth, heigth: logOutButtonHeigth)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    
    
    private func showLogInView() -> Void {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeigth = UIScreen.main.bounds.height
        let fieldWidth = 0.78*screenWidth
        let fieldHeigth = 0.05*screenHeigth
        let marginLeft = 0.11*screenWidth
        let marginTop = 0.32*screenHeigth
        let marginBottom = 0.04*screenHeigth
        
        self.logInView = UIView()
        self.logInView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeigth)
        
        username = UITextField()
        setUp(textField: username, text: "Username", x: marginLeft, y: marginTop, width: fieldWidth, heigth: fieldHeigth)
        
        var tempHeigth = marginTop+fieldHeigth+marginBottom
        
        password = UITextField()
        setUp(textField: password, text: "Password", x: marginLeft, y: tempHeigth, width: fieldWidth, heigth: fieldHeigth)
        tempHeigth += fieldHeigth + marginBottom
        
        logInButton = UIButton()
        setUp(button: logInButton, text: "Login", bgColor: .blue, x: marginLeft, y: tempHeigth, width: fieldWidth, heigth: fieldHeigth)
        self.view.addSubview(logInView)
    }
    
    
    private func setUp(textField: UITextField, text: String, x: CGFloat, y: CGFloat, width: CGFloat, heigth: CGFloat) -> Void {
        textField.frame = CGRect(x: x, y: y, width: width, height: heigth)
        textField.placeholder = text
        textField.textAlignment = .center
        textField.font = textField.font?.withSize(0.5*heigth)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        if text == "Password" { textField.isSecureTextEntry = true }
        self.logInView.addSubview(textField)
    }
    
    
    private func setUp(button: UIButton, text: String, bgColor: UIColor, x: CGFloat, y: CGFloat, width: CGFloat, heigth: CGFloat) -> Void {
        button.frame = CGRect(x: x, y: y, width: width, height: heigth)
        button.setTitle(text, for: .normal)
        button.backgroundColor = bgColor
        
        switch text {
        case "Login": button.addTarget(self, action: #selector(logInTapped), for: .touchDown); self.logInView.addSubview(button)
        case "Log Out": button.addTarget(self, action: #selector(logOutTapped), for: .touchDown); button.tag = 101; self.view.addSubview(button)
        default: print("default"); break
        }
    }
    
    
    private func showAlert(message: String) -> Void {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Oops, something wrong :)", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    static func incOffset() {
        self._offset += Constants.videosLimit
    }
  
    
}
