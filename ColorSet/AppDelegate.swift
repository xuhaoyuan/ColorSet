//
//  AppDelegate.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 13.0, *) {
            let apperance = UINavigationBarAppearance()
            apperance.backgroundColor = UIColor.white
//            apperance.backgroundEffect = UIBlurEffect(style: .regular)/
            UINavigationBar.appearance().scrollEdgeAppearance = apperance
            UINavigationBar.appearance().tintColor = .black
        } else {
            UINavigationBar.appearance().backgroundColor = .white
            UINavigationBar.appearance().isTranslucent = false
        }

        if #available(iOS 15.0, *) {
            let apperance = UITabBarAppearance()
            apperance.backgroundColor = UIColor.white
//            apperance.backgroundEffect = UIBlurEffect(style: .regular)
            UITabBar.appearance().scrollEdgeAppearance = apperance
        } else {
            UITabBar.appearance().isTranslucent = false
        }

        window = UIWindow()

        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()

        return true
    }
}

