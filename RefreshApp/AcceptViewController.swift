//
//  AcceptViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/01/22.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import SwiftyPickerPopover


class AcceptViewController: UIViewController, BRSelectDeviceTableViewControllerDelegate, SelectDateViewDelegate {

    var selectedDeviceInfo : BRPtouchDeviceInfo?
    @IBOutlet weak var printerConnectLabel: UILabel!
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var qrView: UIImageView!
    var prtSerial = ""
    var prtName = ""
    var deviceListByMfi : [BRPtouchDeviceInfo]?
    //let defaults = UserDefaults.standard
    var isConnectPrinter = false
    var conAlert:UIAlertController!
    var setting:PrinterSetting!
    
    @IBOutlet weak var printerConnectBtn:UIButton!
    @IBOutlet weak var tagLabel:UILabel!
    @IBOutlet weak var yoteiBtn:UIButton!
    @IBOutlet weak var paperBtn: UIButton!
    
    @IBOutlet var btns: [UIButton]!
    
    let paperSizeArray:[(String,BRLMQLPrintSettingsLabelSize)] = [("ロール紙62mm赤黒",.rollW62RB),("ロール紙62mm",.rollW62)]
    //IBMへ送るパラメーター
    var YOTEI_HI:Date!
    //受け取るパラメーター
    var printData:PrintData!
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.BRDeviceDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.BRDeviceDidDisconnect, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let selectDeviceTableViewController = BRSelectDeviceTableViewController()
        selectDeviceTableViewController.delegate = self
        
        // Do any additional setup after loading the view.
        tagLabel.text = tagNO
        printerConnectBtn.addTarget(self, action: #selector(printerControl(_:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(printerDidConnect), name: NSNotification.Name.BRDeviceDidConnect , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(printerDidDisconnect), name: NSNotification.Name.BRDeviceDidDisconnect, object: nil)
        
        printView.layer.borderColor = UIColor.gray.cgColor
        printView.layer.borderWidth = 1
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        printerConnectBtn.layer.borderWidth = 2
        printerConnectBtn.layer.borderColor = UIColor.systemBlue.cgColor
        paperBtn.setTitle(paperSizeArray[0].0, for: .normal)
        paperBtn.addTarget(self, action: #selector(chagePaper), for: .touchUpInside)
        setting = PrinterSetting(paperName: paperSizeArray[0].0, paper: paperSizeArray[0].1)

    }
    
    @objc func chagePaper(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        for paper in paperSizeArray {
            alert.addAction(UIAlertAction(title: paper.0, style: .default, handler: {
                Void in
                self.setting.paperName = paper.0
                self.setting.paper = paper.1
                DispatchQueue.main.async {
                    self.paperBtn.setTitle(paper.0, for: .normal)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
//        print(#function)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        print(#function)
        //print(prtSerial)
        super.viewWillAppear(animated)
        
        connectChk()
    }
    
    func connectChk(){
        deviceListByMfi = BRPtouchBluetoothManager.shared()?.pairedDevices() as? [BRPtouchDeviceInfo] ?? []
        
        prtSerial = ""
        prtName = ""
        isConnectPrinter = false
        
        if let serial = defaults.string(forKey: "prtSerial") {
            if let info = deviceListByMfi?.first(where: {$0.strSerialNumber==serial}){
                prtSerial = info.strSerialNumber
                prtName = info.strPrinterName
                isConnectPrinter = true
            }
        }
        connectLabel(connect: isConnectPrinter)
        
    }
    
    @objc func connectLabel(connect:Bool) {
        if connect{
            printerConnectLabel.text = "\(prtName)(\(prtSerial)) is Connected"
            printerConnectLabel.backgroundColor = .systemBlue
            printerConnectBtn.setTitle("プリンター切断", for: .normal)
        }else {
            printerConnectLabel.text = "プリンター未接続"
            printerConnectLabel.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            printerConnectBtn.setTitle("プリンター接続", for: .normal)
        }
    }
    
    @objc func printerControl(_ sender:Any) {
//        print(isConnectPrinter)
        if isConnectPrinter {
            defaults.removeObject(forKey: "prtSerial")
            prtSerial = ""
            prtName = ""
            connectLabel(connect: false)
            isConnectPrinter = false
        }else {
            let storyboard: UIStoryboard = self.storyboard!
            let select = storyboard.instantiateViewController(withIdentifier: "select") as! BRSelectDeviceTableViewController
            select.delegate = self
            self.navigationController?.pushViewController(select, animated: true)
        }
        
    }
        
    func setSelected(deviceInfo: BRPtouchDeviceInfo) {
        //print(#function)
        selectedDeviceInfo = deviceInfo
        print(deviceInfo.strPrinterName!)
        prtSerial = deviceInfo.strSerialNumber
        prtName = deviceInfo.strPrinterName
        defaults.set(deviceInfo.strSerialNumber, forKey: "prtSerial")
        connectLabel(connect: prtName != "")
        
    }
    
    @IBAction func selectDate(_ sender: UIButton) {
        
//        if #available(iOS 14.0, *) {
            // iOS14以降の場合
            
            let pickerView = SelectDateView(frame: self.view.frame)
            pickerView.center = self.view.center
            pickerView.delegate = self
            pickerView.selectedDate = self.YOTEI_HI ?? Date()
            self.view.addSubview(pickerView)
            
                        
//        } else {
//            // iOS14以前の場合
//        let picker = DatePickerPopover(title: "日時選択")
//            .setSelectedDate(self.YOTEI_HI ?? Date())
//            .setLocale(identifier: "ja_JP")
//            .setSelectedDate(Date())
//            //.setMinimumDate(Date())
//            .setValueChange(action: { _, selectedDate in
//                //print("current date \(selectedDate)")
//            })
//            .setDoneButton(action: { popover, selectedDate in
//                print("selectedDate \(selectedDate)")
//                let formatter = DateFormatter()
//                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
//                self.YOTEI_HI = selectedDate
//                self.yoteiBtn.setTitle(formatter.string(from: selectedDate), for: .normal)
//                print(formatter.string(from: selectedDate))
//            } )
//            .setCancelButton(action: { _, _ in print("キャンセル")})
//        picker.appear(originView: sender, baseViewController: self)
//        }

    }
    
    func setDate(date: Date) {
        //print(date)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        self.YOTEI_HI = date
        self.yoteiBtn.setTitle(formatter.string(from: date), for: .normal)
    }
        
    @IBAction func clearDate(_ sender: UIButton){
        YOTEI_HI = nil
        self.yoteiBtn.setTitle("日付を選択", for: .normal)
    }
    
    @IBAction func entryData(_ sender: UIButton){

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
        case 902:
            type = "INQUIRY"
            alertTitle = "再発行します"
        case 903:
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
    
    func labelDsp(){
        if printData == nil {
            return
        }
        
        let QR = "RF="+tagNO
        
        label1.text = printData.date+"-"+printData.renban
        label2.text = printData.customer+" 様"
        label3.text = printData.tagNO
        label4.text = printData.itemCD
        label5.text = printData.itemNM
        let nouki = Array(printData.nouki)
        if nouki.count==8 {
            print(nouki.prefix(4))
            label6.text = nouki[0...3]+"-"+nouki[4...5]+"-"+nouki[6...7]
        }else {
            label6.text = printData.nouki
        }
        let kigen = Array(printData.kigen)
        if kigen.count==8 {
            label6.text = kigen[0...3]+"-"+kigen[4...5]+"-"+kigen[6...7]
        }else {
            label6.text = printData.kigen
        }
        
        qrView.image = UIImage.makeQR(code: QR)
        
        if isConnectPrinter {
            self.printLabel()
        }else {
            SimpleAlert.make(title: "プリンターに接続してください", message: "")
        }

    }
    
    func request(type:String, param:[String:Any]) {
        
        DispatchQueue.main.async {
            self.conAlert = UIAlertController(title: "データ登録中", message: "しばらくお待ちください", preferredStyle: .alert)
            self.present(self.conAlert, animated: true, completion: nil)
        }
        
        IBM().IBMRequest(type: type, parameter: param, completionClosure: {(_,json,err) in
            
            if err == nil, json != nil {
                print(json!)
                print(json!["CUSTOMER_NM"] as? String ?? "")
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
                    if let yotei = json!["YOTEI_HI"] as? String, yotei != "00000000"{
                        yotei_hi = yotei.date.short
                    }
                    
                    self.printData = PrintData(date: yotei_hi,
                                               renban: json!["RENBAN"] as? String ?? "",
                                               customer: json!["CUSTOMER_NM"] as? String ?? "",
                                               tagNO: json!["TAG_NO"] as? String ?? "",
                                               itemCD: json!["SYOHIN_CD"] as? String ?? "",
                                               itemNM: json!["SYOHIN_NM"] as? String ?? "",
                                               nouki: json!["NOUKI"] as? String ?? "",
                                               kigen: json!["KIGEN"] as? String ?? "")
                    
                    DispatchQueue.main.async {
                        if type == "DELETE" {
                            self.conAlert.title = "削除完了"
                            self.conAlert.message = "前ページに戻ります"
                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                self.navigationController?.popViewController(animated: true)
                                self.printData = nil
                            }))
                            
                        }else {
                            self.conAlert.dismiss(animated: true, completion: nil)
                            self.labelDsp()
                        }
                    }
                }
                
            }else {
                print(err!)
                if errMsg != "" {
                    DispatchQueue.main.async {
                        self.conAlert.title = "エラー"
                        self.conAlert.message = errMsg
                        self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    }
                }
            }
            
        })
        
    }
    @IBAction func printLabel() {

        //printView.layer.borderColor = UIColor.clear.cgColor
        let channel = BRLMChannel(bluetoothSerialNumber: prtSerial)
        
        let generateResult = BRLMPrinterDriverGenerator.open(channel)
        guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
              let printerDriver = generateResult.driver else {
            print("Error - Open Channel: \(generateResult.error.code)")
            SimpleAlert.make(title: "Error", message: "プリンターが見つかりません")
            return
        }
        defer {
            printerDriver.closeChannel()
        }
                
        //QL_820NWB
        guard let img = printView.toImage().cgImage,
              let printSettings = BRLMQLPrintSettings(defaultPrintSettingsWith: .QL_820NWB)
        else {
            print("Error - Image file is not found.")
            SimpleAlert.make(title: "Error", message: "オブジェクトが見つかりません")
            return
        }
        printSettings.labelSize = setting.paper
        //printSettings.labelSize = .rollW62RB
        //printSettings.labelSize = .rollW62
        printSettings.autoCut = true
        
        let printError = printerDriver.printImage(with: img, settings: printSettings)
        
        if printError.code != .noError {
            print("Error - Print Image: \(printError)")
            showAlert(title: "印刷できません", message: "\(printError)")
        }
        else {
            print("Success - Print Image")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                let alert = UIAlertController(title: "完了", message: "前ページに戻ります", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    self.navigationController?.popViewController(animated: true)
                    self.printData = nil
                }))
                
                self.present(alert, animated: true, completion: nil)
            })
            
        }
        //printView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK: PrinterConnectNotification
    @objc func printerDidConnect( notification : Notification) {
        print(#function)
        if let connectedAccessory = notification.userInfo?[BRDeviceKey] {
            print("ConnectDevice : \(String(describing: (connectedAccessory as? BRPtouchDeviceInfo)?.description()))")
        }
        isConnectPrinter = true
        connectChk()
        
    }
    
    @objc func printerDidDisconnect( notification : Notification) {
        print(#function)
        if let disconnectedAccessory = notification.userInfo?[BRDeviceKey] {
            print("DisconnectDevice : \(String(describing: (disconnectedAccessory as? BRPtouchDeviceInfo)?.description()))")
        }
        isConnectPrinter = false
        connectChk()
    }
    

}
