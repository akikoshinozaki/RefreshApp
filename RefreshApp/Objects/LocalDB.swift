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
            "workDay TEXT, " +
            "tagNO TEXT, " +
            "syain TEXT, " +
            "kotei TEXT, " +
            "temp TEXT, " +
            "humid TEXT, " +
            "weather TEXT, " +
            "weight TEXT, " +
            "g_gram TEXT, " +
            "s_gram TEXT, " +
            "status TEXT, " +
            "createDate TEXT, " +
            "updateDate TEXT " +
        ");"
        
        if (self.db.executeUpdate(table, withArgumentsIn: [])){
            print("table create successfully")
        }

    }

    func insert(param:[String:Any]) -> (Bool) {
        var insertSuccess:Bool = false

        let entryDate = Date().string
        let workDay = param["DATE"] as? String ?? ""
        let tag = param["TAG_NO"] as? String ?? ""
        let syain = param["SYAIN"] as? String ?? ""
        let kotei = param["KOTEI"] as? String ?? ""
        let temp  = String(param["TEMP"] as! Double)
        let humid = String(param["HUMID"] as! Double)
        let weather = param["WEATHER"] as? String ?? ""
        let weight = param["WEIGHT"] as? String ?? ""
        let g_gram = param["G_GRAM"] as? String ?? ""
        let s_gram = param["S_GRAM"] as? String ?? ""
        let status = "unsent"
        let timestamp = Date().toString(format: "yyyyMMddHHmmss")

        //Insert
        let insert_SQL = "" +
            "INSERT INTO " + tbName +
            " (entryDate, workDay, tagNO, syain, kotei, temp, humid, weather, weight, g_gram, s_gram, status, createDate) " +
            "VALUES " +
            "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" +
        ";"

        print(insert_SQL)
        if self.db.executeUpdate(insert_SQL, withArgumentsIn: [
            entryDate, workDay, tag, syain, kotei, temp, humid, weather, weight, g_gram, s_gram,status,timestamp
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
        
    }*/
    
    func selectTB(status:String) -> [SQLObj] {
        //照会
        var arr:[SQLObj] = []
        let SQLSelect = "SELECT * FROM \(tbName) where status = '\(status)';"
//        let SQLSelect = "SELECT * FROM \(tbName);"
        if let results = self.db.executeQuery(SQLSelect, withArgumentsIn: []) {
            while results.next() {
                //print(results.columnCount)
                let obj = SQLObj(id: Int(results.string(forColumn: "id")!)!,
                                 entryDate: results.string(forColumn: "entryDate") ?? "",
                                 workDay: results.string(forColumn: "workDay") ?? "",
                                 tagNO: results.string(forColumn: "tagNO") ?? "",
                                 syain: results.string(forColumn: "syain") ?? "",
                                 kotei: results.string(forColumn: "kotei") ?? "",
                                 temp: results.string(forColumn: "temp") ?? "",
                                 humid: results.string(forColumn: "humid") ?? "",
                                 weather: results.string(forColumn: "weather") ?? "",
                                 weight: results.string(forColumn: "weight") ?? "",
                                 g_gram: results.string(forColumn: "g_gram") ?? "",
                                 s_gram: results.string(forColumn: "s_gram") ?? "",
                                 timeStamp: results.string(forColumn: "createDate") ?? "",
                                 status: results.string(forColumn: "status") ?? "")
                
                if obj.status == status {
                    arr.append(obj)
                }

            }
        }
        
        return arr
        
    }
    
    //レコードを削除
    func deleteData(deleteID:[Int]) {

        var str = "\(deleteID)"
        print(str)
        str = str.replacingOccurrences(of: "[", with: "(")
        str = str.replacingOccurrences(of: "]", with: ")")
        print(str)

        let deleteSQL = "DELETE FROM \(tbName) WHERE id IN \(str);"
        if self.db.executeUpdate(deleteSQL, withArgumentsIn: []) {
            print("\(tbName) Deleted")
        }else{
            print("\(tbName) delete failed")
        }
        
    }
    
    //レコードを削除
    func updateData(column:String, param:String, idList:[Int]) {

        var str = "\(idList)"
        print(str)
        str = str.replacingOccurrences(of: "[", with: "(")
        str = str.replacingOccurrences(of: "]", with: ")")
        print(str)

        //let deleteSQL = " FROM \(tbName) WHERE id IN \(str);"
        let sqlStr = "UPDATE \(tbName) SET \(column) = '\(param)', updateDate = '\(Date().toString(format: "yyyyMMddHHmmss"))' WHERE id IN \(str);"
        if self.db.executeUpdate(sqlStr, withArgumentsIn: []) {
            print("\(tbName) Updated")
        }else{
            print("\(tbName) update failed")
        }
        
    }
    
    //日付の古いデータを削除する
    func removeOldData(){
        let oldDate = (Date()-60*60*24*30).string //30日前の日付を求める
//        let tables:[String] = ["table1", "table2"]
        
        let SQLDelete = "DELETE FROM \(tbName) WHERE entryDate < '\(oldDate)' AND status <> 'unsent';"
        self.db.executeUpdate(SQLDelete, withArgumentsIn: [])
        
    }
    
    
}

