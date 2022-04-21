//
//  RootViewController.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/20.
//

import UIKit

class RootViewController: UITabBarController {


    private let pickerVC: ColorPickerViewController = {
        let vc = ColorPickerViewController()
        vc.tabBarItem.image = UIImage(named: "tab1")
        vc.tabBarItem.selectedImage = UIImage(named: "tab1Select")
        vc.tabBarItem.title = "颜色板"
        return vc
    }()

    private let decodeVC: DecodeImageViewController = {
        let vc = DecodeImageViewController()
        vc.tabBarItem.image = UIImage(named: "tab2")
        vc.tabBarItem.selectedImage = UIImage(named: "tab2Select")
        vc.tabBarItem.title = "颜色解析"
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let decodeNav = UINavigationController(rootViewController: decodeVC)
        viewControllers = [pickerVC, decodeNav]

    }


}
