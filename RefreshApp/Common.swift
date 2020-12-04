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
    
}
