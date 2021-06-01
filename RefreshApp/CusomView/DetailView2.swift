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
        //預り重量
        //洗浄後重量
        //洗浄前重量
        //投入重量
        koteiArray = []
        
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
        //受付
//        var kotei2 = Kotei(kotei: "受付")
//        if var uketuke = json["UKETUKE"] as? String, uketuke != "20000000" {
//            if uketuke.count == 8 {
//                let str = Array(uketuke)
//                uketuke = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
//            }
//            //self.ukeLabel.text = uketuke
//            kotei2.date = uketuke
//        }
        koteiArray = [kotei1]
        
        //ばらし・洗浄・投入
        if let arr = json["KOTEI_LST"] as? [Dictionary<String,Any>], arr.count>0 {
            
            for list in koteiList {
                var kotei = Kotei(kotei:list.val,date:"未")
                
                for dic in arr {
                    print(dic)
                    var date = ""
                    if let _date = dic["DATE"] as? String, _date.count == 8  { //yyyy/mm/ddに変換
                        let str = Array(_date)
                        date = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                    }
                    
                    if dic["KOTEI"] as? String == list.key {
                        print(list.val+" = "+date)
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
                        
                    }else if list.key == "03" { //工場受付
                        if var uketuke = json["UKETUKE"] as? String, uketuke != "20000000" {
                            if uketuke.count == 8 {
                                let str = Array(uketuke)
                                uketuke = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                            }
                            kotei.date = uketuke
                        }
                    }
                    
                }
                koteiArray.append(kotei)
                
            }
            /*
            for dic in arr {
                print(dic)
                var date = ""
                if let _date = dic["DATE"] as? String, _date.count == 8  { //yyyy/mm/ddに変換
                    let str = Array(_date)
                    date = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
                }
                
                print(koteiList)
                for list in koteiList {
                    var kotei = Kotei()
                    if dic["KOTEI"] as? String == list.key {
                        print(list.val+" = "+date)
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

                    }else {
                        kotei = Kotei(kotei:list.val,
                                      date:"未")
                    }
                    koteiArray.append(kotei)
                    
                }
                
            }
 */
        }
        //最終検査
        var kotei3 = Kotei(kotei: "最終検査",date:"未")
        if var saisyu = json["SAISYU"] as? String, saisyu != "0" {
            if saisyu.count == 8 {
                let str = Array(saisyu)
                saisyu = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            
            //self.saisyuLabel.text = saisyu
            kotei3.date = saisyu
        }
        koteiArray.append(kotei3)
        //出荷
        var kotei4 = Kotei(kotei: "出荷",date:"未")
        if var syukka = json["SYUKKA"] as? String, syukka != "20000000" {
            if syukka.count == 8 {
                let str = Array(syukka)
                syukka = str[0...3]+"/"+str[4...5]+"/"+str[6...7]
            }
            //self.syukkaLabel.text = syukka
            kotei4.date = syukka
        }
        koteiArray.append(kotei4)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        tableView.reloadData()
    }
    
//    //コードから生成したときに通る初期化処理
//    override init(frame: CGRect, json:Dictionary<String,Any>!) {
//        self.json = json
//        super.init(frame: frame)
//        self.nibInit()
//    }
    init(frame: CGRect, json:Dictionary<String,Any>!) {
        self.json = json
        super.init(frame: frame)
        self.nibInit()
    }
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
        
        return cell
    }
    
}
