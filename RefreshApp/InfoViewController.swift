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

protocol InfoViewControllerDelegate{
    func setPrintInfo(json:NSDictionary!, type:String)
}

class InfoViewController: UIViewController, SelectDateViewDelegate {
    
    var delegate:InfoViewControllerDelegate?

    @IBOutlet weak var enrollBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var printBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!

    @IBOutlet weak var yoteiBtn:UIButton!
    @IBOutlet weak var seizouBtn:UIButton!
    
    @IBOutlet var fields: [UITextField]!
    @IBOutlet var btns: [UIButton]!
    @IBOutlet var dspLbls: [UILabel]!
    @IBOutlet weak var enrollLabel: UILabel!
    
    //IBMへ送るパラメーター
    var YOTEI_HI:Date!
    var seizouHI:Date!
    var grd:String = ""
    var g_ritsu:Int!
    var jita_k:Int!
    
    
    var conAlert:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dspInit()
        if _json != nil {
            self.display(json: _json!)
        }
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        
        closeBtn.addTarget(self, action: #selector(closeView), for: .touchUpInside)
    }
    
    func dspInit(){
        //変数クリア
        seizouHI = nil
        YOTEI_HI = nil
        jita_k = nil
        g_ritsu = nil
        grd = ""
        
        //表示クリア
        for lbl in dspLbls {
            lbl.text = ""
        }
        
        for f in fields {
            f.text = ""
            f.delegate = self
        }
        yoteiBtn.setTitle("日付を選択", for: .normal)
        seizouBtn.setTitle("日付を選択", for: .normal)
        
        yoteiBtn.isUserInteractionEnabled = true
        deleteBtn.isHidden = true
        printBtn.isHidden = true
        enrollLabel.isHidden = true
        
    }

    func display(json:NSDictionary){
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))

        var yotei_hi = ""
        if let yotei = json["YOTEI_HI"] as? String, yotei != ""{
            //登録済み → 再印刷or削除
            printBtn.isHidden = false
            deleteBtn.isHidden = false
            enrolled = true
            yotei_hi = yotei.date.short
            YOTEI_HI = yotei.date
            yoteiBtn.setTitle(formatter.string(from: yotei.date), for: .normal)
            enrollBtn.setTitle("更新", for:.normal)
        }else {
            //未登録 → 登録&印刷
            enrolled = false
            //enrollBtn.isHidden = false
            enrollBtn.setTitle("登録", for:.normal)
        }
        enrollLabel.isHidden = !enrolled
        
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

        if printData.nouki != "0/00/00" {
            dspLbls[6].text = printData.nouki
        }
        if printData.kigen != "0/00/00" {
            dspLbls[7].text = printData.kigen
        }
        if let yuuyo = json["YUUYO"] as? String, yuuyo != "0" {
            dspLbls[8].text = yuuyo.trimmingCharacters(in: .whitespaces)
        }
        //自社・他社区分
        if let jita = json["JITA_K"] as? String, jita != " " {
            jita_k = Int(jita) ?? 0
            if jita_k > 0 {
                fields[0].text = arr1[jita_k-1]
            }
        }
        //羽毛グレード
        if let grade = json["GRADE"] as? String, grade != "  " {
            grd = grade
            if let obj = grd_lst.first(where: {$0.cd==grd}) {
                fields[1].text = obj.nm
            }
        }
        //原料比率
        if let ritsu = Double(json["RITSU"] as? String ?? "0.0"), ritsu != 0.0 {
            g_ritsu = Int(ritsu)
            fields[2].text = "\(g_ritsu!)"
        }
                
        if var wata = json["WATA"] as? String, wata != "0.0" {
            wata = wata.trimmingCharacters(in: .whitespaces)
            if let dwata = Double(wata) {
                fields[3].text = "\(dwata)"
            }else {
                fields[3].text = wata
            }
        }
        
        if let seizou = json["SEIZOU"] as? String, seizou != "00000000"{
            seizouHI = seizou.date
            seizouBtn.setTitle(formatter.string(from: seizouHI), for: .normal)
        }
        
        yoteiBtn.isUserInteractionEnabled = !enrolled

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
            print(selectedDate)
        let picker = DatePickerPopover(title: "日時選択")
            .setSelectedDate(selectedDate)
            .setLocale(identifier: "ja_JP")
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
        if sender.tag == 801 {
            if enrolled {return} //登録済みの場合は変更できない
            YOTEI_HI = nil
            self.yoteiBtn.setTitle("日付を選択", for: .normal)
        }else if sender.tag == 802 {
            seizouHI = nil
            self.seizouBtn.setTitle("日付を選択", for: .normal)
            
        }
    }
    
    //MARK: - IBMへ登録
    @IBAction func entryData(_ sender: UIButton){

        /*sender.tag
         901:登録/更新 902:削除
         */
        
        if tagNO == "" {
            SimpleAlert.make(title: "TAG No.が確認できません", message: "")
            return
        }
        var type:String = ""
        var param:[String:Any] =
            ["TAG_NO":tagNO]
        
        var alertTitle:String = ""
        switch sender.tag {
        case 901:
            if enrolled { //更新
                type = "UPDATE"
                alertTitle = "更新してよろしいですか"
            }else { //登録
                type = "ENTRY"
                if YOTEI_HI == nil {
                    SimpleAlert.make(title: "日付が未入力です", message: "")
                    return
                }
                alertTitle = "登録してよろしいですか"
                param["YOTEI_HI"] = YOTEI_HI.toString(format: "yyyyMMdd")
            }
            
            if fields[0].text != "" {
                //自社・他社区分
                param["JITA_K"] = String(jita_k)
            }
            if fields[1].text != "" {
                //グレード
                param["GRADE"] = grd
            }
            if fields[2].text != "" {
                //比率
                param["RITSU"] = String(g_ritsu)
            }
            if fields[3].text != "" {
                param["WATA"] = fields[3].text!
            }else {
                param["WATA"] = "0.0"
            }
            if seizouHI != nil {
                param["SEIZOU"] = seizouHI.toString(format: "yyyyMMdd")
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
    

    @IBAction func labelPrint(_ sender: Any) {
        print(enrolled)
        if enrolled {
            self.dismiss(animated: true, completion: {
                self.delegate?.setPrintInfo(json: _json, type: "print")
            })
        }else {
            SimpleAlert.make(title: "未登録です", message: "")
        }
        
    }
    
    @objc func closeView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func request(type:String, param:[String:Any]) {
        self.dspInit()
        print(param)
        DispatchQueue.main.async {
            self.conAlert = UIAlertController(title: "データ取得中", message: "しばらくお待ちください", preferredStyle: .alert)
            self.present(self.conAlert, animated: true, completion: nil)
        }
        
        IBM().IBMRequest(type: type, parameter: param, completionClosure: {(_,json,err) in
//            var kanri = ""
            if err == nil, json != nil {
                //print(json!)
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

                    DispatchQueue.main.async {
                        
                        if type == "DELETE" {
                            self.conAlert.title = "削除完了"
                            self.conAlert.message = ""
                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                printData = nil
                                _json = nil
                                self.dismiss(animated: true, completion: {
                                    self.delegate?.setPrintInfo(json: _json, type: "delete")
                                })
                            }))
                            
                        }else if type == "ENTRY" {
                            enrolled = true
                            self.conAlert.title = "登録成功"
                            self.conAlert.message = "正常に登録できました"
                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                //print(_json)
                                _json = json
                                self.labelPrint(self)
                                
                            }))

                        }else if type == "UPDATE" {
                            enrolled = true
                            self.conAlert.title = "更新成功"
                            self.conAlert.message = "正常に更新できました"
                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                _json = json
                                self.closeView()
                            }))

                        }
                         
                    }
                }
                
            }else {
                //print(err!.localizedDescription)
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
    let arr1 = ["1:自社","2:他社"]
    
    func showPicker(_ textField:UITextField) {
        //print(textField.tag)
        
        var array:[String] = []
        let intArr:[Int] = ([Int])(70...95)
        var popTitle = ""
        var row:Int = 0
        if textField.tag == 301 {
            //自社・他社
            array = arr1
            popTitle = "自社・他社区分"
            if jita_k != nil {
                row = jita_k-1
            }
        }else if textField.tag == 302 {
            //グレード
            array = grd_lst.map({$0.nm})
            popTitle = "原料グレード"
            print(grd)
            if grd != "" {
                row = grd_lst.firstIndex(where: {$0.cd==grd}) ?? 0
            }
        }else if textField.tag == 303 {
            //原料比率
            array = intArr.map({String($0)})
            popTitle = "原料比率"
            row = intArr.firstIndex(where: {$0==g_ritsu}) ?? 0
        }
        let font = UIFont(name: "HelveticaNeue",size: 17.0)!
        let picker = StringPickerPopover(title: popTitle, choices: array)
            .setFont(font)
            .setDoneButton(action: {
                (_, idx, item) in
                
                textField.text = item
                if textField.tag == 301 {
                    self.jita_k = idx+1
                }else if textField.tag == 302 {
                    self.grd = grd_lst[idx].cd
                    print(grd_lst[idx])
                    let rField = self.view.viewWithTag(303) as! UITextField
                    if self.grd == "99"{
                        //???の時
                        self.view.viewWithTag(302)
                        rField.text = "---"
                        self.g_ritsu = 0
                        rField.isUserInteractionEnabled = false
                    }else {
                        rField.isUserInteractionEnabled = true
                    }

                }else if textField.tag == 303 {
                    self.g_ritsu = intArr[idx]
                }
            })
            .setSelectedRow(row)
            .setCancelButton(action: { _,_,_ in print("キャンセル") })
        picker.appear(originView: textField, baseViewController: self)

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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 301...303:
            self.showPicker(textField)
            
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.tag)
        if textField.text! == "" {return}
        
        
        switch textField.tag {
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
            
        
        case 401: //わた量
            
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
