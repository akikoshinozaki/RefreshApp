//
//  PrintSampleViewController.swift
//  RefreshApp
//
//  Created by administrator on 2020/11/30.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

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
    
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
        print(prtSerial)
        connectLabel(connect: prtSerial != "")
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
        connectLabel(connect: prtName != "")

    }
    
    @IBAction func printImage() {
        let channel = BRLMChannel(bluetoothSerialNumber: prtSerial)
        
        let generateResult = BRLMPrinterDriverGenerator.open(channel)
        guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
            let printerDriver = generateResult.driver else {
                print("Error - Open Channel: \(generateResult.error.code)")
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
                return
        }
//        printSettings.printOrientation = .landscape
//        printSettings.labelSize = .dieCutW29H90
        
        printSettings.labelSize = .rollW62RB
        printSettings.autoCut = true
                
        let printError = printerDriver.printImage(with: img, settings: printSettings)

        if printError.code != .noError {
            print("Error - Print Image: \(printError)")
        }
        else {
            print("Success - Print Image")
        }
    }
    
    
    @IBAction func printAssist(_ sender: Any) {
        let str = "ABCDEFG"
        var path = "printassist-x-callback-url://x-callback-url/open?x-success=m8-refresh://"
        
        path += "&waitforprintcomplete=1"
        path += "&paper=10443"
//        path += "&media=89"
        path += "&1=\(str),5,10,48,5,HiraMinProN-W3,3,0,0,0"
//        path += "&printer=QL-820NWB(6077716D08EC)"
//        path += "&printer=RJ-4030Ai9711"
//        path += "&2=%3C%3C%3CLine%3E%3E%3E,5,10,53,10,1,#000000"
//        path += "&3=%3C%3C%3CBarcode%3E%3E%3E,12,15,50,15,2,\(barcode)"

//        path += "&1=abcdefgABCDEFG"
//        path += "&orientation=0&unit=0&paper=10425&papercut=1"
//        path += "&orientation=0&unit=0&width=100&height=50&paper=1&copies=1"
//        path += "&1=%3C%3C%3CFrame%3E%3E%3E,5,5,48,30,0,0.2,0"
//        path += "&2=abcdefg%20ABCDEFG,12,8,40,10,HiraKakuProNW3,8,0,0,0"
        
        /*
        $&orientation=0&unit=0&width=100&height=50&paper=1&copies=1&1=%3C%3C%3CFrame%3E%3E%3E
        ,5,5,90,40,0,0.2,0%20&2=John%20Smith,12,8,50,10,HiraKakuProNW3,8,0,0,0&3=%3C%3C%3CBarcode%3E%3E%3E,
        12,25,50,15,2,020000220150&4=%3C%3C%3CObject%3E%3E%3E,70,10,20,20,[image decode data] "
        */
        
        print(path)
        UIApplication.shared.open(URL(string: path)!, options: [:], completionHandler: nil)
        
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
        
    }
    
    @objc func printerDidConnect( notification : Notification) {
        print(#function)
        if let connectedAccessory = notification.userInfo?[BRDeviceKey] {
            print("ConnectDevice : \(String(describing: (connectedAccessory as? BRPtouchDeviceInfo)?.description()))")
        }

        deviceListByMfi = BRPtouchBluetoothManager.shared()?.pairedDevices() as? [BRPtouchDeviceInfo] ?? []
        
    }
    
    @objc func printerDidDisconnect( notification : Notification) {
        print(#function)
        if let disconnectedAccessory = notification.userInfo?[BRDeviceKey] {
            print("DisconnectDevice : \(String(describing: (disconnectedAccessory as? BRPtouchDeviceInfo)?.description()))")
        }

        deviceListByMfi = BRPtouchBluetoothManager.shared()?.pairedDevices()  as? [BRPtouchDeviceInfo] ?? []
        
        if deviceListByMfi!.contains(where: {$0.strSerialNumber==prtSerial}){
            connectLabel(connect: true)
        }else {
            prtSerial = ""
            connectLabel(connect: false)
        }
        
    }
    
}
