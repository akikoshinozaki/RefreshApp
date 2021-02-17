//
//  PhotoViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/08.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var collection: UICollectionView!
    var cellEditing: Bool = false
    var edtBtn:UIBarButtonItem!
    var uploadFault:Bool = false
    @IBOutlet weak var uploadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "＜ 戻る", style: .done, target: self, action: #selector(back))
        edtBtn = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(editCollection(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.rightBarButtonItem = edtBtn
        collection.delegate = self
        collection.dataSource = self
        
        uploadBtn.layer.cornerRadius = 8

    }

    override func viewDidLayoutSubviews() {
        print("photo" + #function)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func editCollection(_ sender:UIBarButtonItem){
        cellEditing = !cellEditing
        if cellEditing {
            edtBtn.title = "完了"
        }else {
            edtBtn.title = "編集"
        }
        collection.reloadData()
    }
    /*
    override func setEditing(_ editing: Bool, animated: Bool) {
        print(editing)
            //editing = !editing
        if editing {
            //print(editing)
            editButtonItem.title = "編集"
        }else {
            editButtonItem.title = "完了"
        }
    }*/

    @objc func back() {
        //self.navigationController?.popViewController(animated: true)
        if uploadFault {
            //tagNO = ""
            imageArr = []
            uploadFault = false
        }
        
        //self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
        
    }
    var postAlert: UIAlertController!
    @IBAction func upload(_ sender: UIButton) {
//        print(#function)
        postAlert = UIAlertController(title: "データ送信中", message: "", preferredStyle: .alert)
        
        sender.isEnabled = false
        self.present(postAlert, animated: true, completion: nil)
        Upload().uploadData()
        NotificationCenter.default.addObserver(self, selector: #selector(finishUpload), name: Notification.Name(rawValue:"postImage"), object: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            sender.isEnabled = true
        })
    }
    
    @objc func finishUpload(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"postImage"), object: nil)
        //let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        if errorCode == "" {
            //アップロード成功
            postAlert.title = "送信完了しました"
            postAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                Upload().deleteFM(tag: tagNO)
                //tagNO = ""
                imageArr = []
                self.back()
                
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
        //self.present(alert, animated: true, completion: nil)
    }
    

}

extension PhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200.0, height: 200.0)
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        cell.imageView.image = imageArr[indexPath.item]
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
    
    //@objc func deleteCell(i:Int){
    @objc func deleteCell(_ sender:UIButton){
        let alert = UIAlertController(title: "写真を削除しますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {
            Void in
            let i = sender.tag-300
            //削除したときの処理
            imageArr.remove(at: i)
            DispatchQueue.main.async {
                self.collection.reloadData()
                if imageArr.isEmpty{
                    self.back()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
