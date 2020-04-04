//
//  ViewController.swift
//  TYTiedRender
//
//  Created by zhaotaoyuan on 2018/1/23.
//  Copyright © 2018年 DoMobile21. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   lazy var viewPort = XImageView()
    
    var dymamicLoadImage: XDynamicLoadImage = XDynamicLoadImage()
    lazy var imagePath: String = {
        let sImage = Bundle.main.path(forResource: "缩率图", ofType: "png")
        return sImage ?? ""
    }()
    
    override func viewDidLoad() {
         super.viewDidLoad()
//        view.backgroundColor = .white
//        dymamicLoadImage.imageNamePrefix = "4"
//        dymamicLoadImage.widthNumber = 11
//        dymamicLoadImage.heightNumber = 12
        view.addSubview(dymamicLoadImage)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dymamicLoadImage.frame = view.bounds
        //          viewPort.showImage(imagePath, in: view, with: view.bounds)
    }

}

