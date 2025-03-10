import UIKit
import ProgressHUD

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    // MARK: - Public Props
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Props
    private var enterButton: UIButton?
    private var splashScreenLogoView: UIImageView?
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebViewController()
    }
    
    // MARK: - IB Actions
    @objc
    private func didEnterButtonTapped() {
        showWebView()
    }
    
    // MARK: - Public Methods
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        UIBlockingProgressHUD.show()
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    private func showWebView() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true)
    }
    
    private func setWebViewController() {
        view.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        setEnterButton()
        setSplashScreenLogoView()
    }
    
    private func setEnterButton() {
        let enterButton = UIButton()
        enterButton.setTitle("Войти", for: .normal)
        enterButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        enterButton.setTitleColor(#colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1), for: .normal)
        enterButton.setTitleColor(#colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1), for: .highlighted)
        enterButton.backgroundColor = .white
        enterButton.addTarget(self, action: #selector(didEnterButtonTapped), for: .touchUpInside)
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        enterButton.layer.cornerRadius = 16
        view.addSubview(enterButton)
        
        enterButton.widthAnchor.constraint(equalToConstant: 343).isActive = true
        enterButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        enterButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 640).isActive = true
        
        self.enterButton = enterButton
    }
    
    private func setSplashScreenLogoView() {
        let splashScreenLogoView = UIImageView()
        let splashScreenLogo = UIImage(named: "splash_screen_logo")
        splashScreenLogoView.image = splashScreenLogo
        splashScreenLogoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashScreenLogoView)
        
        splashScreenLogoView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        splashScreenLogoView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        splashScreenLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        splashScreenLogoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.splashScreenLogoView = splashScreenLogoView
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
