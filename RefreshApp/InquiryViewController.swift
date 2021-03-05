//
//  InquiryViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/02/22.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import AVFoundation

struct KEIYAKU {
    var tag:String = ""
    var syohinCD:String = ""
    var syohinNM:String = ""
    var jyotai:String = ""
    var azukari:String = ""
}

class InquiryViewController: UIViewController, ScannerViewDelegate {
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var envLabel: UILabel!
    @IBOutlet weak var kanriLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var yoteiLabel:UILabel!
    @IBOutlet weak var seizouLabel:UILabel!
    @IBOutlet weak var grade1:UILabel!
    @IBOutlet weak var grade2:UILabel!
    @IBOutlet weak var grade3:UILabel!
    @IBOutlet weak var juryo1:UILabel!
    @IBOutlet weak var juryo2:UILabel!
    @IBOutlet weak var yusen:UILabel!
    
    @IBOutlet var tagField: UITextField!
    @IBOutlet var dspLbls: [UILabel]!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailView1: UIView!
    
    var scanner:ScannerView!
    var conAlert:UIAlertController!
    let arr1 = ["1:自社","2:他社"]
    var keiMeisai:[KEIYAKU] = []
    var imgArr:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        scanBtn.addTarget(self, action: #selector(scan), for: .touchUpInside)
        tagField.delegate = self
        
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
        collectionView.delegate = self
        collectionView.dataSource = self

    }
    
    override func viewDidLayoutSubviews() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func dspInit(){
        //表示クリア
        for lbl in dspLbls {
            lbl.text = ""
        }
        kanriLabel.text = ""
        infoView.isHidden = true
    }

    @IBOutlet weak var keiyakuLabel: UILabel!
    var keiyakuNO = ""
    func display(json:NSDictionary){
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
                                   kigen: json["KIGEN"] as? String ?? "")

        dspLbls[0].text = printData.tagNO
        dspLbls[1].text = printData.itemCD+": "+printData.itemNM
        dspLbls[2].text = json["PATERN"] as? String ?? ""
        dspLbls[3].text = json["CLASS"] as? String ?? ""
        keiyakuNO = json["KEI_NO"] as? String ?? ""
        dspLbls[4].text = keiyakuNO
        if printData.customer != "" {
            dspLbls[5].text = printData.customer+" 様"
        }

        if printData.nouki != "0/00/00" {
            dspLbls[6].text = printData.nouki
        }
        if printData.kigen != "0/00/00" {
            dspLbls[7].text = printData.kigen
        }
        if let yuuyo = json["YUUYO"] as? String, yuuyo != "0" {
            dspLbls[8].text = yuuyo.trimmingCharacters(in: .whitespaces)
        }
        //自社・他社区分
        if let jita = json["JITA_K"] as? String, jita != " " {
            let jita_k = Int(jita) ?? 0
            if jita_k > 0 {
                grade1.text = arr1[jita_k-1]
            }
        }
        //羽毛グレード
        if let grade = json["GRADE"] as? String, grade != "  " {
            if let obj = grd_lst.first(where: {$0.cd==grade}) {
                grade2.text = obj.nm
            }
        }
        //原料比率
        if let ritsu = Double(json["RITSU"] as? String ?? "0.0"), ritsu != 0.0 {
            grade3.text = "\(Int(ritsu))"
        }
                
        if var wata = json["WATA"] as? String, wata != "0.0" {
            wata = wata.trimmingCharacters(in: .whitespaces)
            if let dwata = Double(wata) {
                juryo1.text = "\(dwata)"
            }else {
                juryo1.text = wata
            }
        }
        
        if let seizou = json["SEIZOU"] as? String, seizou != "00000000"{
            seizouLabel.text = formatter.string(from: seizou.date)

        }
        kanri += "-"+printData.renban+"-"+printData.tagNO
        kanriLabel.text = kanri
        
        //明細
        if let arr = json["MEISAI"] as? [NSDictionary], arr.count>1 {
            //seizouLabel.text = formatter.string(from: seizou.date)
            for dic in arr {
                print(dic)
                let obj = KEIYAKU(tag: dic["TAG_NO"] as? String ?? "",
                                  syohinCD: dic["SYOHIN_CD"] as? String ?? "",
                                  syohinNM: dic["SYOHIN_NM"] as? String ?? "",
                                  jyotai: dic["JYOTAI"] as? String ?? "",
                                  azukari: dic["AZU_HI"] as? String ?? ""
                )
                keiMeisai.append(obj)
            }
        }
        keiyakuLabel.text = keiyakuNO
        self.tableView.reloadData()
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
            self.getImages(tagNo: tagNO	)
        }
    }

    
    @objc func back(){
        let alert = UIAlertController(title: "データをクリアして戻ります", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            tagNO = ""
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
        //print(param)
        
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
    
    //アップロード済みの画像取得
    func getImages(tagNo:String) {

        var json:NSDictionary!
        let path = "https://oktss03.xsrv.jp/refreshPhoto/refresh1.php"
        let url = URL(string: path)!
        let param = "tagNo=\(tagNo)"
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
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        print(json!)
                        let arr = json["images"] as? [String] ?? []
                        DispatchQueue.main.async {
                            self.imgDL(arr:arr, tag:tagNo)
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

        imgArr = []
        let imgAlert = UIAlertController(title: "ダウンロード中", message: "しばらくお待ちください", preferredStyle: .alert)
        self.present(imgAlert, animated: true, completion: nil)
        
        for file in arr {
            //画像をダウンロードして配列に保存
            let str = "https://ipad:m8mawata@oktss03.xsrv.jp/refreshPhoto/\(file)"
            let encodeStr = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: encodeStr)!

            print(url)
            do{
                let imageData = try Data(contentsOf: url)
                let img = UIImage(data:imageData)

                imgArr.append(img!)
                
            }catch {
                //エラー
                print("imageファイルにアクセスできない")
            }
        }
        
        //print(imgArr.count)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        imgAlert.dismiss(animated: true, completion: nil)
        
    }
    
}

extension InquiryViewController:UITextFieldDelegate {

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
        
        return cell
    }
    
    
    
    
}

extension InquiryViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        cell.imageView.image = imgArr[indexPath.item]

        return cell
    }
    
}