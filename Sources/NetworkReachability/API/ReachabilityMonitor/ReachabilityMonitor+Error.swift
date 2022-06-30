// NetworkReachability
// ReachabilityMonitor+Error.swift
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

@available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
public extension ReachabilityMonitor {

    /// Errors that could cause a ``ReachabilityMonitor`` to fail
    enum Error: LocalizedError, Equatable, Hashable, Sendable, CustomStringConvertible {

        // MARK: - Cases

        /// An error indicating the SystemConfiguration reachability monitor could not be initialized
        case failedToCreate(Int32)

        /// An error indicating the reachability callback could not be configured
        case failedToStartCallback(Int32)

        /// An error indicating the rachability observation could not be scheduled
        case failedToSetDispatchQueue(Int32)

        /// An error indicating the reachability couldn't be obtained from the system
        case failedToGetFlags(Int32)

        /// An unknown error
        case unknown

        // MARK: - API

        /// The SCError Code associated with the error
        public var code: Int32 {
            switch self {
            case let .failedToCreate(code):
                return code
            case let .failedToStartCallback(code):
                return code
            case let .failedToSetDispatchQueue(code):
                return code
            case let .failedToGetFlags(code):
                return code
            case .unknown:
                return -1
            }
        }

        // MARK: - LocalizedError

        /// A localized message describing what error occurred.
        public var errorDescription: String? {
            switch self {
            case .failedToCreate:
                return "Couldn't create system reachability reference"
            case .failedToStartCallback:
                return "Couldn't start system observability callback"
            case .failedToSetDispatchQueue:
                return "Couldn't schedule system observability callback"
            case .failedToGetFlags:
                return "Couldn't get system reachability flags"
            case .unknown:
                return "Unknown ReachabilityMonitor Failure"
            }
        }

        /// A localized message describing the reason for the failure.
        public var failureReason: String? {
            switch self {
            case let .failedToCreate(code):
                return "SCError Code \(code)"
            case let .failedToStartCallback(code):
                return "SCError Code \(code)"
            case let .failedToSetDispatchQueue(code):
                return "SCError Code \(code)"
            case let .failedToGetFlags(code):
                return "SCError Code \(code)"
            case .unknown:
                return "SCError Code Unknown"
            }
        }

        /// A localized message describing how one might recover from the failure.
        public var recoverySuggestion: String? {
            "There is not a lot you can do with this error at runtime, but it can help you with debugging"
        }

        /// A localized message providing "help" text if the user requests help.
        public var helpAnchor: String? {
            "If you think error was caused by a bug in the library, create an issue on GitHub and include this information."
        }

        // MARK: - CustomStringConvertible

        /// A textual representation of this instance.
        public var description: String {
            [errorDescription!, " ", failureReason!].joined()
        }
    }
}
