//
//  SEImagePickerController.swift
//  SEImagePickerController
//
//  Created by xKing on 2019/2/28.
//  Copyright © 2019年 SeeEmil. All rights reserved.
//

import UIKit
import Photos
typealias SelectedImagesBlock = (_ controller: UIViewController,_ images: [UIImage]) -> ()
// MARK: -  代理
@objc protocol SEImagePickerControllerDelegate: class {
    
    /// 取消选择
    @objc optional func imagePickerControllerDidCancelSelect(_ imagePickerController: SEImagePickerController)
    
    /// 选择完成
    ///
    /// - Parameters:
    ///   - imagePickerController: 回调者本身
    ///   - imageModels: 图片模型
    ///   - isOrigin: 是否选择原图
    @objc optional func imagePickerController(_ imagePickerController: SEImagePickerController, didSelected imageModels: [SEImageModel], isOrigin: Bool)

    /// 选择完成
    ///
    /// - Parameters:
    ///   - imagePickerController: 回调者本身
    ///   - images: 图片数组
    @objc optional func imagePickerController(_ imagePickerController: SEImagePickerController, didSelected images: [UIImage])
}

// MARK: -  通知
extension Notification.Name {
    
    /// 是否选择原图
    static let SEImagePickerIsOriginDidChanged = Notification.Name("SEImagePickerIsOriginDidChanged")
    
    /// 是否选择原图
    static let SEImagePickerSelectedImageModelsDidChanged = Notification.Name("SEImagePickerSelectedImageModelsDidChanged")
}

// MARK: -  picker主控制器
class SEImagePickerController: UINavigationController {
    var selectedImages: SelectedImagesBlock?
    
    /// 最大选择图片数
    var maxSelectCount: Int = 9
    var isSelectedFinishDismiss = true
    var isCustomEdit = false
    /// 主题颜色
    var mainTintColor: UIColor = .red
    
    /// 选择媒体类型
    var mediaTypes: [PHAssetMediaType] = [.video, .image]
    
    /// 是否包含相册列表，否则只有相机胶卷
    var hasAlbumList: Bool = true
    
    /// 回调代理
    weak var se_delegate: SEImagePickerControllerDelegate?
    
    /// 是否选中原图
    var isOrigin: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .SEImagePickerIsOriginDidChanged, object: isOrigin)
        }
    }
    
    /// 已选中数组
    var selectedImageModels: [SEImageModel] = [] {
        didSet {
            NotificationCenter.default.post(name: .SEImagePickerSelectedImageModelsDidChanged, object: selectedImageModels)
        }
    }
    
    init(hasAlbumList: Bool = true) {
        var rootVC: UIViewController
        if hasAlbumList {
            rootVC = SEAlbumListViewController()
            if let rootVC = rootVC as? SEAlbumListViewController {
                rootVC.isCustomEdit = isCustomEdit
            }
            

        } else {
            rootVC = SEImageListViewController()
            if let rootVC = rootVC as? SEImageListViewController {
                rootVC.isCustomEdit = isCustomEdit
            }
        }
        super.init(rootViewController: rootVC)
        self.hasAlbumList = hasAlbumList
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        SELog("SEImagePickerController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarUI()
    }
    
    private func setupNavigationBarUI() {
        navigationBar.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        navigationBar.shadowImage = UIImage()
    }
    
    // MARK: -  Public Methods
    
    /// 取消
    func cancelSelect() {
        se_delegate?.imagePickerControllerDidCancelSelect?(self)
        dismiss(animated: true, completion: nil)
    }
    
    /// 选择完成
    func confirmSelectImageModels() {
        se_delegate?.imagePickerController?(self, didSelected: selectedImageModels, isOrigin: isOrigin)
        if se_delegate?.imagePickerController(_:didSelected:) != nil || self.selectedImages != nil {
            var requestFail = false
            let group = DispatchGroup()
            var images: [UIImage] = []
            for _ in 0 ..< selectedImageModels.count {
                images.append(UIImage())
            }
            for imageModel in selectedImageModels {
                group.enter()
                if let editedImage = imageModel.editedImage {
                    images.replaceSubrange(imageModel.selectedIndex ..< imageModel.selectedIndex + 1, with: [editedImage])
                    group.leave()
                } else if isOrigin {
                    SEPhotoImageManager.requestOriginImage(for: imageModel.phAsset) { (image, finished) in
                        if let image = image {
                            images.replaceSubrange(imageModel.selectedIndex ..< imageModel.selectedIndex + 1, with: [image])
                            group.leave()
                        } else {
                            requestFail = true
                            group.leave()
                        }
                    }
                } else {
                    SEPhotoImageManager.requestPreviewImage(for: imageModel.phAsset) { (image, finished) in
                        if let image = image {
                            images.replaceSubrange(imageModel.selectedIndex ..< imageModel.selectedIndex + 1, with: [image])
                            group.leave()
                        } else {
                            requestFail = true
                            group.leave()
                        }
                    }
                }
            }
            group.notify(queue: DispatchQueue.main) { [weak self] in
                guard let `self` = self, !requestFail else {
                    SELog("加载图片出错")
                    return
                }
                
                self.se_delegate?.imagePickerController?(self, didSelected: images)
                self.selectedImages!(self,images)
                if self.isSelectedFinishDismiss {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    /// 弹出不能选择弹框
    func showCanNotSelectAlert() {
        let alertVC = UIAlertController(title: "最多只能选择\(maxSelectCount)张图片", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "我知道了", style: .cancel)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    /// 弹出前往设置授权提示框
    func showAuthorizationAlert() {
        let title = "请开启照片权限"
        let message = "相册权限未开启,请进入系统设置>隐私>照片中打开开关,并允许使用照片权限"
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let callAction = UIAlertAction(title: "立即设置", style: .default) { (action) in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) else { return }
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:]) { isSuccess in
                    
                }
            }
            else
            {
                UIApplication.shared.openURL(url)
            }
            
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(callAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let popedVC = super.popViewController(animated: animated)
        /// 清空已选中的图片
        if popedVC?.isKind(of: SEImageListViewController.self) ?? false {
            selectedImageModels.removeAll()
        }
        return popedVC
    }
    
}
