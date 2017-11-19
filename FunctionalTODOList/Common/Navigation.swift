// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

enum Storyboards: String {
    case Projects
    case Tasks
}

let taskListViewController = "TaskListViewController"
let projectListViewController = "ProjectListViewController"
let taskDetailViewController = "TaskDetailViewController"
let projectDetailViewController = "ProjectDetailViewController"

class Navigation: NSObject {

    static let sharedInstance = Navigation()

    var window: UIWindow?

    func setRootViewController(_ viewController: UIViewController) {

        window.flatMap { $0.rootViewController = viewController } ?? print("ERROR: Window cannot be nil")
    }

    func setRootViewControllerWithNavigationController(_ viewController: UIViewController) {

        guard let window = self.window,
            let navigationController = navigationControllerFromWindow(window) else {
            print("ERROR: Window cannot be nil")
            return
        }

        navigationController.viewControllers = [viewController]
    }

    func setNavigationControllerForViewController(_ viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.viewControllers = [viewController]

        return navigationController
    }

    fileprivate func navigationControllerFromWindow(_ window: UIWindow) -> UINavigationController? {

        if let navigationController = window.rootViewController as? UINavigationController {
            return navigationController
        }

        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return navigationController
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool) {

        guard let window = self.window,
            let navigationController = self.navigationControllerFromWindow(window) else {
            print("ERROR: Window cannot be nil")
            return
        }

        navigationController.pushViewController(viewController, animated: animated)
    }

    func popViewController(_ animated: Bool) {

        guard let window = self.window,
            let navigationController = self.navigationControllerFromWindow(window) else {
            print("ERROR: Window cannot be nil")
            return
        }

        navigationController.popViewController(animated: animated)
    }

    class func getViewController(_ viewControllerIdentifier: String, from storyBoard: String) -> UIViewController? {

        return (UIStoryboard(name: storyBoard, bundle: Bundle(for: type(of: Navigation.sharedInstance.self))).instantiateViewController(withIdentifier: viewControllerIdentifier))
    }
}
