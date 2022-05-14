//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/14/22.
//

import Foundation

public protocol ReachabilityMonitorDelegate: AnyObject {
    
    /// Sent to the delegate when the reachability status changes
    /// - Parameters:
    ///   - monitor: The `ReachabilityMonitor` who's status changed
    ///   - status: The new reachability status
    func monitor(_ monitor: ReachabilityMonitor, didUpdateStatus status: ReachabilityStatus)
    
    /// Sent to the delegate when the reachability monitor failed with an error
    /// - Parameters:
    ///   - monitor: The `ReachabilityMonitor` that failed
    ///   - error: The error that caused the monitor to fail
    func monitor(_ monitor: ReachabilityMonitor, didFailWithError error: Error)
}
