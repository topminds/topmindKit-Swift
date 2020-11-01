//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

@available(*, deprecated, message: "Please use `Combine`")
public final class Signal<T> {
	private var callbacks = [UUID: (Swift.Result<T, Error>) -> Void]()
	private var disposables = [Any]()

	public func subscribe(callback: @escaping (Swift.Result<T, Error>) -> Void) -> Disposable {
		let token = UUID()
		callbacks[token] = callback
		return Disposable {
			self.callbacks[token] = nil
		}
	}

	private func append(disposable: Any) {
		disposables.append(disposable)
	}

	private func send(_ result: Swift.Result<T, Error>) {
		callbacks.forEach {
			$0.value(result)
		}
	}

	public static func pipe() -> ((Swift.Result<T, Error>) -> Void, Signal<T>) {
		let signal = Signal<T>()
		let weakSend: (Swift.Result<T, Error>) -> Void = {
			[weak signal] in signal?.send($0)
		}
		return (weakSend, signal)
	}

	public func map<U>(_ f: @escaping (T) -> U) -> Signal<U> {
		let (sink, signal) = Signal<U>.pipe()
		let disposable = subscribe {
			sink($0.map(f))
		}
		signal.append(disposable: disposable)
		return signal
	}
}
