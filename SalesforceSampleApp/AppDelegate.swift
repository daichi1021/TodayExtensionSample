//
//  AppDelegate.swift
//  SalesforceSampleApp
//
//  Created by 溝口大地 on 2016/10/24.
//  Copyright © 2016年 Daichi. All rights reserved.
//

import UIKit
import SalesforceRestAPI
import Realm
import RealmSwift

let remoteAccessConsumerKey: String = "コンシューマーキー"
let redirectURI: String = "コールバックURI"
let appGroupName: String = "AppGroup名"
let realmPath: String = "realmのファイルパス"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    override init() {
        super.init()
        SFLogger.shared().setLogLevel(.debug, forIdentifier: "test")
        
        SalesforceSDKManager.shared().connectedAppId = remoteAccessConsumerKey
        SalesforceSDKManager.shared().connectedAppCallbackUri = redirectURI
        SalesforceSDKManager.shared().authScopes = ["web", "api"]
        
        SalesforceSDKManager.shared().postLaunchAction = { [weak self] launchActionList in
            let acListString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
            self?.log(.info, msg:"Post-launch: launch actions taken:" + acListString)
            self?.setupRootViewController()
        }
        
        SalesforceSDKManager.shared().launchErrorAction = { [weak self] error, launchActionList in
            let errorString = error.localizedDescription
            self?.log(.error, msg:"Error during SDK launch:" + errorString)
            self?.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
        
        SalesforceSDKManager.shared().postLogoutAction = { [weak self] in
            self?.handleSdkManagerLogout()
        }
        
        SalesforceSDKManager.shared().switchUserAction = { [weak self] fromUser, toUser in
            self?.handleUserSwitch(fromUser: fromUser, toUser: toUser)
        }
        return
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupName)!
            .appendingPathComponent(realmPath)
        var config = Realm.Configuration()
        config.fileURL = fileURL
        config.schemaVersion = 5
        config.migrationBlock = { migration, oldSchemaVersion in
            if (oldSchemaVersion < 5) {
            }
        }
        Realm.Configuration.defaultConfiguration = config
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.initializeAppViewState()
        SalesforceSDKManager.shared().launch()
    }
    
    
    func initializeAppViewState() {
        self.window?.rootViewController = InitialViewController(nibName: "InitialViewController", bundle: nil)
        self.window?.makeKeyAndVisible()
    }
    
    func setupRootViewController() {
        let rootVC: RootViewController = RootViewController()
        let navVC: UINavigationController = UINavigationController(rootViewController: rootVC)
        self.window?.rootViewController = navVC
    }
    
    func resetViewState(postResetBlock: @escaping () -> ()) {
        if ((self.window?.rootViewController?.presentedViewController) != nil) {
            self.window?.rootViewController?.dismiss(animated: false, completion: postResetBlock)
        } else {
            postResetBlock()
        }
    }
    
    func handleSdkManagerLogout() {
        self.log(.debug, msg:"SFAuthenticationManager logged out.  Resetting app.")
        self.resetViewState {
            self.initializeAppViewState()
            let allAccounts = SFUserAccountManager.sharedInstance().allUserAccounts
            
            if (allAccounts.count > 1) {
                let userSwitchVc = SFDefaultUserManagementViewController { [weak self] action in
                    self?.window?.rootViewController?.dismiss(animated: false, completion: nil)
                }
                self.window?.rootViewController?.present(userSwitchVc!, animated: true, completion: nil)
            } else {
                if (allAccounts.count == 1) {
                    SFUserAccountManager.sharedInstance().currentUser = SFUserAccountManager.sharedInstance().allUserAccounts[0]
                }
                SalesforceSDKManager.shared().launch()
            }
        }
    }
    
    func handleUserSwitch(fromUser: SFUserAccount, toUser: SFUserAccount) {
        let switchMsg: String = "SFUserAccountManager changed from user " + fromUser.userName + "to " +  toUser.userName + " Resetting app."
        self.log(.debug, msg:switchMsg)
        self.resetViewState { [weak self] in
            self?.initializeAppViewState()
            SalesforceSDKManager.shared().launch()
        }
    }
}

