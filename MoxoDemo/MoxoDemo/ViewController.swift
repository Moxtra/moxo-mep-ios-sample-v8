//
//  ViewController.swift
//  MEPSwiftDemo
//
//  Created by John Hu on 2023/4/27.
//

import UIKit

let MOXTRA_DOMAIN = ""
let CLIENT_ID = ""
let CLIENT_SECRET = ""
let ORG_ID = ""
let DEFAULT_UNIQUEID = ""

class ViewController: UIViewController, MEPClientDelegate {
    
    var loginBtn: UIBarButtonItem!
    var logoutBtn: UIBarButtonItem!
    var indicator: UIActivityIndicatorView!
    var showBtn : UIButton!
    var showliteBtn : UIButton!
    var timelineBtn : UIButton!
    var dashboardBtn : UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSDK()
        setupInterface()
    }
    
    // MARK: sdk
    private func setupSDK() {
        assert(MOXTRA_DOMAIN.count != 0)
        assert(CLIENT_ID.count != 0)
        assert(CLIENT_SECRET.count != 0)
        assert(ORG_ID.count != 0)
        assert(DEFAULT_UNIQUEID.count != 0)
        MEPClient.sharedInstance().setup(withDomain: MOXTRA_DOMAIN, linkConfig: nil)
    }
    
    @objc private func login() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        //get access token first
        postAction { (res, error) in
            if (res != nil) {
                let jsonResult = res as! Dictionary<AnyHashable, Any>
                let token = jsonResult["access_token"]
                //login with access token
                MEPClient.sharedInstance().linkUser(withAccessToken: token as! String) { (error) in
                    if (error == nil) {
                        self.navigationItem.leftBarButtonItem = self.logoutBtn
                        self.navigationItem.rightBarButtonItem = nil
                        MEPClient.sharedInstance().showMEPWindow()
                    }
                }
            }
        }
    }
    
    @objc private func logout() {
        //Logout with revoke notificaiton device token
        MEPClient.sharedInstance().unlink()
        
        //Logout without revoke notification device token
        //MEPClient.sharedInstance().localUnlink()
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = self.loginBtn
    }
    
    @objc private func showMEPWindow() {
        MEPClient.sharedInstance().showMEPWindow()
    }
    
    @objc private func showMEPWindowLite() {
        MEPClient.sharedInstance().showMEPWindowLite()
    }
    
    @objc private func showCustomTimeline() {
        let timeline = TimelineViewController()
        let navi = UINavigationController(rootViewController: timeline)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true)
    }
    
    @objc private func showCustomDashboard() {
        let dashboard = DashboardViewController()
        let navi = UINavigationController(rootViewController: dashboard)
        navi.modalPresentationStyle = .fullScreen
        present(navi, animated: true)
    }
    
    func client(_ client: MEPClient, didTapClose sender: Any?) {
        MEPClient.sharedInstance().hideMEPWindow()
    }
    
    // MARK: interface
    private func setupInterface() {
        //navigation
        logoutBtn = UIBarButtonItem.init(title: "Logout", style: .done, target: self, action: #selector(logout))
        
        loginBtn = UIBarButtonItem.init(title: "Login", style: .done, target: self, action: #selector(login))
        navigationItem.rightBarButtonItem = self.loginBtn
        
        indicator = UIActivityIndicatorView.init(style: .large)
        indicator.startAnimating()
        
        
        showBtn = UIButton.init(type: .custom)
        showBtn.setTitleColor(.blue, for: .normal)
        showBtn.frame = CGRect.init(x: 0, y: 0, width: 300, height: 20)
        showBtn.setTitle("showMEPWindow", for: .normal)
        showBtn.addTarget(self, action: #selector(showMEPWindow), for: .touchUpInside)

        showliteBtn = UIButton.init(type: .custom)
        showliteBtn.setTitleColor(.blue, for: .normal)
        showliteBtn.frame = CGRect.init(x: 0, y: 0, width: 300, height: 20)
        showliteBtn.setTitle("showMEPWindowLite", for: .normal)
        showliteBtn.addTarget(self, action: #selector(showMEPWindowLite), for: .touchUpInside)
        
        timelineBtn = UIButton.init(type: .custom)
        timelineBtn.setTitleColor(.blue, for: .normal)
        timelineBtn.frame = CGRect.init(x: 0, y: 0, width: 300, height: 20)
        timelineBtn.setTitle("custom timeline", for: .normal)
        timelineBtn.addTarget(self, action: #selector(showCustomTimeline), for: .touchUpInside)
        
        dashboardBtn = UIButton.init(type: .custom)
        dashboardBtn.setTitleColor(.blue, for: .normal)
        dashboardBtn.frame = CGRect.init(x: 0, y: 0, width: 300, height: 20)
        dashboardBtn.setTitle("custom dashboard", for: .normal)
        dashboardBtn.addTarget(self, action: #selector(showCustomDashboard), for: .touchUpInside)
        
        view.addSubview(showBtn)
        view.addSubview(showliteBtn)
        view.addSubview(timelineBtn)
        view.addSubview(dashboardBtn)
    }
    
    override func viewDidLayoutSubviews() {
        showBtn.center = CGPoint(x: view.center.x, y: 120)
        showliteBtn.center = CGPoint(x: view.center.x, y: 160)
        timelineBtn.center = CGPoint(x: view.center.x, y: 200)
        dashboardBtn.center = CGPoint(x: view.center.x, y: 240)
    }
    
    // MARK: request helper to get access token
    private func postAction(completion: @escaping(Any?, Error?)->()) {
        let Url = String(format: "https://%@/v1/core/oauth/token",MOXTRA_DOMAIN);
        guard let serviceUrl = URL(string: Url) else { return }
        let parameterDictionary = ["client_id" : CLIENT_ID, "client_secret" : CLIENT_SECRET, "org_id" : ORG_ID, "unique_id": DEFAULT_UNIQUEID]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    completion(json, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}
