import UIKit
import ProgressHUD

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    // MARK: - Private Props
    private var splashScreenLogoImageView: UIImageView?
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage()
    private enum SplashViewControllerConstants {
        static let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    }
    private var authenticateStatus = false
    
    // MARK: - Overrides Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAuthenticated()
    }
    // MARK: - Public Methods
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    // MARK: - Private Methods
    private func isAuthenticated() {
        guard !authenticateStatus else { return }
        authenticateStatus = true
        if storage.token != nil {
            UIBlockingProgressHUD.show()
            fetchProfile { [weak self] result in
                guard let self else { preconditionFailure("Weak self error") }
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.switchToTabBarController()
                case .failure(let error):
                    print("Error - Profile fetch: \(error)")
                    self.showAlert()
                }
            }
        } else {
            let authViewController = AuthViewController()
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            defer { UIBlockingProgressHUD.dismiss() } // Добавил чтобы в случае фейла тоже завершить загрузку
            switch result {
            case .success:
                self.fetchProfile { result in
                    switch result {
                    case .success:
                        self.switchToTabBarController()
                    case .failure(let error):
                        self.showAlert()
                    }
                }
            case .failure(let error):
                print("Error - fetch token error \(error)")
                self.showAlert()
            }
        }
    }
    private func fetchProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = storage.token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(with: token) { [weak self] result in
            guard let self else { return }
            defer { UIBlockingProgressHUD.dismiss() }
            switch result {
            case .success(let profile):
                self.switchToTabBarController() // defer чтобы завершить загрузку при ответе независимо от ответа
                let username = profile.username
                self.fetchProfileImage(username: username)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        profileImageService.fetchImageURL(with: username) { result in
            switch result {
            case .success(let imageURL):
                print("Profile loaded")
            case .failure(let error):
                print("Error - fetch image error \(error)")
            }
        }
    }
    
    private func showAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { preconditionFailure("weak self error")}
            let alertModel = AlertModel(
                title: "Что-то пошло не так(",
                message: "Не удалось войти в систему",
                buttonText: "Ок"
            ) { [weak self] in
                guard let self else { preconditionFailure("weak self error")}
                self.authenticateStatus = false
                self.isAuthenticated()
            }
            AlertPresenter.showAlert(model: alertModel, vc: self)
        }
    }
    
    private func setSplashScreenLogoImageView() {
        let splashScreenLogoImageView = UIImageView()
        let splashScreenLogo = UIImage(named: "splash_screen_logo")
        splashScreenLogoImageView.image = splashScreenLogo
        splashScreenLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashScreenLogoImageView)
        splashScreenLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        splashScreenLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        splashScreenLogoImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        splashScreenLogoImageView.widthAnchor.constraint(equalToConstant: 72).isActive = true
        
        self.splashScreenLogoImageView = splashScreenLogoImageView
    }
    
    private func setupSplashScreen() {
        setSplashScreenLogoImageView()
        view.backgroundColor = UIColor(named: "YP Black")
    }
}
