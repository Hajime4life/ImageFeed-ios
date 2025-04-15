import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String?)
    func updateAvatar(url: URL?)
    func showLogoutAlert(completion: @escaping () -> Void)
    func switchToSplashScreen()
}
