//
//  XTiledLayerDelegate.swift
//  TYTiedRender
//
//  Created by zhangheyu on 2020/3/20.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit

class XTiledLayerDelegate: NSObject, CALayerDelegate {
    
    var tiledLayer: CATiledLayer?
    
    //图片名称的前缀 本地图片
    var imageNamePrefix: String? {
        didSet {
            if tiledLayer != nil {
                tiledLayer?.setNeedsDisplay()
            }
        }
    }
    
    //网络加载的图片数组 需进一步处理
    var netImages: [UIImage]?
    //网络图片给的是url，也需要另处理
    var netImageURLStrs: [String]?
    
    
    private var coordinateManage: XCoordinateMagage = XCoordinateMagage()
    private var loading: Loading = Loading()

    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        let bounds = ctx.boundingBoxOfClipPath
        if netImages != nil && netImages!.count > 0 || netImageURLStrs != nil && netImageURLStrs!.count > 0 {//需要另外处理
            
            print("需要处理网络请求回来的")
            
            
        } else {
            
            
            
            if let imageName = coordinateManage.imageName(in: ctx, use: layer as! CATiledLayer, with:imageNamePrefix),
                let imageSource = loading.loadingImage(numStr: imageName),
                let cgSourceImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
                print(imageName,imageNamePrefix ?? "")
                let image = UIImage(cgImage: cgSourceImage)
                UIGraphicsPushContext(ctx)
                image.draw(in: bounds)
                UIGraphicsPopContext()
            }
        }
    }
    
    
}
