//
//  Upload.swift
//  RefreshApp
//
//  Created by administrator on 2020/11/09.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
import MessageUI

var errorCode = ""
class Upload: NSObject {

    let fileManager = FileManager.default
    let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var finishUpload:Bool = false
    let semaphore = DispatchSemaphore(value: 0)

    public func saveFM(tag:String, arr:[UIImage]){
        //imageDirを作っておく
        let path = basePath.appending("/\(tag)/")
        //ディレクトリが存在しなければ、作成
        if !fileManager.fileExists(atPath: path){
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        //imageArrをDocumentディレクトリに保存
        for (i,img) in arr.enumerated() {
            let filename = tagNO+"-\(i+1).jpg"
            let data:Data? = img.jpegData(compressionQuality: 1.0)
            if data != nil {
                fileManager.createFile(atPath: path.appending(filename), contents: data, attributes: nil)
            }
        }

    }
    
    public func deleteFM(tag:String){
        let path = basePath.appending("/\(tag)/")
        //アップロード成功したら保存ファイル削除
        if fileManager.fileExists(atPath: path){
            do {
                try self.fileManager.removeItem(atPath: path)
            }catch {
                print("エラー")
            }
        }
    }

    
    func uploadData(){
//        let url = URL(string: "https://oktss03.xsrv.jp/refreshPhoto/refresh.php")!
        let url = URL(string: "https://oktss03.xsrv.jp/refreshPhoto/dev/refresh.php")! //開発
        var request = URLRequest(url:url)
        let boundary = "---------------------------168072824752491622650073"
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        // テキスト部分の設定
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data;".data(using: .utf8)!)
//        body.append("name=\"tagNo\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\(tagNO)\r\n".data(using: .utf8)!)
        body.append("name=\"today\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(Date().string)\r\n".data(using: .utf8)!)
        //何個画像を送るか
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data;".data(using: .utf8)!)
        body.append("name=\"imgCount\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(imageArr.count)\r\n".data(using: .utf8)!)

        for (i,img) in imageArr.enumerated() {
            let filename = tagNO+"-\(i+1).jpg"
            let data:Data? = img.jpegData(compressionQuality: 0.6)
            //画像部分の設定
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data;".data(using: .utf8)!)
            body.append("name=\"uploadfile\(i)\";".data(using: .utf8)!)
            body.append("filename=\(filename)\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(data!)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, err) in
            
            if err != nil {
                //エラーの時
                print("error=\(err!)")
                //タイムアウトの時以外は、
                if (err! as NSError).code != -999 {
                    errorCode = "E1001:\(err!.localizedDescription)"
                    //print((err! as NSError).code)
                }
                self.finishUpload = false
                DispatchQueue.main.async{
                    NotificationCenter.default.post(name: Notification.Name(rawValue:"postImage"), object: nil)
                }
            }else if response != nil {
                // レスポンスを出力
                print("******* response = \(response!)")
                if let responseString = String(data: data!, encoding: .utf8) {
                    print("****** response data = \(responseString)")
                    //アップロード完了
                    if(responseString.contains("OK")){
                        self.finishUpload = true
                        errorCode = ""
                    }else {
                        //phpからの戻り値がOKじゃない
                        print("php error")
                        errorCode = "E2003:PHPサーバーエラー"
                    }
                }else {
                    //dataがnilのとき（Basic認証エラー等）
                    print("data == nil")
                    errorCode = "E2002:サーバーに接続できません"
                }
            }else {
                //レスポンスがない
                print("response nil")
                errorCode = "E2001:サーバーから応答がありません"
            }
            
            DispatchQueue.main.async{
                NotificationCenter.default.post(name: Notification.Name(rawValue:"postImage"), object: nil)
            }
            
            self.semaphore.signal()
            
        })
        
        task.resume()
        self.timeout(task: task, semaphore: semaphore, minute: 20.0
        )
    }
    
    func timeout(task: URLSessionTask, semaphore: DispatchSemaphore, minute:Double) {
        let result = semaphore.wait(timeout: DispatchTime.now() + minute)
        if result == .timedOut {
            task.cancel()
            print("timeout")
            errorCode = "E1002:接続がタイムアウトしました"
        }
    }
    /*
    func aaa(path:String, filename:String) {
        let url = URL(string: "https://oktss:m8mawata@maru8idom.maruhati.jp/IDOM.php")!
        var request = URLRequest(url:url)
        let boundary = "---------------------------168072824752491622650073"
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        //zipPathからデータを取得
        let body = NSMutableData()

        let zipData = NSData(contentsOfFile: path)
        // テキスト部分の設定
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data;".data(using: .utf8)!)
        body.append("name=\"dirName\"\r\n\r\n".data(using: .utf8)!)
        body.append("upload\r\n".data(using: .utf8)!)
        //画像部分の設定
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data;".data(using: .utf8)!)
        body.append("name=\"uploadfile\";".data(using: .utf8)!)
        body.append("filename=\(filename).zip\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/zip\r\n\r\n".data(using: .utf8)!)
        body.append(zipData! as Data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body as Data
    }*/


}
