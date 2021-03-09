//
//  ReceptionViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/02/03.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import SwiftyPickerPopover
import AVFoundation

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
    var seizou:String = ""
}

struct PrinterSetting {
    var printer:String = "QL-820NWB"
    var model:BRLMPrinterModel = .QL_820NWB
    var paperName:String = "ロール紙62mm"
    var paper:BRLMQLPrintSettingsLabelSize = .rollW62
}

class ReceptionViewController: UIViewController, ScannerViewDelegate, BRSelectDeviceTableViewControllerDelegate {
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var envLabel: UILabel!
    
// Printer
    var selectedDeviceInfo : BRPtouchDeviceInfo?
    @IBOutlet weak var printerConnectLabel: UILabel!

    var prtSerial = ""
    var prtName = ""
    var deviceListByMfi : [BRPtouchDeviceInfo]?
    var isConnectPrinter = false
    var setting:PrinterSetting!
    @IBOutlet weak var paperBtn: UIButton!
    //@IBOutlet weak var printerConnectBtn:UIButton!
    var printerConnectBtn:UIBarButtonItem!
    let paperSizeArray:[(String,BRLMQLPrintSettingsLabelSize)] = [("ロール紙62mm",.rollW62),("ロール紙62mm赤黒",.rollW62RB)]

    var scanner:ScannerView!
    var conAlert:UIAlertController!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var tagLabel:UILabel!
    
    @IBOutlet var btns: [UIButton]!
    @IBOutlet weak var kanriLabel: UILabel!
//    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var labelImgView: UIImageView!
    @IBOutlet weak var printBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var photoCollection: UICollectionView!
    var cellEditing: Bool = false
    var yusen:Bool = false
    //@IBOutlet var edtBtn:UIButton!
    
    //IBMへ送るパラメーター
    var YOTEI_HI:Date!
    var seizouHI:Date!
    
    var lbl:BRLabelView! //印刷用のView
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.BRDeviceDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.BRDeviceDidDisconnect, object: nil)
        dspInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //tagLabel.text = tagNO
        
        //printerConnectBtn.addTarget(self, action: #selector(printerControl(_:)), for: .touchUpInside)
        self.navigationItem.hidesBackButton = true
        printerConnectBtn = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(printerControl(_:)))
        let backBtn = UIBarButtonItem(title: "＜戻る", style: .plain, target: self, action: #selector(back))
        self.navigationItem.rightBarButtonItem = printerConnectBtn
        self.navigationItem.leftBarButtonItem = backBtn
                                            
        NotificationCenter.default.addObserver(self, selector: #selector(printerDidConnect), name: NSNotification.Name.BRDeviceDidConnect , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(printerDidDisconnect), name: NSNotification.Name.BRDeviceDidDisconnect, object: nil)
        
//        printView.layer.borderColor = UIColor.gray.cgColor
//        printView.layer.borderWidth = 1
        
        paperBtn.setTitle(paperSizeArray[0].0, for: .normal)
        paperBtn.addTarget(self, action: #selector(chagePaper), for: .touchUpInside)
        setting = PrinterSetting(paperName: paperSizeArray[0].0, paper: paperSizeArray[0].1)
        
        tagField.delegate = self
        scanBtn.addTarget(self, action: #selector(scan), for: .touchUpInside)
        printBtn.addTarget(self, action: #selector(display), for: .touchUpInside)
        detailBtn.addTarget(self, action: #selector(dispDetail), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        //edtBtn.addTarget(self, action: #selector(editCollection(_:)), for: .touchUpInside)
        
        for btn in btns {
            btn.layer.cornerRadius = 8
        }
        
        photoCollection.delegate = self
        photoCollection.dataSource = self

        #if DEV
        envLabel.isHidden = false
        if hostURL == m8URL {
            envLabel.text = "本番"
        }else {
            envLabel.text = "開発"
        }

        #else
        envLabel.isHidden = true
        #endif
        
        self.dspInit()

    }
    
    func dspInit(){
        //変数クリア
        _json = nil
        printData = nil
        YOTEI_HI = nil
        seizouHI = nil
        enrolled = false
        kanriLabel.text = ""
        if tagNO == "" {
            tagField.text = ""
            tagLabel.text = "TagNo.未入力"
            tagLabel.textColor = .gray
        }
        
        labelImgView.image = nil
    }
    
    override func viewDidLayoutSubviews() {
//        print(#function)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.photoCollection.reloadData()
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
            //printerConnectBtn.setTitle("プリンター切断", for: .normal)
            printerConnectBtn.title = "プリンター切断"
        }else {
            printerConnectLabel.text = "プリンター未接続"
            printerConnectLabel.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            //printerConnectBtn.setTitle("プリンター接続", for: .normal)
            printerConnectBtn.title = "プリンター接続"
        }
    }
    
    @objc func printerControl(_ sender:Any) {
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
    
    //MARK: - ScannerDelegate
    
    @objc func scan() {
        self.view.endEditing(true)
        tagField.text = ""
        scanner = ScannerView(frame: self.view.frame)
        
        scanner.delegate = self
        scanner.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        scanner.frame = self.view.frame
        self.view.addSubview(scanner)

        //画面回転に対応
        scanner.translatesAutoresizingMaskIntoConstraints = false
        
        scanner.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scanner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scanner.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func getData(data: String) {
        print(data)
        if Int(data) != nil, data.count == 13 {
            //バーコードの時
            tagNO = String(Array(data)[4...11])
        }else if data.hasPrefix("RF="){
            //QRの時
            tagNO = String(Array(data)[3...10])
        }
        setTag()
    }
    
    func setTag(){
        if tagNO == "" {
            tagLabel.text = "TagNo.未入力"
            tagLabel.textColor = .gray
            tagField.text = ""
        }else {
            tagLabel.text = tagNO
            tagLabel.textColor = .black
            self.request(type: "INQUIRY", param: ["TAG_NO":tagNO])
            
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }else {
            tagNO = ""
            dspInit()
        }
    }
    
    
    @objc func display(){
        kanriLabel.text = ""
        labelImgView.image = nil

        if !enrolled || _json==nil {
            SimpleAlert.make(title: "対象のデータがありません", message: "")
            return
        }
        var kanri = ""
        var yotei_hi = ""
        if let yotei = _json["YOTEI_HI"] as? String, yotei != ""{
            yotei_hi = yotei.date.short
            kanri = yotei
        }
        //優先
        yusen = _json["YUSEN"] as? String == "1"

        printData = PrintData(date: yotei_hi,
                                   renban: _json["RENBAN"] as? String ?? "",
                                   customer: _json["CUSTOMER_NM"] as? String ?? "",
                                   tagNO: _json["TAG_NO"] as? String ?? "",
                                   itemCD: _json["SYOHIN_CD"] as? String ?? "",
                                   itemNM: _json["SYOHIN_NM"] as? String ?? "",
                                   nouki: _json["NOUKI"] as? String ?? "",
                                   kigen: _json["KIGEN"] as? String ?? "")
        
        kanri += "-"+printData.renban+"-"+printData.tagNO
        kanriLabel.text = kanri
        
        lbl = BRLabelView(frame:self.view.frame)
        // シールのPrintView
        let QR = "RF="+tagNO
        lbl.yusenLabel.isHidden = !yusen
        lbl.label1.text = printData.date+"-"+printData.renban
        lbl.label2.text = printData.customer+" 様"
        lbl.label3.text = printData.tagNO
        lbl.label4.text = printData.itemCD
        lbl.label5.text = printData.itemNM
        let nouki = Array(printData.nouki)
        if nouki.count==8 {
            print(nouki.prefix(4))
            lbl.label6.text = nouki[0...3]+"/"+nouki[4...5]+"/"+nouki[6...7]
        }else {
            lbl.label6.text = printData.nouki
        }
        let kigen = Array(printData.kigen)
        if kigen.count==8 {
            lbl.label7.text = kigen[0...3]+"/"+kigen[4...5]+"/"+kigen[6...7]
        }else {
            lbl.label7.text = printData.kigen
        }
        
        lbl.qrView.image = UIImage.makeQR(code: QR)

        
        //self._printLabel()
        self.printLabel()
        
        /*
        if isConnectPrinter {
            self.printLabel()
            
        }else {
            SimpleAlert.make(title: "プリンターに接続してください", message: "")
        }*/
        
    }
    
    
    func request(type:String, param:[String:Any]) {
        self.dspInit()
        //print(param)
        
        DispatchQueue.main.async {
            self.conAlert = UIAlertController(title: "データ取得中", message: "しばらくお待ちください", preferredStyle: .alert)
            self.present(self.conAlert, animated: true, completion: nil)
        }
        
        IBM().IBMRequest(type: type, parameter: param, completionClosure: {(_,json,err) in
            print("IBMRequest")
            _json = nil
            printData = nil
            
            if err == nil, json != nil {
                //print(json!)
                _json = json
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
                    
                    DispatchQueue.main.async {
                        //INQURY
                        self.conAlert.dismiss(animated: true, completion: {
                            self.dispDetail()
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
    
    @objc func dispDetail(){
        if _json == nil {
            SimpleAlert.make(title: "表示する対象がありません", message: "")
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main2", bundle: nil)
        let infoVC = storyboard.instantiateViewController(identifier: "info") as! InfoViewController
        infoVC.delegate = self
        infoVC.isModalInPresentation = true
        self.present(infoVC, animated: true, completion: nil)
    }
    
    //MARK: PrinterSetting
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
    
    @objc func _printLabel(){
        if lbl == nil {
            SimpleAlert.make(title: "対象のオブジェクトがありません", message: "")
            return
        }
        
        guard let img = lbl.printView.toImage().cgImage,
              let printSettings = BRLMQLPrintSettings(defaultPrintSettingsWith: .QL_820NWB)
        else {
            print("Error - Image file is not found.")
            SimpleAlert.make(title: "Error", message: "オブジェクトが見つかりません")
            return
        }
        
        labelImgView.image = UIImage(cgImage: img)
        
    }
    
    @objc func printLabel() {
        if lbl == nil {
            SimpleAlert.make(title: "対象のオブジェクトがありません", message: "")
            return
        }
        
        //QL_820NWB
        guard let img = lbl.printView.toImage().cgImage,
              let printSettings = BRLMQLPrintSettings(defaultPrintSettingsWith: .QL_820NWB)
        else {
            print("Error - Image file is not found.")
            SimpleAlert.make(title: "Error", message: "オブジェクトが見つかりません")
            return
        }
        
        labelImgView.image = UIImage(cgImage: img)
        
        
        if !isConnectPrinter {
            SimpleAlert.make(title: "プリンターに接続してください", message: "")
            return
        }
        
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
        
        
        
        printSettings.labelSize = setting.paper
        //printSettings.labelSize = .rollW62RB
        //printSettings.labelSize = .rollW62
        printSettings.autoCut = true
        
        let printError = printerDriver.printImage(with: img, settings: printSettings)
        
        if printError.code != .noError {
            print("Error - Print Image: \(printError)")
            SimpleAlert.make(title: "印刷できません", message: "\(printError)")
            
        }
        else {
            print("Success - Print Image")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                let alert = UIAlertController(title: "印刷完了", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            })
            
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
        //MARK: - カメラ起動
    //写真を撮る
    @objc func takePhoto() {
        if tagNO == "" {
            SimpleAlert.make(title: "TAG Noが見つかりません", message: "")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let camera = storyboard.instantiateViewController(withIdentifier: "camera")
        
        camera.modalPresentationStyle = .fullScreen

        self.present(camera, animated: true, completion: nil)

    }

    
    @IBAction func showImages(_ sender: UIButton) {
        if imageArr.count == 0 {
            SimpleAlert.make(title: "表示する写真がありません", message: "")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photo = storyboard.instantiateViewController(withIdentifier: "photo")
        
        self.navigationController?.pushViewController(photo, animated: true)

    }
    
    
    @objc func back(){
        if imageArr.count > 0 {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)

        }else {
            tagNO = ""
            dspInit()
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
}
extension ReceptionViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180.0, height: 135.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        cell.imageView.image = imageArr[indexPath.item]
        cell.deleteBtn.isHidden = true
        /*
        cell.deleteBtn.isHidden = !cellEditing
        cell.deleteBtn.tag = 300+indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteCell(_:)), for: .touchUpInside)
        */
        return cell
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !cellEditing {//編集中は拡大しない
            //タップしたら拡大表示
            num = indexPath.row
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let disp = storyboard.instantiateViewController(withIdentifier: "disp")
            disp.modalPresentationStyle = .fullScreen
            
            self.present(disp, animated: true, completion: nil)
        }
    }
    @objc func editCollection(_ sender:UIButton){
        cellEditing = !cellEditing
        if cellEditing {
            edtBtn.setTitle("完了", for: .normal)
        }else {
            edtBtn.setTitle("編集", for: .normal)
        }
        photoCollection.reloadData()
    }
    @objc func deleteCell(_ sender:UIButton){
        let alert = UIAlertController(title: "写真を削除しますか？", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {
            Void in
            let i = sender.tag-300
            //削除したときの処理
            imageArr.remove(at: i)
            DispatchQueue.main.async {
                self.photoCollection.reloadData()
                if imageArr.isEmpty{
                    //self.back()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    */
}

extension ReceptionViewController:UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.tag)
        if textField.text! == "" {return}
        
        switch textField.tag {
        case 100://tag Fieldの時
            if Int(tagField.text!) == nil {
                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
                return
            }
            if tagField.text?.count != 8 {
                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
                return
            }
            tagNO = textField.text!
            setTag()
            
        default:
            return
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
}

extension ReceptionViewController:InfoViewControllerDelegate {

    func setPrintInfo(json: NSDictionary!, type: String) {
        print(json)
        print(type)
        _json = json
        if type == "print" {
            self.display()
        }else if type == "delete" {
            self.dspInit()
            self.clear(self)
        }
        
    }

}
