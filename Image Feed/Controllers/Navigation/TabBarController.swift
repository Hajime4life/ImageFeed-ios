import UIKit

// MARK: - TabBarController
final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ImagesListViewController
        let imagesListViewController = ImagesListViewController()
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesListPresenter)
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        // ProfileViewController
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
        
        setUITabBarAppearance()
    }
    
    private func setUITabBarAppearance() {
        let uITabBarAppearance = UITabBarAppearance()
        uITabBarAppearance.configureWithOpaqueBackground()
        uITabBarAppearance.backgroundColor = UIColor(named: "YP Black")
        uITabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabBar.standardAppearance = uITabBarAppearance
    }
}
