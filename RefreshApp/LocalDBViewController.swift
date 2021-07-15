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
}


extension LocalDBViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dspArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YakanTableViewCell", for: indexPath) as! YakanTableViewCell
        
        let obj = dspArr[indexPath.row]
        
        cell.entryLabel.text = obj.entryDate
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
