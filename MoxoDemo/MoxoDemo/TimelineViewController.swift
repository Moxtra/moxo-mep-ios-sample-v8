//
//  CustomTimelineViewController.swift
//  MoxoDemo
//
//  Created by John Hu on 2023/5/5.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MEPChatListModelDelegate {
    private var chatList:MEPChatListModel!
    private var chats:[MEPChat]!
    private var tableView:UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timeline"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeViewController))
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
        view.addSubview(tableView)
        
        setupSDKData()
    }
    
    @objc private func closeViewController() {
        navigationController?.dismiss(animated: true)
    }
    
    private func setupSDKData() {
        chatList = MEPChatListModel()
        chatList.delegate = self
        refreshData()
    }
    
    private func refreshData() {
        //sort chats
        chats = self.chatList.chats().sorted(by: { a, b in
            return a.lastFeedTime > b.lastFeedTime
        })
        tableView.reloadData()
    }
    
    // MARK: - Listen SDK updates
    // You could manage a chats array by self, or just let chatListModel manage it.
    func chatListModel(_ chatListModel: MEPChatListModel, didDelete deletedChats: [MEPChat]) {
        refreshData()
    }
    
    func chatListModel(_ chatListModel: MEPChatListModel, didCreateChats createdChats: [MEPChat]) {
        refreshData()
    }
    
    func chatListModel(_ chatListModel: MEPChatListModel, didUpdate updatedChats: [MEPChat]) {
        refreshData()
    }
    
    // MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ChatCell")
        let chat = chats[indexPath.row]
        cell.textLabel?.text = chat.topic
        cell.detailTextLabel?.text = chat.lastFeedContent
        chat.fetchCover() { (error, image) in
            if (image != nil) {
                cell.imageView?.image = image
                cell.setNeedsLayout()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = chats[indexPath.row]
        MEPClient.sharedInstance().openChat(chat.chatID, withFeedSequence: nil)
    }

}
