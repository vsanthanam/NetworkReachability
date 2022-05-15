// NetworkReachabiliy
// SCNetworkReachabilityFlags+Reachability.swift
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

extension SCNetworkReachabilityFlags {

    /// The `Reachability` represented by the flags
    var reachability: Reachability {
        guard isReachableFlagSet else { return .unavailable }
        var connection = Reachability.unavailable

        if !isConnectionRequiredFlagSet {
            connection = .wlan
        }

        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wlan
            }
        }

        if isOnWWANFlagSet {
            connection = .wwan
        }

        return connection
    }

    var isOnWWANFlagSet: Bool {
        #if os(iOS)
            contains(.isWWAN)
        #else
            false
        #endif
    }

    var isReachableFlagSet: Bool {
        contains(.reachable)
    }

    var isConnectionRequiredFlagSet: Bool {
        contains(.connectionRequired)
    }

    var isInterventionRequiredFlagSet: Bool {
        contains(.interventionRequired)
    }

    var isConnectionOnTrafficFlagSet: Bool {
        contains(.connectionOnTraffic)
    }

    var isConnectionOnDemandFlagSet: Bool {
        contains(.connectionOnDemand)
    }

    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        !intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }

    var isTransientConnectionFlagSet: Bool {
        contains(.transientConnection)
    }

    var isLocalAddressFlagSet: Bool {
        contains(.isLocalAddress)
    }

    var isDirectFlagSet: Bool {
        contains(.isDirect)
    }

    var isConnectionRequiredAndTransientFlagSet: Bool {
        intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }

    var copyDescription: String {
        let W = isOnWWANFlagSet ? "W" : "-"
        let R = isReachableFlagSet ? "R" : "-"
        let c = isConnectionRequiredFlagSet ? "c" : "-"
        let t = isTransientConnectionFlagSet ? "t" : "-"
        let i = isInterventionRequiredFlagSet ? "i" : "-"
        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = isConnectionOnDemandFlagSet ? "D" : "-"
        let l = isLocalAddressFlagSet ? "l" : "-"
        let d = isDirectFlagSet ? "d" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}
