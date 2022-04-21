//
//  ColorPickerView.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/21.
//

import UIKit
import XHYCategories

class ColorPickerView: UIView {

    private let list: [UIColor] = {
        return [
            UIColor(r: 255, g: 255, b: 255, a: 1),
            UIColor(r: 0, g: 0, b: 0, a: 1),
            UIColor.red,
            UIColor.green,
            UIColor.blue,
            UIColor.cyan,
            UIColor.yellow,
            UIColor.magenta,
            UIColor.orange,
            UIColor.purple,
            UIColor.brown
        ]
    }()

    var colorHandler: SingleHandler<UIColor>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        collectionView.registerCell(UICollectionViewCell.self)
        return collectionView
    }()


}

extension ColorPickerView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(indexPath)
        cell.backgroundColor = list[indexPath.row]
        cell.corner = 6
        cell.border(color: .gray, width: 1)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorHandler?(list[indexPath.row])
    }
}
