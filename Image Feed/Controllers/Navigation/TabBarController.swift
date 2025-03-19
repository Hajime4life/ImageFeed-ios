import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
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
