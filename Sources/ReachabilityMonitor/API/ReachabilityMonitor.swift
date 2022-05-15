// ReachabilityMonitor
// ReachabilityMonitor.swift
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

#if canImport(Combine)
    import Combine
#endif

/// A class used to observe network reachability.
/// Create one of these objects and keep it in memory
public final class ReachabilityMonitor {

    // MARK: - Initializers

    /// Create a `ReachabilityMonitor`
    public convenience init() throws {
        try self.init(updateHandler: nil, delegate: nil)
    }

    /// Create a `ReachabilityMonitor`
    /// - Parameter updateHandler: The closure used to observe reachability updates
    public convenience init(updateHandler: @escaping UpdateHandler) throws {
        try self.init(updateHandler: updateHandler, delegate: nil)
    }

    /// Create a `ReachabilityMonitor`
    /// - Parameter delegate: The object used to observe reachability updates
    public convenience init(delegate: ReachabilityMonitorDelegate) throws {
        try self.init(updateHandler: nil, delegate: delegate)
    }

    // MARK: - API

    /// The closure type used to observe reachability updates
    public typealias UpdateHandler = (ReachabilityMonitor, Result<ReachabilityStatus, ReachabilityError>) -> Void

    /// The closure used to observe reachability updates
    public var updateHandler: UpdateHandler?

    /// The delegate object used to observe reachability updates
    public weak var delegate: ReachabilityMonitorDelegate?

    /// An `AsyncSequence` of reachability updates
    public var status: AsyncThrowingStream<ReachabilityStatus, Error>!

    /// The current reachability updates
    public var currentStatus: ReachabilityStatus {
        get throws {
            refreshFlags()
            return try flags.get()?.connection ?? .unavailable
        }
    }

    #if canImport(Combine)

        /// A `Publisher` of reachability updates
        public var statusPublisher: AnyPublisher<ReachabilityStatus, ReachabilityError> {
            subject
                .prepend(try? currentStatus)
                .compactMap { $0 }
                .removeDuplicates()
                .eraseToAnyPublisher()
        }

    #endif

    // MARK: - Private

    private init(updateHandler: UpdateHandler?,
                 delegate: ReachabilityMonitorDelegate?) throws {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
            throw ReachabilityError.failedToCreate(SCError())
        }
        self.reachability = reachability
        self.updateHandler = updateHandler
        setUp()
    }

    private var reachability: SCNetworkReachability
    private var continuation: AsyncThrowingStream<ReachabilityStatus, Error>.Continuation!

    #if canImport(Combine)
        private var subject = CurrentValueSubject<ReachabilityStatus?, ReachabilityError>(nil)
    #endif

    private var flags: Result<SCNetworkReachabilityFlags?, ReachabilityError> = .success(nil) {
        didSet {
            if flags != oldValue {
                do {
                    let flags = try flags.get()
                    succeed(with: flags)
                } catch {
                    fail(with: error as! ReachabilityError)
                }
            }
        }
    }

    private func setUp() {
        status = .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.continuation = continuation
        }

        let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
            guard let info = info else { return }
            let weakMonitor = Unmanaged<WeakReference<ReachabilityMonitor>>.fromOpaque(info).takeUnretainedValue()
            weakMonitor.obj?.refreshFlags()
        }

        let weakMonitor = weak(self)
        let opaqueMonitor = Unmanaged<WeakReference<ReachabilityMonitor>>.passUnretained(weakMonitor).toOpaque()

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: UnsafeMutableRawPointer(opaqueMonitor),
            retain: { info in
                let unmanaged = Unmanaged<WeakReference<ReachabilityMonitor>>.fromOpaque(info)
                _ = unmanaged.retain()
                return UnsafeRawPointer(unmanaged.toOpaque())
            },
            release: { info in
                let unmanaged = Unmanaged<WeakReference<ReachabilityMonitor>>.fromOpaque(info)
                unmanaged.release()
            },
            copyDescription: { (info: UnsafeRawPointer) -> Unmanaged<CFString> in
                let unmanagedMonitor = Unmanaged<WeakReference<ReachabilityMonitor>>.fromOpaque(info)
                let weakMonitor = unmanagedMonitor.takeUnretainedValue()
                let copyDescription = try? weakMonitor.obj?.flags.get()?.copyDescription ?? "none"
                return Unmanaged.passRetained(copyDescription! as CFString)
            }
        )

        if !SCNetworkReachabilitySetCallback(reachability, callback, &context) {
            flags = .failure(.failedToStartCallback(SCError()))
        }

        if !SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
            flags = .failure(.failedToSetRunLoop(SCError()))
        }

        refreshFlags()
    }

    private func refreshFlags() {
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachability, &flags) {
            self.flags = .success(flags)
        } else {
            self.flags = .failure(.failedToGetFlags(SCError()))
        }
    }

    private func succeed(with flags: SCNetworkReachabilityFlags?) {
        Task {
            await MainActor.run {
                let connection = flags.map(\.connection) ?? .unknown
                continuation.yield(connection)
                subject.send(connection)
                postNotification()
                delegate?.monitor(self, didUpdateStatus: connection)
                updateHandler?(self, .success(connection))
            }
        }
    }

    private func fail(with error: ReachabilityError) {
        Task {
            await MainActor.run {
                continuation.finish(throwing: error)
                subject.send(completion: .failure(error))
                postNotification()
                delegate?.monitor(self, didFailWithError: error)
                updateHandler?(self, .failure(error))
            }
        }
    }

    private func postNotification() {
        NotificationCenter.default.post(name: .reachabilityChanged, object: self)
    }
}
