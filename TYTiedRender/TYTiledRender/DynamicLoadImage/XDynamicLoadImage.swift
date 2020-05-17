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
    ///撤销按钮
    private var cancelBtn: UIButton!
    
    ///绘图layer
    private lazy var shapelayer: CAShapeLayer = {
        var shape = CAShapeLayer()
        shape.strokeColor = UIColor.red.cgColor
        shape.lineCap = kCALineCapRound;
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 2;
        return shape
    }()
    
    ///绘制手势pan
    private var panGesture: UIPanGestureRecognizer!

    ///所有的绘制点
    ///Int:表示在哪个倍率下
    ///[[CGPoint]]:表示连续的标注,第一个点代表起始点,其他点代表绘制的点
    private var allPoints: [String: [[[CGFloat]]]] = [:]
    ///正在绘制过程中的点
    private var drawingPoint: [[CGFloat]] = []
    
    private var drawView: XCustomView = XCustomView()
    
    //大图的像素 可根据网络加载回来的图片计算出来，然后赋值
    var imagePixel: CGSize = .zero {
        didSet {
            if tiledLayer != nil {
                scrollView.contentSize = imagePixel
                imageView.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                drawView.frame = imageView.bounds
                tiledLayer?.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                tiledLayerDelegate.imageNamePrefix = imageNamePrefix
                tiledLayerDelegate.imageUrls = currentRateImageURL
                tiledLayer?.setNeedsDisplay()
                shapelayer.frame = CGRect(x: 0, y: 0, width: imagePixel.width, height: imagePixel.height)
                
            }
        }
    }
    
    //图片名称的前缀 本地图片
    var imageNamePrefix: String? {
        didSet {
            tiledLayerDelegate.imageNamePrefix = imageNamePrefix
            tiledLayerDelegate.imageUrls = currentRateImageURL
            if tiledLayer != nil {
                tiledLayer?.setNeedsDisplay()
            }
        }
    }
    
    ///当前倍率下图片的url
    var currentRateImageURL: [String:String]? {
        get {
            multipleSwitchView.multiples[currentIndex].imageUrl
        }
    }
    
    ///倍率切换view
    lazy var multipleSwitchView: XMultipleSwitchView = XMultipleSwitchView()
    
    //网络图片
    var fileManager: XFileManager = XFileManager(["export_urls-5"], type: "csv")
    
    lazy var coordinateManage: XCoordinateMagage = XCoordinateMagage()
   
    ///X方向的缩放比例
    var rateX: CGFloat = CGFloat()
    ///y方向的缩放比例
    var rateY: CGFloat = CGFloat()
    
    ///scrollView当前的偏距
    private var currentOffset: CGPoint = .zero
    
    var imageViewTest = UIImageView()
    
    
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
        
        imageViewTest.frame = bounds
        
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
        
        cancelBtn.frame = CGRect(x: 0, y: (bounds.size.height - 50) * 0.5 + 100, width: 50, height: 50)
        cancelBtn.layer.cornerRadius = 25
        cancelBtn.layer.masksToBounds = true
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
        tiledLayerDelegate.tiledLayer = tiledLayer
        imageViewTest.backgroundColor = UIColor.orange
        tiledLayerDelegate.imageView = imageViewTest
        
        imageView.frame = tiledLayer.bounds
        scrollView.contentSize = tiledLayer.frame.size
        
        tiledLayer.setNeedsDisplay()
        
        //倍率切换
        multipleSwitchView.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        
        multipleSwitchView.multiples = fileManager.imageModels
        
//        multipleSwitchView.multiples = [
//
//            Rateinfo(imagePrefix: "5", rateName: "1x",widthNumber: 6, heightNumber: 6),
//            Rateinfo(imagePrefix: "4", rateName: "5x",widthNumber: 11, heightNumber: 12),
////            Rateinfo(imagePrefix: "3", rateName: "10x",widthNumber: 22, heightNumber: 24),
////            Rateinfo(imagePrefix: "2", rateName: "20x",widthNumber: 44, heightNumber: 47),
////            Rateinfo(imagePrefix: "1", rateName: "40x",widthNumber: 88, heightNumber: 94),
////            Rateinfo(imagePrefix: "1", rateName: "40x",widthNumber: 86, heightNumber: 92)
//        ]
        
        multipleSwitchView.buttonClickBlock = { (index, rateName) in
            
           
            self.scrollView.setZoomScale(1, animated: false)
            self.currentIndex = index
            self.drawView.currentIndex = index
            
        }
        
        addSubview(multipleSwitchView)
        drawView.multipleSwitchView = multipleSwitchView
        imageView.addSubview(drawView)
        drawView.backgroundColor = UIColor.clear
        
        //绘制按钮
        enterDrawBtn = UIButton(type: .custom)
        enterDrawBtn.setTitle("绘制", for: .normal)
        enterDrawBtn.setTitle("确定", for: .selected)
        enterDrawBtn.setTitleColor(.white, for: .normal)
        enterDrawBtn.setTitleColor(.white, for: .selected)
        enterDrawBtn.backgroundColor = .lightGray
        enterDrawBtn.addTarget(self, action: #selector(drawAction(_:)), for: .touchUpInside)
        addSubview(enterDrawBtn)
        
        //绘制按钮
        cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("撤销", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.setTitleColor(.white, for: .selected)
        cancelBtn.backgroundColor = .lightGray
        cancelBtn.addTarget(self, action: #selector(cancelDrawAction(_:)), for: .touchUpInside)
        addSubview(cancelBtn)
        
        
        //添加pan手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture = pan
        
        //获取标注数据
        if let dic = NSMutableDictionary(contentsOfFile: filePath()) {
            allPoints = dic as! [String : [[[CGFloat]]]]
        }
        
        drawView.allPoints = allPoints
        drawView.setNeedsDisplay()
        
        
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
            drawView.addGestureRecognizer(panGesture)
        } else {
            drawView.removeGestureRecognizer(panGesture)
            scrollView.isScrollEnabled = true
            
            let dic = NSDictionary(dictionary: allPoints)//allPoints as! NSMutableDictionary
           let result = dic.write(toFile: filePath(), atomically: true)
            if !result {
                print("保存失败")
            }
        }
    }
    
    func filePath() -> String {
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let filePath = docPath.appendingPathComponent("data.plist")
        
        return filePath
    }
    
    @objc func panGestureAction(_ pan: UIPanGestureRecognizer) {
        let startPoint = pan.location(in: drawView)
        var points = allPoints["\(currentIndex)"]
        if points == nil {
            points = [[]]
        }
        switch pan.state {
        case .began:
            let value = [startPoint.x,startPoint.y]
            drawingPoint.append(value)
            break
        case .changed:
            let movePoint = pan.location(in: drawView)
            let value = [movePoint.x,movePoint.y]
            drawingPoint.append(value)
            if points?.first?.count == 0 {
                points?.remove(at: 0)
            }
            points?.append(drawingPoint)
            
            allPoints["\(currentIndex)"] = points
            drawView.allPoints = allPoints
            drawView.setNeedsDisplay()
            break
        case .ended:
            
            drawingPoint.removeAll()
            break
        case .cancelled:
            
            drawingPoint.removeAll()
            break
            
        default: break
            
        }
    }
    
    
    
    @objc func cancelDrawAction(_ sender: UIButton) {
        
        if scrollView.isScrollEnabled {
            return
        }
        
        var tempAllPoint: [String: [[[CGFloat]]]] = [:]
        var tempValue:[[[CGFloat]]] = []
        for (key, var value) in allPoints {//遍历字典
            print(value.count)
            if key == "\(currentIndex)" {//撤销当前倍率下的绘制
                tempAllPoint = allPoints
                if value.count > 0 {
                    value.removeLast()
                    tempValue = value
                    tempAllPoint[key] = tempValue
                    drawView.allPoints = tempAllPoint
                    drawView.setNeedsDisplay()
                    allPoints = tempAllPoint
                }
                break
            }

        }
    }
    
}
