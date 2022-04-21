//
//  ColorDetailViewController.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/21.
//

import UIKit
import ProgressHUD

class ColorDetailViewController: UIViewController {

    private let topView = UIView()


    private var list: [String] = []

    func config(color: UIColor) {

        topView.backgroundColor = color
        list.append(String(format: "Red: %.2f Green: %.2f Blue: %.2f", color._red, color._green, color._blue))
        list.append("Hex: \(color.hex)")
        list.append("CIE L: \(color.L) a: \(color.a) b: \(color.b)")
        list.append("X: \(color.X) Y: \(color.Y) Z:\(color.Z)")
        list.append(String(format: "C: %.2f M: %.2f Y: %.2f K: %.2f", color._cyan, color._magenta, color._yellow, color.key))
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(UITableViewCell.self)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "颜色详情"
        view.addSubview(topView)
        view.addSubview(tableView)
        topView.corner = 8
        topView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            make.leading.equalTo(0)
            make.trailing.equalTo(0)
            make.height.equalTo(view).multipliedBy(0.2)
        }
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(0)
            make.top.equalTo(topView.snp.bottom)
        }
    }
}

extension ColorDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell()
        cell.textLabel?.text = list[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        UIPasteboard.general.string = list[indexPath.row]
        ProgressHUD.showSuccess("已经拷贝到剪切板")
    }


}
