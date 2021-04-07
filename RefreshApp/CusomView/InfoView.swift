//
//  InfoView.swift
//  
//
//  Created by administrator on 2021/04/06.
//

import UIKit

class InfoView: UIView {
    
    @IBOutlet weak var yoteiBtn:UIButton!
    @IBOutlet weak var seizouBtn:UIButton!

    @IBOutlet weak var jita1Field: UITextField!
    @IBOutlet weak var grd1Field: UITextField!
    @IBOutlet weak var ritsu1Field: UITextField!
    @IBOutlet weak var jita2Field: UITextField!
    @IBOutlet weak var grd2Field: UITextField!
    @IBOutlet weak var ritsu2Field: UITextField!
    @IBOutlet weak var juryoField: UITextField!
    @IBOutlet weak var zogenField: UITextField!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    

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
        guard let view = UINib(nibName: "InfoView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }

}
