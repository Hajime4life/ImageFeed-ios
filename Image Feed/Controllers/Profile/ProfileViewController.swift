import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - UI Elements
    private var userPhotoView: UIImageView?
    private var logoutButton: UIButton?
    private var nameLabel: UILabel?
    private var usernameLabel: UILabel?
    private var statusLabel: UILabel?
    
    // MARK: - Private props
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let storage = OAuth2TokenStorage.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateProfileDetails()
        addProfileImageObserver()
        updateAvatar()
    }
    
    // MARK: - Actions
    @objc
    private func logoutButtonTapped() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttonText: "Да",
            completion: { [weak self] in
                self?.logout()
            },
            secondaryButtonText: "Нет",
            secondaryButtonCompletion: {
                // тут наверно пусто, не знаю
            }
        )
        AlertPresenter.showAlert(model: alertModel, vc: self)
    }
    
    
    // MARK: - Private methods
    private func logout() {
        storage.clearToken()
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            return
        }
        self.nameLabel?.text = profile.name
        self.usernameLabel?.text = profile.loginName
        self.statusLabel?.text = profile.bio
    }
    
    private func addProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main,
                using: { [weak self] _ in
                    guard let self = self else { return }
                    self.updateAvatar()
                }
            )
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL),
            let imageView = userPhotoView
        else { return }
        
        imageView.kf.indicatorType = .activity
        let targetSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: targetSize)
        let roundCornerProcessor = RoundCornerImageProcessor(cornerRadius: 35, backgroundColor: UIColor(red: 0.101, green: 0.106, blue: 0.136, alpha: 1.0))
        
        imageView.kf.setImage(
            with: url,
            options: [
                .processor(downsamplingProcessor),
                .processor(roundCornerProcessor)
            ]
        )
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        view.backgroundColor = UIColor(red: 0.101, green: 0.106, blue: 0.136, alpha: 1.0)
        setupUserPhoto()
        setupLogoutButton()
        setupNameLabel()
        setupUsernameLabel()
        setupStatusLabel()
    }
    
    private func setupUserPhoto() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20)
        ])
        
        self.userPhotoView = imageView
        
        updateAvatar()
    }
    
    private func setupLogoutButton() {
        guard let logoutIcon = UIImage(named: "logout_icon"),
              let userPhotoView = self.userPhotoView else { return }
        
        let button = UIButton(type: .system)
        button.setImage(logoutIcon, for: .normal)
        button.tintColor = UIColor(hex: "#F56B6C")
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            button.centerYAnchor.constraint(equalTo: userPhotoView.centerYAnchor)
        ])
        
        self.logoutButton = button
    }
    
    private func setupNameLabel() {
        guard let userPhotoView = self.userPhotoView else { return }
        
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: userPhotoView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: userPhotoView.bottomAnchor, constant: 4)
        ])
        
        self.nameLabel = label
    }
    
    private func setupUsernameLabel() {
        guard let nameLabel = self.nameLabel else { return }
        
        let label = UILabel()
        label.text = ""
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4)
        ])
        
        self.usernameLabel = label
    }
    
    private func setupStatusLabel() {
        guard let usernameLabel = self.usernameLabel else { return }
        
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            label.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4)
        ])
        
        self.statusLabel = label
    }
}
