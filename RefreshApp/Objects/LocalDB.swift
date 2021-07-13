//
//  LocalDB.swift
//  LaosApp
//
//  Created by administrator on 2019/10/24.
//  Copyright © 2019 Akiko Shinozaki. All rights reserved.
//

import UIKit
import FMDB

class LocalDB: NSObject {
    private let db :FMDatabase
    
    init(db: FMDatabase) {
        self.db = db
        self.db.open()
        super.init()
    }
    
    deinit {
        self.db.close()
    }
    let tbName = "yakanTB"
    
    /// テーブル作成
    func create() {
        //データ保存場所
        let table = "" +
            "CREATE TABLE IF NOT EXISTS \(tbName) (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "entryDate TEXT, " +
            "tagNO TEXT, " +
            "syain TEXT, " +
            "kotei TEXT, " +
            "temp TEXT, " +
            "humid TEXT, " +
            "weather TEXT, " +
            "weight TEXT, " +
            "g_gram TEXT, " +
            "s_gram TEXT, " +
            "timestamp TEXT " +
        ");"
        
        if (self.db.executeUpdate(table, withArgumentsIn: [])){
            print("table create successfully")
        }

    }

    func insert(param:[String:Any]) -> (Bool) {
        var insertSuccess:Bool = false

        let entryDate = Date().string
        let tag = param["TAG_NO"] as? String ?? ""
        let syain = param["SYAIN"] as? String ?? ""
        let kotei = param["KOTEI"] as? String ?? ""
        let temp  = String(param["TEMP"] as! Double)
        let humid = String(param["HUMID"] as! Double)
        let weather = param["WEATHER"] as? String ?? ""
        let weight = param["WEIGHT"] as? String ?? ""
        let g_gram = param["G_GRAM"] as? String ?? ""
        let s_gram = param["S_GRAM"] as? String ?? ""
        let timestamp = Date().timestamp

        //Insert
        let insert_SQL = "" +
            "INSERT INTO " + tbName +
            " (entryDate, tagNO, syain, kotei, temp, humid, weather, weight, g_gram, s_gram, timestamp) " +
            "VALUES " +
            "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" +
        ";"

        print(insert_SQL)
        if self.db.executeUpdate(insert_SQL, withArgumentsIn: [
            entryDate, tag, syain, kotei, temp, humid, weather, weight, g_gram, s_gram, timestamp
            ]){
            //insert成功
            insertSuccess = true
            print(self.db.lastInsertRowId)
            
        }else {
            //失敗の処理
            insertSuccess = false
            print(self.db.lastError())
        }
        
        return insertSuccess
    }


    /*
    func errorLog(dateTime:String, errCode:String, errMsg:String, filename:String, id:Int, den_no:Int, den_ym:Int){
        let errorMsg = "\(dateTime),errorCode = \(self.db.lastErrorCode()),errormessage = \(self.db.lastErrorMessage())," +
        "id = \(id), den_no = \(den_no), den_ym = \(den_ym)"
        
        if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let filePath = dir.appendingPathComponent("\(filename).txt")
            
            if !manager.fileExists(atPath: filePath.path){
                manager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            }
            
            if self.errWrite(url: filePath, text: errorMsg) {
                print("エラーログ書き込み成功")
            }else {
                print("エラーログ書き込みエラー")
            }
            
        }
    }
    
    //errorLogファイルに書き込み
    func errWrite(url: URL, text: String) -> Bool {

        do {
            let fileHandle = try FileHandle(forWritingTo: url)
            // 改行を入れる
            let stringToWrite = "\n" + text
            
            // ファイルの最後に追記
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: .utf8)!)
            return true
        } catch let error as NSError {
            print("failed to append: \(error)")
            return false
        }
        
    }
    
    func selectTB(date:String, status:String) -> [SQLObj] {
        //照会
        var arr:[SQLObj] = []
        let SQLSelect = "SELECT * FROM \(tbName) where status = '\(status)';"
        if let results = self.db.executeQuery(SQLSelect, withArgumentsIn: []) {
            while results.next() {
                //print(results.columnCount)
                //entryDate, entryTime, itemCD, count, timeStamp, status
                let timestamp = results.string(forColumn: "timeStamp")!
                let itemCD = results.string(forColumn: "itemCD")!
                var itemName = ""
                if let idx = itemArray.firstIndex(where: {$0.cd == itemCD}) {
                    itemName = itemArray[idx].name
                }
                
                var syain_ = ""
                var issue_ = ""
                var receive_ = ""
                //var lot_ = ""
                
                let table1_sel = "SELECT * FROM table1 where timestamp = '\(timestamp)';"
                if let results = self.db.executeQuery(table1_sel, withArgumentsIn: []) {
                    while results.next(){
                        syain_ = results.string(forColumn: "syainCD")!
                        issue_ = results.string(forColumn: "issue")!
                        receive_ = results.string(forColumn: "receive")!
                        //lot_ = results.string(forColumn: "lot")!
                    }
                }
                
                let obj = SQLObj(id: Int(results.int(forColumn: "id")),
                                 syainCD: syain_,
                                 entryDate: results.string(forColumn: "entryDate")!,
                                 entryTime: results.string(forColumn: "entryTime")!,
                                 timeStamp: timestamp,
                                 rowNo: results.string(forColumn: "rowNo")!,
                                 itemCD: itemCD,
                                 itemName: itemName,
                                 count: Double(results.double(forColumn: "count")),
                                 issue: issue_,
                                 receive: receive_,
                                 registNo:results.string(forColumn: "registNo") ?? ""
                                 )
                
                arr.append(obj)
                

            }
        }
        
        return arr
        
    }
    
    //レコードを削除
    func deleteData(deleteID:[Int]) {

        var str = "\(deleteID)"
//        print(str)
        str = str.replacingOccurrences(of: "[", with: "(")
        str = str.replacingOccurrences(of: "]", with: ")")
//        print(str)

        let deleteSQL = "DELETE FROM \(tbName) WHERE id IN \(str);"
        if self.db.executeUpdate(deleteSQL, withArgumentsIn: []) {
            print("\(tbName) Deleted")
        }else{
            print("\(tbName) delete failed")
        }
        
    }
    
    func restoreInsert(table:String, results:FMResultSet) {
        var arr:[String:Any]!
        while results.next(){
            arr = results.resultDictionary as? [String:Any]
            
            //print(arr!)
            var keys:[String] = []
            var values:[Any] = []
            for item in arr {
                //print(item.key)
                if item.key != "id"{
                    keys.append(item.key)
                    values.append(item.value)
                }
            }
            
            var str = "\(keys)"
            str = str.replacingOccurrences(of: "[", with: "(")
            str = str.replacingOccurrences(of: "]", with: ")")
            let q = String(repeating: "?, ", count: keys.count-1)
            
            let insert = "" +
                "INSERT INTO " +
                "\(table) \(str) " +
                "VALUES " +
                "(\(q)?) " +
            ";"
            
            if self.db.executeUpdate(insert, withArgumentsIn: values){
                //insert成功
                insertCount+=1
                //print(self.db.lastInsertRowId)
                
            }else {
                //失敗の処理
                //insertSuccess = false
                //print("code:\(self.db.lastErrorCode())")
                //print("message:\(self.db.lastErrorMessage())")
                //errorcode(19) Unique Keyに重複して挿入しようとした場合
                if self.db.lastErrorCode() == 19 {
                    duplicateCount += 1
                }
            }
            
        }
        
    }*/
    
    
}

