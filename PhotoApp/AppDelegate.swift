//
//  AppDelegate.swift
//  PhotoApp
//
//  Created by Kirill Pahnev on 01/03/2019.
//  Copyright © 2019 Kirill Pahnev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let masterViewController = leftNavController.topViewController as? MasterViewController,
            let rightNavController = splitViewController.viewControllers.last as? UINavigationController,
            let detailViewController = rightNavController.topViewController as? DetailViewController
            else { fatalError() }
        splitViewController.delegate = self

        masterViewController.delegate = detailViewController

        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true

        let navBarBackgroundColor = #colorLiteral(red: 0, green: 0.8549019608, blue: 0.7333333333, alpha: 1)
        leftNavController.navigationBar.backgroundColor = navBarBackgroundColor
        rightNavController.navigationBar.backgroundColor = navBarBackgroundColor

        return true
    }
}

// MARK: - UISplitViewControllerDelegate

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.album == nil {
            return true
        }
        return false
    }
}
