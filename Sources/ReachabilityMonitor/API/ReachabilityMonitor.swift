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

import Combine
import Foundation
import SystemConfiguration

/// A class used to observe network reachability.
///
/// Create an instance of this object and retain it in memory.
///
/// You can observe status changes in several ways:
/// - Synchronously, using the ``currentStatus`` property
/// - Using delegation via ``ReachabilityMonitorDelegate``
/// - Using structured concurrency via the ``status`` property
/// - Using a [Combine](https://developer.apple.com/documentation/combine), via the ``statusPublisher`` property
/// - Using a provided closure via the ``updateHandler-swift.property`` property
/// - Using `Notification` observers on `NotificationCenter.default`
public final class ReachabilityMonitor {

    // MARK: - Initializers

    /// Create a reachability monitor
    /// - Throws: An error of type ``ReachabilityError``
    public convenience init() throws {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
            throw ReachabilityError.failedToCreate(SCError())
        }
        self.init(reachability: reachability,
                  updateHandler: nil,
                  delegate: nil)
    }
    
    /// Create a reachability monitor for a specific host
    ///
    /// Use this initializer to monitor reachability updates for a specific host
    /// - Parameter host: The host who's reachability you wish to monitor
    /// - Throws: An error of type ``ReachabilityError``
    public convenience init(host: String) throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            throw ReachabilityError.failedToCreate(SCError())
        }
        self.init(reachability: reachability,
                  updateHandler: nil,
                  delegate: nil)
    }
    
    /// Create a reachability monitor with a closure used to respond to status changes
    ///
    /// Use this initializer to respond to status updates with a closure
    /// - Parameter updateHandler: The closure used to observe reachability updates
    public convenience init(updateHandler: @escaping UpdateHandler) throws {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
            throw ReachabilityError.failedToCreate(SCError())
        }
        self.init(reachability: reachability,
                  updateHandler: updateHandler,
                  delegate: nil)
    }
    
    /// Create a reachability monitor for a specific host, with a closure used to respond to status changes
    ///
    /// Use this initializer to respond to reachability updates for a specific host with a closure
    /// - Parameters:
    ///   - host: The host who's reachability you wish to monitor
    ///   - updateHandler: The closure used to observe reachability updates
    /// - Throws: An error of type ``ReachabilityError``
    public convenience init(host: String,
                            updateHandler: @escaping UpdateHandler) throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            throw ReachabilityError.failedToCreate(SCError())
        }
        self.init(reachability: reachability,
                  updateHandler: updateHandler,
                  delegate: nil)
    }

    /// Create a reachability monitor with a delegate object used to respond to status changes
    ///
    /// Use this initializer to respond to status updates with an instance of an object that conforms to ``ReachabilityMonitorDelegate``
    /// - Parameter delegate: The delegate object used to observe reachability updates
    /// - Throws: An error of type ``ReachabilityError``
    public convenience init(delegate: ReachabilityMonitorDelegate) throws {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
            throw ReachabilityError.failedToCreate(SCError())
        }
        self.init(reachability: reachability,
                  updateHandler: nil,
                  delegate: delegate)
    }
    
    /// Create a reachability monitor for a specific host, with a delegate object used to respond to status changes
    ///
    /// Use this initializer to respond to status updates with an instance of an object that conforms to ``ReachabilityMonitorDelegate`
    /// - Parameters:
    ///   - host: The host who's reachability you wish to monitor
    ///   - delegate: The delegate object used to observe reachability updates
    /// - Throws: An error of type ``ReachabilityError``
    public convenience init(host: String, delegate: ReachabilityMonitorDelegate) throws {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else {
            throw ReachabilityError.failedToCreate(SCError())
        }
        self.init(reachability: reachability,
                  updateHandler: nil,
                  delegate: delegate)
    }

    // MARK: - API

    /// The closure type used to observe reachability updates
    public typealias UpdateHandler = (ReachabilityMonitor, Result<ReachabilityStatus, ReachabilityError>) -> Void

    /// The closure used to observe reachability updates
    ///
    /// The handler is fed `Result` types and should be used to handle status changes as well as errors
    ///
    /// ```swift
    /// func setUpdateHandler(on monitor: ReachabilityMonitor) {
    ///     let updateHandler: ReachabilityMonitor.UpdateHandler = { (monitor, result) in
    ///         do {
    ///             let status = try result.get()
    ///             // Do something with `status`
    ///         } catch {
    ///             // Handle error
    ///         }
    ///     }
    ///     monitor.updateHandler = updateHandler
    /// }
    /// ```
    public var updateHandler: UpdateHandler?

    /// The delegate object used to observe reachability updates
    public weak var delegate: ReachabilityMonitorDelegate?

    /// An `AsyncSequence` of reachability updates
    ///
    /// Use [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over status updates
    ///
    /// ```swift
    /// do {
    ///     for try await status in monitor.status {
    ///         // Do something with `status`
    ///     }
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    public var status: AsyncThrowingStream<ReachabilityStatus, Error> {
        stream
    }

    /// The current reachability updates
    ///
    /// Use this property to retrieve the current reachability status in a synchronous context:
    ///
    /// ```swift
    /// do {
    ///     let status = try monitor.currentStatus
    ///     // Do something with `status`
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    /// - Throws: An error of type ``ReachabilityError``
    public var currentStatus: ReachabilityStatus {
        get throws {
            refreshFlags()
            return try flags.get()?.connection ?? .unavailable
        }
    }

    /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of reachability updates
    ///
    /// Use this property to observe status updates with [Combine](https://developer.apple.com/documentation/combine).
    ///
    /// ```swift
    /// let cancellable = monitor.statusPublisher
    ///     .map(\.isConnected)
    ///     .replaceError(with: false)
    ///     .sink { isConnected in
    ///         // Do something with `isConnected`
    ///     }
    /// ```
    public var statusPublisher: AnyPublisher<ReachabilityStatus, ReachabilityError> {
        statusSubject
            .prepend(try? currentStatus)
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private init(reachability: SCNetworkReachability,
                 updateHandler: UpdateHandler?,
                 delegate: ReachabilityMonitorDelegate?) {
        self.reachability = reachability
        self.updateHandler = updateHandler
        setUp()
    }

    private var reachability: SCNetworkReachability
    private var stream: AsyncThrowingStream<ReachabilityStatus, Error>!
    private var streamContinuation: AsyncThrowingStream<ReachabilityStatus, Error>.Continuation!
    private var statusSubject = CurrentValueSubject<ReachabilityStatus?, ReachabilityError>(nil)

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
        stream = .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.streamContinuation = continuation
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
        } else if !SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
            flags = .failure(.failedToSetRunLoop(SCError()))
        } else {
            refreshFlags()
        }        
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
        let connection = flags.map(\.connection) ?? .unknown
        streamContinuation.yield(connection)
        statusSubject.send(connection)
        Task {
            await MainActor.run {
                
                postNotification()
                delegate?.monitor(self, didUpdateStatus: connection)
                updateHandler?(self, .success(connection))
            }
        }
    }

    private func fail(with error: ReachabilityError) {
        streamContinuation.finish(throwing: error)
        statusSubject.send(completion: .failure(error))
        Task {
            await MainActor.run {
                postNotification()
                delegate?.monitor(self, didFailWithError: error)
                updateHandler?(self, .failure(error))
            }
        }
    }
    
    private func complete() {
        streamContinuation.finish(throwing: nil)
        statusSubject.send(completion: .finished)
    }

    private func postNotification() {
        NotificationCenter.default.post(name: .reachabilityStatusChanged, object: self)
    }
    
    // MARK: - Deinit
    
    deinit {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        complete()
    }
}
