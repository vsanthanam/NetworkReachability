//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/14/22.
//

import Foundation

/// The available network reachability status
public enum ReachabilityStatus: LocalizedError, Equatable, Hashable, Sendable {
    
    /// The current status is unknown
    case unknown
    
    /// The network is unavailable
    case unavailable
    
    /// The network is available via a cellular wwan connection
    case wwan
    
    /// The network is available via a local wlan connection
    case wlan
    
    // MARK: - LocalizedError
    
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown Status"
        case .unavailable:
            return "Network Offline"
        case .wwan:
            return "Cellular Network Online"
        case .wlan:
            return "Local Network Online"
        }
    }
}
