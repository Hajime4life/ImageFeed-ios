@testable import Image_Feed
import XCTest

// MARK: - ProfilePresenterSpy
final class ProfilePresenterSpy: ProfilePresenterProtocol {
    // MARK: - Public Props
    var viewDidLoadCalled: Bool = false
    var didTapLogoutButtonCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
}

// MARK: - ProfileViewControllerTests
final class ProfileViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // when
        viewController.viewDidLoad()
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsDidTapLogoutButton() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // when
        viewController.logoutButtonTapped()
        
        // then
        XCTAssertTrue(presenter.didTapLogoutButtonCalled)
    }
}
