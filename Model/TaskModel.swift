//
//  TaskModel.swift
//  SalesforceSampleApp
//
//  Created by 溝口大地 on 2016/10/25.
//  Copyright © 2016年 Daichi. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftDate
import RealmSwift
import Realm

public class TaskModel : Object {
    dynamic public var salesforceId: String?
    dynamic public var subject: String?
    dynamic public var activityDate: Date?
    dynamic public var activityDateString: String?
    
    convenience public init(recordJson: JSON) {
        self.init()
        self.salesforceId = ""
        self.subject = ""
        if let salesforceId = recordJson["Id"].string {
            self.salesforceId = salesforceId
        }
        if let subject = recordJson["Subject"].string {
            self.subject = subject
        }
        if let activityDate = recordJson["ActivityDate"].string {
            self.activityDate = try? activityDate.date(format: DateFormat.custom("yyyy-MM-dd")).absoluteDate
            self.activityDateString = self.activityDate?.string(custom:"yyyy-MM-dd") ?? ""
        }
    }
}
