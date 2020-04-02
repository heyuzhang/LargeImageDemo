//
//  XMultipleSwitchViewAttributes.swift
//  TYTiedRender
//
//  Created by hulianxin1 on 2020/4/2.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit

protocol MultipleSwitchViewAttributesProtocol {
 
    ///按钮普通状态下背景颜色 默认值是 UIColor.gray
    var butttonNormalBgColor: UIColor {set get}
    
    ///按钮选中背景颜色 默认值是 UIColor.white
    var butttonSelectedBgColor: UIColor {set get}
    
    ///按钮普通状态文字颜色 默认值是 UIColor.back
    var butttonNormalTextColor: UIColor {set get}
    
    ///按钮选中文字颜色 默认值是 UIColor.back
    var butttonSelectedTextColor: UIColor {set get}
    
    ///按钮文字Font 默认值: UIFont.systemFont(ofSize: 16)
    var butttonTextFont: UIFont {set get}
    
    ///按钮之间的间距 默认: 20
    var buttonsMarge: CGFloat {set get}
    
    ///按钮的大小
    var buttonSize: CGSize {set get}
    
    
}

struct XMultipleSwitchViewAttributes: MultipleSwitchViewAttributesProtocol {
    var butttonNormalBgColor: UIColor = .gray
    
    var butttonSelectedBgColor: UIColor = .white
    
    var butttonNormalTextColor: UIColor = .black
    
    var butttonSelectedTextColor: UIColor = .black
    
    var butttonTextFont: UIFont = UIFont.systemFont(ofSize: 16)
    
    var buttonsMarge: CGFloat = CGFloat(20.0)
    
    var buttonSize: CGSize = CGSize(width: 40, height: 40)
}
