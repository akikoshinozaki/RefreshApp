//
//  BRLabelView2.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/04/13.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class KensaLabelView: UIView {
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var sitenCD: UILabel!
    @IBOutlet weak var sitenNM: UILabel!
    @IBOutlet weak var hokan: UILabel!
    
    @IBOutlet weak var nouki: UILabel!
    @IBOutlet weak var tagNO: UILabel!
    @IBOutlet weak var keiNO: UILabel!
    @IBOutlet weak var itemNO: UILabel!
    @IBOutlet weak var itemNM: UILabel!
    @IBOutlet weak var customer: UILabel!
    @IBOutlet weak var tantou: UILabel!
    
    @IBOutlet weak var kanriLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var barcodeView: UIImageView!
    
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
        guard let view = UINib(nibName: "KensaLabelView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
}
