//
//  PrintSampleViewController.swift
//  RefreshApp
//
//  Created by administrator on 2020/11/30.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
/*
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

}*/

class PrintSampleViewController: UIViewController, BRSelectDeviceTableViewControllerDelegate {


    var selectedDeviceInfo : BRPtouchDeviceInfo?
    @IBOutlet weak var printerConnectLabel: UILabel!
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var qrView: UIImageView!
    var prtSerial = ""
    var prtName = ""
    var deviceListByMfi : [BRPtouchDeviceInfo]?
    let defaults = UserDefaults.standard
    
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
        let tagNo = "24789838"
        let QR = "RF="+tagNo
        let itemCD = "285152"
        let itemName = "UFDXﾘﾌﾚｯｼｭCL3FP"
        
        label1.text = Date().short+"-00001"
        label2.text = "丸八　太郎"
        label3.text = tagNo
        label4.text = itemCD
        label5.text = itemName
        
        //barcodeView.image = UIImage.makeEAN13(code: JAN)
        qrView.image = UIImage.makeQR(code: QR)
        
        //printView.layer.borderWidth = 1
        
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

        //rj_4030Ai
//        guard let img = printView.toImage().cgImage,
//            let printSettings = BRLMRJPrintSettings(defaultPrintSettingsWith: .rj_4030Ai)
//            else {
//                print("Error - Image file is not found.")
//                return
//        }
        
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
    
    
    @IBAction func printAssist(_ sender: Any) {
        let tagNo = "24789838"
        let QR = "RF="+tagNo
        let itemCD = "285152"
        let itemName = "UFDXﾘﾌﾚｯｼｭCL3FP"
        let str1 = Date().short+"-00001"
        let str2 = "丸八　太郎"
        let str3 = tagNo
        let str4 = itemCD
        let str5 = itemName
        let kai = "\n"
        
        let str = str1+kai+str2+kai+str3+kai+str4+kai+str5
//        let str = "ABCDEFG%0Dabcde%0DABCDEFG%0Dabcde"
//        var path = "printassist-x-callback-url://x-callback-url/open?x-success=m8-refresh://"
        let path = "printassist-x-callback-url://x-callback-url/open?" +
            "x-success=m8-refresh://" +
//            "&previewmode=1" +
//            "&orientation=0" +
            "&unit=0" +
            "&width=62" +
            "&height=40" +
//            "&paper=1" +
//            "&copies=1" +
            "&1=\(str),24,5,36,30,HelveticaNeue,4,0,0,0,0" +
//            "&1=%3C%3C%3CFrame%3E%3E%3E,5,5,90,40,0,0.2" +
//            "&2=\(str),12,8,50,10,HiraKakuProN-W3,8,0,0,0"
//            "&3=John%20Smith,12,20,50,10,HiraKakuProNW3,8,0,0,0"
//        "&waitforprintcomplete=1"
        "&paper=10443" +
//        "&media=89"
//        "&printer=QL-820NWB(6077716D08EC)"
//        "&printer=RJ-4030Ai9711"
//        "&2=%3C%3C%3CLine%3E%3E%3E,5,10,53,10,1,#000000"
        "&2=<<<Barcode>>>,2,8,20,20,1,\(QR)"
        
        //print(path)
        let path2 = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: path2)
        //print(url)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
    }

            
    @IBAction func printData(_ sender: Any) {

        let str = "ABCDEFG"
        let printData:Data? = str.data(using: .utf8)
        
        // 印刷
        let printIntaractionController = UIPrintInteractionController.shared
        
        let info = UIPrintInfo(dictionary: nil)
        info.jobName = "Sample Print"
        //info.orientation = .portrait
        //info.outputType = .grayscale
        printIntaractionController.printInfo = info
        printIntaractionController.showsPaperSelectionForLoadedPapers = true
        
        //印刷する内容
        //printIntaractionController.printingItem = PDFMaker.make(views: sendMailViews)
        printIntaractionController.printingItem = printData!
        
        
        printIntaractionController.present(animated: true, completionHandler: {
            controller, completed, error in
            
            if completed, error == nil {
                print("Print Completed.")
                let alert = UIAlertController(title: "印刷データが正常に\n転送されました", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            }
        })
        
    }
    @IBAction func printerDisconnect(_ sender: Any) {
        defaults.removeObject(forKey: "prtSerial")
        prtSerial = ""
        prtName = ""
        connectLabel(connect: false)
    }
    
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
    weak var secureTextAlertAction: UIAlertAction?
    private var textDidChangeObserver: NSObjectProtocol!
    
    @IBAction func showSecureTextEntryAlert(_ sender:Any) {
        let title = "A Short Title is Best"
        let message = "A message should be a short, complete sentence."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "OK"
//        let title = NSLocalizedString("A Short Title is Best", comment: "")
//        let message = NSLocalizedString("A message should be a short, complete sentence.", comment: "")
//        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
//        let otherButtonTitle = NSLocalizedString("OK", comment: "")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add the text field for the secure text entry.
        alertController.addTextField { textField in

            self.textDidChangeObserver = NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: textField,
                queue: OperationQueue.main) { (notification) in
                    if let textField = notification.object as? UITextField {
                        // Enforce a minimum length of >= 5 characters for secure text alerts.
                        if let text = textField.text {
                            self.secureTextAlertAction!.isEnabled = text.count >= 5
                        } else {
                            self.secureTextAlertAction!.isEnabled = false
                        }
                    }
            }
            
            textField.isSecureTextEntry = true
        }
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            print("The \"Secure Text Entry\" alert's cancel action occurred.")
        }
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .default) { _ in
            print("The \"Secure Text Entry\" alert's other action occurred.")
//            guard let textFields = alertController.textFields else {
//                return
//            }
//
//            guard !textFields.isEmpty else {
//                return
//            }
            let textFields = alertController.textFields!
            for field in textFields {
                print(field.text!)
//                if field.tag == 1 {
//                    self.label1.text = text.text
//                } else {
//                    self.label2.text = text.text
//                }
            }
            
        }
        
        /** The text field initially has no text in the text field, so we'll disable it for now.
            It will be re-enabled when the first character is typed.
        */
        otherAction.isEnabled = false
        
        /** Hold onto the secure text alert action to toggle the enabled / disabled
            state when the text changed.
        */
        secureTextAlertAction = otherAction
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
