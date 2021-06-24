//
//  DetailView2.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/03/07.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

struct Kotei {
    var kotei:String = ""
    var date:String = ""
    var tanto:String = ""
    var juryo:String = ""
    var temp:String = ""
    var humid:String = ""
    var weather:String = ""
    var g_gram:Int = 0
    var s_gram:Int = 0
}

class DetailView2: UIView {

    @IBOutlet var juryo1Label: UILabel!
    @IBOutlet var juryo2Label: UILabel!
    @IBOutlet var juryo3Label: UILabel!
    @IBOutlet var juryo4Label: UILabel!
    @IBOutlet var juryo5Label: UILabel!

    @IBOutlet var kensaLabel: UILabel!
    @IBOutlet var ukeLabel: UILabel!
    @IBOutlet var barashiLabel: UILabel!
    @IBOutlet var senjoLabel: UILabel!
    @IBOutlet var tounyuLabel: UILabel!
    @IBOutlet var saisyuLabel: UILabel!
    @IBOutlet var syukkaLabel: UILabel!
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    var json:Dictionary<String,Any>!
    @IBOutlet weak var tableView: UITableView!

    var koteiArray:[Kotei] = []
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if json == nil {return}
        //２ページ目
        koteiArray = []
        
        for list in koteiList { // koteiList(IBMから取得した工程All)
            var kotei = Kotei(kotei:list.val,date:"未")
            
            switch list.val {
            //case "iPad受注入力": //BLK031
            case "預かり日": //BLK005
                if var azu = json["AZUKARI"] as? String, azu != "0" {
                    if azu.count == 8 {
                        let str = Array(azu)
                        azu = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                    }
                    kotei.date = azu
                }
            case "受付検査": //BLK031
                if var kensa = json["UKE_KNS"] as? String, kensa != "0" {
                    if kensa.count == 8 {
                        let str = Array(kensa)
                        kensa = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                    }
                    kotei.date = kensa
                }
            case "工場受付": //BLX099
                if var uketuke = json["UKETUKE"] as? String, uketuke != "20000000" {
                    if uketuke.count == 8 {
                        let str = Array(uketuke)
                        uketuke = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                    }
                    kotei.date = uketuke
                }
            case "最終検査": //FJB005
                if var saisyu = json["SAISYU"] as? String, saisyu != "0" {
                    if saisyu.count == 8 {
                        let str = Array(saisyu)
                        saisyu = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                    }
                    kotei.date = saisyu
                }
            case "出荷": //BLK010
                if var syukka = json["SYUKKA"] as? String, syukka != "20000000" {
                    if syukka.count == 8 {
                        let str = Array(syukka)
                        syukka = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                    }
                    kotei.date = syukka
                }
            default: //それ以外
                if let arr = json["KOTEI_LST"] as? [Dictionary<String,Any>] {
                    for dic in arr {
                        //print(dic)
                        var date = ""
                        if let _date = dic["DATE"] as? String, _date.count == 8  { //yyyy/mm/ddに変換
                            let str = Array(_date)
                            date = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                        }
                        
                        if dic["KOTEI"] as? String == list.key {
                            //print(list.val+" = "+date)
                            var weather  = ""
                            if let cd = dic["WEATHER"] as? String{
                                if let obj = weatherList.first(where: {$0.key==cd}) {
                                    weather = obj.val
                                }
                            }
                            kotei = Kotei(kotei:list.val,
                                          date:date,
                                          tanto:dic["TANTO"] as? String ?? "",
                                          juryo:dic["JURYO"] as? String ?? "",
                                          temp:dic["TEMP"] as? String ?? "",
                                          humid:dic["HUMID"] as? String ?? "",
                                          weather:weather,
                                          g_gram:Int(dic["G_GRAM"] as? String ?? "0")!,
                                          s_gram:Int(dic["S_GRAM"] as? String ?? "0")!
                            )
                            
                        }
                        
                    }
                }
            }
            
            koteiArray.append(kotei)

        }
        //出荷
        var kotei4 = Kotei(kotei: "出荷",date:"未")
        if var syukka = json["SYUKKA"] as? String, syukka != "20000000" {
            if syukka.count == 8 {
                let str = Array(syukka)
                syukka = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            kotei4.date = syukka
        }
        koteiArray.append(kotei4)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        tableView.reloadData()
    }
    /*
    func taihi(){
        //受付検査
        var kotei1 = Kotei(kotei: "受付検査")
        if var kensa = json["UKE_KNS"] as? String, kensa != "0" {
            if kensa.count == 8 {
                let str = Array(kensa)
                kensa = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            //self.kensaLabel.text = kensa
            kotei1.date = kensa
        }
        
        var kotei2 = Kotei(kotei: "工場受付")
        if var uketuke = json["UKETUKE"] as? String, uketuke != "20000000" {
            if uketuke.count == 8 {
                let str = Array(uketuke)
                uketuke = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            kotei2.date = uketuke
        }
        
        koteiArray = [kotei1,kotei2]
        //ばらし・洗浄・投入
        //print(json)
        if let arr = json["KOTEI_LST"] as? [Dictionary<String,Any>] {
            
            for list in koteiList {
                var kotei = Kotei(kotei:list.val,date:"未")
                //工場受付
                if list.key == "03" {
//                    if var uketuke = json["UKETUKE"] as? String, uketuke != "20000000" {
//                        if uketuke.count == 8 {
//                            let str = Array(uketuke)
//                            uketuke = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
//                        }
//                        print(uketuke)
//                        kotei.date = uketuke
//                    }
                    //最終検査
                }else if list.key == "07" {
                    if var saisyu = json["SAISYU"] as? String, saisyu != "0" {
                        if saisyu.count == 8 {
                            let str = Array(saisyu)
                            saisyu = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                        }
                        kotei.date = saisyu
                    }
                    //}else if list.key == "" {
                    
                }else {
                    for dic in arr {
                        //print(dic)
                        var date = ""
                        if let _date = dic["DATE"] as? String, _date.count == 8  { //yyyy/mm/ddに変換
                            let str = Array(_date)
                            date = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                        }
                        
                        if dic["KOTEI"] as? String == list.key {
                            //print(list.val+" = "+date)
                            var weather  = ""
                            if let cd = dic["WEATHER"] as? String{
                                if let obj = weatherList.first(where: {$0.key==cd}) {
                                    weather = obj.val
                                }
                            }
                            kotei = Kotei(kotei:list.val,
                                          date:date,
                                          tanto:dic["TANTO"] as? String ?? "",
                                          juryo:dic["JURYO"] as? String ?? "",
                                          temp:dic["TEMP"] as? String ?? "",
                                          humid:dic["HUMID"] as? String ?? "",
                                          weather:weather
                            )
                            
                        }
                        
                    }
                }
                koteiArray.append(kotei)
                
            }
        }
        
        //出荷
        var kotei4 = Kotei(kotei: "出荷予定",date:"未")
        if var syukka = json["SYUKKA"] as? String, syukka != "20000000" {
            if syukka.count == 8 {
                let str = Array(syukka)
                syukka = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            //self.syukkaLabel.text = syukka
            kotei4.date = syukka
        }
        koteiArray.append(kotei4)
    }
 */
    

    init(frame: CGRect, json:Dictionary<String,Any>!) {
        self.json = json
        super.init(frame: frame)
        self.nibInit()
    }

    /*//コードから生成したときに通る初期化処理
    override init(frame: CGRect, json:Dictionary<String,Any>!) {
        self.json = json
        super.init(frame: frame)
        self.nibInit()
    }
     */
    
    // ストーリーボードで配置した時の初期化処理
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
//        super.init(coder: aDecoder)
//        self.nibInit()
    }

    
    // xibファイルを読み込んでviewに重ねる
    fileprivate func nibInit() {
        // File's OwnerをXibViewにしたので ownerはself になる
        guard let view = UINib(nibName: "DetailView2", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }
    
}

extension DetailView2: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 65
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        print(#function)
        let obj = koteiArray[indexPath.row]
//        print(obj.kotei)
        if obj.kotei == "投入" {
            return 95
        }else {
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return koteiArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as! DetailTableViewCell
        
        let obj = koteiArray[indexPath.row]
                
        cell.koteiLabel.text = obj.kotei
        cell.dateLabel.text = obj.date
        cell.tantoLabel.text = obj.tanto
        
        cell.juryoLabel.text = obj.juryo != "" ? obj.juryo+"Kg":""
        cell.tempLabel.text = obj.temp != "" ? obj.temp+"℃":""
        cell.humidLabel.text = obj.humid != "" ? obj.humid+"%":""
        cell.weatherLabel.text = obj.weather

        cell.tonyuView.isHidden = !(obj.kotei == "投入") //投入の時だけ表示
        if obj.kotei == "投入" {
            cell.label1.text = "側重量:\(obj.g_gram) g"
            cell.label2.text = "総重量:\(obj.s_gram) g"
            cell.label3.text = "投入量:\(obj.s_gram-obj.g_gram) g"
        }
        
        return cell
    }
    
}
