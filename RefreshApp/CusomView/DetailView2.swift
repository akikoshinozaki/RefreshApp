//
//  DetailView2.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/03/07.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class DetailView2: UIView {
    

    //@IBOutlet var juryo1Label: UILabel!
    @IBOutlet var juryo2Label: UILabel!
    @IBOutlet var juryo3Label: UILabel!
    @IBOutlet var juryo4Label: UILabel!
    @IBOutlet var juryo5Label: UILabel!

    @IBOutlet var kensaLabel: UILabel!
    @IBOutlet var ukeLabel: UILabel!
    @IBOutlet var barashinLabel: UILabel!
    @IBOutlet var senjoLabel: UILabel!
    @IBOutlet var tounyuLabel: UILabel!
    @IBOutlet var saisyuLabel: UILabel!
    @IBOutlet var syukkaLabel: UILabel!
    

    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var backBtn: UIButton!
    
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
        guard let view = UINib(nibName: "DetailView2", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }
    
}
