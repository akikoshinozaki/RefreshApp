//
//  Info2View.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/03/07.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class DetailView: UIView {
    
    @IBOutlet var yusenLabel: UILabel!
    
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var syohinLabel: UILabel!
    @IBOutlet var pattenLabel: UILabel!
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var keiyakuLabel: UILabel!
    @IBOutlet var customerLabel: UILabel!
    
    @IBOutlet var jitak1Label: UILabel!
    @IBOutlet var grade1Label: UILabel!
    @IBOutlet var ritsu1Label: UILabel!
    @IBOutlet var jitak2Label: UILabel!
    @IBOutlet var grade2Label: UILabel!
    @IBOutlet var ritsu2Label: UILabel!
    @IBOutlet var juryoLabel: UILabel!
    @IBOutlet var zogenLabel: UILabel!
    
    @IBOutlet var seizouLabel: UILabel!
    @IBOutlet var noukiLabel: UILabel!
    @IBOutlet var kigenLabel: UILabel!
    @IBOutlet var yuuyoLabel: UILabel!

    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var gawaLnkBtn: UIButton!
    var json:Dictionary<String,Any>!
    
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if json == nil {return}
        //print(json)
        
        self.tagLabel.text = json["TAG_NO"] as? String ?? ""
         let itemCD = json["SYOHIN_CD"] as? String ?? ""
        let itemNM = json["SYOHIN_NM"] as? String ?? ""
        self.syohinLabel.text = itemCD+": "+itemNM
        self.pattenLabel.text = json["PATERN"] as? String ?? ""
        self.classLabel.text = json["CLASS"] as? String ?? ""
//        keiyakuNO = json["KEI_NO"] as? String ?? ""
        self.keiyakuLabel.text = json["KEI_NO"] as? String ?? ""

        if let customer = json["CUSTOMER_NM"] as? String {
            self.customerLabel.text = customer + " 様"
        }
        //優先
        self.yusenLabel.isHidden = true
        if let yusen = json["YUSEN"] as? String, yusen != " " {
            self.yusenLabel.isHidden = false
        }
        //1枚目
        //自社・他社区分1
        if let jita = json["JITAK1"] as? String, jita != "" {
            let jita_k = Int(jita) ?? 0
            if jita_k > 0 {
                let obj = jitaArray[jita_k-1]
                self.jitak1Label.text = obj.cd+":"+obj.nm
            }
        }
        //羽毛グレード1
        if let grd1 = json["GRADE1"] as? String, grd1 != "  " {
            if let obj = grd_lst.first(where: {$0.cd==grd1}) {
                self.grade1Label.text = obj.nm
            }
        }
        //原料比率1
        if let ritsu = Double(json["RITSU1"] as? String ?? "0.0"), ritsu != 0.0 {
            self.ritsu1Label.text = "\(Int(ritsu))"
        }
        //2枚目
        //自社・他社区分2
        if let jita = json["JITAK2"] as? String, jita != "" {
            let jita_k = Int(jita) ?? 0
            if jita_k > 0 {
                let obj = jitaArray[jita_k-1]
                self.jitak2Label.text = obj.cd+":"+obj.nm
            }
        }
        //羽毛グレード2
        if let grd2 = json["GRADE2"] as? String, grd2 != "  " {
            if let obj = grd_lst.first(where: {$0.cd==grd2}) {
                self.grade2Label.text = obj.nm
            }
        }
        //原料比率2
        if let ritsu = Double(json["RITSU2"] as? String ?? "0.0"), ritsu != 0.0 {
            self.ritsu2Label.text = "\(Int(ritsu))"
        }
        
        //仕上り重量
        if var wata = json["WATA"] as? String, wata != "0.0" {
            wata = wata.trimmingCharacters(in: .whitespaces)
            if let dwata = Double(wata) {
                self.juryoLabel.text = "\(dwata)"
            }else {
                self.juryoLabel.text = wata
            }
        }
        
        //足し羽毛
        if let zogen = json["ZOGEN"] as? String, zogen != "0"{
            self.zogenLabel.text = zogen
        }

        //製造日
        
        if let seizou = json["SEIZOU"] as? String, seizou != "00000000"{
            let date = seizou.date
            let yy = Calendar.current.component(.year, from: date)
            let mm = Calendar.current.component(.month, from: date)
            self.seizouLabel.text = "\(yy)年\(mm)月"

        }
        //納期・期限
        if let nouki = json["NOUKI"] as? String, nouki != "0/00/00" {
            self.noukiLabel.text = nouki
        }
        if let kigen = json["KIGEN"] as? String, kigen != "0/00/00" {
            self.kigenLabel.text = kigen
        }
        if let yuuyo = json["YUUYO"] as? String, yuuyo != "0" {
            self.yuuyoLabel.text = yuuyo.trimmingCharacters(in: .whitespaces)
        }
        
    }
    

    //コードから生成したときに通る初期化処理
//    override init(frame: CGRect, json:Dictionary<String,Any>!) {
//        print("override init")
//        self.json = json
//        super.init(frame: frame)
//        self.nibInit()
//    }
    
    init(frame: CGRect, json:Dictionary<String,Any>!) {
        //print("init")
        self.json = json
        super.init(frame: frame)
        self.nibInit()
    }
    
    // ストーリーボードで配置した時の初期化処理
    required init?(coder aDecoder: NSCoder) {
        print("required init")
        fatalError("init(coder:) has not been implemented")
//        super.init(coder: aDecoder)
//        self.nibInit()
    }

    
    // xibファイルを読み込んでviewに重ねる
    fileprivate func nibInit() {
        // File's OwnerをXibViewにしたので ownerはself になる
        guard let view = UINib(nibName: "DetailView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }
    
}
