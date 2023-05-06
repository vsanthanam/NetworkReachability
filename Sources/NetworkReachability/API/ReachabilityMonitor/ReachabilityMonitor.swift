// NetworkReachability
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

#if !os(watchOS)
    import Darwin
    import Foundation
    import SystemConfiguration

    /// A class used to observe network reachability changes
    ///
    /// Create an instance of this object and retain it in memory.
    ///
    /// You can observe reachability changes in several ways:
    /// - Synchronously, using the ``currentReachability`` instance property or the ``reachability`` static property.
    /// - Using delegation via ``ReachabilityMonitorDelegate``.
    /// - Using [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) via the ``reachabilityUpdates`` properties
    /// - Using [Combine](https://developer.apple.com/documentation/combine), via the ``reachabilityPublisher`` property.
    /// - Using a provided closure via the ``updateHandler-swift.property`` property.
    /// - Using notification observers on [`NotificationCenter.default`](https://developer.apple.com/documentation/foundation/notificationcenter).
    ///
    /// ## Topics
    ///
    /// ### Initializers
    ///
    /// - ``init()``
    /// - ``init(host:)``
    /// - ``init(address:)``
    /// - ``init(updateHandler:)``
    /// - ``init(updateQueue:updateHandler:)``
    /// - ``init(host:updateHandler:)``
    /// - ``init(host:updateQueue:updateHandler:)``
    /// - ``init(address:updateHandler:)``
    /// - ``init(address:updateQueue:updateHandler:)``
    /// - ``init(delegate:)``
    /// - ``init(updateQueue:delegate:)``
    /// - ``init(host:delegate:)``
    /// - ``init(host:updateQueue:delegate:)``
    /// - ``init(address:delegate:)``
    /// - ``init(address:updateQueue:delegate:)``
    ///
    /// ### Closure Callbacks
    ///
    /// - ``updateHandler-swift.property``
    /// - ``UpdateHandler-swift.typealias``
    /// - ``Result``
    /// - ``Error``
    ///
    /// ### Swift Concurrency
    ///
    /// - ``reachability``
    /// - ``reachabilityUpdates``
    /// - ``reachabilityUpdates(forHost:)``
    /// - ``reachabilityUpdates(forAddress:)``
    ///
    /// ### Delegation
    ///
    /// - ``Delegate-swift.typealias``
    /// - ``delegate-swift.property``
    ///
    /// ### Notifications
    ///
    /// - ``reachabilityChangedNotificationName``
    ///
    /// ### Combine
    ///
    /// - ``reachabilityPublisher``
    /// - ``reachabilityPublisher(forHost:)``
    /// - ``reachabilityPublisher(forAddress:)``
    /// - ``Publisher``
    ///
    /// ### Synchronous
    ///
    /// - ``currentReachability``
    /// - ``reachability``
    /// - ``reachability(forHost:)``
    /// - ``reachability(forAddress:)``
    @available(macOS 10.13, iOS 11, tvOS 11, *)
    public final class ReachabilityMonitor {

        // MARK: - Initializers

        /// Create a reachability monitor
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init() throws {
            try self.init(ref: .general,
                          updateHandler: nil,
                          delegate: nil,
                          updateQueue: nil)
        }

        /// Create a reachablity monitor for a specific host
        ///
        /// - Parameter host: The host to monitor
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(host: String) throws {
            try self.init(ref: .forHost(host),
                          updateHandler: nil,
                          delegate: nil,
                          updateQueue: nil)
        }

        /// Create a reachablity monitor for a socket address
        ///
        /// - Parameter address: The socket address to monitor
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(address: sockaddr) throws {
            try self.init(ref: .forAddress(address),
                          updateHandler: nil,
                          delegate: nil,
                          updateQueue: nil)
        }

        /// Create a reachability monitor with a closure used to respond to reachability changes
        ///
        /// - Parameter updateHandler: The closure used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(updateHandler: @escaping UpdateHandler) throws {
            try self.init(ref: .general,
                          updateHandler: updateHandler,
                          delegate: nil,
                          updateQueue: nil)
        }

        /// Create a reachability monitor with a closure used to respond to reachability changes on a specific queue
        ///
        /// - Parameters:
        ///   - updateQueue: Dispatch queue used to invoke the update handler
        ///   - updateHandler: The closure used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error
        public convenience init(updateQueue: DispatchQueue,
                                updateHandler: @escaping UpdateHandler) throws {
            try self.init(ref: .general,
                          updateHandler: updateHandler,
                          delegate: nil,
                          updateQueue: updateQueue)
        }

        /// Create a reachability monitor for a specific host with a closure used to respond to reachability changes
        ///
        /// - Parameters:
        ///   - host: The host to monitor
        ///   - updateHandler: The closure used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(host: String,
                                updateHandler: @escaping UpdateHandler) throws {
            try self.init(ref: .forHost(host),
                          updateHandler: updateHandler,
                          delegate: nil,
                          updateQueue: nil)
        }

        /// Create a reachability monitor for a specific host with a closure used to respond to reachability changes on a specific queue
        ///
        /// - Parameters:
        ///   - host: The host to monitor
        ///   - updateQueue: Dispatch queue used to invoke the update handler
        ///   - updateHandler: The closure used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``

        public convenience init(host: String,
                                updateQueue: DispatchQueue,
                                updateHandler: @escaping UpdateHandler) throws {
            try self.init(ref: .forHost(host),
                          updateHandler: updateHandler,
                          delegate: nil,
                          updateQueue: updateQueue)
        }

        /// Create a reachability monitor for a specific socket address with a closure used to respond to reachability changes
        ///
        /// - Parameters:
        ///   - address: The socket address to monitor
        ///   - updateHandler: The closure used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(address: sockaddr,
                                updateHandler: @escaping UpdateHandler) throws {
            try self.init(ref: .forAddress(address),
                          updateHandler: updateHandler,
                          delegate: nil,
                          updateQueue: nil)
        }

        /// Create a reachability monitor for a specific socket address with a closure used to respond to reachability changes on a specific queue
        ///
        /// - Parameters:
        ///   - address: The socket address to monitor
        ///   - updateQueue: Dispatch queue used to invoke the update handler
        ///   - updateHandler: The closure used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(address: sockaddr,
                                updateQueue: DispatchQueue,
                                updateHandler: @escaping UpdateHandler) throws {
            try self.init(ref: .forAddress(address),
                          updateHandler: updateHandler,
                          delegate: nil,
                          updateQueue: updateQueue)
        }

        /// Create a reachability monitor with a delegate object used to respond to reachability changes
        ///
        /// - Parameter delegate: The delegate object used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(delegate: any Delegate) throws {
            try self.init(ref: .general,
                          updateHandler: nil,
                          delegate: delegate,
                          updateQueue: nil)
        }

        /// Create a reachability monitor with a delegate object used to respond to reachability changes
        ///
        /// - Parameters:
        ///   - updateQueue: Dispatch queue used to invoke the delegate callbacks
        ///   - delegate: The delegate object used to observe reachability updates
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(updateQueue: DispatchQueue,
                                delegate: any Delegate) throws {
            try self.init(ref: .general,
                          updateHandler: nil,
                          delegate: delegate,
                          updateQueue: updateQueue)
        }

        /// Create a reachability monitor for a specific host with a delegate object used to respond to reachability changes
        ///
        /// - Parameters:
        ///   - host: The host to monitor
        ///   - delegate: The delegate object used to observe reachability update
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(host: String,
                                delegate: any Delegate) throws {
            try self.init(ref: .forHost(host),
                          updateHandler: nil,
                          delegate: delegate,
                          updateQueue: nil)
        }

        /// Create a reachability monitor for a specific host with a delegate object used to respond to reachability changes
        ///
        /// - Parameters:
        ///   - host: The host to monitor
        ///   - updateQueue: Dispatch queue used to invoke the delegate callbacks
        ///   - delegate: The delegate object used to observe reachability update
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(host: String,
                                updateQueue: DispatchQueue,
                                delegate: any Delegate) throws {
            try self.init(ref: .forHost(host),
                          updateHandler: nil,
                          delegate: delegate,
                          updateQueue: updateQueue)
        }

        /// Create a reachability monitor for a specific socket address with a delegate object used to respond to reachability changes
        ///
        /// - Parameters:
        ///   - address: The socket address to monitor
        ///   - delegate: The delegate object used to observe reachability update
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(address: sockaddr,
                                delegate: any Delegate) throws {
            try self.init(ref: .forAddress(address),
                          updateHandler: nil,
                          delegate: delegate,
                          updateQueue: nil)
        }

        /// Create a reachability monitor for a specific socket address with a delegate object used to respond to reachability changes
        ///
        /// - Parameters:
        ///   - address: The socket address to monitor
        ///   - updateQueue: Dispatch queue used to invoke the delegate callbacks
        ///   - delegate: The delegate object used to observe reachability update
        ///
        /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
        ///
        /// - Throws: An error of type ``Error``
        public convenience init(address: sockaddr,
                                updateQueue: DispatchQueue,
                                delegate: any Delegate) throws {
            try self.init(ref: .forAddress(address),
                          updateHandler: nil,
                          delegate: delegate,
                          updateQueue: updateQueue)
        }

        // MARK: - API

        /// Specialized [`Result`](https://developer.apple.com/documentation/swift/result) delivered by a ``ReachabilityMonitor`` to it's ``updateHandler-swift.property``
        public typealias Result = Swift.Result<Reachability, Error>

        /// The closure type used to observe reachability updates
        public typealias UpdateHandler = (ReachabilityMonitor, ReachabilityMonitor.Result) -> Void

        /// A protocol used to observe network path changes from a ``ReachabilityMonitor``
        public typealias Delegate = ReachabilityMonitorDelegate

        /// The closure used to observe reachability updates
        ///
        /// The handler is fed `Result` types and should be used to handle reachability changes as well as errors
        ///
        /// ```swift
        /// func setUpdateHandler(on monitor: ReachabilityMonitor) {
        ///     let updateHandler: ReachabilityMonitor.UpdateHandler = { (monitor: ReachabilityMonitor, result: ReachabilityMonitor.Result) in
        ///         do {
        ///             let reachability = try result.get()
        ///             // Do something with `reachability`
        ///         } catch {
        ///             // Handle error
        ///         }
        ///     }
        ///     monitor.updateHandler = updateHandler
        /// }
        /// ```
        ///
        /// - Tip: The closure only recieves status changes that occured after it was assigned. To recieve every status update, including the reachability status at the time the monitor was initialized, pass in the closure on initialization of the monitor.
        ///
        /// - Note: Instances of ``ReachabilityMonitor`` will always invoke this closure on the ``updateQueue``
        public var updateHandler: UpdateHandler?

        /// The delegate object used to observe reachability updates
        ///
        /// See ``Delegate-swift.typealias`` for more information.
        ///
        /// - Tip: The delegate only recieves status changes that occured after it was assigned. To recieve every status update, including the reachability status at the time the monitor was initialized, pass in the delegate on initialization of the monitor.
        ///
        /// - Important: Instances of ``ReachabilityMonitor`` will perform delegate callbacks on the ``updateQueue``
        public weak var delegate: (any Delegate)?

        /// The dispatch queue used to send closure callbacks, delegate callbacks, and notifications.
        ///
        /// Set this value to `nil` to use the main thread.
        public var updateQueue: DispatchQueue?

        /// The current reachability status
        ///
        /// Use this property to retrieve the current reachability reachability in a synchronous context:
        ///
        /// ```swift
        /// do {
        ///     let reachability = try monitor.reachability
        ///     // Do something with `reachability`
        /// } catch {
        ///     // Handle error
        /// }
        /// ```
        ///
        /// - Throws: An error of type ``Error``
        public var currentReachability: Reachability {
            get throws {
                refreshFlags()
                return try Reachability(flags: flags.get())
            }
        }

        /// Retrieve the latest known reachability.
        ///
        /// ```swift
        /// func updateReachability() throws {
        ///     let reachability = try ReachabilityMonitor.reachability
        ///     // Do something with `reachability`
        /// }
        /// ```
        ///
        /// - Throws: An error of type ``Error``
        public static var reachability: Reachability {
            get throws {
                let monitor = try ReachabilityMonitor()
                return try monitor.currentReachability
            }
        }

        /// Retrieve the latest known reachability for a specific host
        ///
        /// ```
        /// func updateReachability() throws {
        ///     let reachability = try ReachabilityMonitor.reachability(forHost: "www.apple.com")
        ///     // Do something with `reachability`
        /// }
        /// ```
        ///
        /// - Parameter host: The host you want to monitor
        ///
        /// - Returns: The latest known reachability for the provided host
        ///
        /// - Throws: An error of type ``Error``
        public static func reachability(forHost host: String) throws -> Reachability {
            let monitor = try ReachabilityMonitor(host: host)
            return try monitor.currentReachability
        }

        /// Retrieve the latest known reachability for a specific socket address
        ///
        /// ```
        /// func updateReachability() throws {
        ///     let reachability = try ReachabilityMonitor.reachability(forAddress: myAddress)
        ///     // Do something with `reachability`
        /// }
        /// ```
        ///
        /// - Parameter host: The socket address you want to monitor
        ///
        /// - Returns: The latest known reachability for the provided host
        ///
        /// - Throws: An error of type ``Error``
        public static func reachability(forAddress address: sockaddr) throws -> Reachability {
            let monitor = try ReachabilityMonitor(address: address)
            return try monitor.currentReachability
        }

        // MARK: - Private

        static func withContinuation(_ ref: SCNetworkReachability,
                                     continuation: @escaping (Result) -> Void) -> ReachabilityMonitor {
            ReachabilityMonitor(ref: ref,
                                updateHandler: nil,
                                delegate: nil,
                                continuation: continuation,
                                updateQueue: nil)
        }

        private init(ref: SCNetworkReachability,
                     updateHandler: UpdateHandler?,
                     delegate: (any Delegate)?,
                     continuation: ((Result) -> Void)? = nil,
                     updateQueue: DispatchQueue?) {
            self.ref = ref
            self.updateHandler = updateHandler
            self.delegate = delegate
            self.continuation = continuation
            self.updateQueue = updateQueue
            setUp()
        }

        private var ref: SCNetworkReachability
        private var continuation: ((Result) -> Void)?

        private var flags: Swift.Result<SCNetworkReachabilityFlags?, Error> = .success(nil) {
            didSet {
                if flags != oldValue {
                    do {
                        let flags = try flags.get()
                        succeed(with: flags)
                    } catch {
                        if let error = error as? Error {
                            fail(with: error)
                        } else {
                            fail(with: .unknown)
                        }
                    }
                }
            }
        }

        private func setUp() {
            let callback: SCNetworkReachabilityCallBack = { (reachability, flags, info) in
                guard let info = info else { return }
                let weakMonitor = Unmanaged<WeakReference<ReachabilityMonitor>>.fromOpaque(info).takeUnretainedValue()
                weakMonitor.obj?.flags = .success(flags)
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
                copyDescription: { info in
                    let unmanagedMonitor = Unmanaged<WeakReference<ReachabilityMonitor>>.fromOpaque(info)
                    let weakMonitor = unmanagedMonitor.takeUnretainedValue()
                    let copyDescription = try? weakMonitor.obj?.flags.get()?.copyDescription ?? "none"
                    return Unmanaged.passRetained(copyDescription! as CFString)
                }
            )

            if !SCNetworkReachabilitySetCallback(ref, callback, &context) {
                flags = .failure(.failedToStartCallback(SCError()))
            } else if !SCNetworkReachabilitySetDispatchQueue(ref, .reachabilityMonitorQueue) {
                flags = .failure(.failedToSetDispatchQueue(SCError()))
            } else {
                refreshFlags()
            }
        }

        private func refreshFlags() {
            var flags = SCNetworkReachabilityFlags()
            if SCNetworkReachabilityGetFlags(ref, &flags) {
                self.flags = .success(flags)
            } else {
                self.flags = .failure(.failedToGetFlags(SCError()))
            }
        }

        private func succeed(with flags: SCNetworkReachabilityFlags?) {
            let reachability = Reachability(flags: flags)
            if let continuation = continuation {
                continuation(.success(reachability))
            } else if let updateQueue = updateQueue {
                updateQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.postNotification()
                    self.updateDelegate(reachability: reachability)
                    self.updateHandler?(self, .success(reachability))
                }
            } else if #available(macOS 10.15, iOS 13, tvOS 13, *) {
                Task {
                    await MainActor.run {
                        postNotification()
                        updateDelegate(reachability: reachability)
                        updateHandler?(self, .success(reachability))
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.postNotification()
                    self.updateDelegate(reachability: reachability)
                    self.updateHandler?(self, .success(reachability))
                }
            }
        }

        private func fail(with error: Error) {
            if let continuation = continuation {
                continuation(.failure(error))
            } else if let updateQueue = updateQueue {
                updateQueue.async { [weak self] in
                    guard let self = self else { return }
                    self.postNotification()
                    self.failDelegate(error)
                    self.updateHandler?(self, .failure(error))
                }
            } else if #available(macOS 10.15, iOS 13, tvOS 13, *) {
                Task {
                    await MainActor.run {
                        postNotification()
                        failDelegate(error)
                        updateHandler?(self, .failure(error))
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.postNotification()
                    self.failDelegate(error)
                    self.updateHandler?(self, .failure(error))
                }
            }
        }

        private func postNotification() {
            NotificationCenter.default.post(name: .reachabilityChanged, object: self)
        }

        private func updateDelegate(reachability: Reachability) {
            delegate?.reachabilityMonitor(self, didUpdateReachability: reachability)
        }

        private func failDelegate(_ error: Error) {
            delegate?.reachabilityMonitor(self, didFailWithError: error)
        }

        // MARK: - Deinit

        deinit {
            SCNetworkReachabilitySetCallback(ref, nil, nil)
            SCNetworkReachabilitySetDispatchQueue(ref, nil)
        }
    }
#endif
