// NetworkReachability
// Reachability.swift
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
import SystemConfiguration

/// A value type representing network reachability
@available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
public struct Reachability: Equatable, Hashable, Sendable, CustomStringConvertible {

    /// A reachability that cannot be determined
    public static let unknown: Reachability = .init(flags: nil)

    /// An enumeration representing the various connection status options of a ``Reachability``
    public enum Status: Equatable, Hashable, Sendable, CustomStringConvertible {

        // MARK: - Cases

        /// The reachability is unknown
        case unknown

        /// The network is unavailable
        case unavailable

        /// The network is available via a cellular wwan connection
        case wwan

        /// The network is available via a local wlan connection
        case wlan

        // MARK: - API

        /// Whether or not the status is reachable
        public var isReachable: Bool {
            switch self {
            case .wlan, .wwan:
                return true
            case .unavailable, .unknown:
                return false
            }
        }

        // MARK: - CustomStringConvertible

        public var description: String {
            switch self {
            case .unknown:
                return "Unknown Reachability Status"
            case .unavailable:
                return "Network Offline"
            case .wwan:
                return "Cellular Network Online"
            case .wlan:
                return "Local Network Online"
            }
        }
    }

    /// The `SCNetworkReachabilityFlag` that this reachability is based on
    public let flags: SCNetworkReachabilityFlags?

    /// The connection status of the reachability
    public var status: Status {
        flags?.status ?? .unknown
    }

    // MARK: - Equatable

    public static func == (lhs: Reachability, rhs: Reachability) -> Bool {
        lhs.flags == rhs.flags
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(flags?.copyDescription ?? "")
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        (flags?.copyDescription ?? "No Flags") + " | " + status.description
    }

    // MARK: - Private

    init(flags: SCNetworkReachabilityFlags?) {
        self.flags = flags
    }

}
