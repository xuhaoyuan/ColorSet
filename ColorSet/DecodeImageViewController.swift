//
//  DecodeImageViewController.swift
//  ColorSet
//
//  Created by 许浩渊 on 2022/4/21.
//

import UIKit
import Photos
import XHYCategories
import ProgressHUD

class DecodeImageViewController: UIViewController {

    private let imageButton = UIButton(title: "点击请选择图片", titleColor: UIColor.gray, font: UIFont.systemFont(ofSize: 24, weight: .regular), bgColor: UIColor.lightGray)
    private let imageView = UIImageView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(ColorSelectCell.self)
        tableView.backgroundView = resultLabel
        return tableView
    }()

    private let resultLabel = UILabel(text: "无解析结果", font: UIFont.systemFont(ofSize: 22, weight: .regular), color: .gray, alignment: .center)

    private var colors: [ColorFrequency] = []

    private var decodeImage: UIImage? {
        set {
            imageView.image = newValue
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                do {
                    let result = try newValue?.dominantColorFrequencies(with: .low)
                    DispatchQueue.main.async {
                        self.colors = result ?? []
                        self.resultLabel.isHidden = !self.colors.isEmpty
                        self.tableView.reloadData()
                        if self.colors.isEmpty {
                            ProgressHUD.showError("解析图片失败")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.colors = []
                        self.resultLabel.isHidden = false
                        ProgressHUD.showError("解析图片失败")
                        self.tableView.reloadData()
                    }
                }
            }
        }
        get {
            return imageView.image
        }
    }

    private func setResult(text: String, isError: Bool) {
        resultLabel.text = text
        if isError {
            resultLabel.textColor = .orange
        } else {
            resultLabel.textColor = .gray
        }
    }

    private lazy var leftItem: UIBarButtonItem = {
        let i = UIBarButtonItem(title: "选择", style: .done) { [weak self] in
            self?.actionSheet()
        }
        return i
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }

    private func makeUI() {
        navigationItem.title = "解析主题色"
        navigationItem.rightBarButtonItem = leftItem

        view.backgroundColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.clear
        view.addSubview(imageButton)
        imageButton.addSubview(imageView)
        imageButton.corner = 8
        imageButton.snp.makeConstraints { make in
            make.leading.equalTo(8)
            make.trailing.equalTo(-8)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.height.equalToSuperview().multipliedBy(0.4)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(imageButton.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
        imageButton.addTarget(self, action: #selector(actionSheet), for: .touchUpInside)
    }

    @objc private func actionSheet() {
        let action = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        let album = UIAlertAction(title: "从相册中获取", style: .default) { [weak self] _ in
            self?.photosButtonTouched()
        }
        let photo = UIAlertAction(title: "从相机中获取", style: .default) { [weak self] _ in
            self?.cameraButtonTouched()
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        action.addAction(album)
        action.addAction(photo)
        action.addAction(cancel)
        present(action, animated: true) {

        }
    }

    @objc private func cameraButtonTouched() {
        let sourceType = UIImagePickerController.SourceType.camera
        displayMediaPicker(sourceType: sourceType)
    }

    @objc private func photosButtonTouched() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        displayMediaPicker(sourceType: sourceType)
    }
}

extension DecodeImageViewController {

    func displayMediaPicker(sourceType: UIImagePickerController.SourceType) {

        let usingCamera = sourceType == .camera
        let media = usingCamera ? "Camera" : "Photos"

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let noPermissionTitle = "Access to your \'\(media)\' denied"
            let noPermissionMessage = "\nGo to \'Settings\' to allow the access."

            if usingCamera {
                actionAccordingTo(status: AVCaptureDevice.authorizationStatus(for: AVMediaType.video),
                                  noPermissionTitle: noPermissionTitle,
                                  noPermissionMessage: noPermissionMessage)
            } else {
                actionAccordingTo(status: PHPhotoLibrary.authorizationStatus(),
                                  noPermissionTitle: noPermissionTitle,
                                  noPermissionMessage: noPermissionMessage)
            }
        } else {
            let title = "\'\(media)\' unavailable"
            let message = "cannot have acces to your \'\(media)\' at this time."
            troubleAlert(title: title, message: message)
        }
    }

    func actionAccordingTo(status: AVAuthorizationStatus ,
                           noPermissionTitle: String?,
                           noPermissionMessage: String?) {
        let sourceType = UIImagePickerController.SourceType.camera
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) {
                self.checkAuthorizationAccess(granted: $0,
                                              sourceType: sourceType,
                                              noPermissionTitle: noPermissionTitle,
                                              noPermissionMessage: noPermissionMessage)
            }
        case .authorized:
            self.presentImagePicker(sourceType: sourceType)
        case .denied, .restricted:
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        @unknown default:
            fatalError()
        }
    }

    func actionAccordingTo(status: PHAuthorizationStatus ,
                           noPermissionTitle: String?,
                           noPermissionMessage: String?) {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.checkAuthorizationAccess(granted: status == .authorized,
                                                  sourceType: sourceType,
                                                  noPermissionTitle: noPermissionTitle,
                                                  noPermissionMessage: noPermissionMessage)
                }
            }
        case .authorized:
            self.presentImagePicker(sourceType: sourceType)
        case .denied, .restricted:
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        case .limited:
            self.presentImagePicker(sourceType: sourceType)
        @unknown default:
            fatalError()
        }
    }

    func checkAuthorizationAccess(granted: Bool,
                                  sourceType: UIImagePickerController.SourceType,
                                  noPermissionTitle: String?,
                                  noPermissionMessage: String?) {
        if granted {
            self.presentImagePicker(sourceType: sourceType)
        } else {
            self.openSettingsWithUIAlert(title: noPermissionTitle, message: noPermissionMessage)
        }
    }

    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.modalPresentationStyle = .fullScreen
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }


    func openSettingsWithUIAlert(title: String?, message: String?) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: "Settings", style: .default) {
            _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        present(alertController, animated: true, completion: nil)
    }


    func troubleAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
}

extension DecodeImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: { [weak self] in
            var image: UIImage?
            if picker.allowsEditing {
                image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            } else {
                image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
            guard let image = image else { return }
            self?.decodeImage = image
        })

    }

    // Delegate Function: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension DecodeImageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ColorSelectCell = tableView.dequeueReusableCell()
        cell.config(data: colors[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ColorDetailViewController()
        vc.config(color: colors[indexPath.row].color)
        show(vc, sender: nil)
    }
}

class ColorSelectCell: UITableViewCell {

    private let colorView = UIView()
    private let frequencyLabel = UILabel(font: UIFont.systemFont(ofSize: 18, weight: .bold))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(colorView)
        contentView.addSubview(frequencyLabel)
        frequencyLabel.textAlignment = .center
        frequencyLabel.snp.makeConstraints { make in
            make.leading.equalTo(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        colorView.corner = 6
        colorView.snp.makeConstraints { make in
            make.leading.equalTo(frequencyLabel.snp.trailing)
            make.top.equalTo(4)
            make.trailing.equalTo(-8)
            make.bottom.equalTo(-4)
            make.height.equalTo(42)
        }

    }

    func config(data: ColorFrequency) {
        colorView.backgroundColor = data.color
        frequencyLabel.text = "\(data.frequency)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
