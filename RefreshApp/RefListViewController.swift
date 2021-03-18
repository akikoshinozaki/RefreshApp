//
//  RefListViewController.swift
//  
//
//  Created by administrator on 2021/03/16.
//

import UIKit

protocol RefListViewDelegate{
    func remove()
    func getTag(tag:String)
}

extension RefListViewDelegate {
    func remove(){
        print(#function)
    }
}

class RefListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var delegate:RefListViewDelegate?
    var array:[KEIYAKU] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //MARK:- TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "InqTableViewCell") as! InqTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "InqTableViewCell", for: indexPath) as! InqTableViewCell
        
        let obj = array[indexPath.row]
        
        cell.label1.text = obj.tag //TAG No.
        cell.label2.text = obj.syohinCD //商品CD
        cell.label3.text = obj.syohinNM //商品名
        cell.label4.text = obj.jyotai //状態
        cell.label5.text = obj.azukari //預り日
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = array[indexPath.row]
        self.dismiss(animated: true, completion: {
            self.delegate?.getTag(tag: obj.tag)
        })
    }
    
    
}
