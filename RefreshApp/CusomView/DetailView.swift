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
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var gawaLnkBtn: UIButton!
    
    
    
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
        guard let view = UINib(nibName: "DetailView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }
    
}
