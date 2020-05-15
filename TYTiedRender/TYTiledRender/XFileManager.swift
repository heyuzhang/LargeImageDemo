//
//  XFileManager.swift
//  TYTiedRender
//
//  Created by hulianxin1 on 2020/5/15.
//  Copyright © 2020 DoMobile21. All rights reserved.
//

import UIKit

class XFileManager: NSObject {
    
    
    override init() {
        super.init()
    }
    
    ///Rateinfo:该倍率下图片的信息
    public var imageModels: [Rateinfo] = []
    
    
    /// 初始化
    /// - Parameters:
    ///   - names: 各个倍率对应的文件名数组
    ///   - type: 文件的类型
    init(_ names: [String], type: String?) {
        super.init()
        
        resolveFileData(names, type: type)
        
    }
    
    private func resolveFileData(_ fileNames: [String], type: String?) {
        for fileName in fileNames {
            if let filePath = filePath(fileName, type: type),
                let fileData = loadFileData(filePath),
                let imageModels = resolveData(fileData, fileName:fileName) {
                self.imageModels.append(imageModels)
                print(self.imageModels)
            }
        }
    }
    
}


extension XFileManager {
    
    private func filePath(_ fileName: String?, type: String?) -> String? {
        
        let file = Bundle.main.path(forResource: fileName, ofType: type);
        return file
        
    }
    
    private func loadFileData(_ filePath: String) -> String? {
        
        let fileData = try? NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
        print(fileData ?? "暂无数据")
        return fileData
    }
    
    private func resolveData(_ data: String, fileName: String) -> Rateinfo? {
        
        var imageNames: [String] = []
        var imagePrefix: String? = nil
        var imageUrl: [String:String] = [:]
        let dataArray = data.components(separatedBy: "\n")
        
        for (index, value) in dataArray.enumerated() {
            
            if index != 0 {//不需要表头
                let imageDataArray = value.components(separatedBy: ",")
                if imageDataArray.count == 2 { //两个:名称+url
                    let imageNameStr = imageDataArray.first ?? ""
                    
                    let imgUrl = imageDataArray[1]
                    
                    //NSString
                    let name = NSString(string: imageNameStr)
                    
                    //去掉%2F
                    let nameStr = name.replacingPercentEscapes(using: String.Encoding.utf8.rawValue)
                    if nameStr != nil {
                       
                        let imageNamePath = NSString(string: nameStr!) //images/5_0_0.tif
                        let imageNameType = imageNamePath.lastPathComponent //5_0_0.tif
                        let iamgeName = (imageNameType as NSString).deletingPathExtension
                       
                        imageUrl[iamgeName] = imgUrl

                        //图片前缀
                        let prefix = iamgeName[iamgeName.startIndex]
                       
                        imageNames.append(iamgeName)
                        if imagePrefix == nil {
                            imagePrefix = "\(prefix)"
                        }
                    }
                }
            }
        }
        
        let sortedImageNames = imageNames.sorted()
        let lastName = sortedImageNames[sortedImageNames.count - 1]
        let lastNameArray = lastName.components(separatedBy: "_")
        
        let rateinfo = Rateinfo(imagePrefix: imagePrefix ?? "", rateName: fileName, widthNumber: Int(lastNameArray[1]) ?? 0, heightNumber: Int(lastNameArray[2]) ?? 0, imageUrl: imageUrl)
        
        return rateinfo
    }
}
