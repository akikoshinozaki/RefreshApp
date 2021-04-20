//
//  GetLists.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/04/01.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

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

                    var glist:[Dictionary<String,Any>] = []
                    var jlist:[Dictionary<String,Any>] = []
                    var hlist:[Dictionary<String,Any>] = []
                    
                    //print(glist.isEmpty)
                    
                    if let list = json!["GRDLST"] as? [Dictionary<String,Any>] {
                        glist = list
                        defaults.set(list, forKey: "grdList")
                    }
                    if let list = json!["JITALST"] as? [Dictionary<String,Any>] {
                        jlist = list
                        defaults.set(list,forKey: "jitaList")
                    }
                    if let list = json!["HIRITSU"] as? [Dictionary<String,Any>] {
                        hlist = list
                        defaults.set(list,forKey: "hiritsu")
                    }

                    if !glist.isEmpty, !jlist.isEmpty, !hlist.isEmpty {
                        defaults.setValue(Date().string, forKey: "lastDataDownload")
                    }
                    self.setList(list1: glist, list2:jlist, list3:hlist)
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
    

    func setList(list1:[Dictionary<String,Any>],list2:[Dictionary<String,Any>],list3:[Dictionary<String,Any>]) {
        grd_lst = []
        jitaArray = []
        hiritsuArr = []
        
        for li in list1 {
            let cd = li["GRDCD"] as? String ?? ""
            let nm = li["GRDNM"] as? String ?? ""
            grd_lst.append((cd:cd, nm:nm))
        }
        
        if grd_lst.count == 0 {
            
        }
        
        for li in list2 {
            let cd = li["KEY"] as? String ?? ""
            let nm = li["VALUE"] as? String ?? ""
            jitaArray.append((cd:cd, nm:nm))
        }
        
        if jitaArray.count == 0 {
            jitaArray = [("1","自社"),("2","他社"),("3","再リフォーム")]
        }
        
        for li in list3 {
            let min = Int(li["MIN"] as! String) ?? 0
            let max = Int(li["MAX"] as! String) ?? 0
            if max != 0 {
                hiritsuArr += ([Int])(min...max)
            }else {
                hiritsuArr.append(min)
            }
        }
        
        print(hiritsuArr)
        if hiritsuArr.count == 0 {
            hiritsuArr = ([Int])(70...95)+[50,98,99,100]
        }

        hiritsuArr = hiritsuArr.sorted(by: {$0>$1})

//        print(grd_lst)
//        print(jitaArray)
//        print(hiritsuArr)
    }
    
    
}
