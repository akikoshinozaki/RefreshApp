//
//  LocalDBViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/07/14.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

struct SQLObj {
    var id:Int!
    var entryDate : String = ""
    var workDay : String = ""
    var tagNO : String = ""
    var syain : String = ""
    var kotei : String = ""
    var temp : String = ""
    var humid : String = ""
    var weather : String = ""
    var weight : String = ""
    var g_gram: String = ""
    var s_gram: String = ""
    var timeStamp : String = ""
    var status:String = ""
}


class LocalDBViewController: UIViewController {

    @IBOutlet weak var syainField: UITextField!
    @IBOutlet weak var syainLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var entryBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectBtn: UIButton!
    
    var dspArr:[SQLObj] = []
    
    var selectedIndexPaths: [IndexPath] = []
    var cellAllSelected:Bool = false
    var tbEditing:Bool = false
    var _syainCD = ""
    var _syainNM = ""
    
    var conAlert:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = false
//        navigationItem.title = "title"
//        navigationItem.rightBarButtonItem = editButtonItem
        
        dspArr = localDB.selectTB(status: "unsent")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = true
        
        syainField.delegate = self
        
        tbEditing = false
        
            selectBtn.isHidden = true
            selectBtn.layer.cornerRadius = 5
            selectBtn.addTarget(self, action: #selector(selectBtnTapped(_:)), for: .touchUpInside)

        editBtn.addTarget(self, action: #selector(tableEditing), for: .touchUpInside)
        
    }
    

//    override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//        self.tableEditing(editing: editing)
//    }
    
    @objc func tableEditing() {
        tbEditing = !tbEditing
        tableView.isEditing = tbEditing
        selectBtn.isHidden = !tbEditing
        if isEditing {
//            self.editButtonItem.title = "完了"
            editBtn.setTitle("完了", for: .normal)
        }else {
//            self.editButtonItem.title = "編集"
            editBtn.setTitle("編集", for: .normal)
            self.deleteRows()
        }
        
    }
    
    @objc func selectBtnTapped(_ sender:UIButton){

        if tableView.isEditing {
            print("selectBtn")
            cellAllSelected = !cellAllSelected
            //セルを選択状態にする
            for i in 0..<dspArr.count {
                let cell = tableView.cellForRow(at: [0,i])
                cell?.isSelected = cellAllSelected
            }

            selectedIndexPaths = []
            if cellAllSelected {
                selectBtn.setTitle("選択解除", for: .normal)
                //選択したセルを配列に追加
                for i in 0..<dspArr.count {
                    selectedIndexPaths.append([0,i])
                }
//                self.editButtonItem.title = "Delete"
                editBtn.setTitle("削除", for: .normal)
                
            }else {
                selectBtn.setTitle("全て選択", for: .normal)
                editBtn.setTitle("完了", for: .normal)
//                self.editButtonItem.title = "Done"
            }
            

        }
    }
    
    
    @IBAction func postToIBM(_ sender: UIButton) {
        sender.isEnabled = false //二重登録禁止
        if _syainCD == "" {
            SimpleAlert.make(title: "担当社員を入力してください", message: "")
            sender.isEnabled = true
            return
        }
        
        DispatchQueue.main.async {
            self.conAlert = UIAlertController(title: "データ送信中", message: "", preferredStyle: .alert)
            self.present(self.conAlert, animated: true, completion: nil)
        }
        
        print(dspArr)
        var paramStr = ""
        for (i,obj) in dspArr.enumerated() {
            paramStr += "" +
                "DATA_NO=\(i+1)&" +
                "SYAIN=\(_syainCD)&" +
                "TAG_NO=\(obj.tagNO)&" +
                "KOTEI=\(obj.kotei)&" +
                "DATE=\(obj.workDay)&" +
                "TEMP=\(obj.temp)&" +
                "HUMID=\(obj.humid)&" +
                "WEATHER=\(obj.weather)&" +
                "WEIGHT=\(obj.weight)&"
            
            if obj.kotei == "06" {
                paramStr += "G_GRAM=\(obj.g_gram)&" + //側重量(g)
                    "S_GRAM=\(obj.s_gram)&" //総重量(g)
            }
            
        }
        
        paramStr += "DETAILS_CNT=\(dspArr.count)"
        
        IBM().IBMRequest2(type: "YAKAN", parameter: paramStr, completionClosure: { (_,json,err) in
            if err == nil, json != nil {
                //print(json!)
                if json!["RTNCD"] as! String != "000" { //IBMエラー
                    var msg = ""
                    for m in json!["RTNMSG"] as? [String] ?? [] {
                        msg += m+"\n"
                    }
                    DispatchQueue.main.async {
                        self.conAlert.title = "エラー"
                        self.conAlert.message = msg
                        self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                    }
                    
                }else {
                    DispatchQueue.main.async {
                        self.conAlert.title = "登録成功"
                        self.conAlert.message = "正常に登録できました"
                        self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                            Void in
                            self.entryBtn.isEnabled = false //二重登録禁止

                        }))
                    }
                }
                
            }else {
                if errMsg == "" {
                    errMsg = "登録に失敗しました"
                }
                DispatchQueue.main.async {
                    self.conAlert.title = "エラー"
                    self.conAlert.message = errMsg
                    self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                }
            }
            DispatchQueue.main.async {
                self.entryBtn.isEnabled = true
            }
            
        })
        
        
    }
    
}


extension LocalDBViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dspArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YakanTableViewCell", for: indexPath) as! YakanTableViewCell
        
        let obj = dspArr[indexPath.row]
        
//        cell.entryLabel.text = obj.entryDate
        cell.workLabel.text = obj.workDay
        cell.tagLabel.text = obj.tagNO
        if let kotei = koteiList.first(where: {$0.key==obj.kotei}){
            cell.koteiLabel.text = kotei.val
        }
        if let weath = weatherList.first(where: {$0.key==obj.weather}) {
            cell.weatherLabel.text = weath.val
        }
        cell.tempLabel.text = obj.temp+"℃"
        cell.humidLabel.text = obj.humid+"%"
        cell.weightLabel.text = obj.weight+"Kg"
        if obj.kotei == "06" {
            cell.g_Label.text = obj.g_gram+"g"
            cell.s_Label.text = obj.s_gram+"g"
        }else {
            cell.g_Label.text = ""
            cell.s_Label.text = ""
        }
        cell.tantoLabel.text = obj.syain
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集モードじゃない場合はreturn
        guard tableView.isEditing else { return }
        //selectedIndexPaths = tableView.indexPathsForSelectedRows ?? []
        selectedIndexPaths.append(indexPath)
        print(selectedIndexPaths)

        //if let _ = self.tableView.indexPathsForSelectedRows {
        if selectedIndexPaths.count > 0 {
            // 選択肢にチェックが一つでも入ってたら「削除」を表示する。
//            self.editButtonItem.title = "削除"
            editBtn.setTitle("削除", for: .normal)
            cellAllSelected = true
            self.selectBtn.setTitle("選択解除", for: .normal)

        }

    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 編集モードじゃない場合はreturn
        guard tableView.isEditing else { return }
        //selectedIndexPaths = tableView.indexPathsForSelectedRows ?? []
        for (i, idx) in selectedIndexPaths.enumerated() {
            if indexPath == idx {
                selectedIndexPaths.remove(at: i)
            }
        }
        print(selectedIndexPaths)

        //if let _ = self.tableView.indexPathsForSelectedRows {
        if selectedIndexPaths.count > 0 {
            self.editBtn.setTitle("削除", for: .normal)
//            self.editButtonItem.title = "Delete"
            
        } else {
            cellAllSelected = false
            // 何もチェックされていないときは"Done"を表示
//            self.editButtonItem.title = "Done"
            self.editBtn.setTitle("完了", for: .normal)
            selectBtn.setTitle("全て選択", for: .normal)

        }
    }
    
    func deleteRows() {
        //print(selectedIndexPaths)
        var deleteID:[Int] = []
        if selectedIndexPaths.count > 0 {
            // 配列の要素を削除するため、降順にソートする
            let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
            for indexPathList in sortedIndexPaths {
                deleteID.append(dspArr[indexPathList.row].id)
                self.dspArr.remove(at: indexPathList.row) // 選択肢のindexPathから配列の要素を削除
            }
            print(deleteID)
            self.tableView.deleteRows(at: sortedIndexPaths, with: .automatic)
//            localDB.deleteData(deleteID: deleteID)
            localDB.updateData(column: "status", param: "delete", idList: deleteID)
            self.selectedIndexPaths = []

        }
    }
    
    
}

extension LocalDBViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _syainCD = ""
        _syainNM = ""
        syainLabel.text = ""
        if textField.text == "" {return} //ブランクなら何もしない
        let str = textField.text!
        
        if str.count != 5 {
            SimpleAlert.make(title: "5桁で入力してください", message: "")
            return
        }
        
        if Int(str)  == nil {
            SimpleAlert.make(title: "数字以外は入力できません", message: "")
            textField.text = ""
            return
        }
        print("\(workTime.min()!)時")
        print("\(workTime.max()!)時")
        if !yakan {
            syainCheck(cd: str)
        }else {
            SimpleAlert.make(title: "IBM稼働時間外です", message: "6時~21時の間に登録をしてください")
        }
        
    }
    
    func syainCheck(cd:String) {
        
        IBM().search(param: "syain", cd: cd, completionClosure: {
            (str, json,err) in
            if err == nil, json != nil {
                //print(json!)
                var jsonErr:Bool = true
                if json!["RTNCD"] as! String == "000" {
                    self._syainCD = json!["SYAIN_CD"] as? String ?? ""
                    self._syainNM = json!["SYAIN_NM"] as? String ?? ""
                    jsonErr = false
                }else {
                    let errMSG = json!["RTNMSG"] as! [String]
                    var err = ""
                    for e in errMSG {
                        err += e+"\n"
                    }
                    SimpleAlert.make(title: "エラー", message: err)
                    return
                }
                
                DispatchQueue.main.async {
                    self.syainLabel.text = self._syainNM
                    self.syainField.text = self._syainCD
                    if jsonErr {
                        SimpleAlert.make(title: "エラー", message: "社員CDが存在しません")
                    }
                }
                
            }else {
                SimpleAlert.make(title: "エラー", message: err?.localizedDescription)
            }
        })
    }
    
}
