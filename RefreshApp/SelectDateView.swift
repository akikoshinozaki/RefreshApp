//
//  SelectDateView.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/01/25.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

protocol SelectDateViewDelegate{
    func setDate(date:Date)
    func clear()
}

extension SelectDateViewDelegate {
    func clear() {
        
    }
}

class SelectDateView: UIView {

    var delegate:SelectDateViewDelegate?
    
    @IBOutlet weak var picker: UIDatePicker!
    var selectedDate:Date?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        if selectedDate != nil {
            picker.date = selectedDate!
        }
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
        guard let view = UINib(nibName: "SelectDateView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
//    @IBAction func selectDate(_ sender: UIDatePicker) {
//        print(sender.date)
//        delegate?.setDate(date: sender.date)
//    }
    
    @IBAction func doneTapped(_ sender: Any) {
        print(picker.date)
        delegate?.setDate(date: picker.date)
        self.removeFromSuperview()
    }
    @IBAction func cancelTapped(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
