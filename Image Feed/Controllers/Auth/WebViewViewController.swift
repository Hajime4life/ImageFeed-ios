import Foundation
import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - Public Props
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Private Props
    private var backButton: UIButton?
    private var webView: WKWebView?
    private var progressView: UIProgressView?
    private var estimatedProgressObservation: NSKeyValueObservation?
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        setWebViewController()
        guard let webView else { preconditionFailure("unwrap error webView") }
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        loadAuthView()
        webView.navigationDelegate = self
        addNewKVO()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateProgress()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public Methods
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
    
    // MARK: - Private Methods
    private func addNewKVO() {
        guard let webView else { preconditionFailure("unwrap error webView") }
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 self.updateProgress()
             }
        )
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        guard let webView else { preconditionFailure("unwrap error webView") }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        
        webView.load(request)
        updateProgress()
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
    private func updateProgress() {
        guard let webView else { preconditionFailure("unwrap error webView") }
        guard let progressView else { preconditionFailure("unwrap error progressView") }
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
        guard let chevronImage = UIImage(named: "backward_icon") else { preconditionFailure("chevron Image doesn't exist")}
        
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
        guard let backButton = self.backButton else { preconditionFailure("back button doesn't exist")}
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

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
