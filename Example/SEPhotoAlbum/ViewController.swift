//
//  ViewController.swift
//  SEPhotoAlbum
//
//  Created by 17629918 on 12/19/2020.
//  Copyright (c) 2020 17629918. All rights reserved.
//

import UIKit
import SEPhotoAlbum
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SEImageAlbumManager.preventImageViewController(superViewController: self, maxSelectCount: 90, isSelectedFinishDismiss: true, isCustomEdit: true) { (controller, images) in
            
        }
    }

}

