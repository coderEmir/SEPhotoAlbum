//
//  SEImageCell.swift
//  SEImagePickerController
//
//  Created by xKing on 2019/2/28.
//  Copyright © 2019年 SeeEmil. All rights reserved.
//

import UIKit

class SEImageCell: UICollectionViewCell {
    
    ///  数据源
    var imageModel: SEImageModel? {
        didSet {
            guard let imageModel = imageModel else { return }
            selectBtn.setSelectedIndex(imageModel.selectedIndex)
            imageView.image = imageModel.thumbImage
            imageModel.requestThumbImage { [weak self] (model, thumbImage) in
                guard let `self` = self, self.imageModel == model else { return }
                self.imageView.image = thumbImage
            }
            if imageModel.mediaType == .video {
                videoView.isHidden = false
                videoDurationLabel.text = se_formatVideoDuration(imageModel.phAsset.duration)
            } else {
                videoView.isHidden = true
                videoDurationLabel.text = ""
            }
            videoDurationLabel.sizeToFit()
            editedIconImageView.isHidden = !imageModel.isEdited
            maskForegroundView.isHidden = imageModel.canSelect
        }
    }
    
    /// 选中按钮点击回调
    var selectBtnClickedCallback: ((SEImageCell) -> ())?
    
    /// 主题颜色
    var mainTintColor: UIColor = .red {
        didSet {
            selectBtn.mainTintColor = mainTintColor
        }
    }
    // MARK: - 相机

    var showCameraCell: Bool = false {
        didSet {
            if (showCameraCell)
            {
                addSubview(cameraBgView)
                addSubview(cameraImageView)
                addSubview(cameraTipLabel)
            }
            else
            {
                cameraBgView.removeFromSuperview()
                cameraImageView.removeFromSuperview()
                cameraTipLabel.removeFromSuperview()
            }
        }
    }
    // MARK: -  懒加载
    lazy var cameraBgView: UIView = {
        let cameraBgView = UIImageView(frame: bounds)
        cameraBgView.backgroundColor = .black
        return cameraBgView
    }()
    
    lazy var cameraImageView: UIImageView = {
        let cameraBgView = UIImageView(frame: bounds)
        cameraBgView.image = UIImage.init(contentsOfFile: imagePathWith(imageName: "se_camera", currentClass: SEImageCell.self))
        return cameraBgView
    }()
    
    lazy var cameraTipLabel: UILabel = {
        let cameraTipLabel = UILabel.init()
        cameraTipLabel.text = "拍照"
        cameraTipLabel.font = UIFont.systemFont(ofSize: 14)
        cameraTipLabel.textAlignment = .center
        cameraTipLabel.textColor = .white
        return cameraTipLabel
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.isHidden = true
        return videoView
    }()
    
    lazy var editedIconImageView: UIImageView = {
        let editedIconImageView = UIImageView()
        editedIconImageView.image = UIImage(contentsOfFile: imagePathWith(imageName: "se_edited", currentClass: SEImageCell.self))
        editedIconImageView.isHidden = true
        return editedIconImageView
    }()
    
    lazy var videoIconImageView: UIImageView = {
        let videoIconImageView = UIImageView()
        videoIconImageView.image = UIImage(contentsOfFile: imagePathWith(imageName: "se_video" , currentClass: SEImageCell.self))
        return videoIconImageView
    }()
    
    lazy var videoDurationLabel: UILabel = {
        let videoDurationLabel = UILabel()
        videoDurationLabel.font = UIFont.boldSystemFont(ofSize: 12)
        videoDurationLabel.textColor = .white
        return videoDurationLabel
    }()
    
    lazy var selectBtn: SESelectButton = {
        let selectBtn = SESelectButton()
        selectBtn.imageSize = CGSize(width: 24, height: 24)
        selectBtn.addTarget(self, action: #selector(selectBtnClicked), for: .touchUpInside)
        return selectBtn
    }()
    
    lazy var maskForegroundView: UIView = {
        let maskForegroundView = UIView()
        maskForegroundView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        maskForegroundView.isHidden = true
        return maskForegroundView
    }()
    
    // MARK: -  Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(selectBtn)
        addSubview(videoView)
//        videoView.addSubview(videoIconImageView)
//        videoView.addSubview(videoDurationLabel)
        addSubview(editedIconImageView)
        addSubview(maskForegroundView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        selectBtn.frame = CGRect(x: bounds.width - 40, y: 0, width: 40, height: 40)
        videoView.frame = CGRect(x: 0, y: bounds.height - 20, width: bounds.width, height: 14)
        editedIconImageView.frame = CGRect(x: 8, y: bounds.height - 20, width: 17, height: 13)
        videoIconImageView.frame = CGRect(x: 8, y: 1, width: 18, height: 12)
        videoDurationLabel.sizeToFit()
        videoDurationLabel.frame = CGRect(x: videoIconImageView.frame.maxX + 6, y: 0, width: videoDurationLabel.frame.width, height: 14)
        maskForegroundView.frame = bounds
        if showCameraCell {
            cameraBgView.frame = bounds
            cameraImageView.frame = CGRect(x: (bounds.width - 28) * 0.5, y: 20, width: 28, height: 22)
            cameraTipLabel.frame = CGRect(x: 0, y: cameraImageView.frame.maxY + 10, width: bounds.width, height: 15)
        }
    }
    
    /// 点击
    @objc private func selectBtnClicked() {
        selectBtnClickedCallback?(self)
    }
    
}
