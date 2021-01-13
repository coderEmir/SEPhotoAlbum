//
//  SEImageToolView.swift
//  SEImagePickerController
//
//  Created by xKing on 2019/2/28.
//  Copyright © 2019年 SeeEmil. All rights reserved.
//

import UIKit

/// 工具栏高度
let toolBarHeight = se_safeBottomHeight + se_toolBarHeight

class SEImageToolView: UIView {

    enum SEImageToolViewType {
        /// 在列表中
        case list
        /// 在预览中
        case preview
        /// 在裁剪中
        case clip
    }
    
    /// 主题颜色
    var mainTintColor: UIColor = .red {
        didSet {
            originBtn.setImage(se_generateOriginBtnImage(mainTintColor), for: .selected)
            if confirmBtn.isEnabled {
                confirmBtn.backgroundColor = mainTintColor
            } else {
                confirmBtn.backgroundColor = mainTintColor.withAlphaComponent(0.5)
            }
        }
    }
    lazy var maxSelectCount : Int = 1
    var selectedImageCount: Int = 0 {
        didSet {
            if type == .list {
                previewBtn.isEnabled = selectedImageCount > 0
            }
            confirmBtn.isEnabled = selectedImageCount > 0
            confirmBtn.setTitle("添加\(selectedImageCount > 0 ? "(\(selectedImageCount)\("/")\(maxSelectCount))" : "")", for: .normal)
            if confirmBtn.isEnabled {
                confirmBtn.backgroundColor = mainTintColor
            } else {
                confirmBtn.backgroundColor = mainTintColor.withAlphaComponent(0.5)
            }
        }
    }
    
    var isOrigin: Bool = false {
        didSet {
            originBtn.isSelected = isOrigin
        }
    }
    
    // MARK: -  lazy loading
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
        
    lazy var previewBtn: UIButton = {
        let previewBtn = UIButton()
        previewBtn.setTitle("预览", for: .normal)
        previewBtn.setTitleColor(.lightGray, for: .disabled)
        previewBtn.setTitleColor(.white, for: .normal)
        previewBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        previewBtn.isEnabled = false
        return previewBtn
    }()
    
    lazy var editBtn: UIButton = {
        let editBtn = UIButton()
        editBtn.setTitle("编辑", for: .normal)
        editBtn.setTitleColor(.lightGray, for: .disabled)
        editBtn.setTitleColor(.white, for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return editBtn
    }()
    
    lazy var originBtn: UIButton = {
        let originBtn = UIButton()
        originBtn.setTitle("原图", for: .normal)
        originBtn.setImage(se_generateOriginBtnImage(), for: .normal)
        originBtn.setImage(se_generateOriginBtnImage(mainTintColor), for: .selected)
        originBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        originBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        return originBtn
    }()
    
    lazy var confirmBtn: UIButton = {
        let confirmBtn = UIButton()
        confirmBtn.setTitle("完成", for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .disabled)
        confirmBtn.backgroundColor = mainTintColor.withAlphaComponent(0.5)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        confirmBtn.layer.cornerRadius = 5
        confirmBtn.isEnabled = false
        return confirmBtn
    }()
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(contentsOfFile: imagePathWith(imageName: "se_cancel", currentClass: SEImageCell.self)), for: .normal)
        return cancelBtn
    }()
    
    lazy var completeBtn: UIButton = {
        let completeBtn = UIButton()
        completeBtn.setImage(UIImage(contentsOfFile: imagePathWith(imageName: "se_confirm", currentClass: SEImageCell.self)), for: .normal)
        return completeBtn
    }()
    
    lazy var restoreBtn: UIButton = {
        let restoreBtn = UIButton()
        restoreBtn.setTitle("还原", for: .normal)
        restoreBtn.setTitleColor(.lightGray, for: .disabled)
        restoreBtn.setTitleColor(.white, for: .normal)
        restoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        restoreBtn.isEnabled = false
        return restoreBtn
    }()
    
//    lazy var rotateBtn: UIButton = {
//        let rotateBtn = UIButton()
//        rotateBtn.setTitle("旋转", for: .normal)
//        rotateBtn.setTitleColor(.lightGray, for: .disabled)
//        rotateBtn.setTitleColor(.white, for: .normal)
//        rotateBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//        rotateBtn.isEnabled = false
//        return rotateBtn
//    }()
    
    // 加一条分割线
    lazy var lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lineView.isHidden = true
        return lineView
    }()
    
    private var type: SEImageToolViewType = .list
    
    init(frame: CGRect, type: SEImageToolViewType) {
        super.init(frame: frame)
        self.type = type
        setupUI()
        registerNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeNotifications()
    }
    
    private func setupUI() {
        backgroundColor = se_toolBarBackgroundColor
        addSubview(contentView)
        contentView.addSubview(lineView)
        switch type {
        case .list:
            contentView.addSubview(previewBtn)
            contentView.addSubview(originBtn)
            contentView.addSubview(confirmBtn)
        case .preview:
            contentView.addSubview(editBtn)
            contentView.addSubview(originBtn)
            contentView.addSubview(confirmBtn)
        case .clip:
            lineView.isHidden = false
            contentView.addSubview(cancelBtn)
            contentView.addSubview(completeBtn)
            contentView.addSubview(restoreBtn)
//            contentView.addSubview(rotateBtn)
        }
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(isOriginDidChanged(_:)), name: .SEImagePickerIsOriginDidChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectedImageModelsDidChanged(_:)), name: .SEImagePickerSelectedImageModelsDidChanged, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: .SEImagePickerIsOriginDidChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .SEImagePickerSelectedImageModelsDidChanged, object: nil)
    }
    
    @objc private func isOriginDidChanged(_ notification: Notification) {
        guard let isOrigin = notification.object as? Bool else { return }
        self.isOrigin = isOrigin
    }
    
    @objc private func selectedImageModelsDidChanged(_ notification: Notification) {
        guard let models = notification.object as? [SEImageModel] else { return }
        selectedImageCount = models.count
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: se_toolBarHeight)
        lineView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: 0.5)
        switch type {
        case .list:
            previewBtn.frame = CGRect(x: 0, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
            originBtn.frame = CGRect(x: (contentView.bounds.width - 70) / 2, y: (contentView.bounds.height - 44) / 2, width: 90, height: 44)
            confirmBtn.frame = CGRect(x: contentView.bounds.width - 100, y: (contentView.bounds.height - 28) / 2, width: 90, height: 28)
        case .preview:
            editBtn.frame = CGRect(x: 0, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
            originBtn.frame = CGRect(x: (contentView.bounds.width - 70) / 2, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
            confirmBtn.frame = CGRect(x: contentView.bounds.width - 100, y: (contentView.bounds.height - 28) / 2, width: 90, height: 28)
        case .clip:
            cancelBtn.frame = CGRect(x: 0, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
            restoreBtn.frame = CGRect(x: (contentView.bounds.width - 70) / 2, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
            completeBtn.frame = CGRect(x: contentView.bounds.width - 100, y: (contentView.bounds.height - 28) / 2, width: 90, height: 28)
            
//            cancelBtn.frame = CGRect(x: 0, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
//            restoreBtn.frame = CGRect(x: (contentView.bounds.width - 140) / 2 - 35, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
//            completeBtn.frame = CGRect(x: contentView.bounds.width - 70, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
//            rotateBtn.frame = CGRect(x: completeBtn.frame.minX - restoreBtn.frame.origin.x, y: (contentView.bounds.height - 44) / 2, width: 70, height: 44)
            
        }
    }
    
}
