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
    private var criteria : Double
    var projectedValue = false
    var wrappedValue: Double {
        get { value }
        set {
            if abs(value - newValue) > criteria {
                value = newValue
                projectedValue = true
            } else {
                projectedValue = false
            }
        }
    }
 
    init() {
        value = 0.0
        criteria = 0.1
    }
    
    init(wrappedValue: Double) {
        value = wrappedValue
        criteria = 0.1
    }
    
    init(wrappedValue: Double, criteria: Double) {
        value = wrappedValue
        self.criteria = criteria
    }
}


