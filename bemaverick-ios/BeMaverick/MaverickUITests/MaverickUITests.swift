//
//  MaverickUITests.swift
//  MaverickUITests
//
//  Created by Garrett Fritz on 6/4/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import XCTest

class MaverickUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    var i = 0
    private func takeScreenshot(_ name : String) {
        
        snapshot("\(i)_\(name)")
        i = i + 1
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        
        addUIInterruptionMonitor(withDescription: "") { (alert) -> Bool in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
            }
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
            }
            
            return true
        }
        
       
        
        
        let element4 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        if app.buttons["GET STARTED"].exists {
            
            
            let element = element4.children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
            element.swipeLeft()
            takeScreenshot("splash2")
            element.swipeLeft()
            takeScreenshot("splash3")
            
            element.swipeLeft()
            takeScreenshot("splash4")
            element.swipeLeft()
            takeScreenshot("splash5")
            app.buttons["GET STARTED"].tap()
            takeScreenshot("GetStarted")
            app.buttons["SIGN IN"].tap()
            takeScreenshot("SignIn")
            
            let scrollViewsQuery = app.scrollViews.otherElements.scrollViews
            let logInElementsQuery = scrollViewsQuery.otherElements.containing(.button, identifier:"Log In")
            
            takeScreenshot("LogIn")
            let element2 = logInElementsQuery.children(matching: .other).element
            let usernameField = element2.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element
            usernameField.tap()
            usernameField.typeText("sarahfritz")
          
            
            let passwordField = element2.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element.children(matching: .secureTextField).element
            passwordField.tap()
            passwordField.typeText("1234qwer")
            scrollViewsQuery.otherElements.buttons["Log In"].tap()
            
            app.buttons["I'm Down"].tap()
            
            
        }
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["My Feed"].tap()
        tabBarsQuery.buttons["Challenges"].tap()
        tabBarsQuery.buttons["Featured"].tap()
        tabBarsQuery.buttons["My Profile"].tap()
        tabBarsQuery.buttons["Notifications"].tap()
        app.navigationBars["Maverick.NotificationView"].buttons["nav friends"].tap()


        let element3 = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element3.children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
       
        Thread.sleep(forTimeInterval: 1)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowBtn = springboard.buttons["OK"]
        if allowBtn.exists {
            allowBtn.tap()
        }
        Thread.sleep(forTimeInterval: 1)
        app.navigationBars["Text"].buttons["back"].tap()
        element3.children(matching: .other).element(boundBy: 2).children(matching: .button).element.tap()
        app.navigationBars["Email"].buttons["back"].tap()
        element3.children(matching: .other).element(boundBy: 3).children(matching: .button).element.tap()
        app.buttons["nevermind"].tap()
        app.navigationBars["Find My Friends"].buttons["DONE"].tap()
        
        
    }
    
    func testExample1() {
        
        
        
    }
    
}
