//
//  ViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

//var tagNO:String = ""
//var dateTag:Int = 0

class _ViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    //隠しボタンのテスト
    @IBOutlet weak var hiddenBtn: UIButton!
    var tapCnt:Int = 0
    let maxCnt:Int = 5
    let interval: TimeInterval = 2
    var timer: Timer?
    //開発のみ
    @IBOutlet weak var devView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var envLabel: UILabel!
    @IBOutlet weak var devControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = "Ver. "+bundleVersion
        label1.text = hostURL
        
        //本番のデプロイのみ隠しボタン設置
        #if DEV
        #else
        hiddenBtn.addTarget(self, action: #selector(tapHidBtn(_:)), for: .touchUpInside)
        #endif

        if devMode {
            devControl.addTarget(self, action: #selector(valueChange(_:)), for: .valueChanged)
        }

    }
    
    @objc func tapHidBtn(_ sender: UIButton) {
        self.timer?.invalidate() //タイマーを破棄
        
        tapCnt += 1
        label1.text = "タップした回数：\(tapCnt)回"
        if tapCnt >= maxCnt {
            tapCnt = 0
            EnvironmentSwitch().make(dev: devMode)
        }

        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.tapCnt = 0
        })
        
    }
    
    func modeSet(dev:Bool) {
        self.label1.text = hostURL
    }
    
    @objc func valueChange(_ sender: UISegmentedControl) {
        //開発モードのみ使用（m2/m8の切替）
        if sender.selectedSegmentIndex == 0 {
            hostURL = m2URL //開発
            xsrvURL = m2xsrvURL
            envLabel.text = "開発環境です"
            envLabel.backgroundColor = #colorLiteral(red: 1, green: 0.9385977387, blue: 0.4325818419, alpha: 1)
        }else {
            hostURL = m8URL //本番
            xsrvURL = m8xsrvURL
            envLabel.text = "本番環境です"
            envLabel.backgroundColor = #colorLiteral(red: 0.5981173515, green: 1, blue: 0.6414633393, alpha: 1)
        }
        label1.text = hostURL
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func unsentList(_ sender: UIButton) {
        let storyboard: UIStoryboard = self.storyboard!
        let list = storyboard.instantiateViewController(withIdentifier: "list")
        self.navigationController?.pushViewController(list, animated: true)
    }
    

    @IBAction func refreshReception(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let recept = storyboard.instantiateViewController(withIdentifier: "recept")
        self.navigationController?.pushViewController(recept, animated: true)
    }
   
    @IBAction func refreshInquiry(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let inq = storyboard.instantiateViewController(withIdentifier: "inquiry")
        self.navigationController?.pushViewController(inq, animated: true)
    }
}

