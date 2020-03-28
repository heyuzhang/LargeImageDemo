//
//  XCoordinateMagage.swift
//  TYTiedRender
//
//  Created by hulianxin1 on 2020/3/19.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import Foundation
import UIKit

struct XCoordinateMagage {
    
    /** 图片的索引 */
    var sliceImageIndex: String = ""
    
    /* 点击的坐标在新坐标系中的的位置 */
    var newPoint: CGPoint = .zero
    
    //返回格式是 00_00
    func imageName(in context: CGContext, use tiledLayer: CATiledLayer, with prefix: String?) -> String? {
        
        let bounds = context.boundingBoxOfClipPath
        let x = Int(floorf(Float(bounds.origin.x / tiledLayer.tileSize.width)))
        let y = Int(floorf(Float(bounds.origin.y / tiledLayer.tileSize.height)))
        if prefix != nil {
            return "\(prefix!)_\(y)_\(x)"
        }
        return "\(y)_\(x)"
        
    }
    
    /// 计算点击的坐标(x,y)在view坐标内的frame,已经点击位置图片的索引
    mutating func coordinateCalculate(x: CGFloat, y: CGFloat,from sourceView:UIView, to aimView: UIView, cutNumberX numberX:Int, cutNumberY numberY:Int) {
        
        let avgW:CGFloat = sourceView.bounds.size.width / CGFloat(numberX)
        let avgH:CGFloat = sourceView.bounds.size.height / CGFloat(numberY)
        
        var xIndex = "0"
        var yIndex = "0"
        
        //x 方向
        for i in 0..<numberX {
            if x > avgW * CGFloat(Float(i)) &&
               x < avgW * CGFloat(Float(i + 1)) {
                yIndex = "\(i)"
                
            }
            
        }
        
        for i in 0..<numberY {
            if y > avgH * CGFloat(i) &&
               y < avgH * CGFloat(i+1) {
                xIndex = "\(i)"
            }
        }
        
        sliceImageIndex = xIndex + yIndex
        
        
        
        let newPointT = CGPoint(x: x, y: y)
        
        newPoint = sourceView.convert(newPointT, to: aimView)
        
        
    }
}
