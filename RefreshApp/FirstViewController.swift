//
//  FirstViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//
//  トップページ

import UIKit
import AVFoundation

var tagNO:String = ""
var dateTag:Int = 0

class FirstViewController: UIViewController {

    @IBOutlet var btns: [UIButton]!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var scanner:ScannerView!

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
        print("FirstViewController")
        // Do any additional setup after loading the view.
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = "Ver. "+bundleVersion
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        //本番のデプロイのみ隠しボタン設置
        #if DEV
        #else
        hiddenBtn.addTarget(self, action: #selector(tapHidBtn(_:)), for: .touchUpInside)
        #endif
        
        devView.isHidden = !devMode
        if devMode {
            devView.isHidden = false
            devControl.addTarget(self, action: #selector(valueChange(_:)), for: .valueChanged)
            titleLabel.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
        label1.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("vc" + #function)
        //print("isHostConnected=\(isHostConnected)")
    }
    
    override func viewDidLayoutSubviews() {
        //print("vc" + #function)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
        
    @objc func tapHidBtn(_ sender: UIButton) {
        self.timer?.invalidate() //タイマーを破棄
        label1.isHidden = false
        tapCnt += 1
        label1.text = "タップした回数：\(tapCnt)回"
        if tapCnt >= maxCnt {
            tapCnt = 0
            EnvironmentSwitch().make(dev: devMode)
            label1.isHidden = true
        }

        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.tapCnt = 0
            self.label1.isHidden = true
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
    
    @IBAction func photoUpload(_ sender: UIButton) {
   
        let storyboard: UIStoryboard = self.storyboard!
        let upload = storyboard.instantiateViewController(withIdentifier: "upload")
        self.navigationController?.pushViewController(upload, animated: true)
    }

    @IBAction func unsentList(_ sender: UIButton) {
        let storyboard: UIStoryboard = self.storyboard!
        let list = storyboard.instantiateViewController(withIdentifier: "list")
        self.navigationController?.pushViewController(list, animated: true)
    }
    
    @IBAction func listRefresh(_ sender: Any) {
        //IBMからの情報更新
        print("リスト取得")
        GetLists().getList()
    }
    
    
    @IBAction func kotei(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let recept = storyboard.instantiateViewController(withIdentifier: "kotei")
        self.navigationController?.pushViewController(recept, animated: true)
    }
    
}

