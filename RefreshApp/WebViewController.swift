//
//  WebViewController.swift
//  RefreshApp
//
//  Created by administrator on 2021/02/04.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import AVFoundation

class WebViewController: UIViewController {

    var webView: WKWebView!
    //var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView = WKWebView(frame: self.view.frame)
        //webView = UIWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let url = "https://www2.maruhati.com/ipad/test/a/index.html"
        let request = URLRequest(url: URL(string:url)!)
        webView.load(request)
        //webView.loadRequest(request)
        
    }

}
