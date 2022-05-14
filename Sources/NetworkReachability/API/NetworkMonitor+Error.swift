// NetworkReachabiliy
// NetworkMonitor+Error.swift
//
// MIT License
//
// Copyright (c) 2021 Varun Santhanam
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
//
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public extension NetworkMonitor {

    /// Errors that could cause a ``NetworkMonitor`` to fail
    enum Error: LocalizedError, Equatable, Hashable, Sendable {

        // MARK: - Cases

        /// An error indicating the SystemConfiguration reachability monitor could not be initialized
        case failedToCreate(Int32)

        /// An error indicating the reachability callback could not be configured
        case failedToStartCallback(Int32)

        /// An error indicating the rachability observation could not be scheduled
        case failedToSetRunLoop(Int32)

        /// An error indicating the reachability couldn't be obtained from the system
        case failedToGetFlags(Int32)

        // MARK: - LocalizedError

        public var errorDescription: String? {
            switch self {
            case .failedToCreate:
                return "Couldn't create system reachability reference"
            case .failedToStartCallback:
                return "Couldn't start system observability callback"
            case .failedToSetRunLoop:
                return "Couldn't schedule system observability callback"
            case .failedToGetFlags:
                return "Couldn't get system reachability flags"
            }
        }

        public var failureReason: String? {
            switch self {
            case let .failedToCreate(code):
                return "SCError Code \(code)"
            case let .failedToStartCallback(code):
                return "SCError Code \(code)"
            case let .failedToSetRunLoop(code):
                return "SCError Code \(code)"
            case let .failedToGetFlags(code):
                return "SCError Code \(code)"
            }
        }
    }
}
