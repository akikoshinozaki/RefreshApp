//
//  AcceptViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/01/22.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

extension UIImage {
    static func makeCode(type:String,code:String) -> UIImage? {
        guard let data = code.data(using: .utf8) else { return nil }
        var str = ""
        switch type {
        case "EAN13":
            print("EAN13")
            str = "CICode128BarcodeGenerator"
        case "QR":
            print("QR")
            str = "CIQRCodeGenerator"
        default:
            return nil
        }

        guard let filter = CIFilter(name: str, parameters: ["inputMessage": data]) else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let ciImage = filter.outputImage?.transformed(by: transform) else { return nil }
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    static func makeQR(code:String)-> UIImage? {
        return makeCode(type: "QR", code: code)
    }

    static func makeEAN13(code:String)-> UIImage? {
        return makeCode(type: "EAN13", code: code)
    }

}

extension UIView {
    //viewをimageに変換
    public func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("現在のコンテキストを取得できませんでした。")
            return UIImage()
        }

        self.layer.render(in: context)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            print("ビューをイメージに変換できませんでした。")
            return UIImage()
        }

        UIGraphicsEndImageContext()

        return image
    }

}

struct PrintData {
    var date:String = ""
    var renban:String = ""
    var customer:String = ""
    var tagNO:String = ""
    var itemCD:String = ""
    var itemNM:String = ""
    var nouki:String = ""
    var kigen:String = ""
}

class AcceptViewController: UIViewController, BRSelectDeviceTableViewControllerDelegate {
    
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
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var tagLabel:UILabel!
    @IBOutlet weak var yoteiBtn:UIButton!
    
    //IBMへ送るパラメーター
    //var tag:String = ""
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(printerDidConnect), name: NSNotification.Name.BRDeviceDidConnect , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(printerDidDisconnect), name: NSNotification.Name.BRDeviceDidDisconnect, object: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        print(#function)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        print(prtSerial)
        super.viewWillAppear(animated)
        
        connectChk()
    }
    
    func labelDsp(){
        if printData == nil {
            return
        }
        //let tagNo = "24789838"
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
        
    }
    
    func connectChk(){
        deviceListByMfi = BRPtouchBluetoothManager.shared()?.pairedDevices() as? [BRPtouchDeviceInfo] ?? []
        
        prtSerial = ""
        prtName = ""
        connectLabel(connect: false)
        
        if let serial = defaults.string(forKey: "prtSerial") {
            if let info = deviceListByMfi?.first(where: {$0.strSerialNumber==serial}){
                prtSerial = info.strSerialNumber
                prtName = info.strPrinterName
                connectLabel(connect: true)
            }
        }
        
    }
    
    @objc func connectLabel(connect:Bool) {
        if connect{
            printerConnectLabel.text = "\(prtName)(\(prtSerial)) is Connected"
            printerConnectLabel.backgroundColor = .systemBlue
        }else {
            printerConnectLabel.text = "プリンター未接続"
            printerConnectLabel.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    @IBAction func selectPrinter(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let select = storyboard.instantiateViewController(withIdentifier: "select") as! BRSelectDeviceTableViewController
        select.delegate = self
        self.navigationController?.pushViewController(select, animated: true)
        
    }
    
    func setSelected(deviceInfo: BRPtouchDeviceInfo) {
        print(#function)
        selectedDeviceInfo = deviceInfo
        print(deviceInfo.strPrinterName!)
        prtSerial = deviceInfo.strSerialNumber
        prtName = deviceInfo.strPrinterName
        defaults.set(deviceInfo.strSerialNumber, forKey: "prtSerial")
        connectLabel(connect: prtName != "")
        
    }
    
    @IBAction func selectDate(_ sender: UIButton) {
        let picker = DatePickerPopover(title: "日時選択")
            .setSelectedDate(self.YOTEI_HI ?? Date())
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
                self.YOTEI_HI = selectedDate
                self.yoteiBtn.setTitle(formatter.string(from: selectedDate), for: .normal)
                print(formatter.string(from: selectedDate))
            } )
            .setCancelButton(action: { _, _ in print("キャンセル")})
        picker.appear(originView: sender, baseViewController: self)

    }
    
    @IBAction func clearDate(_ sender: UIButton){
        YOTEI_HI = nil
        self.yoteiBtn.setTitle("予定日を選択", for: .normal)
    }
    
    @IBAction func entryData(_ sender: UIButton){
        var type:String = ""
        var param:[String:Any] =
            ["TAG_NO":tagNO]
        switch sender.tag {
        case 901:
            type = "ENTRY"
            param["YOTEI_HI"] = YOTEI_HI.toString(format: "yyyyMMdd")
        case 902:
            type = "INQUIRY"
        case 903:
            type = "DELETE"
        default:
            return
        }
    
        print(param)
        
        IBM().IBMRequest(type: type, parameter: param, completionClosure: {(_,json,err) in
            
            if err == nil, json != nil {
                print(json!)
                print(json!["CUSTOMER_NM"] as? String ?? "")
                self.printData = PrintData(date: json!["YOTEI_HI"] as? String ?? "",
                                           renban: json!["RENBAN"] as? String ?? "",
                                           customer: json!["CUSTOMER_NM"] as? String ?? "",
                                           tagNO: json!["TAG_NO"] as? String ?? "",
                                           itemCD: json!["SYOHIN_CD"] as? String ?? "",
                                           itemNM: json!["SYOHIN_NM"] as? String ?? "",
                                           nouki: json!["NOUKI"] as? String ?? "",
                                           kigen: json!["KIGEN"] as? String ?? "")
                                
                DispatchQueue.main.async {
                    self.labelDsp()
                }
                
                
            }else {
                print(err!)
            }
            
        })
        
        //IBM().inq(type: type, parameter: param)
    }
    
    @IBAction func printImage() {
        let channel = BRLMChannel(bluetoothSerialNumber: prtSerial)
        
        let generateResult = BRLMPrinterDriverGenerator.open(channel)
        guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
              let printerDriver = generateResult.driver else {
            print("Error - Open Channel: \(generateResult.error.code)")
            showAlert(title: "Error", message: "プリンターが見つかりません")
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
            showAlert(title: "Error", message: "オブジェクトが見つかりません")
            return
        }
        
        printSettings.labelSize = .rollW62RB
        //printSettings.labelSize = .rollW62
        printSettings.autoCut = true
        
        let printError = printerDriver.printImage(with: img, settings: printSettings)
        
        if printError.code != .noError {
            print("Error - Print Image: \(printError)")
            showAlert(title: "印刷できません", message: "\(printError)")
        }
        else {
            print("Success - Print Image")
        }
    }
    
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func printerDisconnect(_ sender: Any) {
        defaults.removeObject(forKey: "prtSerial")
        prtSerial = ""
        prtName = ""
        connectLabel(connect: false)
    }
    
    //MARK: PrinterConnectNotification
    @objc func printerDidConnect( notification : Notification) {
        print(#function)
        if let connectedAccessory = notification.userInfo?[BRDeviceKey] {
            print("ConnectDevice : \(String(describing: (connectedAccessory as? BRPtouchDeviceInfo)?.description()))")
        }
        connectChk()
        
    }
    
    @objc func printerDidDisconnect( notification : Notification) {
        print(#function)
        if let disconnectedAccessory = notification.userInfo?[BRDeviceKey] {
            print("DisconnectDevice : \(String(describing: (disconnectedAccessory as? BRPtouchDeviceInfo)?.description()))")
        }
        connectChk()
    }
    

}
