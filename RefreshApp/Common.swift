//
//  Common.swift
//  RefreshApp
//
//  Created by administrator on 2020/11/10.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

extension Date {
    func toString(format:String) -> String{
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(identifier: "Asia/Tokyo")
        df.dateFormat = format
        return df.string(from: self)
    }

    var string: String {
        return toString(format: "yyyy-MM-dd")
    }
    
    var short:String {
        return toString(format: "MM/dd")
    }
    
    var string2: String {
        return toString(format: "yyyyMMdd")
    }
    
}

extension String {
    func toDate(format:String) -> Date?{
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(identifier: "Asia/Tokyo")
        df.dateFormat = format
        return df.date(from: self)
    }
    
    var date: Date {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyyMMdd"
        return df.date(from: self)!
    }
}

typealias CompletionClosure = ((_ resultString:String?,_ resultJson:NSDictionary?, _ err:Error?) -> Void)

//共通のパラメーター
var iPadName:String = ""
var idfv:String = ""
var pingResponse:Bool = true
var IBMResponse:Bool!

var appVersion = ""
var isHostConnected:Bool = false

let defaults = UserDefaults.standard

//#if DEV
//let hostURL = "https://maru8ibm.maruhachi.co.jp:4343/HTP2/WAH001CL.PGM?" //開発
//#else
//let hostURL = "https://maru8ibm.maruhachi.co.jp/HTP2/WAH001CL.PGM?"
//#endif
var devMode:Bool = false
let m2URL = "https://maru8ibm.maruhachi.co.jp:4343/HTP2/WAH001CL.PGM?" //開発
let m8URL = "https://maru8ibm.maruhachi.co.jp/HTP2/WAH001CL.PGM?" //本番
var hostURL = m8URL
