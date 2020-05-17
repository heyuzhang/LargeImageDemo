//
//  XTiledLayerDelegate.swift
//  TYTiedRender
//
//  Created by zhangheyu on 2020/3/20.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage


class XTiledLayerDelegate: NSObject, CALayerDelegate {
    
    var tiledLayer: CATiledLayer?
    
    var imageView:UIImageView?
    
    var imageUrls: [String: String]? {
        didSet {
            if reLoad {
                loadImage()                
            }
            
        }
    }
    var count = 0

    let semaphore = DispatchSemaphore(value: 1)
    
    
    var reLoad: Bool = false
    
    //图片名称的前缀 本地图片
    var imageNamePrefix: String? {
        
        willSet {
            
            if imageNamePrefix == newValue {
                reLoad = false
            } else {
                reLoad = true
            }
            
        }
        
        didSet {
            if tiledLayer != nil {
                tiledLayer?.setNeedsDisplay()
            }
        }
    }
    
    private var coordinateManage: XCoordinateMagage = XCoordinateMagage()
    private var loading: Loading = Loading()

    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        let bounds = ctx.boundingBoxOfClipPath
        
//        print(Thread.current)
        
       let imageInfo = coordinateManage.imageName(in: ctx, use: layer as! CATiledLayer, with:imageNamePrefix, imageURLs: imageUrls)
        
        
       
        
        if let imageName = imageInfo.0 {
            if let imageSource = loading.loadingImage(numStr: imageName),
                let cgSourceImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
                let image = UIImage(cgImage: cgSourceImage)
                UIGraphicsPushContext(ctx)
                image.draw(in: bounds)
                UIGraphicsPopContext()
            } else { //网络图片
                
                let imageCache = SDImageCache.shared()
                var image = imageCache.imageFromDiskCache(forKey: imageInfo.1)

                if image == nil {
                    image = imageCache.imageFromMemoryCache(forKey: imageInfo.1)
                }

                if image != nil {
                    UIGraphicsPushContext(ctx)
                    image!.draw(in: bounds)
                    UIGraphicsPopContext()
                } else {
                    //通知重新下载
                    loadImage(name: imageInfo.0 ?? "")
                }
                
            }
        }
    }
}

extension XTiledLayerDelegate {
    
    func loadImage() {
        if let imageurls = imageUrls {
            DispatchQueue.global().async {
                for (key,_) in imageurls {
                    self.loadImage(name: key)
                }
            }
        }
    }
    
    
    func loadImage(name: String) {
        if let imageurl = imageUrls?[name] {
            self.semaphore.wait()
            self.loading.loadingImage(imageurl) { (image) in
                self.semaphore.signal()
                if self.tiledLayer != nil {
                    self.tiledLayer?.setNeedsDisplay()
                }
            }
        }
    }
    
}
