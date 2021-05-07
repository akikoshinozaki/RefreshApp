//
//  InquiryViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/02/22.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//
//  問い合わせ画面

import UIKit
import AVFoundation

struct KEIYAKU {
    var tag:String = ""
    var syohinCD:String = ""
    var syohinNM:String = ""
    var jyotai:String = ""
    var azukari:String = ""
}

class InquiryViewController: UIViewController, ScannerViewDelegate,RefListViewDelegate {

    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var envLabel: UILabel!
    @IBOutlet weak var kanriLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var keiyakuView: UIView!
    @IBOutlet weak var yoteiLabel:UILabel!
     /*
    @IBOutlet weak var seizouLabel:UILabel!
    @IBOutlet weak var grade1:UILabel!
    @IBOutlet weak var grade2:UILabel!
    @IBOutlet weak var grade3:UILabel!
    @IBOutlet weak var juryo1:UILabel!
    @IBOutlet weak var juryo2:UILabel!
    @IBOutlet weak var yusen:UILabel!
    */
    @IBOutlet var tagField: UITextField!
    @IBOutlet weak var keiyakuField: UITextField!
    @IBOutlet var dspLbls: [UILabel]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoCollection: UICollectionView!
    @IBOutlet weak var imgCollection: UICollectionView!
    @IBOutlet weak var detailView1: UIView!
    @IBOutlet weak var keiyakuLabel: UILabel!
    var keiyakuNO = ""
    var syoCD = ""
    
    var scanner:ScannerView!
    var conAlert:UIAlertController!

    var keiMeisai:[KEIYAKU] = []
    var json_:Dictionary<String,Any>!
    var detail:DetailView!
    var detail2:DetailView2!
    var tagImg:[UIImage] = []
    var gawaImg:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        scanBtn.addTarget(self, action: #selector(scan), for: .touchUpInside)
        tagField.delegate = self
        keiyakuField.delegate = self
        
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "＜戻る", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn

        
        #if DEV
        envLabel.isHidden = false
        if hostURL == m8URL {
            envLabel.text = "本番環境です"
            envLabel.backgroundColor = #colorLiteral(red: 0.5981173515, green: 1, blue: 0.6414633393, alpha: 1)
        }else {
            envLabel.text = "開発環境です"
            envLabel.backgroundColor = #colorLiteral(red: 1, green: 0.9385977387, blue: 0.4325818419, alpha: 1)
        }
        #else
        envLabel.isHidden = true
        #endif

        dspInit()
        
        tableView.delegate = self
        tableView.dataSource = self
        imgCollection.delegate = self
        imgCollection.dataSource = self
        infoCollection.delegate = self
        infoCollection.dataSource = self
        infoCollection.isPagingEnabled = true
        
    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        var n:CGFloat = 2.0
//        var n:CGFloat = 3.0
//        if UIDevice.current.orientation == .portrait {
//            n = 2.0
//        }
        let layout = UICollectionViewFlowLayout()
        let wid = imgCollection.frame.size.width/n-10
        layout.itemSize = CGSize(width: wid, height: wid*0.7)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
        layout.sectionInsetReference = .fromSafeArea
        imgCollection.collectionViewLayout = layout
    }
    
    
    func dspInit(){
        //表示クリア
        for lbl in dspLbls {
            lbl.text = ""
        }
        kanriLabel.text = ""
        infoView.isHidden = true
        photoView.isHidden = true
        keiyakuView.isHidden = true
        
        gawaImg = []
    }

    
    func display(json:Dictionary<String,Any>){
        keiMeisai = []
        kanriLabel.text = ""
        keiyakuNO = ""
        
        var kanri = ""
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))

        var yotei_hi = ""
        if let yotei = json["YOTEI_HI"] as? String, yotei != ""{
            //登録済み → 再印刷or削除
            infoView.isHidden = false
            keiyakuView.isHidden = false
            infoView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            infoView.layer.shadowColor = UIColor.black.cgColor
            infoView.layer.shadowOpacity = 0.6
            infoView.layer.shadowRadius = 4
            
            yotei_hi = yotei.date.short
            yoteiLabel.text = formatter.string(from: yotei.date)
            kanri = yotei
        }else {
            //未登録 → 登録&印刷
            SimpleAlert.make(title: "登録なし", message: "リフレッシュ受付がされていません")
            return
        }
        
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
        
        //let detail:DetailView = DetailView(frame: self.infoView.frame)
        if detail == nil {return}
        if detail2 == nil {return}
        print("detail not nil")

        //１ページ目
        detail.tagLabel.text = printData.tagNO
        detail.syohinLabel.text = printData.itemCD+": "+printData.itemNM
        detail.pattenLabel.text = json["PATERN"] as? String ?? ""
        detail.classLabel.text = json["CLASS"] as? String ?? ""
        keiyakuNO = json["KEI_NO"] as? String ?? ""
        detail.keiyakuLabel.text = keiyakuNO

        if printData.customer != "" {
            detail.customerLabel.text = printData.customer+" 様"
        }
        //優先
        detail.yusenLabel.isHidden = true
        if let yusen = json["YUSEN"] as? String, yusen != " " {
            detail.yusenLabel.isHidden = false
        }
        //1枚目
        //自社・他社区分1
        if let jita = json["JITAK1"] as? String, jita != "" {
            let jita_k = Int(jita) ?? 0
            if jita_k > 0 {
                let obj = jitaArray[jita_k-1]
                detail.jitak1Label.text = obj.cd+":"+obj.nm
            }
        }
        //羽毛グレード1
        if let grd1 = json["GRADE1"] as? String, grd1 != "  " {
            if let obj = grd_lst.first(where: {$0.cd==grd1}) {
                detail.grade1Label.text = obj.nm
            }
        }
        //原料比率1
        if let ritsu = Double(json["RITSU1"] as? String ?? "0.0"), ritsu != 0.0 {
            detail.ritsu1Label.text = "\(Int(ritsu))"
        }
        //2枚目
        //自社・他社区分2
        if let jita = json["JITAK2"] as? String, jita != "" {
            let jita_k = Int(jita) ?? 0
            if jita_k > 0 {
                let obj = jitaArray[jita_k-1]
                detail.jitak2Label.text = obj.cd+":"+obj.nm
            }
        }
        //羽毛グレード2
        if let grd2 = json["GRADE2"] as? String, grd2 != "  " {
            if let obj = grd_lst.first(where: {$0.cd==grd2}) {
                detail.grade2Label.text = obj.nm
            }
        }
        //原料比率2
        if let ritsu = Double(json["RITSU2"] as? String ?? "0.0"), ritsu != 0.0 {
            detail.ritsu2Label.text = "\(Int(ritsu))"
        }
        
        //仕上り重量
        if var wata = json["WATA"] as? String, wata != "0.0" {
            wata = wata.trimmingCharacters(in: .whitespaces)
            if let dwata = Double(wata) {
                detail.juryoLabel.text = "\(dwata)"
            }else {
                detail.juryoLabel.text = wata
            }
        }
        
        //足し羽毛
        if let zogen = json["ZOGEN"] as? String, zogen != "0"{
            detail.zogenLabel.text = zogen
        }

        //製造日
        
        if let seizou = json["SEIZOU"] as? String, seizou != "00000000"{
            let date = seizou.date
            let yy = Calendar.current.component(.year, from: date)
            let mm = Calendar.current.component(.month, from: date)
            detail.seizouLabel.text = "\(yy)年\(mm)月"

        }
        //納期・期限
        if printData.nouki != "0/00/00" {
            detail.noukiLabel.text = printData.nouki
        }
        if printData.kigen != "0/00/00" {
            detail.kigenLabel.text = printData.kigen
        }
        if let yuuyo = json["YUUYO"] as? String, yuuyo != "0" {
            detail.yuuyoLabel.text = yuuyo.trimmingCharacters(in: .whitespaces)
        }
        
        detail.gawaLnkBtn.addTarget(self, action: #selector(gawaLink(_:)), for: .touchUpInside)
        //２ページ目
        //預り重量
        //洗浄後重量
        //洗浄前重量
        //投入重量
        //受付検査
        if var kensa = json["UKE_KNS"] as? String, kensa != "0" {
            if kensa.count == 8 {
                let str = Array(kensa)
                kensa = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            detail2.kensaLabel.text = kensa
        }
        //受付
        if var uketuke = json["UKETUKE"] as? String, uketuke != "20000000" {
            if uketuke.count == 8 {
                let str = Array(uketuke)
                uketuke = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            detail2.ukeLabel.text = uketuke
        }
        //ばらし
        //洗浄
        //投入
        //最終検査
        if var saisyu = json["SAISYU"] as? String, saisyu != "0" {
            if saisyu.count == 8 {
                let str = Array(saisyu)
                saisyu = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            detail2.saisyuLabel.text = saisyu
        }
        //出荷
        if var syukka = json["SYUKKA"] as? String, syukka != "20000000" {
            if syukka.count == 8 {
                let str = Array(syukka)
                syukka = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            detail2.syukkaLabel.text = syukka
        }
        
        kanri += "-"+printData.renban+"-"+printData.tagNO
        kanriLabel.text = kanri
        
        //明細
        if let arr = json["MEISAI"] as? [Dictionary<String,Any>], arr.count>0 {
            //seizouLabel.text = formatter.string(from: seizou.date)
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

                keiMeisai.append(obj)
            }
        }
        keiyakuLabel.text = keiyakuNO
        self.tableView.reloadData()
        //infoCollectionを１ページ目にセット
        self.infoCollection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
    
    func display2(json:Dictionary<String,Any>){
        print(json)
        if let arr = json["MEISAI"] as? [Dictionary<String,Any>], arr.count>0 {
            
            if arr.count == 1 {
                if let tag = arr[0]["TAG_NO"] as? String {
                    tagNO = tag
                    self.request(type: "INQUIRY", param: ["TAG_NO":tagNO])
                    self.getImages(parm: "tagNo", val: tagNO)
                }else {
                    SimpleAlert.make(title: "データ取得に失敗", message: "")
                }
                
                return
            }
            
            self.keiMeisai = []
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
                
                self.keiMeisai.append(obj)
                //print(keiMeisai)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let list = storyboard.instantiateViewController(withIdentifier: "refList") as! RefListViewController
            let list = storyboard.instantiateViewController(withIdentifier: "refList") as! RefListViewController
            
            //let gawaVC = storyboard.instantiateViewController(withIdentifier: "gawa") as! GawaImgViewController
            list.delegate = self
            list.array = keiMeisai
            
            self.present(list, animated: true, completion: nil)
            
        
        }

    }
    //MARK: -RefListViewDelegate
    //RefListで選択した時の挙動
    func getTag(tag: String) {
        tagNO = tag
        self.setTag()
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
        if tagNO != "" {
            self.request(type: "INQUIRY", param: ["TAG_NO":tagNO])
            self.getImages(parm: "tagNo", val: tagNO)
        }
    }
    
    @objc func back(){
        if infoView.isHidden {
            imageArr = []
            self.navigationController?.popViewController(animated: true)
            return
        }

        let alert = UIAlertController(title: "データをクリアして戻ります", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            tagNO = ""
            imageArr = []
            //dspInit()
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @objc func clear(){
        //self.dismiss(animated: true, completion: nil)
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
                    if json!["TAG_NO"] == nil { //契約No.でSearchした結果
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
                        self.syoCD = ""
                        if var cd = json!["SYOHIN_CD"] as? String, cd != "" {
                            //商品CD取得できたら、側生地画像取得
                            print(cd)
                            self.syoCD = cd
                            if cd.count<=8 { //ファイル名・8桁に揃える
                                let zero = String(repeating: "0", count: 8-cd.count)
                                cd = zero+cd
                            }
                            self.getImages(parm: "syoCD", val: cd)
                        }
                        
                        DispatchQueue.main.async {
                            //INQURY
                            self.conAlert.dismiss(animated: true, completion: {
                                self.display(json: json!)
                            })
                            
                        }
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
//        let imgAlert = UIAlertController(title: "ダウンロード中", message: "しばらくお待ちください", preferredStyle: .alert)
        //self.present(imgAlert, animated: true, completion: nil)
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
                    self.tagImg = iArr
                    if arr.count > 0 {
                        self.photoView.isHidden = false
                        self.imgCollection.reloadData()
                    }
                    
                }else {  //syoCD
                    self.gawaImg = iArr
                    if iArr.count > 0 {
                        self.detail.syohinLabel.textColor = .systemBlue
                    }else {
                        self.detail.syohinLabel.textColor = .black
                    }
                }
            }
        }
//        imgAlert.dismiss(animated: true, completion: nil)
        
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

extension InquiryViewController:UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.tag)
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

            if textField.tag  == 100 {
                tagNO = textField.text!
                setTag()
            } else if textField.tag  == 101 {
                //契約No.でSearch
                self.request(type: "SEARCH", param: ["KEI_NO":textField.text!])
            }
        
        default:
            return
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
}

extension InquiryViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keiMeisai.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "InqTableViewCell") as! InqTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "InqTableViewCell", for: indexPath) as! InqTableViewCell
        
        let obj = keiMeisai[indexPath.row]
        
        cell.label1.text = obj.tag //TAG No.
        cell.label2.text = obj.syohinCD //商品CD
        cell.label3.text = obj.syohinNM //商品名
        cell.label4.text = obj.jyotai //状態
        cell.label5.text = obj.azukari //預り日
        
        if obj.tag == tagNO {
            //照会したリフレッシュ分は色付け
            cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.8418682218, blue: 0.8868809342, alpha: 1)
        }else {
            cell.contentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = keiMeisai[indexPath.row]
        print(obj.tag)
        if obj.tag == tagNO { return }
        if obj.syohinNM.hasPrefix("ﾚﾝﾀﾙ") { return }
        tagNO = obj.tag
        self.setTag()
    }
	    
}

extension InquiryViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 888 { //imageCollectionView
            return tagImg.count
        }else {//infoCollectionView
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 888 { //imageCollectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
            cell.imageView.image = tagImg[indexPath.item]
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            let colSize = collectionView.frame.size
            if indexPath.row == 0 { //1ページ目
                detail = DetailView(frame: CGRect(x: 0, y: 0, width: colSize.width, height: colSize.height))
                detail.nextBtn.tag = 901
                detail.nextBtn.addTarget(self, action: #selector(pageChange), for: .touchUpInside)
                for lbl in detail.labels{ //初期化
                    lbl.text = ""
                }
                cell.contentView.addSubview(detail)

            } else {
                //2ページ目
                detail2 = DetailView2(frame: CGRect(x: 0, y: 0, width: colSize.width, height: colSize.height))
                detail2.backBtn.tag = 902
                detail2.backBtn.addTarget(self, action: #selector(pageChange), for: .touchUpInside)
                for lbl in detail2.labels{ //初期化
                    lbl.text = ""
                }
                cell.contentView.addSubview(detail2)
            }
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 888 {//imageCollectionView
            num = indexPath.row
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            imageArr = tagImg //画像を渡す
            let disp = storyboard.instantiateViewController(withIdentifier: "disp")
            disp.modalPresentationStyle = .fullScreen
            
            self.present(disp, animated: true, completion: nil)
        }
    }
        
}
