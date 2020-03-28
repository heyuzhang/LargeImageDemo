//
//  Viewport.swift
//  TYTiedRender
//  Created by 张赫宇 on 2020/3/15.
//

import UIKit
import ImageIO
import CoreGraphics
import Foundation
class Viewport: UIView {
//    var viewport : Viewport
    
    /** 用来展示缩略图 */
    var imageView: UIImageView!
    var thumbnailView:UIView!
    
    override init(frame: CGRect) {
        imageView = UIImageView()  //        self.viewport = Viewport()
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showImage(withImageSource path: String, show view: UIView , frame: CGRect) {
        thumbnailView = view
        
        var touch_x : size_t
        var touch_y : size_t
        
        // Do any additional setup after loading the view, typically from a nib.
        var buffer_frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(view.bounds.size.width), height: CGFloat(view.bounds.size.height))
        if frame.width != 0 && frame.height != 0 { // cus Frame
            buffer_frame = frame
        }
       
        let bufferView = Buffer(
            frame: buffer_frame,
            contentSize: CGSize(width: CGFloat(buffer_frame.size.width),
                                height: CGFloat(buffer_frame.size.height)))
        
        //初始化图像数据
        let url = URL(fileURLWithPath: path)
        let imageSource: CGImageSource? = CGImageSourceCreateWithURL((url as CFURL), nil)
        let cgSourceImage: CGImage = CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)!
        
        //展示缩略图
        imageView.image = UIImage.init(cgImage: cgSourceImage)
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)
        
        NSLog(" func showImage complete. ")
        
        //添加用户点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        imageView.addGestureRecognizer(tap)
        
        
        let imageWidth: Int = cgSourceImage.width
        let imageHeight: Int = cgSourceImage.height
        //            bufferView .pushLevelsOfZoom(levels: scale)
        //            bufferView .levelsOfZoom = scale
        //            bufferView .setLevelsOfDetail(scale)
        //            bufferView .contentMode = .center
        //            bufferView .backgroundColor = UIColor.black
        
//        view.insertSubview(bufferView, at: 0)
        
        //            bufferView.setZoomScale(beginScale, animated: false)
    }
    
    
}
/*
 添加计算属性 - computed properties
 添加方法 - methods
 添加初始化方法 - initializers
 添加附属脚本 - subscripts
 添加并使用嵌套类型 - nested types
 遵循并实现某一协议 - conform protocol
 */
extension Viewport {
    
    @objc func tapAction(tap: UITapGestureRecognizer) {
        if let tapView = tap.view {
            //根据点击位置查看相应高清图
            let tapPoint = tap.location(in: tapView)
            //Bitmap
            let bufferView = Buffer(frame: thumbnailView.bounds, contentSize: CGSize.zero)
//            bufferView.bufferViewDid(x: tapPoint.x, y: tapPoint.y, with: tapView.bounds)
            
            thumbnailView.addSubview(bufferView)
            
            NSLog(" response func tapAction. ")
            
        }
    }
    
    

}


//    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)->(x:CGFloat,y:CGFloat){
//
//        let firstTouch:UITouch = touches.first!
//        let firstPoint = firstTouch.location(in: self.viewport)
//        let x:CGFloat = firstPoint.x
//        let y:CGFloat = firstPoint.y
//        return (x,y)
//    }






/* //向上取整
 let totalRow = Int(ceil(Double(imageHeight / 256)))+1
 let totalCol = Int(ceil(Double(imageWidth / 256)))+1
 //取切片应对用的填充区域的大小
 let blockWidth = Int(view.bounds.size.width / CGFloat(totalCol))
 let blockHeight = Int(view.bounds.size.height / CGFloat(totalRow))
 var minLength: Int = blockWidth < blockHeight ? blockWidth : blockHeight
 //取能被256整除的数字
 while 256%minLength != 0 {
 minLength = minLength-1;
 }
 //计算初始的放大倍数
 let beginScale = Float(Float(view.frame.size.width)/Float(minLength*totalCol))
 let blockSize = CGSize(width: CGFloat(minLength), height: CGFloat(minLength))
 
 //计算应显示的区域大小
 scrollView.tiledView.frame = CGRect(x: CGFloat((CGFloat(scrollView.bounds.size.width) -  CGFloat(minLength * totalCol)) / 2), y: CGFloat((scrollView.bounds.size.height - CGFloat(minLength * totalRow)) / 2), width: CGFloat(minLength * totalCol), height: CGFloat(minLength * totalRow))
 //计算最大放大倍数
 var renderSize: Int = minLength
 let realSize = 256
 
 var scale: Int = 0
 renderSize = renderSize << 1
 while renderSize < realSize {
 scale += 1
 renderSize = renderSize << 1
 }
 scrollView.tiledView.blockSize = blockSize
 scrollView.tiledView.totalCol = totalCol
 scrollView.tiledView.totalRow = totalRow
 scrollView.tiledView.lastColWidth = CGFloat(imageWidth - (totalCol - 1) * 256)
 scrollView.tiledView.lastRowHeight = CGFloat(imageHeight - (totalRow - 1) * 256)
 */


