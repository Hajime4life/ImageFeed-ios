@testable import Image_Feed
import XCTest

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
}


// MARK: - WebViewPresenterSpy
final class WebViewPresenterSpy: WebViewPresenterProtocol {
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

