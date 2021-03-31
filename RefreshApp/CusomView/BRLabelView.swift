//
//  BRLabelView.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/02/10.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class BRLabelView: UIView {

    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var label1: UILabel! //予定日-連番
    @IBOutlet weak var label2: UILabel! //顧客名
    @IBOutlet weak var label3: UILabel! //TAG No.
    @IBOutlet weak var label4: UILabel! //商品CD
    @IBOutlet weak var label5: UILabel! //商品名
    @IBOutlet weak var label6: UILabel! //納期
    @IBOutlet weak var label7: UILabel! //出荷期限
    @IBOutlet weak var qrView: UIImageView!
    @IBOutlet weak var yusenLabel: UILabel!
    @IBOutlet weak var label8: UILabel! //仕上り重量
    @IBOutlet weak var label9: UILabel! //足し羽毛
    @IBOutlet weak var label10: UILabel! //グレード1
    @IBOutlet weak var label11: UILabel! //グレード2
    
    
    
    @IBOutlet weak var jView: UIView!
    
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        yusenLabel.isHidden = true
//        jView.layer.borderWidth = 1
//        jView.layer.borderColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
    }
    
    
    //コードから生成したときに通る初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibInit()
    }
    
    // ストーリーボードで配置した時の初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibInit()
    }
    
    // xibファイルを読み込んでviewに重ねる
    fileprivate func nibInit() {
        // File's OwnerをXibViewにしたので ownerはself になる
        guard let view = UINib(nibName: "BRLabelView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }

}
