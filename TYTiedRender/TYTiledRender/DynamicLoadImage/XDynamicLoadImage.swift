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
            
             imagePixel = CGSize(width:  CGFloat(heightNumber) * titleSize.width * scrollView.zoomScale, height: CGFloat(widthNumber ) * titleSize.height * scrollView.zoomScale)

        }
    }
    
    ///高方向切图的数量
    var heightNumber:Int = 0 {
       didSet {
        imagePixel = CGSize(width:  CGFloat(heightNumber ) * titleSize.width * scrollView.zoomScale , height: CGFloat(widthNumber) * titleSize.height * scrollView.zoomScale)

       }
    }
    
    ///绘制按钮
    private var enterDrawBtn: UIButton!
    ///绘图layer
    private lazy var shapelayer: CAShapeLayer = {
        var shape = CAShapeLayer()
        shape.strokeColor = UIColor.red.cgColor
        shape.lineCap = kCALineCapRound;
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 2;
        return shape
    }()
    ///绘制path
    private var bezierPath: UIBezierPath = UIBezierPath()
    ///绘制手势pan
    private var panGesture: UIPanGestureRecognizer!
    ///所有的绘制点
    ///Int:表示在哪个倍率下
    ///[[CGPoint]]:表示连续的标注,第一个点代表起始点,其他点代表绘制的点
    private var allPoints: [Int: [[CGPoint]]] = [:]
    ///正在绘制过程中的点
    private var drawingPoint: [CGPoint] = []
    
    //大图的像素 可根据网络加载回来的图片计算出来，然后赋值
    var imagePixel: CGSize = .zero {
        didSet {
            if tiledLayer != nil {
                scrollView.contentSize = imagePixel
                imageView.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                tiledLayer?.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                tiledLayerDelegate.imageNamePrefix = imageNamePrefix
                tiledLayer?.setNeedsDisplay()
                shapelayer.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                
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
            reDrawPath()
            
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
        imgV.isUserInteractionEnabled = true
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
             heightNumber = defaultRateInfo.heightNumber
             widthNumber = defaultRateInfo.widthNumber
            imageNamePrefix = defaultRateInfo.imagePrefix
        }
        tiledLayer?.setNeedsDisplay()
        
        enterDrawBtn.frame = CGRect(x: 0, y: (bounds.size.height - 50) * 0.5, width: 50, height: 50)
        enterDrawBtn.layer.cornerRadius = 25
        enterDrawBtn.layer.masksToBounds = true
    }
    
    private var tiledLayerDelegate: XTiledLayerDelegate = XTiledLayerDelegate()
   
    private func setupUI() {
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1000
        scrollView.minimumZoomScale = 0.2
        
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
            Rateinfo(imagePrefix: "3", rateName: "10x",widthNumber: 22, heightNumber: 24),
            Rateinfo(imagePrefix: "2", rateName: "20x",widthNumber: 44, heightNumber: 47),
//            Rateinfo(imagePrefix: "1", rateName: "40x",widthNumber: 88, heightNumber: 94),
//            Rateinfo(imagePrefix: "1", rateName: "40x",widthNumber: 86, heightNumber: 92)
        ]
        multipleSwitchView.buttonClickBlock = { index in
            self.scrollView.setZoomScale(1, animated: false)
            self.currentIndex = index
        }
        
        addSubview(multipleSwitchView)
        
        
        //绘制按钮
        enterDrawBtn = UIButton(type: .custom)
        enterDrawBtn.setTitle("绘制", for: .normal)
        enterDrawBtn.setTitle("确定", for: .selected)
        enterDrawBtn.setTitleColor(.white, for: .normal)
        enterDrawBtn.setTitleColor(.white, for: .selected)
        enterDrawBtn.backgroundColor = .lightGray
        enterDrawBtn.addTarget(self, action: #selector(drawAction(_:)), for: .touchUpInside)
        addSubview(enterDrawBtn)
        
        //添加pan手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture = pan
        imageView.layer.addSublayer(shapelayer)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private var lastContentSize: CGSize = .zero
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let contentSize = scrollView.contentSize
        
        if lastContentSize.width > contentSize.width {//缩小
            if currentIndex != 0 {
                let nextRateinfo = multipleSwitchView.multiples[currentIndex - 1]
                let imagePixel = CGSize(width:  CGFloat(nextRateinfo.heightNumber ) * titleSize.width , height: CGFloat(nextRateinfo.widthNumber) * titleSize.height)
                if contentSize.width < imagePixel.width {//缩小切换
                    multipleSwitchView.clickButton(with: currentIndex - 1)
                }
            }
        } else {//放大
            if currentIndex != multipleSwitchView.multiples.count - 1 {
                let nextRateinfo = multipleSwitchView.multiples[currentIndex + 1]
                let imagePixel = CGSize(width:  CGFloat(nextRateinfo.heightNumber ) * titleSize.width , height: CGFloat(nextRateinfo.widthNumber) * titleSize.height)
                if contentSize.width >= imagePixel.width {//放大切换
                    multipleSwitchView.clickButton(with: currentIndex + 1)
                }
            }
        }
        
        lastContentSize = scrollView.contentSize
    }
    
    private func moveScroll() {
        
        let moveDistance: CGPoint = coordinateManage.moveDistance(scrollView: scrollView, lastContentOffset: currentOffset, rateX: rateX, rateY: rateY)
        scrollView.contentOffset = moveDistance
    }
}

///与标注相关
extension XDynamicLoadImage {
    
    @objc func drawAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            scrollView.isScrollEnabled = false
            imageView.addGestureRecognizer(panGesture)
        } else {
            imageView.removeGestureRecognizer(panGesture)
            scrollView.isScrollEnabled = true
        }
    }
    
    @objc func panGestureAction(_ pan: UIPanGestureRecognizer) {
        let startPoint = pan.location(in: imageView)
        var points = allPoints[currentIndex]
        if points == nil {
            points = [[]]
        }
        switch pan.state {
        case .began:
            drawingPoint.append(startPoint)
            bezierPath.move(to: startPoint)
            break
        case .changed:
            let movePoint = pan.location(in: imageView)
            bezierPath.addLine(to: movePoint)
            shapelayer.path = bezierPath.cgPath
            drawingPoint.append(movePoint)
            break
        case .ended:
            
            points?.append(drawingPoint)
            drawingPoint.removeAll()
            break
        case .cancelled:
            
            points?.append(drawingPoint)
            drawingPoint.removeAll()
            break
            
        default: break
            
        }
        
        allPoints[currentIndex] = points
        
    }
    
    //切换倍率的时候重新绘制
    func reDrawPath() {
        bezierPath.removeAllPoints()
        
        for (key, value) in allPoints {//遍历字典
            for (_, points) in value.enumerated() {//遍历绘制的图形
                for (index, point) in points.enumerated() {
                    var newPoint: CGPoint = .zero
                    
                    if key == currentIndex {//不需要转换坐标
                        newPoint = point
                    } else {
                        //当前所在的倍率
                        let currentRateInfo = self.multipleSwitchView.multiples[currentIndex]
                        
                        //画标注时所在的倍率
                        let rateInfo = multipleSwitchView.multiples[key]
                
                        let rX = CGFloat(currentRateInfo.heightNumber) / CGFloat(rateInfo.heightNumber)
                        let rY = CGFloat(currentRateInfo.widthNumber) / CGFloat(rateInfo.widthNumber)
                        
                        newPoint.x = point.x * rX
                        newPoint.y = point.y * rY
                    }
                    if index == 0 {
                        bezierPath.move(to: newPoint)
                    } else {
                        bezierPath.addLine(to: newPoint)
                    }
                }
            }
        }
        
        shapelayer.path = bezierPath.cgPath
    }
}
