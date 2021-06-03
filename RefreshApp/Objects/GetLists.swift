//
//  GetLists.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/04/01.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

let kList:[String] = ["grdList","jitaList","hiritsu","koteiList","wetherList"]
var lList:[(key:String,list:[Dictionary<String,Any>])] = []

class GetLists: NSObject {

    func getList(){
        //リスト取得
        print("IBM リスト取得")
        
        let alert = UIAlertController(title: "リスト更新中", message: "", preferredStyle: .alert)
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        
        IBM().IBMRequest(type: "GRD_LST", parameter: [:], completionClosure: {(_,json,err) in
            if err == nil, json != nil {
                if json!["RTNCD"] as! String != "000" {
                    var msg = ""
                    for m in json!["RTNMSG"] as? [String] ?? [] {
                        msg += m+"\n"
                    }
                    DispatchQueue.main.async {
                        //SimpleAlert.make(title: "エラー" , message: msg)
                        alert.title = "エラー"
                        alert.message = msg
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    }
                }else {
                    //取得成功
                    print(json!)
                    
                    lList = []
                    var isEmpty:Bool = false
                    
                    if let list = json!["GRDLST"] as? [Dictionary<String,Any>] {
                        defaults.set(list, forKey: "grdList")
                        lList.append((key:"grdList", list:list))
                        if list.count == 0 {isEmpty = true}
                    }else {isEmpty = true}
                    if let list = json!["JITALIST"] as? [Dictionary<String,Any>] {
                        defaults.set(list,forKey: "jitaList")
                        lList.append((key:"jitaList", list:list))
                        if list.count == 0 {isEmpty = true}
                    }else {isEmpty = true}
                    if let list = json!["HIRITSU"] as? [Dictionary<String,Any>] {
                        defaults.set(list,forKey: "hiritsu")
                        lList.append((key:"hiritsu", list:list))
                        if list.count == 0 {isEmpty = true}
                    }else {isEmpty = true}
                    if let list = json!["KOTEILST"] as? [Dictionary<String,Any>] {
                        defaults.set(list, forKey: "koteiList")
                        lList.append((key:"koteiList", list:list))
                        if list.count == 0 {isEmpty = true}
                    }else {isEmpty = true}
                    if let list = json!["WTHRLST"] as? [Dictionary<String,Any>] {
                        defaults.set(list,forKey: "wetherList")
                        lList.append((key:"wetherList", list:list))
                        if list.count == 0 {isEmpty = true}
                    }else {isEmpty = true}

                    print(isEmpty)
                    if !isEmpty {
                        defaults.setValue(Date().string, forKey: "lastDataDownload")
                    }
                    
                    self.setList(lists: lList)
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
                
            }else {
                print(err!)
                if errMsg == "" {
                    errMsg = "データ取得に失敗しました"
                }
                DispatchQueue.main.async {
                    //SimpleAlert.make(title: "エラー" , message: errMsg)
                    alert.title = "エラー"
                    alert.message = errMsg
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                
            }
            
        })
        
    }
    

    func setList(lists:[(key:String,list:[Dictionary<String,Any>])]) {

        for obj in lists {
            switch obj.key {
            case "grdList":
                grd_lst = []
                for li in obj.list {
                    let cd = li["GRDCD"] as? String ?? ""
                    let nm = li["GRDNM"] as? String ?? ""
                    grd_lst.append((cd:cd, nm:nm))
                }
                if grd_lst.count == 0 {
                    //デフォルト値
                }
            case "jitaList":
                jitaArray = []
                for li in obj.list {
                    let cd = li["KEY"] as? String ?? ""
                    let nm = li["VALUE"] as? String ?? ""
                    jitaArray.append((cd:cd, nm:nm))
                }
                
                if jitaArray.count == 0 {
                    jitaArray = [("1","自社"),("2","他社"),("3","再リフォーム")]
                }
            case "hiritsu":
                hiritsuArr = []
                for li in obj.list {
                    let min = Int(li["MIN"] as! String) ?? 0
                    let max = Int(li["MAX"] as! String) ?? 0
                    if max != 0 {
                        hiritsuArr += ([Int])(min...max)
                    }else {
                        hiritsuArr.append(min)
                    }
                }
                if hiritsuArr.count == 0 {
                    hiritsuArr = ([Int])(70...95)+[50,98,99,100]
                }
                hiritsuArr = hiritsuArr.sorted(by: {$0>$1})
            case "koteiList":
                koteiList = []
                for li in obj.list {
                    let key = li["KEY"] as? String ?? ""
                    let val = li["VALUE"] as? String ?? ""
                    let flag = li["FLAG"] as? String == "1"
                    koteiList.append((key:key, val:val, flag:flag))
                }
                if koteiList.count == 0 {
                    //デフォルト値
                }
            case "wetherList":
                weatherList = []
                for li in obj.list {
                    let key = li["KEY"] as? String ?? ""
                    let val = li["VALUE"] as? String ?? ""
                    weatherList.append((key:key, val:val))
                }
                if weatherList.count == 0 {
                    //デフォルト値
                }
            default:
                return
            }
            
        }

    }
    
}
