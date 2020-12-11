//
//  Marker.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/10.
//

import UIKit

class VHCTextLayer: CATextLayer {
    
    var text: String?
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, text: String) {
        var fsize: CGFloat = 0.8
        switch text.count {
        case 1:
            fsize = 0.8
        case 2:
            fsize = 0.7
        case 3:
            fsize = 0.58
        case 4:
            fsize = 0.4
        default:
            fsize = 0.3
        }
        self.init()
        self.frame = frame
        self.text = text
        self.font = UIFont.systemFont(ofSize: frame.width * fsize)
        self.fontSize = CGFloat(frame.width * fsize)
        self.foregroundColor = UIColor.black.cgColor
        contentsScale = UIScreen.main.scale
        string = text
    }
    
    convenience init(frame: CGRect, text: String, fontSize: CGFloat) {
        self.init()
        self.frame = frame
        self.text = text
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.fontSize = fontSize
        self.foregroundColor = UIColor.black.cgColor
        contentsScale = UIScreen.main.scale
        string = text
    }
    
    override func draw(in context: CGContext) {
        let height = self.bounds.size.height
        let width = self.bounds.size.width
        let fontSize = self.fontSize
        let yDiff = (height-fontSize) / 2 - fontSize / 10
        let xDiff = (width - text!.widthOfString(usingFont: UIFont.systemFont(ofSize: fontSize))) / 2
        context.saveGState()
        context.translateBy(x: xDiff, y: yDiff)
        super.draw(in: context)
        context.restoreGState()
    }
}
