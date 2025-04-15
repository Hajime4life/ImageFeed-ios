import XCTest
@testable import Image_Feed
import SwiftKeychainWrapper

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    let email = "" // TODO: ТУТ ВВЕДИТЕ СВОЮ ПОЧТУ
    let password = "" // TODO: ТУТ ВВЕДИТЕ СВОЙ ПАРОЛЬ (Так описывает сам урок, что у вас свои учетки)
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-reset"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testAuth() throws {
        KeychainWrapper.standard.removeObject(forKey: "Auth token")
        
        let authButton = app.buttons["Authenticate"]
        if !authButton.waitForExistence(timeout: 15) {
            XCTFail()
        }
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText(email)
        
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText(password)
        
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
        
        cell.swipeUp()
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        
        cellToLike.buttons["likeButton"].tap()
        
        if app.alerts.element.staticTexts["Rate Limit Exceeded"].exists {
            app.alerts.element.buttons["OK"].tap()
            return
        }
        
        if app.alerts.element.staticTexts["Не удалось изменить лайк: Request already in progress"].exists {
            app.alerts.element.buttons["OK"].tap()
            return
        }
        
        sleep(15)
        
        cellToLike.buttons["likeButton"].tap()
        
        if app.alerts.element.staticTexts["Rate Limit Exceeded"].exists {
            app.alerts.element.buttons["OK"].tap()
            return
        }
        
        if app.alerts.element.staticTexts["Не удалось изменить лайк: Request already in progress"].exists {
            app.alerts.element.buttons["OK"].tap()
            return
        }
        
        sleep(2)
        
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButtonWhiteButton.waitForExistence(timeout: 5))
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        
        let profileTab = app.tabBars.buttons["profile tab"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        
        XCTAssertTrue(app.staticTexts["Name Lastname"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["@username"].waitForExistence(timeout: 5))
        
        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        let yesButton = alert.scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
        yesButton.tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 15))
    }
}
