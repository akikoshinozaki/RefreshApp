//
//  LabelViewController.swift
//  LabelViewController
//
//  Created by 篠崎 明子 on 2021/10/18.
//

import UIKit

class LabelViewController: UIViewController {
    
    var imageView = UIImageView()
    var image:UIImage!
//    var label:KensaLabelView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 310, height: 600)))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.image = image
        
        self.view.addSubview(imageView)
         
//        imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)))
//        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//
//        self.view.addSubview(imageView)
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
