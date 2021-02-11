//
//  InfoViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/02/11.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

//受け取るパラメーター
var printData:PrintData!
var enrolled:Bool = false
var _json:NSDictionary!

class InfoViewController: UIViewController, SelectDateViewDelegate {
    
    @IBOutlet weak var kanriLabel: UILabel!

    @IBOutlet weak var enrollBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var printBtn: UIButton!

    @IBOutlet weak var yoteiBtn:UIButton!
    @IBOutlet weak var seizouBtn:UIButton!
    
    @IBOutlet var fields: [UITextField]!
    @IBOutlet var btns: [UIButton]!
    @IBOutlet var dspLbls: [UILabel]!
    
    //IBMへ送るパラメーター
    var YOTEI_HI:Date!
    var seizouHI:Date!
    
    var conAlert:UIAlertController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.display(json: _json!)
    }
    
    func dspInit(){
        //変数クリア
//        printData = nil
//        YOTEI_HI = nil
//        seizouHI = nil
//        enrolled = false
        //表示クリア
        for lbl in dspLbls {
            lbl.text = ""
        }
        kanriLabel.text = ""
        
        for (i,f) in fields.enumerated() {
            f.text = ""
            f.tag = 300 + i
            f.delegate = self
        }
        yoteiBtn.setTitle("日付を選択", for: .normal)
        seizouBtn.setTitle("日付を選択", for: .normal)
        
        for f in fields {
            f.isUserInteractionEnabled = true
        }
        seizouBtn.isUserInteractionEnabled = true
        enrollBtn.isHidden = true
        deleteBtn.isHidden = true
        printBtn.isHidden = true
        
    }


    //MARK: - 日付ピッカー
    @IBAction func selectDate(_ sender: UIButton) {
        //print(sender.title(for: .normal) as! String)
        var selectedDate:Date = Date()
        if sender.tag == 400 { //工場管理日
            selectedDate = YOTEI_HI ?? Date()
        }else if sender.tag == 401 { //製造年月日
            selectedDate = seizouHI ?? Date()
        }
        
        dateTag = 0
        if #available(iOS 14.0, *) {
            // iOS14以降の場合
            dateTag = sender.tag
            let pickerView = SelectDateView(frame: self.view.frame)
            pickerView.center = self.view.center
            pickerView.delegate = self
            pickerView.selectedDate = selectedDate
            self.view.addSubview(pickerView)
                        
        } else {
            // iOS14以前の場合
        let picker = DatePickerPopover(title: "日時選択")
            .setSelectedDate(selectedDate)
            .setLocale(identifier: "ja_JP")
            .setSelectedDate(Date())
            //.setMinimumDate(Date())
            .setValueChange(action: { _, selectedDate in
                //print("current date \(selectedDate)")
            })
            .setDoneButton(action: { popover, selectedDate in
                print("selectedDate \(selectedDate)")
                let formatter = DateFormatter()
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
                //選択された日付をボタンタイトルへセット
                if sender.tag == 400 {
                    self.YOTEI_HI = selectedDate
                }else if sender.tag == 401 {
                    self.seizouHI = selectedDate
                }
                sender.setTitle(formatter.string(from: selectedDate), for: .normal)
                print(formatter.string(from: selectedDate))
            } )
            .setCancelButton(action: { _, _ in print("キャンセル")})
        picker.appear(originView: sender, baseViewController: self)
        }

    }
    
    func setDate(date: Date) {
        //print(date)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        if dateTag == 400 { //工場管理日
            self.YOTEI_HI = date
            self.yoteiBtn.setTitle(formatter.string(from: date), for: .normal)
        }else if dateTag == 401 { //製造年月日
            self.seizouHI = date
            self.seizouBtn.setTitle(formatter.string(from: date), for: .normal)
        }
    }
        
    @IBAction func clearDate(_ sender: UIButton){
        YOTEI_HI = nil
        self.yoteiBtn.setTitle("日付を選択", for: .normal)
    }
    
    //MARK: - IBMへ登録
    @IBAction func entryData(_ sender: UIButton){

        /*sender.tag
         901:登録 902:削除
         */
        
        if tagNO == "" {
            SimpleAlert.make(title: "TAG No.が未入力です", message: "")
            return
        }
        var type:String = ""
        var param:[String:Any] =
            ["TAG_NO":tagNO]
        
        var alertTitle:String = ""
        switch sender.tag {
        case 901:
            type = "ENTRY"
            if YOTEI_HI == nil {
                SimpleAlert.make(title: "日付が未入力です", message: "")
                return
            }
            alertTitle = "登録してよろしいですか"
            param["YOTEI_HI"] = YOTEI_HI.toString(format: "yyyyMMdd")
            if fields[0].text != "" {
                param["GRADE"] = fields[0].text!
            }
            if fields[1].text != "" {
                param["WATA"] = fields[1].text!
            }
            if seizouHI != nil {
                param["SEIZOU"] = YOTEI_HI.toString(format: "yyyyMMdd")
            }
            
        case 902:
            type = "DELETE"
            alertTitle = "削除してよろしいですか"

        default:
            return
        }

        //print(param)
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            self.request(type: type, param: param)
        }))
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }

    func display(json:NSDictionary){
        if printData == nil {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))

        var yotei_hi = ""
        if let yotei = json["YOTEI_HI"] as? String, yotei != ""{
            //登録済み → 再印刷or削除
            printBtn.isHidden = false
            deleteBtn.isHidden = false
            enrolled = true
            yotei_hi = yotei.date.short
            yoteiBtn.setTitle(formatter.string(from: yotei.date), for: .normal)
            kanriLabel.text = yotei+"-"+printData.renban+"-"+printData.tagNO
        }else {
            //未登録 → 登録&印刷
            enrolled = false
            enrollBtn.isHidden = false
            printBtn.isHidden = false
        }
        
        printData = PrintData(date: yotei_hi,
                                   renban: json["RENBAN"] as? String ?? "",
                                   customer: json["CUSTOMER_NM"] as? String ?? "",
                                   tagNO: json["TAG_NO"] as? String ?? "",
                                   itemCD: json["SYOHIN_CD"] as? String ?? "",
                                   itemNM: json["SYOHIN_NM"] as? String ?? "",
                                   nouki: json["NOUKI"] as? String ?? "",
                                   kigen: json["KIGEN"] as? String ?? "")
        
        dspLbls[0].text = printData.tagNO
        dspLbls[1].text = printData.itemCD+": "+printData.itemNM
        dspLbls[2].text = json["PATERN"] as? String ?? ""
        dspLbls[3].text = json["CLASS"] as? String ?? ""
        dspLbls[4].text = json["KEI_NO"] as? String ?? ""
        if printData.customer != "" {
            dspLbls[5].text = printData.customer+" 様"
        }
        dspLbls[6].text = printData.nouki
        dspLbls[7].text = printData.kigen
        dspLbls[8].text = json["YUUYO"] as? String ?? ""
        
        if enrolled {
            fields[0].text = json["GRADE"] as? String ?? ""
            if let wata = json["WATA"] as? String, wata != "00000" {
                fields[1].text = wata
            }
            
            if let seizou = json["SEIZOU"] as? String, seizou != "00000000"{
                seizouBtn.setTitle(formatter.string(from: seizou.date), for: .normal)
            }
            
        }
        
        for f in fields {
            f.isUserInteractionEnabled = !enrolled
        }
        seizouBtn.isUserInteractionEnabled = !enrolled
        
        /*
        let lbl = BRLabelView()
        // シールのPrintView
        let QR = "RF="+tagNO
        
        lbl.label1.text = printData.date+"-"+printData.renban
        lbl.label2.text = printData.customer+" 様"
        lbl.label3.text = printData.tagNO
        lbl.label4.text = printData.itemCD
        lbl.label5.text = printData.itemNM
        let nouki = Array(printData.nouki)
        if nouki.count==8 {
            print(nouki.prefix(4))
            lbl.label6.text = nouki[0...3]+"-"+nouki[4...5]+"-"+nouki[6...7]
        }else {
            lbl.label6.text = printData.nouki
        }
        let kigen = Array(printData.kigen)
        if kigen.count==8 {
            lbl.label6.text = kigen[0...3]+"-"+kigen[4...5]+"-"+kigen[6...7]
        }else {
            lbl.label6.text = printData.kigen
        }
        
        lbl.qrView.image = UIImage.makeQR(code: QR)
        
        if isConnectPrinter {
            self.printLabel()
        }else {
            SimpleAlert.make(title: "プリンターに接続してください", message: "")
        }*/

    }
    
    func request(type:String, param:[String:Any]) {
        self.dspInit()
        print(param)
        DispatchQueue.main.async {
            self.conAlert = UIAlertController(title: "データ取得中", message: "しばらくお待ちください", preferredStyle: .alert)
            self.present(self.conAlert, animated: true, completion: nil)
        }
        
        IBM().IBMRequest(type: type, parameter: param, completionClosure: {(_,json,err) in
            var kanri = ""
            if err == nil, json != nil {
                print(json!)
                //print(json!["CUSTOMER_NM"] as? String ?? "")
                if json!["RTNCD"] as! String != "000" {
                    var msg = ""
                    for m in json!["RTNMSG"] as? [String] ?? [] {
                        msg += m+"\n"
                    }
                    DispatchQueue.main.async {
                        self.conAlert.title = "エラー"
                        self.conAlert.message = msg
                        self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    }

                    
                }else {
                    var yotei_hi = ""
                    if let yotei = json!["YOTEI_HI"] as? String, yotei != ""{
                        yotei_hi = yotei.date.short
                        kanri = yotei
                    }
                    
                    printData = PrintData(date: yotei_hi,
                                               renban: json!["RENBAN"] as? String ?? "",
                                               customer: json!["CUSTOMER_NM"] as? String ?? "",
                                               tagNO: json!["TAG_NO"] as? String ?? "",
                                               itemCD: json!["SYOHIN_CD"] as? String ?? "",
                                               itemNM: json!["SYOHIN_NM"] as? String ?? "",
                                               nouki: json!["NOUKI"] as? String ?? "",
                                               kigen: json!["KIGEN"] as? String ?? "")
                    kanri += "-"+printData.renban+"-"+printData.tagNO
                    
                    DispatchQueue.main.async {
                        
                        if type == "DELETE" {
                            self.conAlert.title = "削除完了"
                            self.conAlert.message = "前ページに戻ります"
                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                self.navigationController?.popViewController(animated: true)
                                printData = nil
                            }))
                            
                        }else  if type == "ENTRY" {
                            self.conAlert.title = "登録成功"
                            self.conAlert.message = "正常に登録できました"
                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                self.dspInit()
                                self.kanriLabel.text = kanri
                                
                            }))
                            
//                        }else { //INQURY
//                            self.conAlert.dismiss(animated: true, completion: nil)
//                            self.display(json:json!)
                        }
                         
                    }
                }
                
            }else {
                print(err!)
                if errMsg == "" {
                    errMsg = "データ取得に失敗しました"
                }
                DispatchQueue.main.async {
                    self.conAlert.title = "エラー"
                    self.conAlert.message = errMsg
                    self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                
            }
            
        })
        
    }

}
extension InfoViewController:UITextFieldDelegate {
/*
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print(#function)
        print(textField.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(#function)
        print(textField.text!)
    }*/
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.tag)
        if textField.text! == "" {return}
        
        switch textField.tag {
//        case 100://tag Fieldの時
//            if Int(tagField.text!) == nil {
//                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
//                return
//            }
//            if tagField.text?.count != 8 {
//                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
//                return
//            }
//            tagNO = textField.text!
//            setTag()
//            
        case 300: //羽毛グレード
            //英数文字のみ

            if textField.text!.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil {
                SimpleAlert.make(title: "英数文字で入力してください", message: "")
                return
            }else if textField.text!.count > 2 {
                SimpleAlert.make(title: "2文字で入力してください", message: "")
                return
            }else {
                textField.text = textField.text!.uppercased()
            }
            
        
        case 301: //わた量
            
            if let wata = Double(textField.text!) {
                let wata10 = wata*10
                
                let fraction = wata10.truncatingRemainder(dividingBy: 1)
                
                print(wata10)
                //print(wata10.count)
                print(fraction)
                
                if fraction != 0.0 {
                    SimpleAlert.make(title: "小数点以下は１桁までです", message: "")
                    return
                }
                if wata10 > 99999 {
                    SimpleAlert.make(title: "桁数が大きすぎます", message: "")
                    return
                }
                
            }else {
                SimpleAlert.make(title: "数字でのみ入力できます", message: "")
                return
            }
            
            
            
        default:
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
}
