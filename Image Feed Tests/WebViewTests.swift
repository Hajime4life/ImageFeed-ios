@testable import Image_Feed
import XCTest

// MARK: - WebViewPresenterSpy
final class WebViewPresenterSpy: WebViewPresenterProtocol { /// По какой-то причине тест не видит этот класс в отдельном файле. Делал его и public, не помогло
    // MARK: - Public Props
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    func didTapBackButton() {}
}

// MARK: - WebViewTests
final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.viewDidLoad()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) // behaviour verification
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: viewController, delegate: nil, authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: viewController, delegate: nil, authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        let progress: Double = 0.6
        
        //when
        presenter.didUpdateProgressValue(progress)
        
        //then
        XCTAssertFalse(viewController.setProgressHiddenCalledWith ?? true)
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: viewController, delegate: nil, authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        let progress: Double = 1.0
        
        //when
        presenter.didUpdateProgressValue(progress)
        
        //then
        XCTAssertTrue(viewController.setProgressHiddenCalledWith ?? false)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testAuthHelperCodeFromURL() {
        //given
        let authHelper = AuthHelper()
        
        let validURLString = "https://unsplash.com/oauth/authorize/native?code=abc123"
        guard let validURL = URL(string: validURLString) else {
            XCTFail("Failed to create valid URL")
            return
        }
        
        let invalidURLString = "https://unsplash.com/wrong/path?code=abc123"
        guard let invalidURL = URL(string: invalidURLString) else {
            XCTFail("Failed to create invalid URL")
            return
        }
        
        //when
        let codeFromValidURL = authHelper.code(from: validURL)
        let codeFromInvalidURL = authHelper.code(from: invalidURL)
        
        //then
        XCTAssertEqual(codeFromValidURL, "abc123", "Should extract code from valid URL")
        XCTAssertNil(codeFromInvalidURL, "Should return nil for invalid URL")
    }
    
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(code, "test code")
    }
}
