//
//  _ReceptViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/02/19.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class _ReceptViewController: UIViewController {
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var baseView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //let shadowView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width/2-140, y: 60, width: 280, height: 120))
        //infoView.backgroundColor = UIColor.red
        //self.view.addSubview(infoView)
        infoView.layer.cornerRadius = 7.0

        // 影の方向（width=右方向、height=下方向、CGSize.zero=方向指定なし）
        infoView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        // 影の色
        infoView.layer.shadowColor = UIColor.black.cgColor
        // 影の濃さ
        infoView.layer.shadowOpacity = 0.6
        // 影をぼかし
        infoView.layer.shadowRadius = 4
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
