//
//  GawaImgViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/03/10.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit

class GawaImgViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var syoCDLabel: UILabel!

    var arr:[UIImage] = []
    var syoCD:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collection.delegate = self
        collection.dataSource = self
        
        syoCDLabel.text = "商品CD: \(syoCD)"
    }

    override func viewDidLayoutSubviews() {
        let layout = UICollectionViewFlowLayout()
        let wid = collection.frame.size.width
        
        //layout.estimatedItemSize = CGSize(width: wid/2-10, height: (wid/2-20)*0.7)
        //layout.itemSize = CGSize(width: wid/2-10, height: (wid/2-20)*0.7)
        layout.itemSize = CGSize(width: wid*0.7, height: wid*0.5)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.sectionInsetReference = .fromSafeArea
        collection.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        cell.imageView.frame.size = cell.frame.size
        cell.imageView.image = arr[indexPath.row]
        
        return cell
    }
    
    @IBAction func close(_ sender:UIButton) {
        imageArr = []
        self.dismiss(animated: true, completion: nil)
    }
    
}
