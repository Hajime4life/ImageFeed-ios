import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapBackButton()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: - Public Props
    weak var view: WebViewViewControllerProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Private Props
    private let authHelper: AuthHelperProtocol
    
    // MARK: - Init
    init(view: WebViewViewControllerProtocol, delegate: WebViewViewControllerDelegate?, authHelper: AuthHelperProtocol) {
        self.view = view
        self.delegate = delegate
        self.authHelper = authHelper
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(view as! WebViewViewController)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    // MARK: - Private Methods
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
