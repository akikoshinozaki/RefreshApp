//
//  EnvironmentSwitch.swift
//  RefreshApp
//
//  Created by administrator on 2021/01/28.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

var devMode:Bool = false

class EnvironmentSwitch: NSObject {

    func make(dev:Bool) {
        devMode = !dev
        //var envRequest = ""
        var envWord = ""
        if devMode {
            //envRequest = "d"
            envWord = "開発"
        } else {
            //envRequest = "p"
            envWord = "本番"
        }
        
        DispatchQueue.main.async {
            defaults.set(devMode, forKey: "devMode")
            let alert = UIAlertController(title: "\(envWord)環境での起動がリクエストされました", message: "起動中のアプリは\(envWord)環境ではありません。次回の起動から\(envWord)環境となります。一旦アプリを終了します", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {
                _ in
                exit(1)
            }))
            //alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            
            window_.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
