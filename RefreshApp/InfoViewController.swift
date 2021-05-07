//
//  InfoViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/02/11.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//
//　問い合わせ画面内で情報表示する

import UIKit
import SwiftyPickerPopover

//受け取るパラメーター
var printData:PrintData!
var isBLXexist:Bool = false
var enrolled:Bool = false
var _json:Dictionary<String,Any>!

protocol InfoViewControllerDelegate{
    func setPrintInfo(json:Dictionary<String,Any>!, type:String)
    func setEntry(param:[String:Any])
}

class InfoViewController: UIViewController, SelectDateViewDelegate {
    
    var delegate:InfoViewControllerDelegate?

    @IBOutlet weak var enrollBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var printBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
/* */
    @IBOutlet weak var yoteiBtn:UIButton!
    @IBOutlet weak var seizouBtn:UIButton!
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var keiyakuLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var syohinLabel: UILabel!
    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var nohinLabel: UILabel!
    @IBOutlet weak var kigenLabel: UILabel!
    @IBOutlet weak var yuuyoLabel: UILabel!
    
    @IBOutlet weak var grd1Field: UITextField!
    @IBOutlet weak var grd2Field: UITextField!
    @IBOutlet weak var jita1Field: UITextField!
    @IBOutlet weak var ritsu1Field: UITextField!
    @IBOutlet weak var jita2Field: UITextField!
    @IBOutlet weak var ritsu2Field: UITextField!
    @IBOutlet weak var juryoField: UITextField!
    @IBOutlet weak var zogenField: UITextField!
/* */
    
    @IBOutlet var fields: [UITextField]!
    @IBOutlet var btns: [UIButton]!
    @IBOutlet var dspLbls: [UILabel]!
    @IBOutlet weak var enrollLabel: UILabel!
    @IBOutlet weak var yusenSwitch: UISwitch!
    @IBOutlet weak var uploadedLabel: UILabel!
    
    //IBMへ送るパラメーター
    var YOTEI_HI:Date!
    var seizouHI:Date!
    var jitak1:Int!
    var grd1:String = ""
    var ritsu1:Int!
    var jitak2:Int!
    var grd2:String = ""
    var ritsu2:Int!
    var juryo:Double!
    var zogen:Int!

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
        //uploadedLabel.isHidden = !isImgUploaded
        uploadedLabel.isHidden = true
        closeBtn.addTarget(self, action: #selector(closeView), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
        //uploadedLabel.isHidden = !isImgUploaded
    }
    
    func dspInit(){
        //変数クリア
        seizouHI = nil
        YOTEI_HI = nil
        jitak1 = nil
        grd1 = ""
        ritsu1 = nil
        jitak2 = nil
        ritsu2 = nil
        grd2 = ""
        juryo = nil
        zogen = nil
        
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

    func display(json:Dictionary<String,Any>){
        
        //enrolled :新規登録 -> true
        //isBLXexist :BLKに登録済-> true
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))

        var yotei_hi = ""
        if let yotei = json["YOTEI_HI"] as? String, yotei != ""{
            //予定日がある-> 登録済み（enrolledで２回目表示した場合もある）
            yotei_hi = yotei.date.short
            YOTEI_HI = yotei.date
            yoteiBtn.setTitle(formatter.string(from: yotei.date), for: .normal)
            
            if enrolled {
                //未登録 → 登録&印刷
                isBLXexist = false
                enrollBtn.setTitle("完了", for:.normal)
            }else {
                //登録済み → 再印刷or削除
                printBtn.isHidden = false
                deleteBtn.isHidden = false
                
                isBLXexist = true
                enrollBtn.setTitle("更新", for:.normal)
            }
            
            
        }else { //予定日がなかった場合
            if let yotei2 =  defaults.object(forKey: "yoteiHI") as? String {
                print(yotei2)
                yotei_hi = yotei2.date.short
                YOTEI_HI = yotei2.date
                yoteiBtn.setTitle(formatter.string(from: yotei2.date), for: .normal)
            }
            //未登録 → 登録&印刷
            isBLXexist = false
            enrolled = true
            //enrollBtn.isHidden = false
            enrollBtn.setTitle("登録", for:.normal)
        }
        enrollLabel.isHidden = !isBLXexist
        
        printData = PrintData(date: yotei_hi,
                                   renban: json["RENBAN"] as? String ?? "",
                                   customer: json["CUSTOMER_NM"] as? String ?? "",
                                   tagNO: json["TAG_NO"] as? String ?? "",
                                   itemCD: json["SYOHIN_CD"] as? String ?? "",
                                   itemNM: json["SYOHIN_NM"] as? String ?? "",
                                   nouki: json["NOUKI"] as? String ?? "",
                                   kigen: json["KIGEN"] as? String ?? "",
                                   grade1: json["GRADE1"] as? String ?? "",
                                   ritsu1: json["RITSU1"] as? String ?? "0.0",
                                   jita1: json["JITAK1"] as? String ?? "",
                                   grade2: json["GRADE2"] as? String ?? "",
                                   ritsu2: json["RITSU2"] as? String ?? "0.0",
                                   jita2: json["JITAK2"] as? String ?? "")

        tagLabel.text = printData.tagNO
        syohinLabel.text = printData.itemCD+": "+printData.itemNM
        patternLabel.text = json["PATERN"] as? String ?? ""
        classLabel.text = json["CLASS"] as? String ?? ""
        keiyakuLabel.text = json["KEI_NO"] as? String ?? ""
        if printData.customer != "" {
            customerLabel.text = printData.customer+" 様"
        }

        if printData.nouki != "0/00/00" {
            nohinLabel.text = printData.nouki
        }
        if printData.kigen != "0/00/00" {
            kigenLabel.text = printData.kigen
        }
        if let yuuyo = json["YUUYO"] as? String, yuuyo != "0" {
            yuuyoLabel.text = yuuyo.trimmingCharacters(in: .whitespaces)
        }
        
        //自社・他社区分1
        if let jita1 = json["JITAK1"] as? String, jita1 != "" {
            jitak1 = Int(jita1) ?? 0
            if jitak1 > 0 {
                let obj = jitaArray[jitak1-1]
                jita1Field.text = obj.cd+":"+obj.nm
            }
        }
        //羽毛グレード1
        if let grd = json["GRADE1"] as? String, grd != "  " {
            grd1 = grd
            if let obj = grd_lst.first(where: {$0.cd==grd}) {
                grd1Field.text = obj.nm
            }
        }
        
        //原料比率1
        if let rit1 = Double(json["RITSU1"] as? String ?? "0.0"), rit1 != 0.0 {
            ritsu1 = Int(rit1)
            ritsu1Field.text = "\(ritsu1!)"
        }
        //自社・他社区分2
	        if let jita2 = json["JITAK2"] as? String, jita2 != "" {
            jitak2 = Int(jita2) ?? 0
            if jitak2 > 0 {
                let obj = jitaArray[jitak2-1]
                jita2Field.text = obj.cd+":"+obj.nm

            }
        }
        //羽毛グレード2
        if let grd = json["GRADE2"] as? String, grd != "  " {
            grd2 = grd
            if let obj = grd_lst.first(where: {$0.cd==grd}) {
                grd2Field.text = obj.nm
            }
        }
        //原料比率2
        if let rit2 = Double(json["RITSU2"] as? String ?? "0.0"), rit2 != 0.0 {
            ritsu2 = Int(rit2)
            ritsu2Field.text = "\(ritsu2!)"
        }
        
        if grd1 == "99"{
            //グレード???の時比率は入力できなくする
            self.ritsu1 = 0
            self.ritsu1Field.text = ""
            self.ritsu1Field.isUserInteractionEnabled = false
        }else {
            self.ritsu1Field.isUserInteractionEnabled = true
        }
        
        if grd2 == "99"{
            //グレード???の時比率は入力できなくする
            self.ritsu2 = 0
            self.ritsu2Field.text = ""
            self.ritsu2Field.isUserInteractionEnabled = false
        }else {
            self.ritsu2Field.isUserInteractionEnabled = true
        }
                
        if var wata = json["WATA"] as? String, wata != "0.0" {
            wata = wata.trimmingCharacters(in: .whitespaces)
            if let dwata = Double(wata) {
                juryoField.text = "\(dwata)"
            }else {
                juryoField.text = wata
            }
        }
        
        if let zgn = json["ZOGEN"] as? String, zgn != "0" {
            zogenField.text = zgn
        }else {
            zogenField.text = "なし"
        }
        
        if let seizou = json["SEIZOU"] as? String, seizou != "00000000" {
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.dateFormat = "yyyyMMdd"
            if let d = df.date(from: seizou) {
                seizouHI = d
                let yy = Calendar.current.component(.year, from: seizouHI)
                let mm = Calendar.current.component(.month, from: seizouHI)
                seizouBtn.setTitle("\(yy)年\(mm)月", for: .normal)
            }
        }
        //優先
        yusenSwitch.isOn = json["YUSEN"] as? String == "1"

    }

    //MARK: - 日付ピッカー
    @IBAction func selectDate(_ sender: UIButton) {
        let kongetu = Calendar.current.component(.month, from: Date())
        
        //print(sender.title(for: .normal) as! String)
        var selectedDate:Date = Date()
        if sender.tag == 400 { //工場管理日
            selectedDate = YOTEI_HI ?? Date()
            
            if #available(iOS 14.0, *) {
                // iOS14以降の場合
                dateTag = sender.tag
                let pickerView = SelectDateView(frame: self.view.frame)
                pickerView.center = self.view.center
                pickerView.delegate = self
                pickerView.selectedDate = selectedDate
                pickerView.picker.minimumDate = Date()-365*24*3600
                pickerView.picker.maximumDate = Date()+2*365*24*3600
                self.view.addSubview(pickerView)
                            
            } else {
                // iOS14以前の場合
                print(selectedDate)
            let picker = DatePickerPopover(title: "日時選択")
                .setSelectedDate(selectedDate)
                .setMinimumDate(Date()-365*24*3600)
                .setMaximumDate(Date()+2*365*24*3600)
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
                        if !isBLXexist {
                            print("保存")
                            print(selectedDate.string2)
                            defaults.setValue(selectedDate.string2, forKey: "yoteiHI")
                        }
//                    }else if sender.tag == 401 {
//                        self.seizouHI = selectedDate
                        
                    }
                    sender.setTitle(formatter.string(from: selectedDate), for: .normal)
                    
                    print(formatter.string(from: selectedDate))
                } )
                .setCancelButton(action: { _, _ in print("キャンセル")})
                picker.appear(originView: sender, baseViewController: self)
            }
        }else if sender.tag == 401 { //製造年月日
            selectedDate = seizouHI ?? Date()
            
            //print(selectedDate)
            var seizoSelected:[Int] = [0,0]
            var yearArr:[String] = [] //yyyy年
            var montArr:[String] = [] //MM月

            let kotoshi:Int = Calendar.current.component(.year, from: Date())
            var arr1:[Int] = []
            let arr2:[Int] = Array(1...12)
            
            arr1 = Array(kotoshi-30...kotoshi-5)
            yearArr = arr1.map({String($0)+"年"})
            montArr = arr2.map({String($0)+"月"})

            seizoSelected[0] = arr1.firstIndex(of: kotoshi-5) ?? 0
            seizoSelected[1] = arr2.firstIndex(of: kongetu) ?? 0
     
            //@objc func selectMonth2(_ sender: UITextField) {
            let font = UIFont.init(name: "HelveticaNeue", size: 20.0)
            let picker = ColumnStringPickerPopover(title: "選択してください", choices: [yearArr,montArr], selectedRows: seizoSelected, columnPercents: [0.5,0.5])
                .setFonts([font,font])
                .setDoneButton(action: {
                    (popover, selectedRows, selectedStrings) in

                    print(selectedRows)
                    print(arr1[selectedRows[0]])
                    print(arr2[selectedRows[1]])
                    
                    let yy = String(arr1[selectedRows[0]])
                    var mm = arr2[selectedRows[1]]
                    var date:Date!
                    
                    if mm != 12 {
                        //翌月の1日を指定して1日引く（月末日を求める）...12月以外
                        mm += 1
                        if mm < 10 {
                            date = (yy+"0\(mm)01").date
                        }else {
                            date = (yy+"\(mm)01").date
                        }

                        self.seizouHI = date-24*3600
                    }else {
                        //12月を選択した場合
                        self.seizouHI = (yy+"1231").date
                        
                    }
//                    print(self.seizouHI!)
//                    print(self.seizouHI.string2)
                    
                    let text = selectedStrings[0]+selectedStrings[1]
                    sender.setTitle(text, for: .normal)
                })
                .setCancelButton(action: { _, _, _ in print("キャンセル")})
            
            picker.appear(originView: sender, baseViewController: self)
        
        }
        

    }
    
    func setDate(date: Date) {//日付ピッカーを選択した時のデリゲート
        //print(date)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        if dateTag == 400 { //工場管理日
            self.YOTEI_HI = date
            self.yoteiBtn.setTitle(formatter.string(from: date), for: .normal)
            if !isBLXexist {
                print("保存")
                print(YOTEI_HI.string2)
                defaults.setValue(YOTEI_HI.string2, forKey: "yoteiHI")
            }
//        }else if dateTag == 401 { //製造年月日では使わなくなりました
//            self.seizouHI = date
//            self.seizouBtn.setTitle(formatter.string(from: date), for: .normal)
        }
    }
    
    @IBAction func clearGRD(_ sender: UIButton) {
        if sender.tag == 301 { //1枚目クリア
            jitak1 = nil
            grd1 = ""
            ritsu1 = nil
            
            jita1Field.text = ""
            grd1Field.text = ""
            ritsu1Field.text = ""
            
            printData.jita1 = ""
            printData.grade1 = ""
            printData.ritsu1 = "0.0"
            
            
        }else if sender.tag == 302 { //2枚目クリア
            jitak2 = nil
            ritsu2 = nil
            grd2 = ""
            
            jita2Field.text = ""
            grd2Field.text = ""
            ritsu2Field.text = ""
            
            printData.jita2 = ""
            printData.grade2 = ""
            printData.ritsu2 = "0.0"
        }
        
    }
    
        
    @IBAction func clearDate(_ sender: UIButton){
        if sender.tag == 801 {
            if isBLXexist {return} //登録済みの場合は変更できない
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
        var param:[String:Any] = ["TAG_NO":tagNO]
        
        var alertTitle:String = ""
        switch sender.tag {
        case 901:
            if isBLXexist { //更新
                type = "UPDATE"
                alertTitle = "更新してよろしいですか"
            }else { //登録
                type = "ENTRY"
                if YOTEI_HI == nil {
                    SimpleAlert.make(title: "日付が未入力です", message: "")
                    return
                }
                alertTitle = "登録してよろしいですか"
                param["YOTEI_HI"] = YOTEI_HI.string2
                _json["YOTEI_HI"] = YOTEI_HI.string2
            }
            
            //自社・他社区分
            var j1 = ""
            if jitak1 != nil {
                j1 = String(jitak1)
            }
            param["JITAK1"] = j1
            _json["JITAK1"] = j1
            printData.jita1 = j1
            
            //グレード
            param["GRADE1"] = grd1
            _json["GRADE1"] = grd1
            printData.grade1 = grd1
            
            //比率
            var r1 = "0"
            if ritsu1 != nil {
                //比率
                r1 = String(ritsu1)
            }
            param["RITSU1"] = r1
            _json["RITSU1"] = r1
            printData.ritsu1 = r1

            //自社・他社区分
            var j2 = ""
            if jitak2 != nil {
                j2 = String(jitak2)
            }
            param["JITAK2"] = j2
            _json["JITAK2"] = j2
            printData.jita2 = j2
            
            //グレード
            param["GRADE2"] = grd2
            _json["GRADE2"] = grd2
            printData.grade2 = grd2
            
            //比率
            var r2 = "0"
            if ritsu2 != nil {
                r2 = String(ritsu2)
            }

            param["RITSU2"] = r2
            _json["RITSU2"] = r2
            printData.ritsu2 = r2
            
            if juryoField.text != "" {
                if juryoField.text == "不明" {
                    param["WATA"] = "0"
                    _json["WATA"] = "0"
                }else {
                    param["WATA"] = juryoField.text!
                    _json["WATA"] = juryoField.text!
                }
            }
            
            if zogenField.text != "" {
                if zogenField.text == "なし" {
                    param["ZOGEN"] = "0"
                    _json["ZOGEN"] = "0"
                }else {
                    param["ZOGEN"] = zogenField.text!
                    _json["ZOGEN"] = zogenField.text!
                }
            }
            
            if seizouHI != nil {
                param["SEIZOU"] = seizouHI.string2
                _json["SEIZOU"] = seizouHI.string2
            }
            
            if yusenSwitch.isOn {
                param["YUSEN"] = "1"
                _json["YUSEN"] = "1"
            }else {
                param["YUSEN"] = ""
                _json["YUSEN"] = ""
            }
            
        case 902:
            type = "DELETE"
            alertTitle = "削除してよろしいですか"

        default:
            return
        }

        print(param)
        
        if type == "ENTRY" {
            print(param)
            //print(_json)
            self.dismiss(animated: true, completion: {
                self.delegate?.setEntry(param: param)
            })
            
        }else {
            let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                self.request(type: type, param: param)
            }))
            
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    

    @IBAction func labelPrint(_ sender: Any) {
        print(isBLXexist)
        if isBLXexist {
            self.dismiss(animated: true, completion: {
                self.delegate?.setPrintInfo(json: _json, type: "print")
            })
        }else {
            SimpleAlert.make(title: "未登録です", message: "")
        }
        
    }
    
    @objc func closeView(){
        self.dismiss(animated: true, completion: {
            //self.delegate?.setPrintInfo(json: _json, type: "close")
        })
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
                            
//                        }else if type == "ENTRY" {
//                            isBLXexist = true
//                            self.conAlert.title = "登録成功"
//                            self.conAlert.message = "正常に登録できました"
//                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
//                                Void in
//                                //print(_json)
//                                _json = json
//                                self.labelPrint(self)
//
//                            }))

                        }else if type == "UPDATE" {
                            isBLXexist = true
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
    
    func showPicker(_ textField:UITextField) {
        //print(textField.tag)
        
        var array:[String] = []
//        var intArr:[Int] = ([Int])(70...95)+[50,98,99,100]
//        intArr = intArr.sorted(by: {$0>$1})
        var popTitle = ""
        var row:Int = 0
        
        switch textField.tag {
        case 301, 304: //自社・他社区分
            //自社・他社
            array = jitaArray.map({($0.cd+":"+$0.nm)})
            popTitle = "自社・他社区分"
            var jitak:Int!
            if textField.tag == 301 {
                jitak = jitak1
            }else {
                jitak = jitak2
            }
            if jitak != nil {
                row = jitak-1
            }
        case 302, 305: //羽毛グレード
            //グレード
            array = grd_lst.map({$0.nm})
            popTitle = "原料グレード"
            var grd = ""
            if textField.tag == 302 {
                grd = grd1
            }else {
                grd = grd2
            }
            if grd != "" {
                row = grd_lst.firstIndex(where: {$0.cd==grd}) ?? 0
            }
        case 303, 306: //原料比率
            //原料比率
            array = hiritsuArr.map({String($0)})
            popTitle = "原料比率"
            var ritsu:Int!
            if textField.tag == 303 {
                ritsu = ritsu1
            }else {
                ritsu = ritsu2
            }
            let d = hiritsuArr.firstIndex(where: {$0==90}) //デフォルトは90
            row = hiritsuArr.firstIndex(where: {$0==ritsu}) ?? d!
            
        case 401://仕上り重量
            let arr:[Int] = ([Int])(7...21)
            array = arr.map({String(format: "%.1f",Double($0)*0.1)})
            array.insert("不明", at: 0)
            popTitle = "仕上り重量"
            row = array.firstIndex(where: {$0==textField.text!}) ?? 0
        case 402://足し羽毛
            let arr:[Int] = ([Int])(-5...5)
            array = arr.map({String($0*100)})
            let zero = arr.firstIndex(where: {$0==0})
            array[zero!]="なし"
            popTitle = "羽毛増減"
            let d = array.firstIndex(where: {$0=="100"}) //デフォルトは100?
            row = array.firstIndex(where: {$0==textField.text!}) ?? d!
        default:
            return
        }
        
        let font = UIFont(name: "HelveticaNeue",size: 17.0)!
        let picker = StringPickerPopover(title: popTitle, choices: array)
            .setFont(font)
            .setDoneButton(action: {
                (_, idx, item) in
                
                textField.text = item
                
                if textField.tag == 302 {
                    self.grd1 = grd_lst[idx].cd

                    if self.grd1 == "99"{
                        //グレード???の時比率は入力できなくする
                        //self.grd1Field.text = "---"
                        self.ritsu1 = 0
                        self.ritsu1Field.text = ""
                        self.ritsu1Field.isUserInteractionEnabled = false
                    }else {
                        self.ritsu1Field.isUserInteractionEnabled = true
                    }
                }else if textField.tag == 305 {
                    self.grd2 = grd_lst[idx].cd

                    if self.grd2 == "99"{
                        //グレード???の時比率は入力できなくする
                        //self.grd2Field.text = "---"
                        self.ritsu2 = 0
                        self.ritsu2Field.text = ""
                        self.ritsu2Field.isUserInteractionEnabled = false
                    }else {
                        self.ritsu2Field.isUserInteractionEnabled = true
                    }
                }else if textField.tag == 301 {
                    self.jitak1 = idx+1
                    //self.jitak1 = Int(jitaArray[idx].cd)
                }else if textField.tag == 303 {
                    self.ritsu1 = hiritsuArr[idx]
                }else if textField.tag == 304 {
                    self.jitak2 = idx+1
                    //self.jitak2 = Int(jitaArray[idx].cd)
                }else if textField.tag == 306 {
                    self.ritsu2 = hiritsuArr[idx]
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
        case 300...402:
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
        /*
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
            }*/
            
        
        case 401, 402: //わた量・増減
            
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
