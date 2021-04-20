//
//  SimpleAlert.swift
//  m8navi2
//
//  Created by mapipo office on 2017/06/18.
//  Copyright © 2017年 mapipo office. All rights reserved.
//  mapipo office confidential

import UIKit
var window_ = UIWindow()
class SimpleAlert: NSObject {
    class func make (title: String?, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action1)
            
            if var topViewController: UIViewController = UIApplication.topViewController(){
                
                if topViewController.classForCoder == UIAlertController.classForCoder(){
                    topViewController.dismiss(animated: true, completion: {
                        topViewController = UIApplication.topViewController()!
                    })
                }
                topViewController.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    class func make (title: String?, message: String?, action:[UIAlertAction]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for act in action {
                alert.addAction(act)
            }
            
            if var topViewController: UIViewController = UIApplication.topViewController(){

                if topViewController.classForCoder == UIAlertController.classForCoder(){
                    topViewController.dismiss(animated: true, completion: {
                        topViewController = UIApplication.topViewController()!
                    })
                }
                topViewController.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
}

