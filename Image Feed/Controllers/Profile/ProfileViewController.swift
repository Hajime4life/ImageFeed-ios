import UIKit
import Kingfisher

// MARK: - ProfileViewController
final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - UI Elements
    private var userPhotoView: UIImageView?
    private var logoutButton: UIButton?
    private var nameLabel: UILabel?
    private var usernameLabel: UILabel?
    private var statusLabel: UILabel?
    
    // MARK: - Private Props
    private var presenter: ProfilePresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.viewDidLoad()
    }
    
    // MARK: - Public Methods
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        if var presenterInstance = presenter as? ProfilePresenter {
            presenterInstance.view = self
            self.presenter = presenterInstance
        }
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String?) {
        nameLabel?.text = name
        usernameLabel?.text = loginName
        statusLabel?.text = bio
    }
    
    func updateAvatar(url: URL?) {
        guard let url = url, let imageView = userPhotoView else { return }
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
    
    func showLogoutAlert(completion: @escaping () -> Void) {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttonText: "Да",
            completion: completion,
            secondaryButtonText: "Нет",
            secondaryButtonCompletion: {}
        )
        AlertPresenter.showAlert(model: alertModel, vc: self)
    }
    
    func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    // MARK: - Actions
    @objc func logoutButtonTapped() {
        presenter.didTapLogoutButton()
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
