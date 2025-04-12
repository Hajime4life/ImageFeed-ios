import Foundation
import UIKit
@preconcurrency import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WKNavigationDelegate, WebViewViewControllerProtocol {
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    private var backButton: UIButton?
    private var webView: WKWebView?
    private var progressView: UIProgressView?
    
    override func viewDidLoad() {
        setWebViewController()
        guard let webView else { preconditionFailure("unwrap error webView") }
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        webView.navigationDelegate = self
        addNewKVO()
        presenter?.viewDidLoad()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            guard let webView else { preconditionFailure("unwrap error webView") }
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    @objc
    private func didTapBackButton() {
        presenter?.didTapBackButton()
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func load(request: URLRequest) {
        guard let webView else { preconditionFailure("unwrap error webView") }
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        guard let progressView else { preconditionFailure("unwrap error progressView") }
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        guard let progressView else { preconditionFailure("unwrap error progressView") }
        progressView.isHidden = isHidden
    }
    
    private func addNewKVO() {
        guard let webView else { preconditionFailure("unwrap error webView") }
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [], context: nil)
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
    
    private func setWebViewController() {
        view.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        setWebView()
        setBackButton()
        setProgressView()
    }
    
    private func setWebView() {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.webView = webView
    }
    
    private func setBackButton() {
        guard let webView else { preconditionFailure("unwrap error webView") }
        guard let chevronImage = UIImage(named: "backward_icon") else { preconditionFailure("chevron Image doesn't exist") }
        
        let backButton = UIButton.systemButton(
            with: chevronImage,
            target: self,
            action: #selector(Self.didTapBackButton)
        )
        backButton.tintColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        backButton.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 9).isActive = true
        backButton.topAnchor.constraint(equalTo: webView.layoutMarginsGuide.topAnchor, constant: 9).isActive = true
        
        self.backButton = backButton
    }
    
    private func setProgressView() {
        guard let webView else { preconditionFailure("unwrap error webView") }
        guard let backButton = self.backButton else { preconditionFailure("back button doesn't exist") }
        let progressView = UIProgressView()
        progressView.tintColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(progressView)
        progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor).isActive = true
        self.progressView = progressView
    }
}
