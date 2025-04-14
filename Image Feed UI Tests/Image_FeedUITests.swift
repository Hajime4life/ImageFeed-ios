import XCTest
import WebKit
@testable import Image_Feed
import SwiftKeychainWrapper

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    let email = "" // TODO: ТУТ ВСТАВЛЯЕТЕ ПОЧТУ
    let password = "" // TODO: ТУТ ВСТАВЛЯЕТЕ ПАРОЛЬ
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        KeychainWrapper.standard.removeObject(forKey: "Auth token")
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        URLCache.shared.removeAllCachedResponses()
        
        // Очистка данных от вебвью
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast) {
            print("WebView data cleared")
        }
        
        app.launchArguments = ["-reset"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 15))
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
        let table = tablesQuery.element
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 20))
        
        table.swipeUp()
        sleep(1)
        table.swipeUp()
        sleep(1)
        
        table.swipeDown()
        sleep(1)
        table.swipeDown()
        sleep(1)
        
        let likeButtonOff = firstCell.buttons["like button off"]
        let likeButtonOn = firstCell.buttons["like button on"]
        
        if likeButtonOff.waitForExistence(timeout: 5) {
            likeButtonOff.tap()
            sleep(15)
            XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 15))
            
            likeButtonOn.tap()
            sleep(15)
            XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 15))
        } else if likeButtonOn.waitForExistence(timeout: 5) {
            print("Like button on found")
            likeButtonOn.tap()
            sleep(15)
            XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 15))
            
            likeButtonOff.tap()
            sleep(15)
            XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 15))
        } else {
            XCTFail("")
        }
        
        firstCell.tap()
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
        
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 5))
    }
}
