//
//  Camera2ViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/08.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

public extension UIView {
    func convertToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class Camera2ViewController: UIViewController {
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var composeView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    
    var image:UIImage!
    var shutterButton = UIButton()
    
    // 回転禁止
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面の向きを固定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        print(self.view.frame)
        print(imgView.frame)
        imgView.image = dispImg
        
        //tagNOがあれば表示
        if tagNO == "" {
            tagLabel.font = UIFont.boldSystemFont(ofSize: 50)
            tagLabel.text = "TAGNoが不明です"
            tagLabel.textColor = .red
        }else {
            tagLabel.font = UIFont.boldSystemFont(ofSize: 100)
            tagLabel.text = tagNO
            tagLabel.textColor = .black
        }
        
        tagLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        tagLabel.textAlignment = .center
        tagLabel.adjustsFontSizeToFitWidth = true
        tagLabel.minimumScaleFactor = 0.5
        
        /* ツールバーの設定 */
        let cancelButton = UIBarButtonItem(title: "撮り直す", style: .plain, target: self, action: #selector(self.retake))
        let useButton = UIBarButtonItem(title: "写真を使用", style: .plain, target: self, action: #selector(self.usePhoto))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [cancelButton,flexSpace, useButton]
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func usePhoto() {
        let img = composeView.convertToImage()
        imageArr.append(img!)
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        //self.navigationController?.popToRootViewController(animated: true)

    }
    
    //取り直し
    @objc func retake() {
        dispImg = nil
        self.dismiss(animated: false, completion: nil)
        //self.navigationController?.popViewController(animated: true)
    }
    

}
