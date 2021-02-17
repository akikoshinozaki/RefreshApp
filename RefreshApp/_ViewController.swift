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

var tagNO:String = ""
var dateTag:Int = 0

class ViewController: UIViewController, ScannerViewDelegate {

    @IBOutlet var fields: [UITextField]!
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
    @IBOutlet weak var devView: UIView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var envLabel: UILabel!
    @IBOutlet weak var devControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        // Do any additional setup after loading the view.
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = "Ver. "+bundleVersion
        for field in fields {
            field.delegate = self
        }
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        
        scanBtn.addTarget(self, action: #selector(imgChk), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        #if DEV
        #else
        hiddenBtn.addTarget(self, action: #selector(tapHidBtn(_:)), for: .touchUpInside)
        #endif

//        devMode =  defaults.bool(forKey: "devMode")
//        self.modeSet(dev: devMode)
        label1.text = hostURL
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
            //self.label1.text = "タップした回数：0回"
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTag()
    }
    
    override func viewDidLayoutSubviews() {
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
    
    //MARK: - ScannerDelegate
    @objc func imgChk() {
        //スキャナー起動・各種ボタン無効に
        
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
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
    
    func removeView() {
        //スキャナーが消えたときの処理・各種ボタン有効に
    }
    
    func getData(data: String) {
        print(data)
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
            showAlert(title: "tagNoを入力してください", message: "")
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
            showAlert(title: "表示する写真がありません", message: "")
            return
        }
        let storyboard: UIStoryboard = self.storyboard!
        let photo = storyboard.instantiateViewController(withIdentifier: "photo")
        
//        let camera = CameraViewController(nibName: nil, bundle: nil)
//        camera.modalPresentationStyle = .fullScreen
//        self.present(photo, animated: true, completion: nil)
        self.navigationController?.pushViewController(photo, animated: true)
        
        
    }
    
    @IBAction func unsetnList(_ sender: UIButton) {
        let storyboard: UIStoryboard = self.storyboard!
        let list = storyboard.instantiateViewController(withIdentifier: "list")
        self.navigationController?.pushViewController(list, animated: true)
    }
    
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func printSample(_ sender: Any) {
//        if tagNO == "" {
//            showAlert(title: "TAG No.を入力してください", message: "")
//            return
//        }
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let accept = storyboard.instantiateViewController(withIdentifier: "recept")
        self.navigationController?.pushViewController(accept, animated: true)
    }
    /* webViewテストに使用
    @IBAction func webCamera(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let accept = storyboard.instantiateViewController(withIdentifier: "web")
        self.navigationController?.pushViewController(accept, animated: true)
    }
    
    @IBAction func safariView(_ sender: UIButton) {
        let url = URL(string:"https://www2.maruhati.com/ipad/test/a/index.html")
        if let url = url{
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }*/
    
    
}

extension ViewController:UITextFieldDelegate {
    
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
            self.showAlert(title: "数字８桁で入力してください", message: "")
            return
        }
        if tagField.text?.count != 8 {
            self.showAlert(title: "数字８桁で入力してください", message: "")
            return
        }
        tagNO = textField.text!
        setTag()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
    
    
}
