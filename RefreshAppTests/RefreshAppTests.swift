//
//  RefreshAppTests.swift
//  RefreshAppTests
//
//  Created by administrator on 2021/02/02.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import XCTest
@testable import RefreshApp

class RefreshAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testExample() {
        let exp = expectation(description: "test expectation")
        
        //var json:NSDictionary!
        var param = "COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HBR030&PROC_TYPE=INQUIRY&"
        param += "TAG_NO=72676340"
        /*
        for p in ["TAG_NO":"72676340"] {
            param += "\(p.key)=\(p.value)&"
        }
        
        if param.last == "&" {
            param = String(param.dropLast())
        }*/
        
        let url = URL(string: hostURL)!

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        // POSTを指定
        request.httpMethod = "POST"
        // POSTするデータをBodyとして設定
        request.httpBody = param.data(using: .utf8)
        
        session.dataTask(with: request) { (data, response, err) in
            
            if err != nil {
                print(err!.localizedDescription)
                XCTAssertNil(err)
            }
            
            guard let data = data
            else {
                print("error found in data")
                return
            }
            
            print("*******")
            
            let outputStr  = String(data: data, encoding: String.Encoding.utf8) as String?
            
            print (outputStr!)
            /*
            do{
                json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary

                print(json!)
                XCTAssertNil(err)
                XCTAssertNotNil(json)
                //exp?.fulfill()
                
            }catch{
                print("json error")
            }*/
            
            exp.fulfill()
            
        }.resume()
        
        
        waitForExpectations(timeout: 5.0) { (error) in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }

    }
    
    /*
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        var json:NSDictionary!
        //var errMsg = ""
        var param = "COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HBR030&PROC_TYPE=INQUIRY&"
        
        for p in ["TAG_NO":"72676340"] {
            param += "\(p.key)=\(p.value)&"
        }
        
        if param.last == "&" {
            param = String(param.dropLast())
            //print(param)
        }
        
        let url = URL(string: hostURL)!
        print(url)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        // POSTを指定
        request.httpMethod = "POST"
        // POSTするデータをBodyとして設定
        request.httpBody = param.data(using: .utf8)
        
        measure {
            let task = session.dataTask(with:request, completionHandler: {
                (data, response, err) in
                
                if (err == nil){
                    if(data != nil){
                        //戻ってきたデータを解析
                        do{
                            json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary

                            print(json!)
                            XCTAssertNil(err)
                            XCTAssertNotNil(json)
                            //exp?.fulfill()
                            
                        }catch{
                            print("json error")
                        }
                    }else{
                        print("レスポンスがない")
                    }
                    
                } else {
                    print("error : \(err!)")
                }

            })
            // タスクの実行.
            task.resume()
            
            
        }
    }*/
        
}
  
