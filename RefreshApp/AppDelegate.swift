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
    }

    
    //MARK: HostConnectDelegate
    func complete(_: Any) {
        print(#function)
        //ホスト接続成功
        isHostConnected = true
        
        //最終更新日チェック
        let lastUPD = defaults.object(forKey: "lastDataDownload") as? String ?? ""
        if Date().string != lastUPD {
            //データ取得
            self.getList()
        }else {
            //ユーザーデフォルト呼び出し
            if let list = defaults.object(forKey: "grdList") as? [NSDictionary] {
                //print(list)
                self.setGrdList(list: list)
            }else {
                //データ取得
                self.getList()
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
        if let list = defaults.object(forKey: "grdList") as? [NSDictionary] {
            print(list)
            self.setGrdList(list: list)
        }
    }
    
    func getList(){
        //リスト取得
        print("GRADEリスト取得")
        IBM().IBMRequest(type: "GRD_LST", parameter: [:], completionClosure: {(_,json,err) in
            if err == nil, json != nil {
                if json!["RTNCD"] as! String != "000" {
                    var msg = ""
                    for m in json!["RTNMSG"] as? [String] ?? [] {
                        msg += m+"\n"
                    }
                    DispatchQueue.main.async {
//                        self.conAlert.title = "エラー"
//                        self.conAlert.message = msg
//                        self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        SimpleAlert.make(title: "エラー" , message: msg)
                    }
                }else {
                    //取得成功
                    let list = json!["GRDLST"] as? [NSDictionary] ?? []
                    self.setGrdList(list: list)
                    //print(grd_lst)
                    defaults.set(list, forKey: "grdList")
                    defaults.setValue(Date().string, forKey: "lastDataDownload")
                }
                
            }else {
                print(err!)
                if errMsg == "" {
                    errMsg = "データ取得に失敗しました"
                }
                DispatchQueue.main.async {
//                    self.conAlert.title = "エラー"
//                    self.conAlert.message = errMsg
//                    self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                
            }
            
        })
    }
    
    func setGrdList(list:[NSDictionary]) {
        grd_lst = []
        for li in list {
            let cd = li["GRDCD"] as? String ?? ""
            let nm = li["GRDNM"] as? String ?? ""
            grd_lst.append((cd:cd, nm:nm))
        }
    }

}
