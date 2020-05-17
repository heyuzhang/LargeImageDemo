//
//  Loading.swift
//  TYTiedRender
//
//  Created by 张赫宇 on 2020/3/15.
//

import UIKit
import ImageIO
import CoreGraphics
import SDWebImage

class Loading: NSObject {
    
    var imageView = UIImageView()
    
    override init() {
        super.init()
    }
    
    func loadingImage(numStr :String)->CGImageSource? {
        let sImage = Bundle.main.path(forResource: numStr, ofType: "tif")
        guard let loadImage = sImage else { return nil }
        let url = URL(fileURLWithPath: loadImage)
        let imageSource: CGImageSource? = CGImageSourceCreateWithURL((url as CFURL), nil)
        return imageSource ?? nil
    }
    
       var count = 0
    func loadingImage(_ urlStr: String,completion: @escaping (UIImage?)->()) {
        imageView.sd_setHighlightedImage(with: URL(string: urlStr), options: .allowInvalidSSLCertificates) { (image, error, cacheType, url) in
            
            completion(image)
            if error != nil {
                print(error ?? "发生错误")
            }
        }
    }
    
}

/*
 extension UIImage {
 /// 截取图片的指定区域，并生成新图片
 /// - Parameter rect: 指定的区域
 func cropping(to rect: CGRect) -> UIImage? {
 let scale = UIScreen.main.scale
 let x = rect.origin.x * scale
 let y = rect.origin.y * scale
 let width = rect.size.width * scale
 let height = rect.size.height * scale
 let croppingRect = CGRect(x: x, y: y, width: width, height: height)
 // 截取部分图片并生成新图片
 guard let sourceImageRef = self.cgImage else { return nil }
 guard let newImageRef = sourceImageRef.cropping(to: croppingRect) else { return nil }
 let newImage = UIImage(cgImage: newImageRef, scale: scale, orientation: .up)
 return newImage
 }
 */



