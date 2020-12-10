//
//  Atomic.swift
//  NaverMapA
//
//  Created by 채훈기 on 2020/12/08.
//

import Foundation

@propertyWrapper
struct AtomicArray<Value> {
    
    private var values: [Value]
    private let queue = DispatchQueue(label: "atomicArray")

    var wrappedValue: [Value] {
        get { queue.sync { values } }
        set { queue.sync { values = newValue } }
    }
 
    init() {
        values = []
    }
}

@propertyWrapper
struct Atomic<Value> {
    
    private var values: Value
    private let queue = DispatchQueue(label: "atomicArray")

    var wrappedValue: Value {
        get { queue.sync { values } }
        set { queue.sync { values = newValue } }
    }
 
    init(value: Value) {
        self.values = value
    }
}
