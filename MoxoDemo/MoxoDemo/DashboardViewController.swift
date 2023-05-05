//
//  DashboardViewController.swift
//  MoxoDemo
//
//  Created by John Hu on 2023/5/5.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MEPRelationListModelDelegate {
    private var relationList:MEPRelationListModel!
    private var relations:[MEPRelation]!
    private var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dashboard"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeViewController))
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RelationCell")
        view.addSubview(tableView)
        
        setupSDKData()
        // Do any additional setup after loading the view.
    }
    
    @objc private func closeViewController() {
        navigationController?.dismiss(animated: true)
    }
    
    private func setupSDKData() {
        relationList = MEPRelationListModel()
        relationList.delegate = self
        refreshData()
    }
    
    private func refreshData() {
        //sort chats
        if let originRelations = relationList.relations {
            relations = originRelations.sorted(by: { a, b in
                return a.chat?.lastFeedTime ?? Date() > b.chat?.lastFeedTime ?? Date()
            })
            tableView.reloadData()
        }
    }
    
    private func getPresenceString(_ presence:MEPRelationUserStatus) -> String {
        switch presence {
            case .online:
                return "Online"
            case .offline:
                return "Offline"
            case .outOfOffice:
                return "Away"
            case .busy:
                return "Busy"
            case .unknown:
                return "Invisible"
            @unknown default:
                return "Invisible"
        }
    }

    // MARK: - Listen SDK updates
    // You could manage a chats array by self, or just let chatListModel manage it.
    func relationListModel(_ relationListModel: MEPRelationListModel, didDelete deletedRelations: [MEPRelation]) {
        refreshData()
    }
    
    func relationListModel(_ relationListModel: MEPRelationListModel, didUpdate updatedRelations: [MEPRelation]) {
        refreshData()
    }
    
    func relationListModel(_ relationListModel: MEPRelationListModel, didCreateRelations createdRelations: [MEPRelation]) {
        refreshData()
    }
    
    // MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RelationCell")
        let relation = relations[indexPath.row]
        cell.textLabel?.text = "\(relation.user.firstname ?? "") \(relation.user.lastname ?? "")"
        let status = getPresenceString(relation.user.userStatus)
        cell.detailTextLabel?.text = status
        relation.user.fetchProfile() { (error, image) in
            if (image != nil) {
                cell.imageView?.image = image
                cell.setNeedsLayout()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let relation = relations[indexPath.row]
        if let email = relation.user.email {
            MEPClient.sharedInstance().openRelationChat(withEmail: email)
            return
        }
        if let uniqueId = relation.user.uniqueId {
            MEPClient.sharedInstance().openRelationChat(withUniqueID: uniqueId)
            return
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
