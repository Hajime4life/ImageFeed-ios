@testable import Image_Feed
import XCTest

// MARK: - WebViewPresenterSpy
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    // MARK: - Public Props
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        // Заглушка, не используется в тесте
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    func didTapBackButton() {
        // Заглушка, не используется в тесте
    }
}

// MARK: - WebViewTests
final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = WebViewViewController()
        let authHelper = AuthHelper()
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
        
        // Сценарий 1: Корректный URL с кодом
        let validURLString = "https://unsplash.com/oauth/authorize/native?code=abc123"
        guard let validURL = URL(string: validURLString) else {
            XCTFail("Failed to create valid URL")
            return
        }
        
        // Сценарий 2: Некорректный URL (неправильный путь)
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
}
