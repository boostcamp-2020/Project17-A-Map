//
//  Unit.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/09.
//

import Foundation

@propertyWrapper
struct Unit {
    
    private var value: Double
    private var threshold: Double
    var projectedValue = false
    var wrappedValue: Double {
        get { value }
        set {
            if abs(value - newValue) > threshold {
                value = newValue
                projectedValue = true
            } else {
                projectedValue = false
            }
        }
    }
 
    init() {
        value = 0.0
        threshold = 0.1
    }
    
    init(wrappedValue: Double) {
        value = wrappedValue
        threshold = 0.1
    }
    
    init(wrappedValue: Double, threshold: Double) {
        value = wrappedValue
        self.threshold = threshold
    }
}
