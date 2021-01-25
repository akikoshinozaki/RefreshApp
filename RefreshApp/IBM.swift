//
//  IBM.swift
//  QRReader
//
//  Created by administrator on 2017/07/10.
//  Copyright © 2017年 Akiko Shinozaki. All rights reserved.
//

import UIKit


var buttonTag_:Int!
var json_:NSDictionary!
//IBMのレスポンスから取り出すデータ
//var UKE_TYPE:String! = "" //受付タイプ
//var UKE_CDD:String! = "" //受付CD表示用
//var SYOHIN_CD:String! = "" //商品CD
//var CUSTOMER_NM:String! = "" //顧客名
//var ORDER_SPEC:String! = "" //オーダー仕様

let semaphore = DispatchSemaphore(value: 0)

class IBM: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    func IBMRequest(type:String, parameter:[String:Any], completionClosure:@escaping CompletionClosure){

        IBMResponse = false
        var json:NSDictionary!
        var errMsg = ""
        var param = "COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HBR030&PROC_TYPE=\(type)&"
        
        for p in parameter {
            param += "\(p.key)=\(p.value)&"
        }
        
        if param.last == "&" {
            param = String(param.dropLast())
            print(param)
        }
        
        let url = URL(string: hostURL)!
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        // POSTを指定
        request.httpMethod = "POST"
        // POSTするデータをBodyとして設定
        request.httpBody = param.data(using: .utf8)
        // 通信のタスクを生成.
        let task = session.dataTask(with:request, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    //戻ってきたデータを解析
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        IBMResponse = true
                    }catch{
                        print("json error")
                        errMsg += "E3001:json error"
                    }
                }else{
                    print("レスポンスがない")
                    errMsg += "E3001:No Response"
                }
                
            } else {
                print("error : \(err!)")
                if (err! as NSError).code == -1001 {
                    print("timeout")
                }
                
                errMsg += "E3003:\(err!.localizedDescription)"
            }
            completionClosure(nil,json, err)

        })
        
        // タスクの実行.
        task.resume()
        
    }

    
}