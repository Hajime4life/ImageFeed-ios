import UIKit
import ProgressHUD

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    // MARK: - Public Props
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Props
    private lazy var enterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(#colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1), for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1), for: .highlighted)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didEnterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        return button
    }()
    
    private lazy var splashScreenLogoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage.shared
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    private func setupUI() {
        view.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        
        view.addSubview(enterButton)
        NSLayoutConstraint.activate([
            enterButton.widthAnchor.constraint(equalToConstant: 343),
            enterButton.heightAnchor.constraint(equalToConstant: 48),
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enterButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 640)
        ])
        
        view.addSubview(splashScreenLogoView)
        NSLayoutConstraint.activate([
            splashScreenLogoView.widthAnchor.constraint(equalToConstant: 60),
            splashScreenLogoView.heightAnchor.constraint(equalToConstant: 60),
            splashScreenLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogoView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
