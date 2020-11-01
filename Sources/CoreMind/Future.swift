//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

public enum ResultQueue {
    case any, main, specific(DispatchQueue)

    public func execute(block: @escaping () -> Void) {
        guard let queue = self.queue else {
            block()
            return
        }
        queue.async(execute: block)
    }

    fileprivate var queue: DispatchQueue? {
        switch self {
        case .any:
            return nil

        case .specific(let q):
            return q

        case .main:
            return DispatchQueue.main
        }
    }
}

/// Future class executing "compute" exactly once
/// The calculated result is cached for later access
public final class Future<T> {

    private var disposable: Any?
    private let resultQueue: ResultQueue
    private var data: Atomic<Data<T>> = Atomic(Data())

    public convenience init(resultQueue: ResultQueue = .any, value: T) {
        self.init(resultQueue: resultQueue, result: .success(value))
    }

    public convenience init(resultQueue: ResultQueue = .any, error: Error) {
        self.init(resultQueue: resultQueue, result: .failure(error))
    }

    public init(resultQueue: ResultQueue = .any, result: Swift.Result<T, Error>) {
        self.resultQueue = resultQueue
        notifyQueued(result)
    }

    public init(resultQueue: ResultQueue = .any, compute: (@escaping (Swift.Result<T, Error>) -> Void) -> Void) {
        self.resultQueue = resultQueue
        compute(notifyQueued)
    }

    public init(resultQueue: ResultQueue = .any, compute: (@escaping (Swift.Result<T, Error>) -> Void) -> Any?) {
        self.resultQueue = resultQueue
        disposable = compute(notifyQueued)
    }

    public static func join<T>(_ futures: [Future<T>], resultQueue: ResultQueue = .any) -> Future<[Swift.Result<T, Error>]> {
        return Future<[Swift.Result<T, Error>]>(resultQueue: resultQueue) {
            futureCompletion in

            let results = Atomic([Swift.Result<T, Error>]())
            let group = DispatchGroup()
            for f in futures {
                group.enter()
                f.onResult {
                    result in

                    results.mutate { $0.append(result) }
                    group.leave()
                }
            }

            group.notify(queue: resultQueue.queue ?? .main) {
                futureCompletion(.success(results.value))
            }
        }
    }

    public func onResult(resultQueue: ResultQueue, callback: @escaping (Swift.Result<T, Error>) -> Void) {
        onResult { result in
            resultQueue.execute {
                callback(result)
            }
        }
    }

    public func onResult(callback: @escaping (Swift.Result<T, Error>) -> Void) {

        guard let cached = data.value.cached else {
            // remember callback for later execution
            data.mutate {
                $0.queuedCallbacks.append(callback)
            }
            return
        }

        // use previously calculated value
        notify(value: cached, to: [callback])
    }

    /// flatMap
    public func then<U>(_ next: @escaping (T) -> Future<U>) -> Future<U> {
        return Future<U> {
            completion in

            self.onResult {
                result in

                switch result {
                case .success(let value):
                    next(value).onResult(callback: completion)

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    // map
    public func map<U>(_ transform: @escaping (T) -> U) -> Future<U> {
        return Future<U> {
            completion in
            onResult {
                completion($0.map(transform))
            }
        }
    }

    /// Intercept errors in a pipeline of futures
    public func catchError(_ handleError: @escaping (Error) -> Void) -> Future<T> {
        return Future<T> { promise in

            self.onResult { result in
                if case .failure(let error) = result {
                    handleError(error)
                }
                promise(result)
            }
        }
    }

    public func mapThrowing<U>(_ transform: @escaping (T) throws -> U) -> Future<U> {
        return Future<U> {
            completion in
            onResult {
                completion($0.mapThrowing(transform))
            }
        }
    }

    private func notifyQueued(_ value: Swift.Result<T, Error>) {
        assert(data.value.cached == nil, "Don't call notify twice")

        var callbacks: [(Swift.Result<T, Error>) -> Void] = []

        data.mutate {
            callbacks = $0.queuedCallbacks
            $0.cached = value
            $0.queuedCallbacks.removeAll()
        }

        notify(value: value, to: callbacks)
    }

    private func notify(value: Swift.Result<T, Error>, to callbacks: [(Swift.Result<T, Error>) -> Void]) {
        resultQueue.execute {
            callbacks.forEach { $0(value) }
        }
    }
}

extension Future {
    fileprivate final class Data<T> {
        var queuedCallbacks: [(Swift.Result<T, Error>) -> Void] = []
        var cached: Swift.Result<T, Error>?
    }
}
