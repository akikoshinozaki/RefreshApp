//
//  ViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
import AVFoundation

var tagNO:String = ""

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
    @IBOutlet weak var label2: UILabel!
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
        
        hiddenBtn.addTarget(self, action: #selector(tapHidBtn(_:)), for: .touchUpInside)

        devMode =  defaults.bool(forKey: "devMode")
        self.modeChange(dev: devMode)
        devControl.addTarget(self, action: #selector(valueChange(_:)), for: .valueChanged)

    }
    
    @objc func tapHidBtn(_ sender: UIButton) {
        self.timer?.invalidate() //タイマーを破棄
        
        tapCnt += 1
        
        if tapCnt >= maxCnt {
            tapCnt = 0
            devMode = !devMode
            modeChange(dev: devMode)
            defaults.set(devMode, forKey: "devMode")
        }
        label1.text = "タップした回数：\(tapCnt)回"
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.tapCnt = 0
            self.label1.text = "タップした回数：0回"
        })
        
    }
    
    func modeChange(dev:Bool) {
        self.label1.text = hostURL
        //print("hostURL=\(hostURL)")
        devView.isHidden = !devMode
        if dev {
            //開発モード
            label2.text = "開発"
            titleLabel.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            hostURL = m2URL
            devControl.selectedSegmentIndex = 0
            
        }else {
            //本番
            label2.text = ""
            titleLabel.backgroundColor = #colorLiteral(red: 0, green: 0.6475384831, blue: 0.5196911097, alpha: 1)
            hostURL = m8URL
        }
        
    }
    
    @objc func valueChange(_ sender: UISegmentedControl) {
        //開発モードのみ使用（m2/m8の切替）
        if sender.selectedSegmentIndex == 0 {
            //開発
            hostURL = m2URL
        }else {
            //本番
            hostURL = m8URL
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
        if tagNO == "" {
            showAlert(title: "TAG No.を入力してください", message: "")
            return
        }
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let accept = storyboard.instantiateViewController(withIdentifier: "accept")
        self.navigationController?.pushViewController(accept, animated: true)
    }
    
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
