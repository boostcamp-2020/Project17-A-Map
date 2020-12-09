//
//  Animator.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/10.
//

import UIKit

protocol Animator {
    
    var queue: DispatchQueue { get }
    func animatingView() -> UIView
    func animateOneView(start: CGPoint, end: CGPoint)
    func animateAllView(before: [Cluster], after: [Cluster])
}
