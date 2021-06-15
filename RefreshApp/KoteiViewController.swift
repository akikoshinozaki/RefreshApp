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

var weatherList:[(key:String,val:String)] = []
var koteiList:[(key:String,val:String, flag:Bool)] = []


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
    var maxrow:Int = 0//工程選択ピッカー用
    var _koteiList:[(key:String,val:String, flag:Bool)] = []
    
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
        setDefaultValue()
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
        //風袋
        tareWeight = defaults.double(forKey: "tareWeight")
        if tareWeight == 0 {
            tareWeight = 0.2
        }
        tareField.text = String(Int(tareWeight*1000)) //グラムに直す
        
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
                            self.display(json: json!)
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
        sender.isUserInteractionEnabled = false
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
        
        if errStr.count > 0 { //未入力があったら登録しない
            SimpleAlert.make(title: "未入力の項目があります", message: errStr.joined(separator: "\n"))
            sender.isUserInteractionEnabled = true
        }else { //-----登録-------
            var param:[String:Any] = [:]
            param["TAG_NO"] = _tagNO
            param["SYAIN"] = _syainCD
            param["KOTEI"] = kotei
            param["DATE"] = workDay.string2
            param["TEMP"] = temperature
            param["HUMID"] = humidity
            //浮動小数点数の誤差対応
            let w = floor((weight-tareWeight)*100)/100
            param["WEIGHT"] = String(w)
            param["WEATHER"] = weather
            
            print(param)
            self.present(conAlert, animated: true, completion: nil)
            IBM().IBMRequest(type: "HBR031", parameter: param, completionClosure: { [self](_,json,err) in
                print("IBMRequest")
                DispatchQueue.main.async {
                    sender.isEnabled = true
                }
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
                                sender.isEnabled = false //二重登録禁止
                                //print(_json)
                                //self.dspInit() //表示クリア
                                
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
                    sender.isUserInteractionEnabled = true
                }
                
            })
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
                syainCheck(cd: str)
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
            if let wei = Double(str), wei > tareWeight { //少なくとも風袋よりは大きく
                weight = floor(wei*100)/100 //小数点3位以下は切り捨てる
                textField.text = String(weight)
            }else {
                SimpleAlert.make(title: "不正な値です", message: "")
                weight = 0
                textField.text = ""
                return
            }

        case tareField: //風袋
            if let tare = Double(str) ,tare > 0 {
                tareWeight = floor(tare)/1000
//                print(tareWeight)
                textField.text = String(Int(tare))
                defaults.set(tareWeight, forKey: "tareWeight")
            }else {
                SimpleAlert.make(title: "不正な値です", message: "")
                tareWeight = 0.2
                textField.text = "200"
                return
            }

        default:
            break
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
                setTag()
                picker.dismiss(animated: true, completion: nil)
            }
                        
        }
    }
    
    func setTag(){
        if _tagNO == "" {
            tagLabel.text = "TagNo.未入力"
            tagLabel.textColor = .gray
            tagField.text = ""
        }else {
            tagLabel.text = _tagNO
            tagLabel.textColor = .black

            self.request(type: "INQUIRY", param: ["TAG_NO":_tagNO])

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
    
    func display(json:Dictionary<String,Any>){
//        keiMeisai = []
        kanriLabel.text = ""
        keiyakuNO = ""
        _tagNO = json["TAG_NO"] as? String ?? ""
        var kanri = ""
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
            
            let renban = json["RENBAN"] as? String ?? ""
            kanri = yotei+"-"+renban
            
            kanriLabel.text = kanri
            
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
            kotei = _koteiList[idx].key
            koteiBtn.setTitle(_koteiList[idx].val, for: .normal)

        }else {
            //工程履歴がなければ、バラシから
            kotei = "04"
            koteiBtn.setTitle("ばらし", for: .normal)
        }
        
        maxrow = _koteiList.firstIndex(where: {$0.key==kotei}) ?? 0
        self.infoCollection.reloadData()
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
