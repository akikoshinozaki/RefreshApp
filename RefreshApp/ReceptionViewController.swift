//
//  ReceptionViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/02/03.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//
//  受付入力画面

import UIKit
import SwiftyPickerPopover
import AVFoundation
import ZBarSDK

extension UIImage {
    static func makeCode(type:String,code:String) -> UIImage? {
        guard let data = code.data(using: .utf8) else { return nil }
        var str = ""
        switch type {
        case "EAN13":
            //print("EAN13")
            str = "CICode128BarcodeGenerator"
        case "QR":
            //print("QR")
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


class ReceptionViewController: UIViewController, BRSelectDeviceTableViewControllerDelegate, RefListViewDelegate, ZBarReaderDelegate {
    
    struct PrinterSetting {
        var printer:String = "QL-820NWB"
        var model:BRLMPrinterModel = .QL_820NWB
        var paperName:String = "ロール紙62mm"
        var paper:BRLMQLPrintSettingsLabelSize = .rollW62
    }
    
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
    var printerConnectBtn:UIBarButtonItem!
    let paperSizeArray:[(String,BRLMQLPrintSettingsLabelSize)] = [("ロール紙62mm",.rollW62),("ロール紙62mm赤黒",.rollW62RB)]

    var conAlert:UIAlertController!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var tagLabel:UILabel!
    @IBOutlet weak var keiyakuField: UITextField!
    
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
    var keiNO:String = ""
    
    @IBOutlet weak var fnLabel1: UILabel!
    @IBOutlet weak var fnLabel2: UILabel!
    @IBOutlet weak var fnLabel3: UILabel!
    var imgCnt = 2
    
    //IBMへ送るパラメーター
    var YOTEI_HI:Date!
    var seizouHI:Date!
    var brLabel:BRLabelView! //印刷用のView
    var kensaLabel:KensaLabelView! //ラベル（大）
    
    @IBOutlet weak var uploadedLabel: UILabel!
    var entryData:[String:Any] = [:] //infoViewから受け取ったパラメータ（ENTRY用）
    var iArr:[UIImage] = [] //サーバー上の画像を格納する
    @IBOutlet weak var edtBtn:UIButton!
    let dispatchGroup = DispatchGroup()
    var postAlert: UIAlertController!
    var isPostImage:Bool = false
    var isDouble:Bool = false
//    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var kanriView: UIView!
    @IBOutlet var kanriLabels: [UILabel]!
    @IBOutlet weak var kLabel01: UILabel!
    @IBOutlet weak var kLabel02: UILabel!
    @IBOutlet weak var kLabel03: UILabel!
    @IBOutlet weak var kLabel04: UILabel!
    @IBOutlet weak var kLabel05: UILabel!
    @IBOutlet weak var kLabel06: UILabel!
    @IBOutlet weak var kLabel07: UILabel!
    @IBOutlet weak var kLabel08: UILabel!
    @IBOutlet weak var kLabel09: UILabel!
    @IBOutlet weak var kLabel10: UILabel!
    @IBOutlet weak var kLabel11: UILabel!
    @IBOutlet weak var kLabel12: UILabel!
    @IBOutlet weak var kLabel13: UILabel!
    @IBOutlet weak var kLabel14: UILabel!
    @IBOutlet weak var kLabel15: UILabel!
    var _type:String = ""
    
    deinit {
        //print("deinit")
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
        keiyakuField.delegate = self
        scanBtn.addTarget(self, action: #selector(scan(_ :)), for: .touchUpInside)
        printBtn.addTarget(self, action: #selector(display), for: .touchUpInside)
        detailBtn.addTarget(self, action: #selector(dispDetail), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        edtBtn.addTarget(self, action: #selector(editCollection(_:)), for: .touchUpInside)
        
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
        uploadedLabel.isHidden = true
        self.dspInit()
        
    }
    
    func dspInit(){
        //変数クリア
        _json = nil
        printData = nil
        YOTEI_HI = nil
        seizouHI = nil
        enrolled = false
        isBLXexist = false
        isPostImage = false
        kanriLabel.text = ""
        iArr = []
        imageArr = []
        cellEditing = false
        edtBtn.setTitle("編集", for: .normal)
        photoCollection.reloadData()
        isImgUploaded = false
        uploadedLabel.isHidden = true
        
        if tagNO == "" {
            tagField.text = ""
            tagLabel.text = "TagNo.未入力"
            tagLabel.textColor = .gray
        }
        if keiNO == "" {
            keiyakuField.text = ""
        }
        
        labelImgView.image = nil
        
        fnLabel1.text = "未"
        fnLabel2.text = "未"
        fnLabel3.text = "未"
        kanriView.isHidden = true
        for lbl in kanriLabels {
            lbl.text = ""
        }
        
    }
    
    override func viewDidLayoutSubviews() {
//        print(#function)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.photoCollection.reloadData()
        connectChk()
        if printData != nil {
            self.imageChk()
        }
        
    }
    
    func imageChk() {
        if printData != nil, printData.jita2 != "", printData.jita2 != "0" { //2枚目預りがある場合は、写真4枚以上必要
            imgCnt = 4
        }else {
            imgCnt = 2
        }
        
        if imageArr.count + iArr.count < imgCnt {
            fnLabel2.text = "未"
        }else {
            fnLabel2.text = "済"
        }

    }

    func setKanriLabel() {
        if _json == nil {return}
        kanriView.isHidden = false
        kanriView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        kanriView.layer.borderWidth = 2
        kanriView.layer.cornerRadius = 8
        for lbl in kanriLabels {
            lbl.text = ""
        }

        if let yotei = _json["YOTEI_HI"] as? String, yotei != ""{
            if yotei.count == 8 {
                kLabel01.text = yotei.date.toString(format: "yyyy年MM月dd日")
            }
        }

        let grade1 = _json["GRADE1"] as? String ?? ""
        let ritsu1 = _json["RITSU1"] as? String ?? "0.0"
        let jita1 = _json["JITAK1"] as? String ?? ""
        let grade2 = _json["GRADE2"] as? String ?? ""
        let ritsu2 = _json["RITSU2"] as? String ?? "0.0"
        let jita2 = _json["JITAK2"] as? String ?? ""

        //grade1
        if grade1=="",ritsu1=="", jita1=="" {
            kLabel06.text = ""
        }else {
            var grd = ""
            if let obj = grd_lst.first(where: {$0.cd==grade1}) {
                grd = obj.nm
            }
            var ritsu = ""
            if let rit = Double(ritsu1), rit != 0.0 {
                ritsu = "\(Int(rit))"
            }
            
            var jita = ""
            let j = Int(jita1) ?? 0
            if j > 0 {
                let obj = jitaArray[j-1]
                jita = obj.nm
            }
            //kLabel06.text = grd + "　\(ritsu)\(jita)"
            kLabel06.text = "\(jita) \(grd) \(ritsu)"+"%"
        }
        
        //grade2
        if grade2=="",ritsu2=="", jita2=="" {
            kLabel07.text = ""
        }else {
            var grd = ""
            if let obj = grd_lst.first(where: {$0.cd==grade2}) {
                grd = obj.nm
            }
            var ritsu = ""
            if let rit = Double(ritsu2), rit != 0.0 {
                ritsu = "\(Int(rit))"
            }
            var jita = ""
            let j = Int(jita2) ?? 0
            if j > 0 {
                let obj = jitaArray[j-1]
                jita = obj.nm
            }
            //kLabel07.text = grd + "　\(ritsu)\(jita)"
            kLabel07.text = "\(jita) \(grd) \(ritsu)"+"%"
        }
        //仕上り重量
        if var wata = _json["WATA"] as? String, wata != "0.0" {
            wata = wata.trimmingCharacters(in: .whitespaces)
            if let dwata = Double(wata) {
                kLabel08.text = "\(dwata)"+" Kg"
            }else {
                kLabel08.text = wata
            }
        }
        //増減
        if let zgn = _json["ZOGEN"] as? String, zgn != "0" {
            kLabel09.text = zgn+" g"
        }else {
            kLabel09.text = "なし"
        }
        
        if let seizou = _json["SEIZOU"] as? String, seizou != "00000000" {
            let seiz = Array(seizou)
            if seiz.count == 8 {
                kLabel10.text = seiz[0...3]+"年"+seiz[4...5]+"月"
                
            }
  
        }
        //納期
        if let nouki = _json["NOUKI"] as? String, nouki != "0/00/00" {
            kLabel13.text = nouki
        }
        //出荷期限
        if let kigen = _json["KIGEN"] as? String, kigen != "0/00/00" {
            kLabel14.text = printData.kigen
        }
               
        kLabel02.text = tagNO//tagNO.
        kLabel03.text = _json["KEI_NO"] as? String ?? ""//契約NO.
        kLabel04.text = (_json["CUSTOMER_NM"] as? String ?? "")+" 様"//顧客
        kLabel05.text = (_json["SYOHIN_CD"] as? String ?? "")+": "+(_json["SYOHIN_NM"] as? String ?? "")//item
        kLabel11.text = _json["PATERN"] as? String ?? ""//パターン
        kLabel12.text = _json["CLASS"] as? String ?? ""//クラス
        kLabel15.isHidden = !(_json["YUSEN"] as? String == "1")
        
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
    
    //MARK: - ZBar Delegate
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
                tagNO = tag
                picker.dismiss(animated: true, completion: {
                    self.setTag()
                })
            }
                        
        }
    }

    func setTag(){
        if tagNO == "" {
            tagLabel.text = "TagNo.未入力"
            tagLabel.textColor = .gray
            tagField.text = ""
        }else {
            tagLabel.text = tagNO
            tagLabel.textColor = .black
            dspInit()
            self.request(type: "ENTCHK", param: ["TAG_NO":tagNO])
            getImages(tag:tagNO)
            
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        if imageArr.count > 0, isPostImage == false {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }else {
            tagNO = ""
            keiNO = ""
            dspInit()
        }
    }

    //ラベルシールのイメージを表示→印刷
    @objc func display(){
        kanriLabel.text = ""
        labelImgView.image = nil
//        print(_json)
//        print("tag=\(tagNO)")
        if _json==nil || _json["YOTEI_HI"] == nil {
            SimpleAlert.make(title: "印刷できません", message: "")
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
                              keiNO: _json["KEI_NO"] as? String ?? "",
                              itemCD: _json["SYOHIN_CD"] as? String ?? "",
                              itemNM: _json["SYOHIN_NM"] as? String ?? "",
                              nouki: _json["NOUKI"] as? String ?? "",
                              kigen: _json["KIGEN"] as? String ?? "",
                              juryo: _json["WATA"] as? String ?? "0.0",
                              zogen: _json["ZOGEN"] as? String ?? "0",
                              grade1: _json["GRADE1"] as? String ?? "",
                              ritsu1: _json["RITSU1"] as? String ?? "0.0",
                              jita1: _json["JITAK1"] as? String ?? "",
                              grade2: _json["GRADE2"] as? String ?? "",
                              ritsu2: _json["RITSU2"] as? String ?? "0.0",
                              jita2: _json["JITAK2"] as? String ?? "",
                              haiso_cd: _json["H_STNCD"] as? String ?? "",
                              haiso_nm: _json["H_STNNM"] as? String ?? "",
                              tanto:_json["TANTO_NM"] as? String ?? ""
        )
        
        kanri += "-"+printData.renban+"-"+printData.tagNO
        kanriLabel.text = kanri

        //シール１の設定
        settingLabel()
        //viewをimageに変換
        let img = brLabel.printView.toImage()
        labelImgView.image = img
        //シール２の設定
        settingLabel2()
        let img2 = kensaLabel.printView.toImage()
        
        //プリンターの状態チェック
        if !isConnectPrinter {
            SimpleAlert.make(title: "プリンターに接続してください", message: "")
            return
        }
        //印刷
        self.printLabel(image: img) //受付用ラベル
        self.printLabel(image: img2) //検査ラベル
        
    }
    
    //MARK: - シール1の設定
    func settingLabel() {
        brLabel = BRLabelView(frame:self.view.frame)
        let QR = "RF="+tagNO
        brLabel.yusenLabel.isHidden = !yusen
        brLabel.label1.text = printData.date+"-"+printData.renban
        brLabel.label2.text = printData.customer+" 様"
        brLabel.label3.text = printData.tagNO
        brLabel.label4.text = printData.itemCD
        brLabel.label5.text = printData.itemNM
        let nouki = Array(printData.nouki)
        if nouki.count==8 {
            print(nouki.prefix(4))
            //lbl.label6.text = nouki[0...3]+"/"+nouki[4...5]+"/"+nouki[6...7]
            brLabel.label6.text = nouki[4...5]+"月"+nouki[6...7]+"日"
        }else {
            if printData.nouki.contains("/") {
                let n = printData.nouki.components(separatedBy: "/")
                if n.count>2 {
                    print(n)
                    brLabel.label6.text = n [1]+"月"+n[2]+"日"
                }else {
                    brLabel.label6.text = printData.nouki
                }
            }
        }
        
        let kigen = Array(printData.kigen)
        if kigen.count==8 {
            //lbl.label7.text = kigen[0...3]+"/"+kigen[4...5]+"/"+kigen[6...7]
            brLabel.label7.text = kigen[4...5]+"月"+kigen[6...7]+"日"
        }else {
            if printData.kigen.contains("/") {
                let n = printData.kigen.components(separatedBy: "/")
                if n.count>2 {
                    print(n)
                    brLabel.label7.text = n[1]+"月"+n[2]+"日"
                }else {
                    brLabel.label7.text = printData.nouki
                }
            }
        }
        if printData.juryo == "0.0" {
            brLabel.label8.text = "---"
        }else {
            brLabel.label8.text = printData.juryo
        }
        if printData.zogen == "0" {
            brLabel.label9.text = "---"
        }else {
            brLabel.label9.text = printData.zogen
        }
        //grade1
        if printData.grade1=="",printData.ritsu1=="", printData.jita1=="" {
            brLabel.label10.text = "---"
        }else {
            var grd = ""
            if let obj = grd_lst.first(where: {$0.cd==printData.grade1}) {
                grd = obj.nm
            }
            var ritsu = ""
            if let rit = Double(printData.ritsu1), rit != 0.0 {
                ritsu = "\(Int(rit))"
            }
            var jita = ""
            switch printData.jita1 {
            case "1":
                jita = "自"
            case "2":
                jita = "他"
            case "3":
                jita = "再"
            default:
                jita = ""
            }

            brLabel.label10.text = grd + "　\(ritsu)\(jita)"
        }
        //grade2
        if printData.grade2=="",printData.ritsu2=="", printData.jita2=="" {
            brLabel.label11.text = "---"
        }else {
            var grd = ""
            if let obj = grd_lst.first(where: {$0.cd==printData.grade2}) {
                grd = obj.nm
            }
            var ritsu = ""
            if let rit = Double(printData.ritsu2), rit != 0.0 {
                ritsu = "\(Int(rit))"
            }
            var jita = ""
            switch printData.jita2 {
            case "1":
                jita = "自"
            case "2":
                jita = "他"
            case "3":
                jita = "再"
            default:
                jita = ""
            }

            brLabel.label11.text = grd + "　\(ritsu)\(jita)"
        }
                
        brLabel.qrView.image = UIImage.makeQR(code: QR)
        
    }
    //MARK: - シール2の設定
    func settingLabel2() {
        kensaLabel = KensaLabelView(frame:self.view.frame)
        kensaLabel.sitenCD.text = printData.haiso_cd
        kensaLabel.sitenNM.text = printData.haiso_nm
        kensaLabel.nouki.text = printData.nouki
        kensaLabel.tagNO.text = printData.tagNO
        kensaLabel.keiNO.text = printData.keiNO
        kensaLabel.itemNO.text = printData.itemCD
        kensaLabel.itemNM.text = printData.itemNM
        kensaLabel.customer.text = printData.customer+" 様"
        kensaLabel.tantou.text = printData.tanto
        kensaLabel.takuhai.text = ""
        let code = "2300"+printData.tagNO
        if Int(code) != nil, code.count==12 {
            //１文字ずつ分割
            let array = Array(code).map({Int(String($0))!})
            var chk = 0
            for (i,val) in array.enumerated() {
                //チェックデジットの計算
                if i % 2 == 1 { //奇数
                    chk += val*3
                }else { //偶数
                    chk += val
                }
            }
            let digit = String(10-(chk % 10))
            kensaLabel.barcodeLabel.text = code + digit
            kensaLabel.barcodeView.image = UIImage.makeEAN13(code: code + digit)
        }

    }
       
    //テスト用
    @IBAction func dspLabel(_ sender:UIButton) {
        self.settingLabel2()
        //表示テスト
        let img = kensaLabel.printView.toImage()
        let labelVC = LabelViewController()
        labelVC.image = img
        labelVC.modalPresentationStyle = .fullScreen
        self.present(labelVC, animated: true, completion: nil)

    }
    
    func request(type:String, param:[String:Any]) {
        //self.dspInit()
        DispatchQueue.main.async {
            self.conAlert = UIAlertController(title: "データ取得中", message: "しばらくお待ちください", preferredStyle: .alert)
            self.present(self.conAlert, animated: true, completion: nil)
        }
        
        IBM().IBMRequest(type: type, parameter: param, completionClosure: { [self](_,json,err) in
            print("IBMRequest")
            _json = nil
            printData = nil
            
            if err == nil, json != nil {
                print(json!)
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
                        print(self.isDouble)
                        enrolled = false
//                        if !self.isDouble {
//                            self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        }else {
//                            enrolled = false
//                        }
                    }
                    
                }else {
                    if type == "ENTRY" || type == "UPDATE" {
                        _json = json
                        enrolled = true
                    }else if json!["TAG_NO"] == nil { //契約No.でSearchした結果
                        //明細チェック
                        if let arr = json!["MEISAI"] as? [Dictionary<String,Any>], arr.count>0 {
                            DispatchQueue.main.async {
                                self.conAlert.dismiss(animated: true, completion: {
                                    self.display2(json: json!)
                                })
                            }
                        }else {
                            if errMsg == "" {
                                errMsg = "データ取得に失敗しました"
                            }
                            DispatchQueue.main.async {
                                self.conAlert.title = "エラー"
                                self.conAlert.message = errMsg
                                self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            }
                        }
                        
                    }else { //INQURY

                        DispatchQueue.main.async {
                            //INQURY
                            self.conAlert.dismiss(animated: true, completion: {
                                self.dispDetail()
                            })
                            
                        }
                    }
                    
                }
                
            }else {
                //print(err!)
                if errMsg == "" {
                    errMsg = "データ取得に失敗しました"
                }
                DispatchQueue.main.async {
                    self.conAlert.title = "エラー"
                    self.conAlert.message = errMsg
                    if !self.isDouble {
                        self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    }
                }
                
            }
            
            if type == "ENTRY" || type == "UPDATE" {
//            if self.isDouble {
                print("-----IBM登録-----")
                self.dispatchGroup.leave()
            }
        })
        
    }
    
    @objc func dispDetail(){//infoView表示

        if _json == nil {
            SimpleAlert.make(title: "表示する対象がありません", message: "")
            return
        }
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let infoVC = storyboard.instantiateViewController(identifier: "info") as! InfoViewController
        //let infoVC = storyboard.instantiateViewController(identifier: "info2") as! InfoViewController2
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
    
    func display2(json:Dictionary<String,Any>){
        if let arr = json["MEISAI"] as? [Dictionary<String,Any>], arr.count>0 {
            
            if arr.count == 1 { //明細が1つだったら、TagNo.で問い合わせ
                if let tag = arr[0]["TAG_NO"] as? String {
                    tagNO = tag
                    self.setTag()
                }else {
                    SimpleAlert.make(title: "データ取得に失敗", message: "")
                }
                
                return
            }
            
            var meisai:[KEIYAKU] = []
            //self.keiMeisai = []
            for dic in arr {
                print(dic)
                var azukari = ""
                if let azu = dic["AZU_HI"] as? String, azu.count == 6  { //預かり日yy/mm/ddに変換
                    let str = Array(azu)
                    azukari = str[0...1]+"/"+str[2...3]+"/"+str[4...5]
                    
                }
                let obj = KEIYAKU(tag: dic["TAG_NO"] as? String ?? "",
                                  syohinCD: dic["SYOHIN_CD"] as? String ?? "",
                                  syohinNM: dic["SYOHIN_NM"] as? String ?? "",
                                  jyotai: dic["JYOTAI"] as? String ?? "",
                                  azukari: azukari
                )
                
                meisai.append(obj)
                //print(keiMeisai)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let list = storyboard.instantiateViewController(withIdentifier: "refList") as! RefListViewController

            list.delegate = self
            list.array = meisai
            
            self.present(list, animated: true, completion: nil)

        }

    }

    //MARK: -RefListViewDelegate
    func getTag(tag: String) {
        tagNO = tag
        self.setTag()
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
    
    @objc func printLabel(image:UIImage) {
        //QL_820NWB
        guard let img = image.cgImage,
              let printSettings = BRLMQLPrintSettings(defaultPrintSettingsWith: .QL_820NWB)
        else {
            print("Error - Image file is not found.")
            SimpleAlert.make(title: "Error", message: "オブジェクトが見つかりません")
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
    
    @IBAction func entryDataAndImage(_ sender: UIButton) {
        print(_json)
        print(entryData)
        
        if isPostImage { return } //二重登録禁止
        if _json == nil {
            return
        }
        if entryData.count == 0, imageArr.count == 0 {
            //SimpleAlert.make(title: "データが不足しています", message: "")
            return
        }
        if entryData.count == 0 {
            SimpleAlert.make(title: "データが不足しています", message: "")
            return
        }
        
        //print(printData)
        if printData.jita2 != "", printData.jita2 != "0" { //2枚目預りがある場合は、写真4枚以上必要
            imgCnt = 4
        }else {
            imgCnt = 2
        }
        
        if _type == "ENTRY" {
            guard let yotei = _json["YOTEI_HI"] as? String, yotei != "" else {
                SimpleAlert.make(title: "工場管理日が未入力です", message: "")
                return
            }

            if imageArr.count + iArr.count < imgCnt {
                SimpleAlert.make(title: "\(imgCnt)枚以上画像が必要です", message: "")
                return
            }
        }
        
        //データ・画像両方送る
        let alert = UIAlertController(title: "送信してよろしいですか", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            self.isDouble = imageArr.count>0
            self.upload(type: self._type)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    func upload(type:String) {
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        self.dispatchGroup.enter()
        dispatchQueue.async(group: self.dispatchGroup) {
//            self.request(type: "ENTRY", param: self.entryData)
            self.request(type: type, param: self.entryData)
        }
        if imageArr.count > 0 {
            self.dispatchGroup.enter()
            dispatchQueue.async(group: self.dispatchGroup) {
                self.postImages()
            }
        }
        
        self.dispatchGroup.notify(queue: .main) {
            print("All Process Done!")
            print("enrolled = \(enrolled)")
            print("post = \(self.isPostImage)")
            self.isDouble = false
            
            DispatchQueue.main.async {
                //var success:Bool = false
                if enrolled {
                    self.conAlert.title = "登録成功"
                    self.conAlert.message! = "データ登録成功\n"
                    self.fnLabel3.text = "済"
                }
                if imageArr.count > 0 {
                    if self.isPostImage {
                        self.conAlert.title = "送信完了しました"
                        self.conAlert.message! += "画像送信成功\n"
                        
                        Upload().deleteFM(tag: tagNO)
//                        self.iArr = []
//                        imageArr = []
//                        self.photoCollection.reloadData()
//                        tagNO = ""
//                        self.tagField.text = ""
//                        self.setTag()
                        
                    }else {
                        self.conAlert.title = "画像アップロードに失敗しました"
                        self.conAlert.message! += "画像は未送信データに一時的に保存されました\n"+errorCode
                        //self.uploadFault = true
                        Upload().saveFM(tag: tagNO, arr: imageArr)
                    }
                }
                                
                self.conAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    if enrolled {
                        //ラベル印刷
                        self.display()
                    }
                }))
                    
            }
            
            
        }
    }
    
    //MARK: - 画像送信
    func postImages() {
//        isPostImage = false
        DispatchQueue.main.async {
            if self.conAlert != nil {
                self.conAlert.title = "画像送信中"
            }
            //self.present(self.postAlert, animated: true, completion: nil)
            print(_json["YOTEI_HI"] as? String)
            var date = Date().string
            if let yotei = _json["YOTEI_HI"] as? String {
                date = yotei.date.string
            }
            print(date)
            
            Upload().uploadData(date:date)
            NotificationCenter.default.addObserver(self, selector: #selector(self.finishUpload), name: Notification.Name(rawValue:"postImage"), object: nil)
        }
    }
    
    @objc func finishUpload(){
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"postImage"), object: nil)
        DispatchQueue.main.async {
            self.isPostImage = errorCode == ""
            self.dispatchGroup.leave()

        }
    }
    
    //アップロード済みの画像取得
    func getImages(tag:String){
        
        var json:Dictionary<String,Any>!
        //let path = "https://oktss03.xsrv.jp/refreshPhoto/refresh1.php"
        let url = URL(string: "https://oktss03.xsrv.jp/refreshPhoto/refresh1.php")!
        let param = "tagNo=\(tag)"
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
                        //print(json!)
                        let arr = json["images"] as? [String] ?? []
                        //print(arr)
                        DispatchQueue.main.async {
                            //Xserver内の画像を検索して、アップロード済みかどうか、チェック
                            if arr.count > 0 {
                                isImgUploaded = true
                                self.imgDL(arr: arr, tag: tag)
                                self.uploadedLabel.isHidden = false
                                //TODO: 画像存在する場合ラベル表示
                                if InfoViewController() != nil {
                                    if let label = InfoViewController().uploadedLabel {
                                        label.isHidden = false
                                    }
                                }
                                
                            }else {
                                isImgUploaded = false
                            }
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
    
    func imgDL(arr:[String], tag:String) {
        iArr = []
        
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
                    
                    self.iArr.append(img!)
                    
                }catch {
                    //エラー
                    print("imageファイルにアクセスできない")
                }
            }
            
            DispatchQueue.main.async {
                self.photoCollection.reloadData()
            }
        }
        
    }
    
    
    @objc func back(){
        if imageArr.count > 0, isPostImage == false {
            let alert = UIAlertController(title: "未送信の写真があります", message: "画像送信画面で送信または削除してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }else if tagNO != "" {
            let alert = UIAlertController(title: "データをクリアして戻ります", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  {
                Void in
                tagNO = ""
                self.dspInit()
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
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
        //imageArrがゼロだったら、編集ボタンを隠す
        edtBtn.isHidden = imageArr.count == 0
        return iArr.count+imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        cell.deleteBtn.isHidden = true
        let row = indexPath.item
        if indexPath.row < iArr.count {
            //Xserver上の写真
            cell.imageView.image = iArr[row]
            cell.filterView.isHidden = false
        
        }else {
            //撮影した写真
            cell.imageView.image = imageArr[row-iArr.count]
            cell.filterView.isHidden = true
            cell.deleteBtn.isHidden = !cellEditing
            cell.deleteBtn.tag = 300+row-iArr.count
            cell.deleteBtn.addTarget(self, action: #selector(deleteCell(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > iArr.count, !cellEditing { //編集中は拡大しない
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
            if imageArr.count == 0 {
                self.cellEditing = false
            }
            DispatchQueue.main.async {
                self.photoCollection.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

extension ReceptionViewController:UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.tag)
        keiNO = ""
        if textField.text! == "" {return}
        
        switch textField.tag {
        case 100, 101://tag Fieldの時
            if Int(textField.text!) == nil {
                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
                return
            }
            if textField.text?.count != 8 {
                SimpleAlert.make(title: "数字８桁で入力してください", message: "")
                return
            }
            
            if textField.tag == 100 { //tagField
                tagNO = textField.text!
                setTag()
            }else { //keiyakuField
                //契約No.でSearch
                keiNO = textField.text!
                dspInit()
                self.request(type: "SEARCH", param: ["KEI_NO":keiNO])
            }
            
        default:
            return
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
}

//MARK: InfoViewControllerDelegate
extension ReceptionViewController:InfoViewControllerDelegate {
    func setEntry(param: [String : Any], type:String) {
        //print(_json)
//        print(type)
        self.entryData = param
        print(param)
        _type = type
        if param.count > 0 {
            self.fnLabel1.text = "済"
        }else {
            self.fnLabel1.text = "未"
        }
        if printData != nil {
            self.imageChk()
        }
        setKanriLabel()
//        textView.text = "\(_json)"
    }

    func setPrintInfo(json: Dictionary<String,Any>!, type: String) {
        print(type)
        if type == "print" {
            //print(json!)
            _json = json
            self.display()
        //}else{
        }else if type == "delete" {
            self.dspInit()
            self.clear(self)
        }else if type == "update" {
            self.fnLabel1.text = "済"
            self.fnLabel3.text = "済"
            if printData != nil {
                self.imageChk()
            }
            setKanriLabel()
//            textView.text = "\(json)"
        }
        
    }

}

