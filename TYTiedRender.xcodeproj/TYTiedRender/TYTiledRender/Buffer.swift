//
//  Buffer.swift
//  TYTiedRender
//  Created by 张赫宇 on 2020/3/15.
//缓冲区这个函数，想要完成256*256像素瓦片16*16张瓦块的拼接，并剪裁出中间的8*8块显示到视口中
//其中8*8=64张瓦块的拼接（这64张显示到视口中）

import CoreGraphics
import UIKit
import Foundation
class Buffer: UIView,UIScrollViewDelegate{
    
    var bufferView : UIScrollView
    var imageView: UIImageView!
    var imageSource : CGImageSource?
    
    public var tapX：CGFloat = 0
    public var tapY：CGFloat = 0
    
//  存放瓦片编号的一个数组
    var numStr = [String]()
//  存放瓦片编号x值
    var a：Int = 0
//  存放瓦片编号y值
    var b：Int = 0
//  拼接瓦块时候，存放横起来左右拼接的一个大图的数组
    var array = [CGImage]()
    
    var addimage: CGImage?
    var isfirst: Bool = true
    var len: Int
    
    var closeBtn: UIButton!
    
    init(frame: CGRect, contentSize: CGSize) {
        bufferView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        //设置最大最小缩放比例
        bufferView.maximumZoomScale = 4.0
        bufferView.minimumZoomScale = 1.0
        bufferView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView = UIImageView()
        numStr = ""
        var imageSource : CGImageSource?
        numStr = [""]
        a：Int = 0
        b：Int = 0
        var addimage: CGImage?
        var isfirst: Bool = true
        var len: Int = numStr.count
        
        //退出高清图view
        closeBtn = UIButton(type: .custom)
        closeBtn.setTitle("退出", for: .normal)
        closeBtn.frame = CGRect(x: 10, y: 30, width: 50, height: 50)
        closeBtn.backgroundColor = .lightGray
        
        super.init(frame: frame)
        bufferView.delegate = self

        bufferView.addSubview(imageView)
        self.addSubview(bufferView)
        
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.addSubview(closeBtn)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func close() {
           numStr = ""
           self.removeFromSuperview()
       }
       
       func viewForZooming(in scrollView: UIScrollView) -> UIView? {
           return imageView
       }
    
    func bufferViewDid(x:CGFloat , y:CGFloat, with rect: CGRect){
        var tx: CGFloat = 0
        var ty: CGFloat = 0
        tx = rect.size.width / 3
        ty = rect.size.height / 3
        
        NSLog("coordinate：（x:%.2f y:%.2f） ", x,y)
        
        var imageSource: CGImageSource?
        
        var a：Int = 0
        var b：Int = 0
            
               for i in 0...2 {
                  if y > ty * CGFloat(i) &&
                     y < ty * CGFloat(i+1) {
                    //存放瓦片编号x值
                     a = i
        //              numStr += "\(i)"
                     }
                   }
          
               for i in 0...2 {
                  if x > tx * CGFloat(Float(i)) &&
                     x < tx * CGFloat(Float(i + 1)) {
                    //  存放瓦片编号y值
                     b = i
        //             numStr += "\(i)"
                     
                  }
                }
            
                for i in a-1...a+1{
                    for j in b-1...b+1{
                        if i>=0 && i < 3 && j >= 0 && j < 3 {
                            var s = "\(i)"+"\(j)"
                            numStr += [s]
                        }
                     }
                }

//        将瓦块拼接的函数，先左右拼接，然后上下拼接（能够把这个函数写出来更好）
         for  i in 1...len{
            //如果不换行
            if numStr[i-1][0] == numStr[i][0]{
                let loading = Loading()
            //加载第一张图片
                var imageSource1: CGImageSource = loading.loadingImage(numStr: numStr[i-1])!
                let imageS1 = imageSource1
                let cgImage1 = CGImageSourceCreateImageAtIndex(imageS1, 0, nil)
            //加载第二张图片
                var imageSource2: CGImageSource = loading.loadingImage(numStr: numStr[i])!
                let imageS2 = imageSource2
                let cgImage2 = CGImageSourceCreateImageAtIndex(imageS2, 0, nil)
                //是不是第一次拼接
                if (isfirst)
                {
//                左右拼接图片
                    addimage = addImage(Image1: cgImage1, toImage: cgImage2)
                    isfirst = false
                }
                else{
                //不是第一次拼接
                    addimage = addImage(Image1: addimage, toImage: cgImage2)
            //如果换行了
                }}else {
            //上下拼接长图
                array += [addimage, CGImage]
                array = []
                    self.isfirst = true
            }
        }

        len = array.count
        isfirst = true
        addimage = nil
        for i in 1...len
        {
            if (isfirst)
            {
                addimage = addImage(Image1: array[i-1], toImage: [i])
                isfirst = false
            }
            else{
                addimage = addImage(Image1: addimage, toImage: [i])
            }
        
            }

            
        
//        let loading = Loading()
//        imageSource = loading.loadingImage(numStr: numStr)
        
        
        NSLog("Loading image ID:%@",numStr)


//左右拼接
        func addImage(image1:UIImage ,toImage image2:UIImage )->UIImage {

                    UIGraphicsBeginImageContext(image1.size);

            // Draw image1

                image1.draw(in: CGRect.init(x: 0, y: 0, width: image1.size.width, height: image1.size.height));

            // Draw image2

            image2.draw(in: CGRect.init(x: 0, y: 0, width: image2.size.width, height: image2.size.height));

                    let resultingImage = UIGraphicsGetImageFromCurrentImageContext();

                UIGraphicsEndImageContext();

                    return resultingImage! ;

            }
            
//  上下拼接 https://www.jianshu.com/p/9249bc7b5c4e（上下拼接这个代码我不知道可不可以行得通）

        func compose(withHeader header: UIImage, content: UIImage, footer: UIImage) -> UIImage {
            var size = CGSize(width: content.size.width, height: header.size.height + content.size.height + footer.size.height)
            UIGraphicsBeginImageContext(size)
            header.draw(in: CGRect(x: 0, y: 0, width: header.size.width, height: header.size.height))
            content.draw(in: CGRect(x: 0, y: header.size.height, width: content.size.width, height: content.size.height))
            footer.draw(in: CGRect(x: 0, y: header.size.height + content.size.height, width: footer.size.width, height: footer.size.height))
            var image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
   
    
    
        /// 截取图片的指定区域，并生成新图片
        /// - Parameter rect: 指定的区域
    func cropping(to rect: CGRect) -> UIImage? {
        let scale = UIScreen.main.scale
        let x = rect.origin.x * scale
        let y = rect.origin.y * scale
        let width = rect.size.width * scale
        let height = rect.size.height * scale
        let croppingRect = CGRect(x: x, y: y, width: width, height: height)
        guard let imageS = self.imageSource else { return nil }
        let cgImage = CGImageSourceCreateImageAtIndex(imageS, 0, nil)
                   
        // 截取部分图片并生成新图片
        guard let sourceImageRef = cgImage else { return nil }
        guard let newImageRef = sourceImageRef.cropping(to: croppingRect) else { return nil }
        let newImage = UIImage(cgImage: newImageRef, scale: scale, orientation: .up)
        return newImage
    }
   
}

    

/*
 //设置TileView的中心始终在scrollview中心
 var xcenter: CGFloat = bufferView.center.x
 var ycenter: CGFloat = bufferView.center.y
 
 xcenter = bufferView.contentSize.width > bufferView.frame.size.width ? bufferView.contentSize.width / 2 : xcenter
 ycenter = bufferView.contentSize.height > bufferView.frame.size.height ? bufferView.contentSize.height / 2 : ycenter
 */
