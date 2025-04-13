import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    // MARK: - Public Props
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Props
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    func viewDidLoad() {
        updateProfileDetails()
        addProfileImageObserver()
        updateAvatar()
    }
    
    func didTapLogoutButton() {
        view?.showLogoutAlert { [weak self] in
            OAuth2TokenStorage.shared.clearToken()
            HTTPCookieStorage.shared.removeCookies(since: .distantPast)
            self?.view?.switchToSplashScreen()
        }
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(name: profile.name ?? "", loginName: profile.loginName, bio: profile.bio)
    }
    
    private func addProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main,
                using: { [weak self] _ in
                    guard let self else { return }
                    self.updateAvatar()
                }
            )
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        view?.updateAvatar(url: url)
    }
}
