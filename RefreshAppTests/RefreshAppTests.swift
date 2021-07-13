//
//  RefreshAppTests.swift
//  RefreshAppTests
//
//  Created by AkikoShinozaki on 2021/07/12.
//  Copyright © 2021 Akiko Shinozaki. All rights reserved.
//

import XCTest
//@testable import RefreshApp

class RefreshAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //時間を調べて、IBM稼働中かチェック
        let time = Calendar.current.component(.hour, from: Date())
        yakan = !(workTime.contains(time))
        //print(yakan)
        

        for key in kList {
            let list = defaults.object(forKey: key) as? [Dictionary<String,Any>] ?? []
            lList.append((key:key, list:list))
        }
//        GetLists().setList(lists: lList)
        print(lList)
        
        let _koteiList = koteiList.filter({$0.flag==true})
        let maxrow = _koteiList.count-1
        print(koteiList)
        print(_koteiList)
        
        
        print(maxrow)



        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
