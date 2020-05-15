//
//  XMultipleSwitchView.swift
//  TYTiedRender
//

//  Created by zhangheyu on 2020/4/2.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit
///一个倍率需要的信息
struct Rateinfo {
    ///该倍率下图片的前缀
    var imagePrefix: String
    ///该倍率的名称 eg: 30x
    var rateName: String

    ///
    var widthNumber:Int
    var heightNumber:Int
    
    ///该倍率下的图片字典,一个名称对应一个图片url
    var imageUrl: [String:String]?
}

class XMultipleSwitchView: UIView {
    
    ///总共有多少个倍率
    var multiples:[Rateinfo] = [] {
        didSet {
            setupButtons()
        }
    }
    

    var buttonClickBlock:((Int, String)->())?
   
    var rateName: String = ""
    
    
    lazy var viewAttributes: XMultipleSwitchViewAttributes = XMultipleSwitchViewAttributes()
    

    ///倍率多的时候,可以滑动
    private lazy var scrollView = UIScrollView()
    
    ///点击的按钮数组
    private lazy var buttons: [UIButton] = []
    

    private var reClick = false
    private var currentIndex: Int = 0 {
        willSet {
            
            if currentIndex == newValue { //重复点击
                reClick = true
                return
            }
            reClick = false
            let button = buttons[currentIndex]
            button.isSelected = false
            button.backgroundColor = viewAttributes.butttonNormalBgColor
        }
        
        didSet {
            let button = buttons[currentIndex]
            button.isSelected = true
            button.backgroundColor = viewAttributes.butttonSelectedBgColor
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
        
    }
    
    convenience init(frame: CGRect, multiples: [Rateinfo]) {
        self.init(frame: frame)
        self.multiples = multiples
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
        
        //布局按钮
        for (index, button) in buttons.enumerated() {
            
            let x = (viewAttributes.buttonSize.width + viewAttributes.buttonsMarge) * CGFloat(index)
            let y = (scrollView.frame.size.height - viewAttributes.buttonSize.height) * 0.5
            button.frame = CGRect(x: x, y: y, width: viewAttributes.buttonSize.width, height: viewAttributes.buttonSize.height)
            button.drawCircle()
        }
        
        let contentW = viewAttributes.buttonSize.width * CGFloat(buttons.count) + viewAttributes.buttonsMarge * CGFloat((buttons.count - 1))
        
        scrollView.contentSize = CGSize(width: contentW, height: 0)
    }
    
    public func clickButton(with index: NSInteger) {
        
        
        buttonAction(buttons[index])
      }
}

//初始化UI
extension XMultipleSwitchView {
    
    private func setupUI() {
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
    }
    
    ///创建按钮
    private func setupButtons() {
        
        for (index,rateInfo) in self.multiples.enumerated() {
            
            let button = UIButton(type: .custom)
            
            button.setTitleColor(viewAttributes.butttonNormalTextColor, for: .normal)
            button.setTitleColor(viewAttributes.butttonSelectedTextColor, for: .selected)
            button.setTitle(rateInfo.rateName, for: .normal)
            button.titleLabel?.font = viewAttributes.butttonTextFont
            
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            button.tag = index
            
            if index == 0 {
                button.isSelected = true
                button.backgroundColor = viewAttributes.butttonSelectedBgColor

            } else {
                button.backgroundColor = viewAttributes.butttonNormalBgColor
                button.isSelected = false
            }
            
            buttons.append(button)
            scrollView.addSubview(button)
        }
    }
}

///action
extension XMultipleSwitchView {
    
    @objc private func buttonAction(_ sender: UIButton) {
        
        currentIndex = sender.tag

        if !reClick {
            if let block = buttonClickBlock {

                rateName = multiples[currentIndex].rateName
                block(currentIndex,rateName)
            }
        }
        
    }
}

extension UIView {
    func drawCircle() {
          let circlePath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.size.width)
          let maskLayer = CAShapeLayer()
          maskLayer.frame = self.bounds
          maskLayer.path = circlePath.cgPath
          self.layer.mask = maskLayer
      }
}
