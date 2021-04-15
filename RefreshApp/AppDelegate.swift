//
//  AppDelegate.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
import CoreData
import LUKeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HostConnectDelegate {

    var window: UIWindow?
    let hostName = "maru8ibm.maruhachi.co.jp"

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(hostURL)
        // Override point for customization after application launch.
        window_ = self.window! //SimpleAlert用
        // このバンドルのバージョンを調べる
        appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        
        if let str = defaults.object(forKey: "appVersion") as? String, appVersion == str {
            print(str)
            //launchCountを１増やす
            let count = defaults.integer(forKey: "launchCount") + 1
            defaults.set(count, forKey: "launchCount")
        }else {
            print("アップデート後、初起動")
            defaults.set(appVersion, forKey: "appVersion")
            defaults.removeObject(forKey: "lastDataDownload")
            defaults.removeObject(forKey: "lastLaunchDate")
            defaults.set(0, forKey: "launchCount")
        }
        
        //キーチェーンからidfvを取得
        let keychain = LUKeychainAccess.standard()
        
        idfv = keychain.string(forKey: "idfv") ?? ""
        //print("idfv="+idfv)
        //idfvが空の時（初回起動時）idfvを取得してセット
        if idfv == "" {
            let uuid = UIDevice.current.identifierForVendor
            idfv = uuid?.uuidString ?? ""
            //保存
            keychain.setString(idfv, forKey: "idfv")
        }
//        print("idfv="+idfv)
        
        //var id = "dev"
        #if DEV
        hostURL = m2URL //開発
        xsrvURL = m2xsrvURL
        devMode = true
        #else
        devMode =  defaults.bool(forKey: "devMode")
        //開発モードのチェック
        if devMode {
            hostURL = m2URL //開発
            xsrvURL = m2xsrvURL
        }else {
            hostURL = m8URL //本番
            xsrvURL = m8xsrvURL
            //id = "vc"
        }
        #endif
        //print(id)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewController(identifier: id)
        
        //受付入力リリース後
        let vc = storyboard.instantiateViewController(identifier: "first")
        window?.rootViewController = UINavigationController(rootViewController: vc)
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function)
        isHostConnected = false
        /* iPadNameとidfvを取得して保存 */
        #if targetEnvironment(simulator)//シュミレーターの場合
        iPadName = "PADE48"
        #else
        iPadName = UIDevice.current.name.uppercased()
        #endif

        //IBMと通信可能かチェック
        hostConnect.delegate = self
        hostConnect.start(hostName: hostName)
        
        let launchDate = defaults.object(forKey: "lastLaunchDate") as? String ?? ""
        print(launchDate)
        if Date().string2 != launchDate {//yyyyMMdd
            //最終起動日が今日じゃなければセット
            defaults.setValue(Date().string2, forKey: "lastLaunchDate")
            defaults.removeObject(forKey: "yoteiHI")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        //アラートが表示されていたら消す
        if let top = SimpleAlert.topViewController() as? UIAlertController {
            print("dismiss")
            top.dismiss(animated: false, completion: nil)
        }
    }
    
    //MARK: HostConnectDelegate
    func complete(_: Any) {
        print(#function)
        //ホスト接続成功
        isHostConnected = true
        //最終更新日チェック
        let lastUPD = defaults.object(forKey: "lastDataDownload") as? String ?? ""
        print(lastUPD)
        if Date().string != lastUPD {
            //データ取得
            GetLists().getList()
        }else {
            //ユーザーデフォルト呼び出し
            let list1 = defaults.object(forKey: "grdList") as? [NSDictionary] ?? []
            let list2 = defaults.object(forKey: "jitaList") as? [NSDictionary] ?? []
            let list3 = defaults.object(forKey: "hiritsu") as? [NSDictionary] ?? []
            
            print(list1)
            print(list2)
            print(list3)
            if list1 != [], list2 != [], list3 != [] {
                //print(list)
                GetLists().setList(list1: list1, list2:list2, list3:list3)
            }else {
                //データ取得
                GetLists().getList()
            }
            
        }
        
    }
    
    func failed(status: ConnectionStatus) {
        //ホスト接続失敗
        var errStr = ""
        //ホストに接続できなかった時
        switch status {
        case .vpn_error:
            print("vpn_error")
            errStr = "E1002:VPNに接続してください"
        case .host_res_error:
            //VPNはつながっているが、サーバーから返事がない時の処理
            print("host_res_error")
            errStr = "E1003:ホストから応答がありません"
        case .notConnect:
            print("notConnect")
            errStr = "E1001:インターネット接続がありません"
        default:
            return
        }
//        let action1 = UIAlertAction(title: "接続を確認", style: .default, handler: {
//        (action) -> Void in
//            self.openSetting()
//        })
//        let action2 = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        SimpleAlert.make(title: "サーバーに接続できません", message: errStr)
        //ユーザーデフォルトがあれば、セット
        let list1 = defaults.object(forKey: "grdList") as? [NSDictionary] ?? []
        let list2 = defaults.object(forKey: "jitaList") as? [NSDictionary] ?? []
        let list3 = defaults.object(forKey: "hiritsu") as? [NSDictionary] ?? []
        GetLists().setList(list1: list1, list2:list2, list3: list3)

    }

}
