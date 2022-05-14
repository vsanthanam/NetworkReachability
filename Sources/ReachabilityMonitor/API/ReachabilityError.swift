//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/14/22.
//

import Foundation

/// Errors that could cause a `ReachabiltiyMonitor` to fail
public enum ReachabilityError: LocalizedError, Equatable, Hashable, Sendable {
    
    /// An error indicating the SystemConfiguration reachability monitor could not be initialized
    case failedToCreate(Int32)
    
    /// An error indicating the reachability callback could not be configured
    case failedToStartCallback(Int32)
    
    /// An error indicating the rachability observation could not be scheduled
    case failedToSetRunLoop(Int32)
    
    /// An error indicating the reachability status couldn't be obtained from the system
    case failedToGetFlags(Int32)
}
