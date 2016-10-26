//
//  RootViewController.swift
//  SalesforceSampleApp
//
//  Created by 溝口大地 on 2016/10/24.
//  Copyright © 2016年 Daichi. All rights reserved.
//

import UIKit
import SalesforceRestAPI
import SwiftyJSON
import SwiftDate
import RealmSwift
import Realm
import Model

class RootViewController: UITableViewController {
    private var tasks: [Model.TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestQuery(queryString: "SELECT Id, Subject, ActivityDate FROM Task WHERE IsClosed = false AND OwnerId = '\(SFUserAccountManager.sharedInstance().currentUser!.idData.userId)' LIMIT 10")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func requestQuery (queryString: String) {
        SFRestAPI.sharedInstance().performSOQLQuery(queryString,
                                                    fail: { [weak self] e in self?.queryFailed(e: e as! NSError)},
                                                    complete: { [weak self] result in self?.queryCompleted(result: result!) })
    }
 
    func queryFailed(e: NSError) {
        let alertController = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
        let returnAction = UIAlertAction(title: "OK", style: .default) {
            action in print(e.localizedDescription)
        }
        alertController.addAction(returnAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func queryCompleted(result :[AnyHashable:Any]) {
        let jsonResult = JSON(result)
        print("jsonResult === \(jsonResult)")
        
        self.tasks.removeAll()
        jsonResult["records"].array?.forEach{ [weak self] record in
            let task = Model.TaskModel(recordJson: record)
            self?.tasks.append(task)
        }
        
        DispatchQueue.main.async { [weak self] in
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
                realm.add(self!.tasks)
            }
            self?.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "TaskCell")
        let task = self.tasks[indexPath.row]
        cell.textLabel!.text = task.subject
        cell.detailTextLabel!.text = task.activityDateString
        return cell
    }
}

