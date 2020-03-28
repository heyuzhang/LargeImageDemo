//
//  ImageView.swift
//  TYTiedRender
//
//  Created by hulianxin1 on 2020/3/19.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit

class XImageView: UIView,UIScrollViewDelegate {

    /** 缩略图路径 */
    private var  thumbnailImagePath: String?
    
    /** 缩略图大小的宽高比 */
    private var thumbnailImageWHRatio: CGFloat = 1.0
    
    /** 缩略图imageView */
    private lazy var thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /** 高清图 scrollView */
    private lazy var hdImageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.maximumZoomScale = 5
        scrollView.minimumZoomScale = 0.5
        return scrollView
    }()
    
    /** 高清图 imageView */
    private lazy var hdImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var coordinateManage = XCoordinateMagage()
    private var imageLoading = Loading()
    
    init() {
        super.init(frame: CGRect.zero)
        setUI()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        
    }
    
    private func setUI() {
        //单击放大
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        thumbnailView.isUserInteractionEnabled = true
        thumbnailView.addGestureRecognizer(tap)
        self.addSubview(thumbnailView)
        
        //双击缩小
        let zoomOutTap = UITapGestureRecognizer(target: self, action: #selector(zoomOutTapAction(tap:)))
        hdImageView.addGestureRecognizer(zoomOutTap)
        zoomOutTap.numberOfTapsRequired = 2
        
        hdImageScrollView.delegate = self
        hdImageScrollView.addSubview(hdImageView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        hdImageScrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        hdImageView.frame = hdImageScrollView.bounds

        //缩略图的frame 按比列大小显示
        var thumbnailImageViewW: CGFloat = 0.0
        var thumbnailImageViewH: CGFloat = 0.0
        if frame.size.width > frame.size.height {
            thumbnailImageViewH = frame.size.height
            thumbnailImageViewW = thumbnailImageViewH * thumbnailImageWHRatio
        } else {
            thumbnailImageViewW = frame.size.width
            thumbnailImageViewH = thumbnailImageViewW / thumbnailImageWHRatio
        }
        thumbnailView.frame = CGRect(x: 0, y: 0, width: thumbnailImageViewW, height: thumbnailImageViewH)
        thumbnailView.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //显示缩略图
    func showImage(_ imagePath: String?, in view: UIView, with frame: CGRect) {
        thumbnailImagePath = imagePath
        thumbnailView.image = UIImage.init(contentsOfFile: thumbnailImagePath ?? "")
        self.frame = frame
        view.addSubview(self)
        
        //设置缩略图的大小
        let url = URL(fileURLWithPath: thumbnailImagePath ?? "")
        if let imageSource = CGImageSourceCreateWithURL((url as CFURL), nil),
            let cgSourceImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
            hdImageView.image = UIImage(cgImage: cgSourceImage)
            let imageWidth: Int = cgSourceImage.width
            let imageHeight: Int = cgSourceImage.height
            thumbnailImageWHRatio = CGFloat(imageWidth) / CGFloat(imageHeight)
            layoutIfNeeded()
        }
        
       
    }
    
    @objc private func tapAction(tap: UITapGestureRecognizer) {
        
        let clickPoint = tap.location(in: thumbnailView)
        
        //添加scrollView到keyWindow上
        UIApplication.shared.keyWindow?.addSubview(hdImageScrollView)
        
        coordinateManage.coordinateCalculate(x: clickPoint.x, y: clickPoint.y, from: thumbnailView, to: hdImageScrollView, cutNumberX: 3, cutNumberY: 3)
        
        //设置hdImageViwe的frame
        let frame1 = CGRect(x: coordinateManage.newPoint.x, y: coordinateManage.newPoint.y, width: 0, height: 0)
        hdImageView.frame = frame1
        
        let imageIndex = coordinateManage.sliceImageIndex
        print("裁剪图索引:\(imageIndex)---点击位置:\(clickPoint) 缩略图frame:\(thumbnailView.bounds)")
        if let imageSource = imageLoading.loadingImage(numStr: imageIndex),
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
            hdImageView.image = UIImage(cgImage: cgImage)
        }
        
        let frame2 = CGRect(x: 0, y: 0, width: hdImageScrollView.frame.size.width, height: hdImageScrollView.frame.size.height)
        UIView.animate(withDuration: 0.3, animations: {
            self.hdImageView.frame = frame2

        }) { (comple) in
            self.thumbnailView.isUserInteractionEnabled = false
            self.coordinateManage.sliceImageIndex = ""
        }
        
    }
    
    @objc private func zoomOutTapAction(tap: UITapGestureRecognizer) {
        
        //设置hdImageViwe的frame
        let frame = CGRect(x: coordinateManage.newPoint.x, y: coordinateManage.newPoint.y, width: 0, height: 0)
       
        UIView.animate(withDuration: 0.3, animations: {
            
            self.hdImageView.frame = frame
            
        }) { (comple) in
            self.hdImageScrollView.removeFromSuperview()
            self.hdImageView.image = nil;
            self.thumbnailView.isUserInteractionEnabled = true
            self.hdImageScrollView.zoomScale = 1.0
            
        }
    }
}


extension XImageView {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return hdImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offSetX =  max((scrollView.bounds.size.width - scrollView.contentInset.left - scrollView.contentInset.right - scrollView.contentSize.width) * 0.5, 0)
        
        let offSetY = max((scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom - scrollView.contentSize.height) * 0.5, 0)
        
        hdImageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offSetX, y: scrollView.contentSize.height * 0.5 + offSetY)
    }
    
    
}


