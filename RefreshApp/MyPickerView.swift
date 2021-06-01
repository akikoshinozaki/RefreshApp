//
//  MyPickerView.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2021/01/25.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

protocol MyPickerViewDelegate{
    func setDate(date:Date, dateTime:String)
    func pickerCancel()
}

extension MyPickerViewDelegate {
    func pickerCancel() {

    }
}

class MyPickerView: UIView {

    var delegate:MyPickerViewDelegate?
        
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var selectedTime:Date?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code

        //baseView.layer.cornerRadius = 8

        if selectedTime != nil {
            picker.date = selectedTime!
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
        guard let view = UINib(nibName: "MyPickerView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    @IBAction func selectDate(_ sender: UIDatePicker) {
        print(sender.date)
        var str = ""
        if sender.tag == 100 {
            str = "date"
        }else {
            str = "time"
        }
        delegate?.setDate(date: sender.date, dateTime:str)
    }

}
