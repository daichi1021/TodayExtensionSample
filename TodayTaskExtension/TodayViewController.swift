//
//  TodayViewController.swift
//  TodayTaskExtension
//
//  Created by 溝口大地 on 2016/10/25.
//  Copyright © 2016年 Daichi. All rights reserved.
//

import UIKit
import NotificationCenter
import Realm
import RealmSwift
import SwiftDate
import Model

@objc(TodayViewController)
class TodayViewController: UITableViewController, NCWidgetProviding {
    private var tasks: [Model.TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupName)!
            .appendingPathComponent(realmPath)
        var config = Realm.Configuration()
        config.fileURL = fileURL
        config.schemaVersion = 5
        Realm.Configuration.defaultConfiguration = config
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let realm = try! Realm()
        self.tasks = realm.objects(Model.TaskModel).allObjects
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
}

extension Results {
    var allObjects:[Element] {
        return self.map{$0}
    }
}
