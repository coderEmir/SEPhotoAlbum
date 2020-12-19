//
//  SEImageNavigationView.swift
//  SEImagePickerController
//
//  Created by xKing on 2019/3/14.
//  Copyright © 2019年 SeeEmil. All rights reserved.
//

import UIKit

class SEImageNavigationView: UIView {

    /// 主题颜色
    var mainTintColor: UIColor = .red {
        didSet {
            selectBtn.mainTintColor = mainTintColor
        }
    }
    
    lazy var selectBtn: SESelectButton = {
        let selectBtn = SESelectButton()
        selectBtn.imageSize = CGSize(width: 30, height: 30)
        return selectBtn
    }()
    
    lazy var backBtn: UIButton = {
        let backBtn = UIButton()
        backBtn.setImage(UIImage(contentsOfFile: imagePathWith(imageName: "se_back", currentClass: SEImageCell.self)), for: .normal)
        return backBtn
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    private var contentHeight: CGFloat = 0
    
    // MARK: -  Life Cycle
    
    init(frame: CGRect, contentHeight: CGFloat) {
        super.init(frame: frame)
        backgroundColor = se_toolBarBackgroundColor
        self.contentHeight = contentHeight
        addSubview(contentView)
        contentView.addSubview(selectBtn)
        contentView.addSubview(backBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: bounds.height - contentHeight, width: bounds.width, height: contentHeight)
        backBtn.frame = CGRect(x: 0, y: (contentHeight - 44) / 2, width: 44, height: 44)
        selectBtn.frame = CGRect(x: bounds.width - 54, y: (contentHeight - 44) / 2, width: 44, height: 44)
    }

}
