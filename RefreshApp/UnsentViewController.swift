//
//  UnsentViewController.swift
//  RefreshApp
//
//  Created by administrator on 2020/11/09.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

class UnsentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var list:[String] = []
    
    let fileManager = FileManager.default
    let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    //var path = ""
    @IBOutlet weak var tableView: UITableView!
    
    
    deinit {
        //print("deinit")
        imageArr = []
        tagNO = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "未送信データ"
        //list = getFileInfoListInDir(basePath)
        //print(list)
        tableView.delegate = self
        tableView.dataSource = self
    }
    	
    override func viewDidAppear(_ animated: Bool) {
        print("unsent" + #function)
        list = getFileInfoListInDir(basePath)
        tableView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        print("unsent" + #function)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func getFileInfoListInDir(_ dirName: String) -> [String] {
        var files: [String] = []
        do {
            files = try fileManager.contentsOfDirectory(atPath: dirName)
        } catch {
            return files
        }
        return files
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        return image
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tagNO = list[indexPath.row]
        let path = basePath.appending("/\(tagNO)/")
        
        var files: [String] = []
        do {
            files = try fileManager.contentsOfDirectory(atPath: path)
        } catch {
            //return files
        }
        
//        print(files)
        imageArr = []
        for file in files {
            let imgPath = path.appending(file)
            if let image = UIImage(contentsOfFile: imgPath) {
                imageArr.append(image)
            }
        }

        let storyboard: UIStoryboard = self.storyboard!
        let photo = storyboard.instantiateViewController(withIdentifier: "photo")
        
        self.navigationController?.pushViewController(photo, animated: true)
                
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            Upload().deleteFM(tag: list[indexPath.row])
//            list.remove(at: indexPath.row)
            list = self.getFileInfoListInDir(basePath)
            tableView.reloadData()
        }
    }
    

}

