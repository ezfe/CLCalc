//
//  CLTests.swift
//  CLTests
//
//  Created by Ezekiel Elin on 2/23/16.
//  Copyright © 2016 Ezekiel Elin. All rights reserved.
//

import XCTest

class CLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIntegerAddition() {
        let uip = UserInputObject("1+84")?.eval()
        XCTAssert(uip == 85)
    }
    
    func testFloatAddition() {
        let uip = UserInputObject("4.39234 + 12393.123")?.eval()
        XCTAssert(uip == 12397.51534)
    }
    
    func testDivision() {
        let uip = UserInputObject("954/5")?.eval()
        XCTAssert(uip == 190.8)
    }
    
    func testOOP() {
        let uip = UserInputObject("1+2*3")?.eval()
        XCTAssert(uip == 7)
        let uip2 = UserInputObject("1-1-1")?.eval()
        XCTAssert(uip2 == -1)
        let uip3 = UserInputObject("1-1-1*-1")?.eval()
        XCTAssert(uip3 == 1)
    }

}
