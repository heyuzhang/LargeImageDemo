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
    
    private var coordinateManage: XCoordinateMagage = XCoordinateMagage()
    private var loading: Loading = Loading()

    
    func draw(_ layer: CALayer, in ctx: CGContext) {
        let bounds = ctx.boundingBoxOfClipPath
        
        if let imageName = coordinateManage.imageName(in: ctx, use: layer as! CATiledLayer, with:imageNamePrefix) {
            
            if let imageSource = loading.loadingImage(numStr: imageName),
                let cgSourceImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
                let image = UIImage(cgImage: cgSourceImage)
                UIGraphicsPushContext(ctx)
                image.draw(in: bounds)
                UIGraphicsPopContext()
            } else { //网络图片
                
                
            }
        }
        
    }
}
