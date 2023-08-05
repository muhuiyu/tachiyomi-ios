//
//  AppCoordinator.swift
//  Tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxSwift

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let disposeBag = DisposeBag()

    private(set) var mainTabBarController: MainTabBarController?

    let dataProvider = LocalStorage()

    init?(window: UIWindow?) {
        guard let window = window else { return nil }
        self.window = window
    }


    func start() {
//        configureBindings()
//        showLoadingScreen()
//        configureCoordinators()
        setupMainTabBar()
        configureDatabase()
        showHome()
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()
    }

    private func configureBindings() {

    }
}

// MARK: - Services and managers
extension AppCoordinator {
    private func configureDatabase() {
//        dataProvider.setup()
    }
}

// MARK: - UI Setup
extension AppCoordinator {
    private func setupMainTabBar() {
        mainTabBarController = MainTabBarController()
        mainTabBarController?.appCoordinator = self
        mainTabBarController?.configureTabBarItems()
    }
}

// MARK: - Generic Navigation
extension AppCoordinator {
    enum Destination {
        case home
        case loadingScreen
    }
    private func changeRootViewController(to viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        window.rootViewController = viewController
    }
    func showHome(forceReplace: Bool = true, animated: Bool = true) {
        changeRootViewController(to: self.mainTabBarController)
    }
//    func showLoadingScreen(forceReplace: Bool = false, animated: Bool = true) {
//        let viewController = LoadingScreenViewController(appCoordinator: self)
//        changeRootViewController(to: viewController)
//    }
}
