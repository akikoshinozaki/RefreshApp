//
//  ScanData.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/06/15.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import AudioToolbox

class ScanData: NSObject {

    public func readCode(picker: UIImagePickerController, result:String) -> String{
        var tag = ""
        let myLabel:UILabel = UILabel(frame: CGRect(x: 0, y:0, width: picker.view.frame.size.width, height: 80))
        myLabel.textAlignment = .center
        myLabel.textColor = .yellow
        myLabel.font = UIFont.boldSystemFont(ofSize: 20)
        //ラベルが表示されていたら取り除く
        for v in picker.view.subviews {
            if type(of: v) == UILabel.self{
                v.removeFromSuperview()
            }
        }
        picker.view.addSubview(myLabel)
        
        myLabel.isHidden = true

        if Int(result) != nil, result.count == 13 {
            if result.hasPrefix("2300"){
                //バーコードの時
                AudioServicesPlaySystemSound(1106)
                AudioServicesPlaySystemSound(4095) //バイブ(iPhoneのみ)
                tag = String(Array(result)[4...11])
            }else {
                myLabel.isHidden = false
                myLabel.text = "このバーコードは認識できません"
            }
        }else if result.hasPrefix("RF="), result.count > 10 {
            //QRの時
            AudioServicesPlaySystemSound(1106)
            AudioServicesPlaySystemSound(4095) //バイブ(iPhoneのみ)
            tag = String(Array(result)[3...10])
        }else {
            myLabel.isHidden = false
            myLabel.text = "このQRコードは認識できません"
        }
        
        return tag
        
    }
    
    
}
