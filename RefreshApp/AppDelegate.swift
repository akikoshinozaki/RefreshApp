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
        print("idfv="+idfv)
        
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
        
        devMode =  defaults.bool(forKey: "devMode")
        //開発モードのチェック
        if devMode {
            //開発
            hostURL = "https://maru8ibm.maruhachi.co.jp:4343/HTP2/WAH001CL.PGM?"
        }else {
            //本番
            hostURL = "https://maru8ibm.maruhachi.co.jp/HTP2/WAH001CL.PGM?"
        }
        
        //最終更新日チェック
        if Date().string != defaults.object(forKey: "lastDataDownload") as? String {
            //データ取得
        }else {
            //保存データ呼び出し
        }
        
        //IBMと通信可能かチェック
        hostConnect.delegate = self
        hostConnect.start(hostName: hostName)
    }

    
    //MARK: HostConnectDelegate
    func complete(_: Any) {
        //ホスト接続成功
        isHostConnected = true
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
    }

}
