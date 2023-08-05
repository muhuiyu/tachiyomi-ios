//
//  MainTabBarController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    weak var appCoordinator: AppCoordinator?
}

extension MainTabBarController {
    func configureTabBarItems() {
        var mainViewControllers = [UINavigationController]()
        TabBarCategory.allCases.forEach { [weak self] category in
            if let viewController = self?.generateViewController(category) {
                mainViewControllers.append(viewController)
            }
        }
        self.viewControllers = mainViewControllers
    }
    
    private func generateViewController(_ category: TabBarCategory) -> UINavigationController? {
        let viewController = category.getViewController(appCoordinator)
        return viewController.embedInNavgationController()
    }
}

enum TabBarCategory: Int, CaseIterable {
    case library = 0
    case updates
    case history
    case browse
    case settings
    
    var title: String {
        switch self {
        case .library: return "Library"
        case .updates: return "Updates"
        case .history: return "History"
        case .browse: return "Browse"
        case .settings: return "Settings"
        }
    }
    var inactiveImageValue: UIImage? {
        switch self {
        case .library: return UIImage(systemName: Icons.bookClosed)
        case .updates: return UIImage(systemName: Icons.exclamationmarkCircle)
        case .history: return UIImage(systemName: Icons.clockArrowCirclepath)
        case .browse: return UIImage(systemName: Icons.safari)
        case .settings: return UIImage(systemName: Icons.ellipsis)
        }
    }
    var activeImageValue: UIImage? {
        switch self {
        case .library: return UIImage(systemName: Icons.bookClosedFill)
        case .updates: return UIImage(systemName: Icons.exclamationmarkCircleFill)
        case .history: return UIImage(systemName: Icons.clockArrowCirclepath)
        case .browse: return UIImage(systemName: Icons.safariFill)
        case .settings: return UIImage(systemName: Icons.ellipsis)
        }
    }
    func getViewController(_ appCoordinator: AppCoordinator?) -> BaseViewController {
        let viewController: BaseViewController
        
        switch self {
        case .library:
            viewController = LibraryViewController(viewModel: LibraryViewModel(appCoordinator: appCoordinator))
        case .updates:
            viewController = UpdatesViewController(viewModel: UpdatesViewModel(appCoordinator: appCoordinator))
        case .history:
            viewController = HistoryViewController(viewModel: HistoryViewModel(appCoordinator: appCoordinator))
        case .browse:
            viewController = BrowseViewController(viewModel: BrowseViewModel(appCoordinator: appCoordinator))
        case .settings:
            viewController = SettingsViewController(viewModel: SettingsViewModel(appCoordinator: appCoordinator))
        }
        
        viewController.title = self.title
        viewController.appCoordinator = appCoordinator
        viewController.tabBarItem = self.tabBarItem
        return viewController
    }
    var tabBarItem: UITabBarItem {
        let item = UITabBarItem(title: self.title, image: self.inactiveImageValue, tag: self.rawValue)
        item.selectedImage = self.activeImageValue
        return item
    }
}
