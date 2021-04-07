//
//  InfoView.swift
//  
//
//  Created by administrator on 2021/04/06.
//

import UIKit

class InfoView2: UIView {
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var keiyakuLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var syohinLabel: UILabel!
    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var nohinLabel: UILabel!
    @IBOutlet weak var kigenLabel: UILabel!
    @IBOutlet weak var yuuyoLabel: UILabel!

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
        guard let view = UINib(nibName: "InfoView2", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }

}
