//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/14/22.
//

import Foundation
import SystemConfiguration

extension SCNetworkReachabilityFlags {
    
    /// The `ReachabilityStatus` represented by the flags
    var connection: ReachabilityStatus {
        guard isReachableFlagSet else { return .unavailable }
        var connection = ReachabilityStatus.unavailable

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
