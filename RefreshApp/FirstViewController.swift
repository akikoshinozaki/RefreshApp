//
//  FirstViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
import AVFoundation

//var tagNO:String = ""

class FirstViewController: UIViewController, ScannerViewDelegate {

    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagField: UITextField!
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
        
        // Do any additional setup after loading the view.
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = "Ver. "+bundleVersion
        tagField.delegate = self
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        scanBtn.addTarget(self, action: #selector(imgChk), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        //本番のデプロイのみ隠しボタン設置
        #if DEV
        #else
        hiddenBtn.addTarget(self, action: #selector(tapHidBtn(_:)), for: .touchUpInside)
        #endif

        if devMode {
            devView.isHidden = false
            devControl.addTarget(self, action: #selector(valueChange(_:)), for: .valueChanged)
            titleLabel.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }else {
            devView.isHidden = true
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("vc" + #function)
        setTag()
        print(#function)
        print("isHostConnected=\(isHostConnected)")
    }
    
    override func viewDidLayoutSubviews() {
        //print("vc" + #function)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    func setTag(){
        if tagNO == "" {
            tagLabel.text = "TagNo.未入力"
            tagLabel.textColor = .gray
            tagField.text = ""
        }else {
            tagLabel.text = tagNO
            tagLabel.textColor = .black
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
    
    //MARK: - ScannerDelegate
    @objc func imgChk() {
        //スキャナー起動・各種ボタン無効に
//        backButton.isEnabled = false
//        listButton.isEnabled = false
        
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "画像を破棄", style: .destructive, handler: {
//                Void in
//                imageArr = []
//                self.scan()
//            }))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else {
            self.scan()
        }

    }
    
    func scan() {
        tagField.text = ""
        scanner = ScannerView(frame: self.view.frame)
        
        scanner.delegate = self
        scanner.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        scanner.frame = self.view.frame
        self.view.addSubview(scanner)

        //画面回転に対応
        scanner.translatesAutoresizingMaskIntoConstraints = false
        
        scanner.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scanner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scanner.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }

    
    func getData(data: String) {
        //print(data)
        if Int(data) != nil, data.count == 13 {
            //バーコードの時
            tagNO = String(Array(data)[4...11])
        }else if data.hasPrefix("RF="){
            //QRの時
            tagNO = String(Array(data)[3...10])
        }
        setTag()
    }
    @IBAction func clearTag(_ sender: Any) {
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "画像を破棄", style: .destructive, handler: {
//                Void in
//                imageArr = []
//                tagNO = ""
//                self.setTag()
//            }))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }else {
            tagNO = ""
            setTag()
        }
    }
    
    //MARK: - カメラ起動
    //写真を撮る
    @objc func takePhoto() {
        if tagNO == "" {
            SimpleAlert.make(title: "tagNoを入力してください", message: "")
            return
        }
        let storyboard: UIStoryboard = self.storyboard!
        let camera = storyboard.instantiateViewController(withIdentifier: "camera")
        
        camera.modalPresentationStyle = .fullScreen

        self.present(camera, animated: true, completion: nil)
//        self.navigationController?.pushViewController(camera, animated: true)
    }

    @IBAction func showPhoto(_ sender: UIButton) {
        if imageArr.count == 0 {
            SimpleAlert.make(title: "表示する写真がありません", message: "")
            return
        }
        let storyboard: UIStoryboard = self.storyboard!
        let photo = storyboard.instantiateViewController(withIdentifier: "photo")
        
//        let camera = CameraViewController(nibName: nil, bundle: nil)
//        camera.modalPresentationStyle = .fullScreen
//        self.present(photo, animated: true, completion: nil)
        self.navigationController?.pushViewController(photo, animated: true)
        
        
    }
    
    @IBAction func unsentList(_ sender: UIButton) {
        let storyboard: UIStoryboard = self.storyboard!
        let list = storyboard.instantiateViewController(withIdentifier: "list")
        self.navigationController?.pushViewController(list, animated: true)
    }
    @IBAction func refreshInquiry(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let inq = storyboard.instantiateViewController(withIdentifier: "inquiry")
        self.navigationController?.pushViewController(inq, animated: true)
    }
    
    @IBAction func refreshReception(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let recept = storyboard.instantiateViewController(withIdentifier: "recept")
        self.navigationController?.pushViewController(recept, animated: true)
    }
   

    
}

extension FirstViewController:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
            return false
        }else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print(textField.text!)
        if tagField.text! == "" {return}
        if Int(tagField.text!) == nil {
            SimpleAlert.make(title: "数字８桁で入力してください", message: "")
            return
        }
        if tagField.text?.count != 8 {
            SimpleAlert.make(title: "数字８桁で入力してください", message: "")
            return
        }
        tagNO = textField.text!
        setTag()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
    
    
}
