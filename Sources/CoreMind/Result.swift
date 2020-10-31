//
// Copyright (c) topmind GmbH and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

/// Conform String to Error in order to use it for simpler error throwing
extension String: Error { }

/// The Result type either represents a success - which has an associated value
/// representing the successful result - or a falure - whith an associated error.
/// See http://alisoftware.github.io/swift/async/error/2016/02/06/async-errors/
///
/// - success: represents the successful result
/// - failure: represents a failure with an associated error
// @available(*, deprecated, message: "Please use `Swift.Result`")
public typealias Result<T> = Swift.Result<T, Error>

// Mark: - Non throwing values
extension Swift.Result {
    /// Unwraps a Result without throwing
    ///
    /// - Returns: nil in case of an error, the value otherwise
    public var value: Success? {
        guard case .success(let value) = self else {
            return nil
        }
        return value
    }

    /// Returns the error in case of failure, nil otherwise
    public var error: Failure? {
        guard case .failure(let error) = self else {
            return nil
        }
        return error
    }

    /// Unwraps a Result
    ///
    /// - throws: a .failure error
    /// usefull for result creation/transformation
    /// Result { try result.resolve() }
    ///
    /// - returns: the value if it's a .Success or throw the error if it's a .Failure
    public func resolve() throws -> Success {
        switch self {

        case .success(let value):
            return value

        case .failure(let error):
            throw error
            
        }
    }
    
    // MARK: - Double Null
    
    public init?(_ valueOrNil: Success?, _ errorOrNil: Failure?) {
        if let error = errorOrNil {
            self = .failure(error)
            
            if let value = valueOrNil {
                logError("Result's value\(value) and error(\(error)) is set")
            }
        } else if let value = valueOrNil {
            self = .success(value)
        } else {
            return nil
        }
    }
    
    public func mapThrowing<U>(_ f: (Success) throws -> U) -> Swift.Result<U, Error> {
        switch self {
        case .success(let result):
            do {
                let u = try f(result)
                return .success(u)
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
