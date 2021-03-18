//
//  DispViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/08.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

var num:Int = 0

class DispViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageCounter: UIPageControl!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = imageArr[num]
        
        if imageArr.count > 1 {
            //複数写真がある時
            forwardButton.isHidden = false
            nextButton.isHidden = false
            
            pageCounter.numberOfPages = imageArr.count
            pageCounter.currentPage = num
        }else {
            forwardButton.isHidden = true
            nextButton.isHidden = true
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forwardImage(_ sender: UIButton) {
        if num > 0 {
            num -= 1
            imageView.image = imageArr[num]
            pageCounter.currentPage = num
        }
    }
    
    @IBAction func nextImage(_ sender: UIButton) {
        if num <  imageArr.count-1 {
            num += 1
            imageView.image = imageArr[num]
            pageCounter.currentPage = num
        }
    }
}
