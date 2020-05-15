//
//  ViewController.swift
//  TYTiedRender
//
//  Created by zhaotaoyuan on 2018/1/23.
//  Copyright © 2018年 DoMobile21. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class ViewController: UIViewController {

    
    var dymamicLoadImage: XDynamicLoadImage = XDynamicLoadImage()
    
    override func viewDidLoad() {
         super.viewDidLoad()
        view.addSubview(dymamicLoadImage)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dymamicLoadImage.frame = view.bounds
    }

}

