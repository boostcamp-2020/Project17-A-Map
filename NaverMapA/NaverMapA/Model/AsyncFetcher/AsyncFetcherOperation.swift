//
//  AsyncFetcherOperation.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/10.
//

import Foundation

final class AsyncFetcherOperation: Operation {
    
    // MARK: Properties

    let viewModel: DetailViewModel
    // MARK: Initialization

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
    }

    // MARK: Operation overrides

    override func main() {
        Thread.sleep(until: Date().addingTimeInterval(1))
        guard !isCancelled else { return }
    }
    
}
