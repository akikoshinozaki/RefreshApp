//
//  UploadViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
import AVFoundation
import ZBarSDK

class UploadViewController: UIViewController {

    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet var btns: [UIButton]!
    @IBOutlet weak var collection: UICollectionView!
    var cellEditing: Bool = false
    @IBOutlet var edtBtn:UIButton!
    @IBOutlet weak var edtView: UIView!
    
    var uploadFault:Bool = false
    var backBtn:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
        backBtn = UIBarButtonItem(title: "＜戻る", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn
        
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        scanBtn.addTarget(self, action: #selector(imgChk), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        
        collection.delegate = self
        collection.dataSource = self
        
        edtBtn.setTitle("編集", for: .normal)
        edtBtn.addTarget(self, action: #selector(editCollection(_:)), for: .touchUpInside)
        tagField.delegate = self
        setTag()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collection.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        var n:CGFloat = 3.0
        if UIDevice.current.orientation == .portrait {
            n = 2.0
        }
        let layout = UICollectionViewFlowLayout()
        let wid = collection.frame.size.width/n-10
        layout.itemSize = CGSize(width: wid, height: wid*0.7)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
        layout.sectionInsetReference = .fromSafeArea
        collection.collectionViewLayout = layout
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
//        backButton.isEnabled = false
//        listButton.isEnabled = false
        
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "TAGの変更はできません", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else {
            self.scan()
        }

    }
    
    
    @IBAction func clearTag(_ sender: Any) {
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "TAGの変更はできません", preferredStyle: .alert)
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

    }
    //MARK: - 画像送信
    var postAlert: UIAlertController!
    @IBAction func upload(_ sender: UIButton) {
        if imageArr.count == 0 {
            SimpleAlert.make(title: "画像が存在しません", message: "")
            return
        }
        postAlert = UIAlertController(title: "データ送信中", message: "", preferredStyle: .alert)
        
        sender.isEnabled = false
        let alert = UIAlertController(title: "画像を送信します", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            DispatchQueue.main.async {
                
                self.present(self.postAlert, animated: true, completion: nil)
                Upload().uploadData()
                NotificationCenter.default.addObserver(self, selector: #selector(self.finishUpload), name: Notification.Name(rawValue:"postImage"), object: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            sender.isEnabled = true
        })
        
    }
    
    @objc func finishUpload(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"postImage"), object: nil)
        
        if errorCode == "" {
            //アップロード成功
            postAlert.title = "送信完了しました"
            postAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                Upload().deleteFM(tag: tagNO)
                imageArr = []
                self.collection.reloadData()
                tagNO = ""
                self.tagField.text = ""
                self.setTag()
                
            }))
        }else {
            postAlert.title = "送信できませんでした"
            postAlert.message = errorCode
            postAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                self.uploadFault = true
                Upload().saveFM(tag: tagNO, arr: imageArr)
            }))
            
        }

    }
    
    //MARK: - 戻る
    @objc func back(){
        if imageArr.count > 0, !uploadFault {
            let alert = UIAlertController(title: "未送信の写真があります", message: "破棄しますか？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                imageArr = []
                tagNO = ""
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)

        }else {
            tagNO = ""
            imageArr = []
            uploadFault = false
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}

extension UploadViewController:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "TAGの変更はできません", preferredStyle: .alert)
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
    
    @objc func editCollection(_ sender:Any){
        cellEditing = !cellEditing
        //編集中は操作できないようにする
        backBtn.isEnabled = !cellEditing
        for btn in btns {
            btn.isUserInteractionEnabled = !cellEditing
        }
        tagField.isUserInteractionEnabled = !cellEditing
        
        if cellEditing {
            edtBtn.setTitle("完了", for: .normal)
        }else {
            edtBtn.setTitle("編集", for: .normal)
        }
        collection.reloadData()
    }
    
}

extension UploadViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        edtView.isHidden = imageArr.count==0
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        cell.imageView.image = imageArr[indexPath.item]
        cell.filterView.isHidden = !cellEditing
        cell.deleteBtn.isHidden = !cellEditing
        cell.deleteBtn.tag = 300+indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteCell(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !cellEditing {//編集中は拡大しない
            //タップしたら拡大表示
            num = indexPath.row
            let storyboard: UIStoryboard = self.storyboard!
            let disp = storyboard.instantiateViewController(withIdentifier: "disp")
            disp.modalPresentationStyle = .fullScreen
            
            self.present(disp, animated: true, completion: nil)
        }
    }
    
    @objc func deleteCell(_ sender:UIButton){
        let alert = UIAlertController(title: "写真を削除しますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {
            Void in
            let i = sender.tag-300
            //削除したときの処理
            imageArr.remove(at: i)
            DispatchQueue.main.async {
                self.collection.reloadData()
                if imageArr.count == 0 {
                    self.editCollection(self)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

//MARK: - ZBar Delegate
extension UploadViewController: ZBarReaderDelegate{

    @objc func scan(){
        //ZBarReaderViewControllerのオブジェクトを生成
        let reader = ZBarReaderViewController()
        reader.readerDelegate = self
        reader.cameraFlashMode = .off
        
        let scanner:ZBarImageScanner = reader.scanner
        scanner.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
        reader.isModalInPresentation = false //下スワイプで閉じないように
        self.present(reader, animated: true, completion: nil)
        
//        reader.showsZBarControls = false
        reader.showsCameraControls = false

    }

    //バーコードを読み取った後の処理(ZBar)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        var symbol : ZBarSymbol? = nil
        
        if let symbolset = info[UIImagePickerController.InfoKey(rawValue: "ZBarReaderControllerResults")] as? ZBarSymbolSet {
            var iterator = NSFastEnumerationIterator(symbolset)
            
            while let value = iterator.next() {
                if let sym = value as? ZBarSymbol {
                    symbol = sym
                    break
                }
            }

        }

        if symbol == nil {
            return
        }
        
        let resultString = symbol!.data as String
        print(resultString)
        if symbol!.typeName! == "EAN-13" || symbol!.typeName! == "QR-Code" {
            let tag = ScanData().readCode(picker:picker, result: resultString)
            if tag != "" {
                tagNO = tag
                setTag()
                picker.dismiss(animated: true, completion: nil)
            }
                        
        }
    }
    
}

