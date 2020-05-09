//
//  XImageView.swift
//  TYTiedRender
//
//  Created by hulianxin1 on 2020/5/9.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit

class XCustomView: UIView {
    
    var allPoints: [Int: [[CGPoint]]] = [:] {
        didSet {
//            setNeedsDisplay()
        }
    }
    var currentIndex: Int = 0
    var multipleSwitchView: XMultipleSwitchView?
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        
        if let context = UIGraphicsGetCurrentContext() {
            
            context.setLineWidth(3.0)
            context.setFillColor(UIColor.clear.cgColor)
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineCap(.round)
            
            for (key, value) in allPoints {//遍历字典
                for (_, points) in value.enumerated() {//遍历绘制的图形
                    for (index, point) in points.enumerated() {
                        var newPoint: CGPoint = .zero
                        
                        if key == currentIndex {//不需要转换坐标
                            newPoint = point
                        } else {
                            //当前所在的倍率
                            let currentRateInfo = multipleSwitchView!.multiples[currentIndex]
                            
                            //画标注时所在的倍率
                            let rateInfo = multipleSwitchView!.multiples[key]
                            
                            let rX = CGFloat(currentRateInfo.heightNumber) / CGFloat(rateInfo.heightNumber)
                            let rY = CGFloat(currentRateInfo.widthNumber) / CGFloat(rateInfo.widthNumber)
                            
                            newPoint.x = point.x * rX
                            newPoint.y = point.y * rY
                        }
                        
                        if index == 0 {
                            context.move(to: newPoint)
                        } else {
                            context.addLine(to: newPoint)
                        }
                        
                    }
                }
            }
            context.strokePath()

        }
    }
        
}
