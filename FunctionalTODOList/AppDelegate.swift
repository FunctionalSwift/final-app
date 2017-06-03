// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let navigationController = UINavigationController()
        window!.rootViewController = navigationController
        window!.makeKeyAndVisible()

        Navigation.sharedInstance.window = window
        Navigation.sharedInstance.setRootViewControllerWithNavigationController((Navigation.getViewController(projectListViewController, from: Storyboards.Projects.rawValue))!)

        window?.makeKeyAndVisible()

        return true
    }
}
