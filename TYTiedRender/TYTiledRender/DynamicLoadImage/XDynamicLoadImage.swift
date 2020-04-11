//
//  XDynamicLoadImage.swift
//  TYTiedRender
//
//  Created by zhangheyu on 2020/3/28.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit

class XDynamicLoadImage: UIView,UIScrollViewDelegate {
    
    //默认，也可以改变
    var titleSize: CGSize = CGSize(width: 256, height: 256)

    
    ///宽方向切图的数量
    var widthNumber:Int = 0 {
        didSet {
//            imagePixel = CGSize(width:  CGFloat(heightNumber) * titleSize.width, height: CGFloat(widthNumber ) * titleSize.height)
            imagePixel = CGSize(width:  CGFloat(heightNumber) * titleSize.width * scrollView.zoomScale, height: CGFloat(widthNumber ) * titleSize.height * scrollView.zoomScale)

        }
    }
    ///高方向切图的数量
    var heightNumber:Int = 0 {
       didSet {
//        imagePixel = CGSize(width:  CGFloat(heightNumber ) * titleSize.width, height: CGFloat(widthNumber) * titleSize.height)

        imagePixel = CGSize(width:  CGFloat(heightNumber ) * titleSize.width * scrollView.zoomScale , height: CGFloat(widthNumber) * titleSize.height * scrollView.zoomScale)

        
       }
    }
    //大图的像素 可根据网络加载回来的图片计算出来，然后赋值
    var imagePixel: CGSize = .zero {
        didSet {
            if tiledLayer != nil {
//                scrollView.zoomScale = 1
                scrollView.contentSize = imagePixel
                tiledLayer?.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                imageView.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                tiledLayerDelegate.imageNamePrefix = imageNamePrefix
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
    
    
    lazy var coordinateManage: XCoordinateMagage = XCoordinateMagage()
   
    ///X方向的缩放比例
    var rateX: CGFloat = CGFloat()
    ///y方向的缩放比例
    var rateY: CGFloat = CGFloat()
    
    ///scrollView当前的偏距
    private var currentOffset: CGPoint = .zero
    ///当前倍率索引
    private var currentIndex: Int = 0 {
        willSet {
            
            currentOffset = scrollView.contentOffset
            let rateInfo = self.multipleSwitchView.multiples[newValue]
            let newImageSize = CGSize(width:  CGFloat(rateInfo.heightNumber) * titleSize.width * scrollView.zoomScale, height: CGFloat(rateInfo.widthNumber ) * titleSize.height * scrollView.zoomScale)
            
            rateX = newImageSize.width / scrollView.contentSize.width
            rateY = newImageSize.height / scrollView.contentSize.width
        }
        
        didSet {
           
            let rateInfo = self.multipleSwitchView.multiples[currentIndex]
            self.widthNumber = rateInfo.widthNumber
            self.heightNumber = rateInfo.heightNumber
            self.imageNamePrefix = rateInfo.imagePrefix
            moveScroll()
            
            
        }
    }
    
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
        if  multipleSwitchView.multiples.count != 0  {
            let defaultRateInfo = multipleSwitchView.multiples[currentIndex]
             heightNumber = defaultRateInfo.widthNumber
             widthNumber = defaultRateInfo.heightNumber
            imageNamePrefix = defaultRateInfo.imagePrefix
        }
        tiledLayer?.setNeedsDisplay()
        
    }
    
    private var tiledLayerDelegate: XTiledLayerDelegate = XTiledLayerDelegate()
   
    private func setupUI() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 200
        scrollView.minimumZoomScale = 1
        if #available(iOS 13.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        let tiledLayer = CATiledLayer()
        tiledLayer.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
        tiledLayer.tileSize = CGSize(width: 256, height: 256)
        self.tiledLayer = tiledLayer
        tiledLayer.delegate = tiledLayerDelegate
        imageView.layer.addSublayer(tiledLayer)
//        imageView.backgroundColor = .red
        
        imageView.frame = tiledLayer.bounds
        scrollView.contentSize = tiledLayer.frame.size

        tiledLayer.setNeedsDisplay()
        
        //倍率切换
        multipleSwitchView.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        
        multipleSwitchView.multiples = [
            Rateinfo(imagePrefix: "5", rateName: "1x",widthNumber: 6, heightNumber: 6),
            Rateinfo(imagePrefix: "4", rateName: "5x",widthNumber: 11, heightNumber: 12),
//            Rateinfo(imagePrefix: "3", rateName: "10x",widthNumber: 22, heightNumber: 24),
//            Rateinfo(imagePrefix: "4", rateName: "20x",widthNumber: 44, heightNumber: 47),
//            Rateinfo(imagePrefix: "1", rateName: "40x",widthNumber: 88, heightNumber: 94),
//            Rateinfo(imagePrefix: "1", rateName: "40x",widthNumber: 86, heightNumber: 92)
        ]
        multipleSwitchView.buttonClickBlock = { index in
            self.currentIndex = index
        }
        
        addSubview(multipleSwitchView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        print(scrollView.contentSize)
        
    }
    
    
    func moveScroll() {
        
        let moveDistance: CGPoint = coordinateManage.moveDistance(scrollView: scrollView, lastContentOffset: currentOffset, rateX: rateX, rateY: rateY)
//        scrollView.zoomScale = 1
//        scrollView.contentSize = imagePixel
        
        let rateInfo = self.multipleSwitchView.multiples[currentIndex]
        self.widthNumber = rateInfo.widthNumber
        self.heightNumber = rateInfo.heightNumber
        self.imageNamePrefix = rateInfo.imagePrefix
        
        scrollView.contentOffset = moveDistance
    }
    

}
