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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = "Ver. "+bundleVersion
        for field in fields {
            field.delegate = self
        }
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        
        scanBtn.addTarget(self, action: #selector(startScan), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setTag()
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
    var scanner:ScannerView!
    @objc func startScan() {
        //スキャナー起動・各種ボタン無効に
//        backButton.isEnabled = false
//        listButton.isEnabled = false
        

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
        //print(data)
        tagNO = String(Array(data)[4...11])
        setTag()
    }
    @IBAction func clearTag(_ sender: Any) {
        tagNO = ""
        setTag()
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

    @IBAction func showPhoto(_ sender: Any) {
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
    
}

extension ViewController:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
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
