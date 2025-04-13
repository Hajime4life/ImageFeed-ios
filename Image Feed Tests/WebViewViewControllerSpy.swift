import Image_Feed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    // MARK: - Public Props
    var loadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    var setProgressHiddenCalledWith: Bool?
    
    // MARK: - Public Methods
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    
    func setProgressHidden(_ isHidden: Bool) {
        setProgressHiddenCalledWith = isHidden
    }
}
