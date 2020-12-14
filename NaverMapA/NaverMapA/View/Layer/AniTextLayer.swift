//
//  AniTextLayer.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/12.
//

import UIKit

class AniTextLayer: CATextLayer {
    
    var characterLayer: [CATextLayer] = []
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, text: String, charFont: UIFont) {
        self.init()
        self.frame = frame

        let charFont = charFont
        let charWidths = text.map { c in
            String(c).widthOfString(usingFont: charFont)
        }
        let diffX = (frame.width - charWidths.reduce(0.0, +)) / 2
        
        for i in 0..<text.count {
            let catlayer = CATextLayer()
            let str = String(text[i])
            let charWidth = str.widthOfString(usingFont: charFont)
            let charHeight = str.heightOfString(usingFont: charFont)
            let charY = (frame.height - charHeight) / 2
            let charX = diffX + charWidths[0..<i].reduce(0, +)
            catlayer.frame = CGRect(x: charX, y: charY, width: charWidth, height: charHeight)
            catlayer.string = String(text[i])
            catlayer.contentsScale = UIScreen.main.scale
            catlayer.font = charFont
            catlayer.fontSize = 17
            catlayer.alignmentMode = .center
            catlayer.foregroundColor = UIColor.white.cgColor
            addSublayer(catlayer)
            characterLayer.append(catlayer)
        }
    }
    func cancelAnimation() {
        characterLayer.forEach {
            $0.removeAllAnimations()
        }
    }
    
    func animating(delay: Double) {
        let animations = (0..<characterLayer.count).map { seconds -> CAAnimation in
            let animation = CAKeyframeAnimation()
            animation.keyPath = AnimationKeyPath.transform.rawValue
            animation.valueFunction = CAValueFunction(name: .translateY)
            animation.keyTimes = [0, 0.2, 0.4, 1]
            animation.values = [0, -10, 0, 0]
            animation.duration = 1
            animation.repeatCount = 1000
            animation.beginTime = CACurrentMediaTime() + 0.05 * Double(seconds) + delay
            return animation
        }
        zip(characterLayer, animations).forEach {
            $0.0.add($0.1, forKey: "")
        }
    }
    
    func animating1(delay: Double) {
        let animations = (0..<characterLayer.count).map { i -> CAAnimation in
            let start = characterLayer[i].frame.origin
            let end = characterLayer[characterLayer.count / 2].frame.origin
            let bpath = makeParabolaPath(start: start, end: end)
            let animation = CAKeyframeAnimation.position(path: bpath, duration: 0.4, repeatCount: 1)
            return animation
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            zip(self.characterLayer, animations).forEach {
                $0.0.add($0.1, forKey: "")
            }
        })
    }
    
    func makeParabolaPath(start: CGPoint, end: CGPoint) -> UIBezierPath {
        let bpath = UIBezierPath()
        let centerX = Double((start.x + end.x) / 2)
        let centerY = Double((start.y + end.y) / 2)
        let newEnd = CGPoint(x: Double(end.x) - centerX, y: Double(end.y) - centerY)
        var direction: Double = -1
        switch (start.x - end.x, start.y - end.y) {
        case let (x, y) where x > 0 && y >= 0:
            direction = 1
        case let (x, y) where x >= 0 && y < 0:
            direction = 1
        case let (x, y) where x < 0 && y <= 0:
            direction = -1
        default:
            direction = -1

        }
        let sinus = sin(90.0 * Double.pi * direction / 180)
        let cosinus = cos(90 * Double.pi * direction / 180)
        let rotatedX = cosinus * Double(newEnd.x) - sinus * Double(newEnd.y)
        let rotatedY = sinus * Double(newEnd.x) + cosinus * Double(newEnd.y)
        let controlPoint = CGPoint(x: rotatedX + centerX, y: rotatedY + centerY)
        bpath.move(to: start)
        bpath.addQuadCurve(to: end, controlPoint: controlPoint)
        
        return bpath
    }

}
