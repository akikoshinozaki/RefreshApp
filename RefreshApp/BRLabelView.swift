//
//  BRLabelView.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/02/10.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class BRLabelView: UIView {

    @IBOutlet weak var label1: UILabel! //予定日-連番
    @IBOutlet weak var label2: UILabel! //顧客名
    @IBOutlet weak var label3: UILabel! //TAG No.
    @IBOutlet weak var label4: UILabel! //商品CD
    @IBOutlet weak var label5: UILabel! //商品名
    @IBOutlet weak var label6: UILabel! //納期
    @IBOutlet weak var label7: UILabel! //出荷期限
    @IBOutlet weak var qrView: UIImageView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
