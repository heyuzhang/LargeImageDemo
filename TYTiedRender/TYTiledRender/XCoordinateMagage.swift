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
    
    
    /// 需要移动的距离
    func moveDistance(scrollView: UIScrollView, lastContentOffset offSet: CGPoint ,rateX: CGFloat, rateY: CGFloat) -> CGPoint {
        var movePoint: CGPoint = .zero
        
        var contentOffsetX = CGFloat()
        var contentOffsetY = CGFloat()
        
        if rateX >= 1 {//放大
            
            contentOffsetX = scrollView.contentOffset.x
            contentOffsetY = scrollView.contentOffset.y
            let currentCenterPoint = CGPoint(
                x:contentOffsetX + scrollView.frame.size.width * 0.5,
                y: contentOffsetY + scrollView.frame.size.height * 0.5)
            
            let actualPoint = currentCenterPoint;//CGPoint(x: currentCenterPoint.x / scrollView.zoomScale, y: currentCenterPoint.y / scrollView.zoomScale)
            
            movePoint.x = actualPoint.x * rateX - scrollView.frame.size.width * 0.5
            movePoint.y = actualPoint.y * rateY - scrollView.frame.size.height * 0.5
            
        } else {//缩小
            
            contentOffsetX = offSet.x
            contentOffsetY = offSet.y
            
            let currentCenterPoint = CGPoint(
            x:contentOffsetX + scrollView.frame.size.width * 0.5,
            y: contentOffsetY + scrollView.frame.size.height * 0.5)
            
            //转换到小图上的点的坐标
            let smallPoint = CGPoint(x: currentCenterPoint.x * rateX, y: currentCenterPoint.y * rateY)
            
            var moveX = smallPoint.x - scrollView.frame.size.width * 0.5
            var moveY = smallPoint.y - scrollView.frame.size.height * 0.5
            
            if moveX >= scrollView.contentSize.width - scrollView.frame.size.width {
                moveX = scrollView.contentSize.width - scrollView.frame.size.width
            } else if moveX <= 0{
                moveX = 0
            }
            
            if moveY >= scrollView.contentSize.height - scrollView.frame.size.height  {
                moveY = scrollView.contentSize.height - scrollView.frame.size.height
            } else if moveY <= 0{
                moveY = 0
            }
            
            movePoint.x = moveX
            movePoint.y = moveY
            
        }
        
        return movePoint
        
    }
    
    
    
}
