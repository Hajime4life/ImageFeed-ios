//final class ProfileViewController: UIViewController {
//    @IBOutlet private var avatarImageView: UIImageView!
//    @IBOutlet private var nameLabel: UILabel!
//    @IBOutlet private var loginNameLabel: UILabel!
//    @IBOutlet private var descriptionLabel: UILabel!
//
//    @IBOutlet private var logoutButton: UIButton!
//
//    @IBAction private func didTapLogoutButton() {
//    }
//}
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private var userPhotoView: UIImageView?
    private var logoutButton: UIButton?
    private var nameLabel: UILabel?
    private var usernameLabel: UILabel?
    private var statusLabel: UILabel?
    private var favoritesLabel: UILabel?
    private var emptyFavoritesIcon: UIImageView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    @objc
    private func logoutButtonTapped() {
        // Обработка нажатия на кнопку выхода
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        view.backgroundColor = UIColor(red: 0.101, green: 0.106, blue: 0.136, alpha: 1.0)
        setupUserPhoto()
        setupLogoutButton()
        setupNameLabel()
        setupUsernameLabel()
        setupStatusLabel()
        setupFavoritesLabel()
        setupEmptyFavoritesIcon()
    }
    
    private func setupUserPhoto() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 32)
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
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 235),
            label.heightAnchor.constraint(equalToConstant: 18),
            label.leadingAnchor.constraint(equalTo: userPhotoView.leadingAnchor),
            label.topAnchor.constraint(equalTo: userPhotoView.bottomAnchor, constant: 8)
        ])
        
        self.nameLabel = label
    }
    
    private func setupUsernameLabel() {
        guard let nameLabel = self.nameLabel else { return }
        
        let label = UILabel()
        label.text = "ekaterina_nov"
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 99),
            label.heightAnchor.constraint(equalToConstant: 18),
            label.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        
        self.usernameLabel = label
    }
    
    private func setupStatusLabel() {
        guard let usernameLabel = self.usernameLabel else { return }
        
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 77),
            label.heightAnchor.constraint(equalToConstant: 18),
            label.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            label.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
        ])
        
        self.statusLabel = label
    }
    
    private func setupFavoritesLabel() {
        guard let statusLabel = self.statusLabel else { return }
        
        let label = UILabel()
        label.text = "Избранное"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 129),
            label.heightAnchor.constraint(equalToConstant: 18),
            label.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            label.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24)
        ])
        
        self.favoritesLabel = label
    }
    
    private func setupEmptyFavoritesIcon() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noPhoto")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 115),
            imageView.heightAnchor.constraint(equalToConstant: 115),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            imageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 332)
        ])
        
        self.emptyFavoritesIcon = imageView
    }
}
