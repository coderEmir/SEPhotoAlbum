//
//  SEImageClipViewController.swift
//  SEImagePickerController
//
//  Created by xKing on 2019/3/15.
//  Copyright © 2019年 SeeEmil. All rights reserved.
//

import UIKit

class SEImageClipViewController: UIViewController {
    
    var imageModel: SEImageModel?
    
    var clipImageCallback: ((SEImageModel) -> ())?
    private var orientation : UIImage.Orientation?
    // MARK: -  懒加载
    
    /// 底部工具栏
    private lazy var imageToolView: SEImageToolView = {
        let imageToolView = SEImageToolView(frame: CGRect(x: 0, y: se_screenHeight - toolBarHeight, width: se_screenWidth, height: toolBarHeight), type: .clip)
        imageToolView.cancelBtn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
        imageToolView.restoreBtn.addTarget(self, action: #selector(restoreBtnClicked), for: .touchUpInside)
        imageToolView.completeBtn.addTarget(self, action: #selector(completeBtnClicked), for: .touchUpInside)
        imageToolView.rotateBtn.addTarget(self, action: #selector(rotateBtnClicked), for: .touchUpInside)
        return imageToolView
    }()
    
    private var clipScrollView: SEImageClipScrollView?
    
    private lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        return activityView
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.backgroundColor = .black
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(activityView)
        view.addSubview(imageToolView)
        setupClipScrollView()
    }
    
    private func setupClipScrollView() {
        guard let imageModel = imageModel else { return }
        let contentInset = UIEdgeInsets(top: se_statusBarHeight, left: 0, bottom: toolBarHeight, right: 0)
        if let editedImage = imageModel.editedImage {
            addClipScrollViewWithImage(editedImage, contentInset: contentInset)
        } else {
            activityView.startAnimating()
            SEPhotoImageManager.requestPreviewImage(for: imageModel.phAsset) { [weak self] (image, finished) in
                guard let `self` = self else { return }
                self.activityView.stopAnimating()
                guard let image = image else { return }
                self.addClipScrollViewWithImage(image, contentInset: contentInset)
            }
        }
    }
    
    private func addClipScrollViewWithImage(_ image: UIImage, contentInset: UIEdgeInsets) {
        let clipScrollView = SEImageClipScrollView(frame: view.bounds, image: image, margin: 30, contentInset: contentInset)
        clipScrollView.canRecoveryClosure = { [weak self] (_, canRecovery) in
            guard let `self` = self else { return }
            self.imageToolView.restoreBtn.isEnabled = canRecovery
        }
        clipScrollView.prepareToScaleClosure = { [weak self] (_, prepareToScale) in
            guard let `self` = self else { return }
            self.imageToolView.cancelBtn.isEnabled = !prepareToScale
            self.imageToolView.completeBtn.isEnabled = !prepareToScale
        }
        view.insertSubview(clipScrollView, at: 0)
        self.clipScrollView = clipScrollView
    }
    
    // MARK: - Actions
    
    @objc private func cancelBtnClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func restoreBtnClicked() {
        clipScrollView?.recovery()
    }
    
    @objc private func completeBtnClicked() {
        guard let clipScrollView = clipScrollView,
        let imageModel = imageModel else { return }
        activityView.startAnimating()
        clipScrollView.clipImage(isOriginImageSize: true) { [weak self] (image) in
            guard let `self` = self else { return }
            self.activityView.stopAnimating()
            imageModel.editedImage = image
            self.clipImageCallback?(imageModel)
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc private func rotateBtnClicked() {
        orientation = clipScrollView?.image?.imageOrientation
        switch orientation {
        case .up:
            orientation = .right
        case .right:
            orientation = .down
        case .down:
            orientation = .left
        case .left:
            orientation = .up
        
        default:
            orientation = .up
        }
        clipScrollView?.rotate(orientation: orientation!)
    }
}
