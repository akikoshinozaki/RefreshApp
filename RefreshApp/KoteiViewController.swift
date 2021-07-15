//
//  KoteiViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/05/27.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import SwiftyPickerPopover
import ZBarSDK

class KoteiViewController: UIViewController {
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var kanriLabel: UILabel!
    @IBOutlet weak var koteiBtn: UIButton!
    @IBOutlet weak var entryBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var syainField: UITextField!
    @IBOutlet weak var syainLabel: UILabel!
    @IBOutlet weak var workField: UITextField!
    @IBOutlet weak var tempField: UITextField!
    @IBOutlet weak var humidField: UITextField!
    @IBOutlet weak var weatherField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var tareField: UITextField!
    
    //@IBOutlet weak var weight2Field: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var kg_gLabel: UILabel!
    @IBOutlet weak var tonyuView: UIView!
    @IBOutlet weak var finishLabel: UILabel!
    @IBOutlet weak var gawaImgBtn: UIButton!
    @IBOutlet weak var yakanLabel: UILabel!
    @IBOutlet weak var dbBtn: UIButton!
    
    var kotei:String! //"04:ばらし"
    var weather:String = ""
    var _tagNO:String = ""
    var _syainCD:String = ""
    var _syainNM:String = ""
    var temperature:Double!
    var humidity:Double!
    var weight:Double!
    var workDay:Date!
    var tareWeight:Double = 0.2
    var gWeight:Int = 0 //側重量
    var aWeight:Int = 0 //総重量
    var tWeight:Int = 0 //投入量
    var fWeight:Double = 0 //仕上がり重量
    
    var maxrow:Int = 0//工程選択ピッカー用
    var _koteiList:[(key:String,val:String, flag:Bool)] = []
    var gawaImg:[UIImage] = []
    var syoCD:String = ""
    
    /*--- inquiryVCからコピー ---START---*/
    //@IBOutlet weak var yoteiLabel:UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoCollection: UICollectionView!
    var conAlert:UIAlertController!
    //let conAlert = UIAlertController(title: "登録中", message: "", preferredStyle: .alert)
    var keiyakuNO = ""
    var detail:DetailView!
    var detail2:DetailView2!
    /*--- inquiryVCからコピー ---END---*/
    @IBOutlet weak var infoView2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dspInit()
        scanBtn.addTarget(self, action: #selector(scan), for: .touchUpInside)
        koteiBtn.addTarget(self, action: #selector(selectKotei(_:)), for: .touchUpInside)
        entryBtn.layer.cornerRadius = 8
        clearBtn.layer.cornerRadius = 8
        _koteiList = koteiList.filter({$0.flag==true})
        
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        setDefaultValue()
        self.yakanSwitch()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        print(#function)
//        self.yakanSwitch()
//    }
    
    @IBAction func pushLocalDB(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        let recept = storyboard.instantiateViewController(withIdentifier: "local")
        self.navigationController?.pushViewController(recept, animated: true)
    }
    
    func yakanSwitch() {
        let time = Calendar.current.component(.hour, from: Date())
        yakan = !(workTime.contains(time))
        yakanLabel.isHidden = !yakan
        
        if yakan != defaults.bool(forKey: "yakanMode") {
            if yakan {
                SimpleAlert.make(title: "夜間モード切り替え", message: "")
            }else {
                SimpleAlert.make(title: "夜間モード終了", message: "")
            }
        }
        defaults.set(yakan, forKey: "yakanMode")
    }
    
    func setDefaultValue() {
        //ユーザーデフォルトの値をセット
        workField.text = workDay.toString(format: "yyyy年MM月dd日")
        //社員
        if let cd = defaults.string(forKey: "syainCD"){
            _syainCD = cd
            syainField.text = _syainCD
            if let nm = defaults.string(forKey: "syainNM"){
                _syainNM = nm
                syainLabel.text = _syainNM
            }else {
                //社員cdがあって、名前がなかったら問い合わせ？
            }
        }
        //天気
        if let key = defaults.string(forKey: "weather"){
            weather = key
            let val = weatherList.first(where: {$0.key == key})?.val ?? ""
            weatherField.text = key+":"+val
        }
        //気温
        temperature = defaults.double(forKey: "temperature")
        if temperature > 0 {
            tempField.text = String(temperature)
        }
        //湿度
        humidity = defaults.double(forKey: "humidity")
        if humidity > 0 {
            humidField.text = String(humidity)
        }
        //風袋(04:ばらし・05:洗浄の時)
        if kotei == "04" || kotei == "05" {
            tareWeight = defaults.double(forKey: "tareWeight")
            if tareWeight == 0 {
                tareWeight = 0.2
            }
            tareField.text = String(Int(tareWeight*1000)) //グラムに直す
        }
        
    }
    
    func dspInit(){
        tagLabel.text = ""
        kanriLabel.text = ""
        infoView.isHidden = true
        infoView2.isHidden = true
        kotei = "" //"04:ばらし"
        koteiBtn.setTitle("", for: .normal)
        //koteiBtn.isEnabled = false
        koteiBtn.isHidden = true
        entryBtn.isEnabled = false
        
        _tagNO = ""
        weight = 0
        workDay = Date()
        
        for field in textFields {
            field.delegate = self
            field.text = ""
        }
        syainLabel.text = ""
        setDefaultValue()
    }
    
    func request(type:String, param:[String:Any]) {
        self.dspInit()
        DispatchQueue.main.async {
            self.conAlert = UIAlertController(title: "データ取得中", message: "しばらくお待ちください", preferredStyle: .alert)
            self.present(self.conAlert, animated: true, completion: nil)
        }
        
        IBM().IBMRequest(type: type, parameter: param, completionClosure: {(_,json,err) in
            //print("IBMRequest")
            _json = nil
            
            if err == nil, json != nil {
                _json = json
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
                    //INQURY
                    DispatchQueue.main.async {
                        //INQURY
                        self.conAlert.dismiss(animated: true, completion: {
                            self.display(json: json!, selected: false)
                        })
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
    
    func yakanDisplay(tagNo:String) {
        self.dspInit()
        _tagNO = tagNo
        print(_tagNO)
        kanriLabel.text = ""
        keiyakuNO = ""
        //登録済み → 再印刷or削除
        //                infoView.isHidden = false
        infoView2.isHidden = false
        
        //keiyakuView.isHidden = false
        infoView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.6
        infoView.layer.shadowRadius = 4
        
        tagLabel.text = _tagNO
        
        //工程を確認
        koteiBtn.isEnabled = true
        koteiBtn.isHidden = false
        entryBtn.isEnabled = true
        if let str = defaults.string(forKey: "yakan_kotei"),
           let ko = _koteiList.first(where: {$0.key==str}) {
            print(str)
            print(ko)
            kotei = ko.key
            koteiBtn.setTitle(ko.val, for: .normal)
        }else {
            print("no defaults")
            //保存済みの工程がなければ、バラシから
            kotei = "04"
            koteiBtn.setTitle("ばらし", for: .normal)
            defaults.setValue(kotei, forKey: "yakan_kotei")
        }
        print(kotei)
        if kotei == "06" { //投入
            tonyuView.isHidden = false
            titleLabel.text = "側重量"
            title2Label.text = "総重量"
            kg_gLabel.text = "g"
            tareField.text = "" //風袋の重さ消す
            
        }else { //ばらし・洗浄
            tonyuView.isHidden = true
            titleLabel.text = "重量(風袋込み)"
            title2Label.text = "風袋"
            kg_gLabel.text = "Kg"
            //風袋の重さをセット
            tareWeight = defaults.double(forKey: "tareWeight")
            if tareWeight == 0 {
                tareWeight = 0.2
            }
            tareField.text = String(Int(tareWeight*1000)) //グラムに直す
        }
        /*
         if !selected {
         maxrow = _koteiList.firstIndex(where: {$0.key==kotei}) ?? 0 //工程選択ピッカーの数
         self.infoCollection.reloadData()
         }*/
    }
    
    func pickerAppear(_ textField: UITextField) {
        //datepicker表示
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(_ sender:UIDatePicker) {
        workDay = sender.date
        workField.text = sender.date.toString(format: "yyyy年MM月dd日")
    }
    
    
    @objc func selectKotei(_ sender:UIButton) {
        print(maxrow)//ばらししか選択できない時はピッカー出さない
        print(koteiList)
        print(_koteiList)
        if yakan {//夜間はノーチェックでピッカー表示
            maxrow = _koteiList.count-1
        }
        if maxrow == 0 {return}
        var array:[String] = []
        var popTitle = ""
        var row:Int = 0
        popTitle = "工程選択"
        row = _koteiList.firstIndex(where: {$0.key==kotei}) ?? 0
        array = _koteiList[0...maxrow].map({($0.key+":"+$0.val)})
        
        let font = UIFont(name: "HelveticaNeue",size: 17.0)!
        let picker = StringPickerPopover(title: popTitle, choices: array)
            .setFont(font)
            .setDoneButton(action: {
                (_, idx, item) in
                
                sender.setTitle(self._koteiList[idx].val, for: .normal)
                self.kotei = self._koteiList[idx].key
                if yakan {
                    defaults.setValue(self.kotei, forKey: "yakan_kotei")
                    self.yakanDisplay(tagNo: self._tagNO)
                }else if _json != nil {
                    self.display(json: _json, selected: true)
                }
                
            })
            .setSelectedRow(row)
            .setCancelButton(action: { _,_,_ in print("キャンセル") })
        picker.appear(originView: sender, baseViewController: self)
        
    }
    
    func selectWeather(_ textField:UITextField) {
        
        var array:[String] = []
        var popTitle = ""
        var row:Int = 0
        
        array = weatherList.map({($0.key+":"+$0.val)})
        popTitle = "天気"
        row = weatherList.firstIndex(where: {$0.key==weather}) ?? 0
        
        let font = UIFont(name: "HelveticaNeue",size: 17.0)!
        let picker = StringPickerPopover(title: popTitle, choices: array)
            .setFont(font)
            .setDoneButton(action: {
                (_, idx, item) in
                
                textField.text = item
                self.weather = weatherList[idx].key
                defaults.setValue(self.weather, forKey: "weather")
                
            })
            .setSelectedRow(row)
            .setCancelButton(action: { _,_,_ in print("キャンセル") })
        picker.appear(originView: textField, baseViewController: self)
        
    }
    
    @IBAction func entry(_ sender: UIButton) {
        sender.isEnabled = false
        conAlert = UIAlertController(title: "登録中", message: "", preferredStyle: .alert)
        self.view.endEditing(true)
        var errStr:[String] = []
        //ブランクチェック
        if kotei == "" {
            errStr.append("工程を選択してください")
        }
        if _tagNO == "" {
            errStr.append("TAGを読み込んでください")
        }
        if _syainCD == "" {
            errStr.append("作業者を入力してください")
        }
        if weatherField.text == "" {
            errStr.append("天気を選択してください")
        }
        if humidField.text == "" {
            errStr.append("湿度を入力してください")
        }
        if tempField.text == "" {
            errStr.append("気温を入力してください")
        }
        if weightField.text == "" {
            errStr.append("重量を入力してください")
        }
        
        if tareField.text == "" {
            if kotei == "06" {
                errStr.append("側重量を入力してください")
            }else {
                errStr.append("風袋の重量を入力してください")
            }
        }
        
        if kotei == "06", !yakan {
            if fWeight>0, abs(Int(fWeight)-tWeight) <= 20 {
            }else {
                errStr.append("仕上り重量と投入量が違います")
            }
        }
        
        if errStr.count > 0 { //未入力があったら登録しない
            //SimpleAlert.make(title: "エラー", message: errStr.joined(separator: "\n"))
            let alert = UIAlertController(title: "エラー",
                                          message: errStr.joined(separator: "\n"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                sender.isEnabled = true
            }))
            self.present(alert, animated: true, completion: nil)
        }else { //-----登録-------
            var param:[String:Any] = [:]
            param["TAG_NO"] = _tagNO
            param["SYAIN"] = _syainCD
            param["KOTEI"] = kotei
            param["DATE"] = workDay.string2
            param["TEMP"] = temperature
            param["HUMID"] = humidity
            
            param["WEATHER"] = weather
            
            if kotei == "06" {
                param["G_GRAM"] = String(gWeight) //側重量(g)
                param["S_GRAM"] = String(aWeight) //総重量(g)
                
                let w = Double(tWeight)/1000
                print(w)
                param["WEIGHT"] = String(floor((w)*100)/100)
            }else {
                //浮動小数点数の誤差対応
                let w = floor((weight-tareWeight)*100)/100
                param["WEIGHT"] = String(w)
            }
            
            print(param)
            self.present(conAlert, animated: true, completion: nil)
            if yakan{
                self.dbEntry(param: param)

            }else {
                self.ibmEntry(param: param)
            }
        }
        
    }
    
    
    func ibmEntry(param:[String:Any]){//IBMへ登録
        IBM().IBMRequest(type: "HBR031", parameter: param, completionClosure: { [self](_,json,err) in
            //print("IBMRequest")
            if err == nil, json != nil {
                //print(json!)
                if json!["RTNCD"] as! String != "000" { //IBMエラー
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
                        self.conAlert.title = "登録成功"
                        self.conAlert.message = "正常に登録できました"
                        self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                            Void in
                            self.entryBtn.isEnabled = false //二重登録禁止
                            
                        }))
                    }
                }
                
            }else {
                if errMsg == "" {
                    errMsg = "登録に失敗しました"
                }
                DispatchQueue.main.async {
                    self.conAlert.title = "エラー"
                    self.conAlert.message = errMsg
                    self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                }
            }
            print("isUserInteractionEnabled")
            DispatchQueue.main.async {
                self.entryBtn.isEnabled = true
            }
            
        })
    }
    func dbEntry(param:[String:Any]) {//夜間対応・DB登録
        
        if localDB.insert(param: param) {
            //登録成功
            DispatchQueue.main.async {
                self.conAlert.title = "登録成功"
                self.conAlert.message = "正常に登録できました"
                self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    self.entryBtn.isEnabled = false //二重登録禁止
                    
                }))
            }
        }else {
            //登録失敗
            DispatchQueue.main.async {
                self.conAlert.title = "エラー"
                self.conAlert.message = "msg"
                self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.entryBtn.isEnabled = true
            }
        }
        
    }
    
    @IBAction func clearData(_ sender: UIButton) {
        
        if entryBtn.isEnabled {
            let alert = UIAlertController(title: "データをクリアしてよろしいですか？", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                self.dspInit()
            }))
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else {
            self.dspInit()
        }
        
    }
    
    @objc func back() {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func syainCheck(cd:String) {
        _syainCD = ""
        _syainNM = ""
        syainLabel.text = ""
        
        IBM().search(param: "syain", cd: cd, completionClosure: {
            (str, json,err) in
            if err == nil, json != nil {
                //                print(json!)
                var jsonErr:Bool = true
                if json!["RTNCD"] as! String == "000" {
                    self._syainCD = json!["SYAIN_CD"] as? String ?? ""
                    self._syainNM = json!["SYAIN_NM"] as? String ?? ""
                    defaults.set(self._syainCD, forKey: "syainCD")
                    defaults.set(self._syainNM, forKey: "syainNM")
                    jsonErr = false
                }else {
                    let errMSG = json!["RTNMSG"] as! [String]
                    var err = ""
                    for e in errMSG {
                        err += e+"\n"
                    }
                    SimpleAlert.make(title: "エラー", message: err)
                    return
                }
                
                DispatchQueue.main.async {
                    self.syainLabel.text = self._syainNM
                    self.syainField.text = self._syainCD
                    if jsonErr {
                        SimpleAlert.make(title: "エラー", message: "社員CDが存在しません")
                    }
                }
                
            }else {
                SimpleAlert.make(title: "エラー", message: err?.localizedDescription)
            }
        })
    }
    
}

extension KoteiViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print(#function)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //print(#function)
        var isBeginEditing:Bool = true
        switch textField {
        case workField:
            //print("作業日")
            self.pickerAppear(textField)
        //        case tempField:
        //            print("気温")
        //        case humidField:
        //            print("湿度")
        case weatherField:
            //print("天気")
            self.selectWeather(textField)
            isBeginEditing = false
        //        case weightField:
        //            print("重量")
        //        case tareField:
        //            print("風袋")
        
        default:
            break
        }
        
        return isBeginEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //print(#function)
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print(#function)
        if textField.text == "" {return}
        
        let str = textField.text!
        switch textField {
        case tagField:
            if Int(textField.text!) == nil {
                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
                return
            }
            if textField.text?.count != 8 {
                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
                return
            }
            
            
            _tagNO = textField.text!
            setTag()
            
        case workField:
            print("作業日")
        case syainField: //社員CD
            if Int(str) != nil, str.count == 5 {
                if yakan {
                    syainLabel.text = ""
                    _syainCD = str
                    defaults.set(str, forKey: "syainCD")
                    defaults.set("", forKey: "syainNM")
                }else {
                    syainCheck(cd: str)
                }
            }else {
                SimpleAlert.make(title: "不正な値です", message: "")
                _syainCD = ""
                _syainNM = ""
                textField.text = ""
                syainField.text = ""
                return
            }
        case tempField: //気温
            if let temp = Double(str), temp < 60, temp > -20 {
                temperature = floor(temp*10)/10 //小数点２位以下は切り捨てる
                textField.text = String(temperature)
                defaults.set(temperature, forKey: "temperature")
                
            }else {
                SimpleAlert.make(title: "不正な値です", message: "")
                temperature = 0
                textField.text = ""
                return
            }
            
        case humidField: //湿度
            if let humid = Double(str), humid<100, humid>0 {
                humidity = floor(humid*10)/10 //小数点２位以下は切り捨てる
                textField.text = String(humidity)
                defaults.set(humidity, forKey: "humidity")
            }else {
                SimpleAlert.make(title: "不正な値です", message: "")
                humidity = 0
                textField.text = ""
                return
            }
            
        case weightField: //重量
            if kotei == "06" {
                if let g = Int(str), str.count <= 4 { //最大桁数4桁
                    gWeight = Int(g)
                }else {
                    SimpleAlert.make(title: "不正な値です", message: "")
                    weight = 0
                    textField.text = ""
                    return
                }
            }else {
                if let wei = Double(str), wei > tareWeight { //少なくとも風袋よりは大きく
                    weight = floor(wei*100)/100 //小数点3位以下は切り捨てる
                    textField.text = String(weight)
                }else {
                    SimpleAlert.make(title: "不正な値です", message: "")
                    weight = 0
                    textField.text = ""
                    return
                }
            }
            
        case tareField: //風袋
            if kotei == "06" {
                if let t = Int(str), str.count <= 4{ //最大桁数4桁
                    aWeight = Int(t)
                }else {
                    SimpleAlert.make(title: "不正な値です", message: "")
                    return
                }
            }else {
                if let tare = Double(str) ,tare > 0 {
                    tareWeight = floor(tare)/1000
                    //print(tareWeight)
                    textField.text = String(Int(tare))
                    defaults.set(tareWeight, forKey: "tareWeight")
                }else {
                    SimpleAlert.make(title: "不正な値です", message: "")
                    tareWeight = 0.2
                    textField.text = "200"
                    return
                }
            }
            
        default:
            break
        }
        
        if kotei == "06", weightField.text != "", tareField.text != "" {
            if aWeight < gWeight {
                //側重量の方が大きかったらエラー
                SimpleAlert.make(title: "入力エラー", message: "総重量は側重量より大きい値を入力してください")
                return
            }else {
                tWeight = aWeight-gWeight
                title3Label.text = String(tWeight)
                if !yakan {
                    if fWeight>0, abs(Int(fWeight)-tWeight) <= 20 {
                        //仕上り重量と投入量、±20g
                        title3Label.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    }else {
                        title3Label.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
                    }
                }
            }
        }
    }
    
}

//MARK: - ZBar Delegate
extension KoteiViewController: ZBarReaderDelegate{
    
    @objc func scan(_ sender: UIButton){
        //ZBarReaderViewControllerのオブジェクトを生成
        let reader = ZBarReaderViewController()
        reader.readerDelegate = self
        reader.cameraFlashMode = .off
        
        let scanner:ZBarImageScanner = reader.scanner
        scanner.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
        reader.isModalInPresentation = false //下スワイプで閉じないように
        self.present(reader, animated: true, completion: nil)
        
        //        reader.showsZBarControls = false
        reader.showsCameraControls = false
        
    }
    
    //バーコードを読み取った後の処理(ZBar)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var symbol : ZBarSymbol? = nil
        if let symbolset = info[UIImagePickerController.InfoKey(rawValue: "ZBarReaderControllerResults")] as? ZBarSymbolSet {
            var iterator = NSFastEnumerationIterator(symbolset)
            
            while let value = iterator.next() {
                if let sym = value as? ZBarSymbol {
                    symbol = sym
                    break
                }
            }
        }
        
        if symbol == nil {
            return
        }
        let resultString = symbol!.data as String
        //        print(resultString)
        if symbol!.typeName! == "EAN-13" || symbol!.typeName! == "QR-Code" {
            let tag = ScanData().readCode(picker:picker, result: resultString)
            if tag != "" {
                _tagNO = tag
                picker.dismiss(animated: true, completion: {
                    self.setTag()
                })
            }
            
        }
    }
    
    func setTag(){
        self.yakanSwitch()
        if _tagNO == "" {
            tagLabel.text = "TagNo.未入力"
            tagLabel.textColor = .gray
            tagField.text = ""
        }else {
            tagLabel.text = _tagNO
            tagLabel.textColor = .black
            if yakan {
                yakanDisplay(tagNo: _tagNO)
            }else {
                self.request(type: "INQUIRY", param: ["TAG_NO":_tagNO])
            }
        }
    }
    
    //アップロード済みの画像取得
    func getImages(parm:String,val:String) {
        
        var json:Dictionary<String,Any>!
        let path = "https://oktss03.xsrv.jp/refreshPhoto/refresh1.php"
        let url = URL(string: path)!
        //let param = "tagNo=\(tagNo)
        let param = parm+"="+val
        print(param)
        let config = URLSessionConfiguration.default
        //config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = param.data(using: .utf8)
        // 通信のタスクを生成.
        let task = session.dataTask(with:request, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    //戻ってきたデータを解析
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String,Any>
                        print(json!)
                        let arr = json["images"] as? [String] ?? []
                        print(arr)
                        DispatchQueue.main.async {
                            self.imgDL(arr:arr, tag:val, syu:parm)
                        }
                        
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
            
        })
        
        // タスクの実行.
        task.resume()
        
    }
    
    func imgDL(arr:[String], tag:String, syu:String) {
        var iArr:[UIImage] = []
        DispatchQueue.global().async {
            for file in arr {
                //画像をダウンロードして配列に保存
                let str = "https://ipad:m8mawata@oktss03.xsrv.jp/refreshPhoto/\(file)"
                let encodeStr = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let url = URL(string: encodeStr)!
                
                //print(url)
                do{
                    let imageData = try Data(contentsOf: url)
                    let img = UIImage(data:imageData)
                    
                    iArr.append(img!)
                    
                }catch {
                    //エラー
                    print("imageファイルにアクセスできない")
                }
            }
            
            
            DispatchQueue.main.async {
                if syu == "tagNo" {
//                    self.tagImg = iArr
//                    if arr.count > 0 {
//                        self.photoView.isHidden = false
//                        self.imgCollection.reloadData()
//                    }
                    
                }else {  //syoCD
                    self.gawaImg = iArr
                    if self.gawaImg.count > 0 {//リンクボタン青くする
                        self.gawaImgBtn.isEnabled = true
                        self.gawaImgBtn.setTitleColor(.systemBlue, for: .normal)
                        
                        let itemNM = _json["SYOHIN_NM"] as? String ?? ""
                        self.gawaImgBtn.setTitle("側生地画像 "+self.syoCD+": "+itemNM, for: .normal)
                        self.gawaImgBtn.addTarget(self, action: #selector(self.gawaLink(_:)), for: .touchUpInside)
                    }
                }
            }
        }
        //imgAlert.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func gawaLink(_ sender: Any) {
        if gawaImg.count > 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let gawaVC = storyboard.instantiateViewController(withIdentifier: "gawa") as! GawaImgViewController
            gawaVC.isModalInPresentation = true
            
            gawaVC.arr = gawaImg
            gawaVC.syoCD = self.syoCD
            self.present(gawaVC, animated: true, completion: nil)
        }else {
            
        }
        
    }
    
}

extension KoteiViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print(#function)
        let size = collectionView.frame.size
        return size
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        //        let cellSize = cell.frame.size
        //        print(cellSize)
        if indexPath.row == 0 { //1ページ目
            detail2 = DetailView2(frame: CGRect(origin: .zero, size: cell.frame.size), json: _json)
            detail2.nextBtn.tag = 901
            detail2.nextBtn.addTarget(self, action: #selector(pageChange), for: .touchUpInside)
            detail2.backBtn.isHidden = true
            cell.contentView.addSubview(detail2)
            
        } else {
            //2ページ目
            detail = DetailView(frame: CGRect(origin: .zero, size: cell.frame.size), json: _json)
            detail.nextBtn.isHidden = true
            detail.backBtn.tag = 902
            detail.backBtn.addTarget(self, action: #selector(pageChange), for: .touchUpInside)
            for lbl in detail.labels{ //初期化
                lbl.text = ""
            }
            cell.contentView.addSubview(detail)
            
        }
        return cell
    }
    
    func display(json:Dictionary<String,Any>, selected:Bool){
        //        keiMeisai = []
        kanriLabel.text = ""
        keiyakuNO = ""
        _tagNO = json["TAG_NO"] as? String ?? ""
        var kanri = ""
        syoCD = ""
        
        infoCollection.delegate = self
        infoCollection.dataSource = self
        infoCollection.isPagingEnabled = true
        
        if let yotei = json["YOTEI_HI"] as? String, yotei != ""{
            //登録済み → 再印刷or削除
            infoView.isHidden = false
            infoView2.isHidden = false
            
            //keiyakuView.isHidden = false
            infoView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            infoView.layer.shadowColor = UIColor.black.cgColor
            infoView.layer.shadowOpacity = 0.6
            infoView.layer.shadowRadius = 4
            
            //            infoView2.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            //            infoView2.layer.shadowColor = UIColor.black.cgColor
            //            infoView2.layer.shadowOpacity = 0.6
            //            infoView2.layer.shadowRadius = 4
            
            //管理No.
            let renban = json["RENBAN"] as? String ?? ""
            kanri = yotei+"-"+renban
            kanriLabel.text = kanri
            
            //仕上り重量
            if var wata = json["WATA"] as? String, wata != "0.0" {
                wata = wata.trimmingCharacters(in: .whitespaces)
                if let dwata = Double(wata) {
                    fWeight = dwata*1000 //グラムに直す
                    self.finishLabel.text = "仕上り重量 : "+wata+"Kg"
                    //self.juryoLabel.text = "\(dwata)"
                }else {
                    fWeight = 0
                    self.finishLabel.text = ""
                    //self.juryoLabel.text = wata
                }
            }
            //品番・品名
            guard var cd = json["SYOHIN_CD"] as? String else {
                gawaImgBtn.setTitle("", for: .normal)
                gawaImgBtn.isEnabled = false
                return
            }
            
            syoCD = cd
            if cd.count<=8 { //ファイル名・8桁に揃える
                let zero = String(repeating: "0", count: 8-cd.count)
                cd = zero+cd
            }
            self.getImages(parm: "syoCD", val: cd)
            
        }else {
            //未登録 → 登録&印刷
            SimpleAlert.make(title: "登録なし", message: "リフレッシュ受付がされていません")
            return
        }
        
        tagLabel.text = _tagNO
        
        //工程を確認
        //        koteiBtn.isEnabled = true
        koteiBtn.isHidden = false
        entryBtn.isEnabled = true
        if let arr = json["KOTEI_LST"] as? [Dictionary<String,Any>], arr.count>0 {
            
            var koteiArr = arr.map({$0["KOTEI"] as? String ?? ""})
            koteiArr.sort()
            print(koteiArr.last!)
            let ko = koteiArr.last! //既に登録済みの工程
            var idx = Int(_koteiList.firstIndex(where: {$0.key==ko}) ?? 0)
            print(idx)
            if idx < _koteiList.count-1 {
                idx += 1
            }
            if !selected { //ピッカーから選択されていなければ、自動でセット
                kotei = _koteiList[idx].key
                koteiBtn.setTitle(_koteiList[idx].val, for: .normal)
            }
            
        }else {
            //工程履歴がなければ、バラシから
            kotei = "04"
            koteiBtn.setTitle("ばらし", for: .normal)
        }
        print(kotei)
        
        if kotei == "06" { //投入
            tonyuView.isHidden = false
            titleLabel.text = "側重量"
            title2Label.text = "総重量"
            kg_gLabel.text = "g"
            tareField.text = "" //風袋の重さ消す
            
        }else { //ばらし・洗浄
            tonyuView.isHidden = true
            titleLabel.text = "重量(風袋込み)"
            title2Label.text = "風袋"
            kg_gLabel.text = "Kg"
            //風袋の重さをセット
            tareWeight = defaults.double(forKey: "tareWeight")
            if tareWeight == 0 {
                tareWeight = 0.2
            }
            tareField.text = String(Int(tareWeight*1000)) //グラムに直す
        }
        
        if !selected {
            maxrow = _koteiList.firstIndex(where: {$0.key==kotei}) ?? 0 //工程選択ピッカーの数
            self.infoCollection.reloadData()
        }
        //infoCollectionを１ページ目にセット
        self.infoCollection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
    
    @objc func pageChange(_ sender:UIButton){
        //print(sender.tag)
        var indexPath:IndexPath!
        if sender.tag == 901 {
            indexPath = IndexPath(item: 1, section: 0)
        }else{
            indexPath = IndexPath(item: 0, section: 0)
        }
        infoCollection.isPagingEnabled = false
        infoCollection.scrollToItem(at: indexPath, at: .left, animated: true)
        infoCollection.isPagingEnabled = true
    }
    
    
}
