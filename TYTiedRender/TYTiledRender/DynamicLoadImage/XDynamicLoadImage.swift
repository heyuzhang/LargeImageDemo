//
//  XDynamicLoadImage.swift
//  TYTiedRender
//
//  Created by 吴新 on 2020/3/28.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit

class XDynamicLoadImage: UIView,UIScrollViewDelegate {
    
    //默认，也可以改变
    var titleSize: CGSize = CGSize(width: 256, height: 256)
    
    //大图的像素 可根据网络加载回来的图片计算出来，然后赋值即可
    var imagePixel: CGSize = CGSize(width: 33 * 256, height: 31 * 256)  {
        didSet {
            if tiledLayer != nil {
                scrollView.contentSize = imagePixel
                tiledLayer?.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                imageView.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                tiledLayer?.setNeedsDisplay()

            }
        }
    }
    
    //图片名称的前缀 本地图片
    var imageNamePrefix: String? {
        didSet {
            tiledLayerDelegate.imageNamePrefix = imageNamePrefix
            if tiledLayer != nil {
                tiledLayer?.setNeedsDisplay()
            }
        }
    }
    
    //网络加载的图片数组 需进一步处理
    var netImages: [UIImage]?
    //网络图片给的是url，也需要另处理
    var netImageURLStrs: [String]?
    
    
    ///倍率切换view
    lazy var multipleSwitchView: XMultipleSwitchView = XMultipleSwitchView()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private var tiledLayer: CATiledLayer?
    private lazy var imageView: UIImageView = {
        
        let imgV = UIImageView()
        imgV.backgroundColor = .clear
        return imgV
        
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        multipleSwitchView.frame = CGRect(x: 0, y: bounds.size.height - 50, width: bounds.size.width, height: 50)
        
    }
    
    private var tiledLayerDelegate: XTiledLayerDelegate = XTiledLayerDelegate()
   
    private func setupUI() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 1
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        let tiledLayer = CATiledLayer()
        tiledLayer.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
        self.tiledLayer = tiledLayer
        tiledLayer.delegate = tiledLayerDelegate
        imageView.layer.addSublayer(tiledLayer)
        imageView.frame = tiledLayer.bounds
        scrollView.contentSize = tiledLayer.frame.size

        tiledLayer.setNeedsDisplay()
        
        //倍率切换
        multipleSwitchView.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        
        multipleSwitchView.multiples = [
            Rateinfo(imagePrefix: "1", rateName: "20x"),
            Rateinfo(imagePrefix: "1", rateName: "30x"),
            Rateinfo(imagePrefix: "1", rateName: "40x"),
            Rateinfo(imagePrefix: "1", rateName: "50x")]
        addSubview(multipleSwitchView)
        
        
        
    }
    
   
    
    
   
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    

}
