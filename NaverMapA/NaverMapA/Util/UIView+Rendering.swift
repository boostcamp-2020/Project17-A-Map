//
//  UIView+Rendering.swift
//  NaverMapA
//
//  Created by 박태희 on 2020/12/08.
//

import UIKit

extension UIView {
    func getImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
