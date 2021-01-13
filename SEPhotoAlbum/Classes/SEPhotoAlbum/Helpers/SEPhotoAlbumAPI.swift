//
//  SEImageAlbumManager.swift
//  SEImagePickerController
//
//  Created by wenchang on 2020/12/17.
//  Copyright © 2020 SeeEmil. All rights reserved.
//

import UIKit

@objc public class SEPhotoAlbumAPI : NSObject {
    @objc static public func preventImageViewController(superViewController :UIViewController, maxSelectCount :Int, isSelectedFinishDismiss: Bool, isCustomEdit: Bool,_ selectImagesBlock :@escaping (_ controller: UIViewController,_ images: [UIImage]) -> ()) {
        let imagePircker = SEImagePickerController()
        imagePircker.mediaTypes = [.image]
        imagePircker.selectedImages = selectImagesBlock
        imagePircker.maxSelectCount = maxSelectCount
        imagePircker.isCustomEdit = isCustomEdit
        imagePircker.isSelectedFinishDismiss = isSelectedFinishDismiss
        imagePircker.mainTintColor = UIColor(red: 249 / 255.0, green: 60 / 255.0, blue: 83 / 255.0, alpha: 1)
        imagePircker.modalPresentationStyle = .fullScreen
        superViewController.present(imagePircker, animated: true, completion: nil)
    }
    
    @objc static public func preventEditImageController(withImage image: UIImage, fromController superViewController :UIViewController, editFinished:@escaping (_ newImage: UIImage?) -> ()) {
        let clipVC = SEImageClipViewController()
        clipVC.clipImageBlock = editFinished
        clipVC.originImage = image
        superViewController.present(clipVC, animated: true, completion: nil)
    }
}
