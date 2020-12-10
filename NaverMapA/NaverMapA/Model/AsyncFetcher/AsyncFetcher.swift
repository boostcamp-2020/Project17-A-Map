//
//  AsyncFetcher.swift
//  NaverMapA
//
//  Created by 홍경표 on 2020/12/10.
//

import Foundation

final class AsyncFetcher {
    
    // MARK: Types

    private let serialAccessQueue = OperationQueue()

    private let fetchQueue = OperationQueue()

    private var completionHandlers = [UUID: [(DetailViewModel?) -> Void]]()

    private var cache = NSCache<NSUUID, DetailViewModel>()

    // MARK: Initialization

    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }

    // MARK: Object fetching

    func fetchAsync(_ viewModel: DetailViewModel, completion: ((DetailViewModel?) -> Void)? = nil) {
        // Use the serial queue while we access the fetch queue and completion handlers.
        serialAccessQueue.addOperation {
            // If a completion block has been provided, store it.
            if let completion = completion {
                let handlers = self.completionHandlers[viewModel.identifier, default: []]
                self.completionHandlers[viewModel.identifier] = handlers + [completion]
            }
            
            self.fetchData(for: viewModel)
        }
    }

    func fetchedData(for viewModel: DetailViewModel) -> DetailViewModel? {
        return cache.object(forKey: viewModel.identifier as NSUUID)
    }

    func cancelFetch(_ viewModel: DetailViewModel) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }

            self.operation(for: viewModel.identifier)?.cancel()
            self.completionHandlers[viewModel.identifier] = nil
        }
    }

    private func fetchData(for viewModel: DetailViewModel) {
        guard operation(for: viewModel.identifier) == nil else { return }
        if let data = fetchedData(for: viewModel) {
            invokeCompletionHandlers(for: viewModel.identifier, with: data)
        } else {
            let operation = AsyncFetcherOperation(viewModel: viewModel)
            operation.completionBlock = { [weak operation] in
                guard let viewModel = operation?.viewModel else { return }
                self.cache.setObject(viewModel, forKey: viewModel.identifier as NSUUID)
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: viewModel.identifier, with: viewModel)
                }
            }
            fetchQueue.addOperation(operation)
        }
    }
    
    private func operation(for identifier: UUID) -> AsyncFetcherOperation? {
        for case let fetchOperation as AsyncFetcherOperation in fetchQueue.operations
        where !fetchOperation.isCancelled && fetchOperation.viewModel.identifier == identifier {
            return fetchOperation
        }
        return nil
    }

    private func invokeCompletionHandlers(for identifier: UUID, with fetchedData: DetailViewModel) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil
        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
    
}
