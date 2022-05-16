// NetworkReachabiliy
// NetworkMonitor.swift
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
/// You can observe reachability changes in several ways:
/// - Synchronously, using the ``currentReachability`` property.
/// - Using delegation via ``NetworkMonitorDelegate``.
/// - Using structured concurrency via the ``reachability`` property.
/// - Using [Combine](https://developer.apple.com/documentation/combine), via the ``reachabilityPublisher`` property.
/// - Using a provided closure via the ``updateHandler-swift.property`` property.
/// - Using notification observers on [`NotificationCenter.default`](https://developer.apple.com/documentation/foundation/notificationcenter).
public final class NetworkMonitor {

    // MARK: - Initializers

    /// Create a network monitor
    /// - Throws: An error of type ``Error``
    public convenience init() throws {
        self.init(ref: try .general,
                  updateHandler: nil,
                  delegate: nil)
    }

    /// Create a network monitor for a specific host
    ///
    /// Use this initializer to monitor reachability updates for a specific host
    /// - Parameter host: The host who's reachability you wish to monitor
    /// - Throws: An error of type ``Error``
    public convenience init(host: String) throws {
        self.init(ref: try .forHost(host),
                  updateHandler: nil,
                  delegate: nil)
    }

    /// Create a network monitor with a closure used to respond to reachability changes
    ///
    /// Use this initializer to respond to reachability updates with a closure
    /// - Parameter updateHandler: The closure used to observe reachability updates
    /// - Throws: An error of type ``Error``
    public convenience init(updateHandler: @escaping UpdateHandler) throws {
        self.init(ref: try .general,
                  updateHandler: updateHandler,
                  delegate: nil)
    }

    /// Create a network monitor for a specific host, with a closure used to respond to reachability changes
    ///
    /// Use this initializer to respond to reachability updates for a specific host with a closure
    /// - Parameters:
    ///   - host: The host who's reachability you wish to monitor
    ///   - updateHandler: The closure used to observe reachability updates
    /// - Throws: An error of type ``Error``
    public convenience init(host: String,
                            updateHandler: @escaping UpdateHandler) throws {
        self.init(ref: try .forHost(host),
                  updateHandler: updateHandler,
                  delegate: nil)
    }

    /// Create a network monitor with a delegate object used to respond to reachability changes
    ///
    /// Use this initializer to respond to reachability updates with an instance of an object that conforms to ``NetworkMonitorDelegate``
    /// - Parameter delegate: The delegate object used to observe reachability updates
    /// - Throws: An error of type ``Error``
    public convenience init(delegate: NetworkMonitorDelegate) throws {
        self.init(ref: try .general,
                  updateHandler: nil,
                  delegate: delegate)
    }

    /// Create a network monitor for a specific host, with a delegate object used to respond to reachability changes
    ///
    /// Use this initializer to respond to reachability updates with an instance of an object that conforms to ``NetworkMonitorDelegate`
    /// - Parameters:
    ///   - host: The host who's reachability you wish to monitor
    ///   - delegate: The delegate object used to observe reachability updates
    /// - Throws: An error of type ``Error``
    public convenience init(host: String, delegate: NetworkMonitorDelegate) throws {
        self.init(ref: try .forHost(host),
                  updateHandler: nil,
                  delegate: delegate)
    }

    // MARK: - API

    /// Specialized [`Result`](https://developer.apple.com/documentation/swift/result) delivered by a ``NetworkMonitor`` to it's ``updateHandler-swift.property``
    public typealias Result = Swift.Result<Reachability, Error>

    /// The closure type used to observe reachability updates
    public typealias UpdateHandler = @MainActor(NetworkMonitor, NetworkMonitor.Result) -> Void

    /// The closure used to observe reachability updates
    ///
    /// The handler is fed `Result` types and should be used to handle reachability changes as well as errors
    ///
    /// ```swift
    /// func setUpdateHandler(on monitor: NetworkMonitor) {
    ///     let updateHandler: NetworkMonitor.UpdateHandler = { (monitor: NetworkMonitor, result: NetworkMonitor.Result) in
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
    public var updateHandler: UpdateHandler?

    /// The delegate object used to observe reachability updates
    public weak var delegate: NetworkMonitorDelegate?

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of reachability updates
    ///
    /// Use [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates
    ///
    /// ```swift
    /// do {
    ///     for try await reachability in monitor.reachability {
    ///         // Do something with `reachability`
    ///     }
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    public var reachability: AsyncThrowingStream<Reachability, Swift.Error> {
        stream
    }

    /// The current reachability updates
    ///
    /// Use this property to retrieve the current reachability reachability in a synchronous context:
    ///
    /// ```swift
    /// do {
    ///     let reachability = try monitor.currentReachability
    ///     // Do something with `reachability`
    /// } catch {
    ///     // Handle error
    /// }
    /// ```
    /// - Throws: An error of type ``Error``
    public var currentReachability: Reachability {
        get throws {
            refreshFlags()
            return try flags.get()?.reachability ?? .unavailable
        }
    }

    /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of reachability updates
    ///
    /// Use this property to observe reachability updates with [Combine](https://developer.apple.com/documentation/combine).
    ///
    /// ```swift
    /// let cancellable = monitor.reachabilityPublisher
    ///     .map(\.isReachable)
    ///     .replaceError(with: false)
    ///     .sink { isReachable in
    ///         // Do something with `isReachable`
    ///     }
    /// ```
    public var reachabilityPublisher: AnyPublisher<Reachability, Error> {
        reachabilitySubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private init(ref: SCNetworkReachability,
                 updateHandler: UpdateHandler?,
                 delegate: NetworkMonitorDelegate?) {
        self.ref = ref
        self.updateHandler = updateHandler
        self.delegate = delegate
        setUp()
    }

    private var ref: SCNetworkReachability
    private var stream: AsyncThrowingStream<Reachability, Swift.Error>!
    private var streamContinuation: AsyncThrowingStream<Reachability, Swift.Error>.Continuation!
    private var reachabilitySubject = CurrentValueSubject<Reachability?, Error>(nil)

    private var flags: Swift.Result<SCNetworkReachabilityFlags?, Error> = .success(nil) {
        didSet {
            if flags.map(\.?.reachability) != oldValue.map(\.?.reachability) {
                do {
                    let flags = try flags.get()
                    succeed(with: flags)
                } catch {
                    fail(with: error as! Error)
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
            let weakMonitor = Unmanaged<WeakReference<NetworkMonitor>>.fromOpaque(info).takeUnretainedValue()
            weakMonitor.obj?.flags = .success(flags)
        }

        let weakMonitor = weak(self)
        let opaqueMonitor = Unmanaged<WeakReference<NetworkMonitor>>.passUnretained(weakMonitor).toOpaque()

        var context = SCNetworkReachabilityContext(
            version: 0,
            info: UnsafeMutableRawPointer(opaqueMonitor),
            retain: { info in
                let unmanaged = Unmanaged<WeakReference<NetworkMonitor>>.fromOpaque(info)
                _ = unmanaged.retain()
                return UnsafeRawPointer(unmanaged.toOpaque())
            },
            release: { info in
                let unmanaged = Unmanaged<WeakReference<NetworkMonitor>>.fromOpaque(info)
                unmanaged.release()
            },
            copyDescription: { (info: UnsafeRawPointer) -> Unmanaged<CFString> in
                let unmanagedMonitor = Unmanaged<WeakReference<NetworkMonitor>>.fromOpaque(info)
                let weakMonitor = unmanagedMonitor.takeUnretainedValue()
                let copyDescription = try? weakMonitor.obj?.flags.get()?.copyDescription ?? "none"
                return Unmanaged.passRetained(copyDescription! as CFString)
            }
        )

        if !SCNetworkReachabilitySetCallback(ref, callback, &context) {
            flags = .failure(.failedToStartCallback(SCError()))
        } else if !SCNetworkReachabilityScheduleWithRunLoop(ref, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) {
            flags = .failure(.failedToSetRunLoop(SCError()))
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
        let reachability = flags.map(\.reachability) ?? .unknown
        streamContinuation.yield(reachability)
        reachabilitySubject.send(reachability)
        Task {
            await postNotification()
            await delegate?.networkMonitor(self, didUpdateReachability: reachability)
            await updateHandler?(self, .success(reachability))
        }
    }

    private func fail(with error: Error) {
        streamContinuation.finish(throwing: error)
        reachabilitySubject.send(completion: .failure(error))
        Task {
            await postNotification()
            await updateHandler?(self, .failure(error))
            await delegate?.networkMonitor(self, didFailWithError: error)
        }
    }

    private func complete() {
        streamContinuation.finish(throwing: nil)
        reachabilitySubject.send(completion: .finished)
    }

    @MainActor
    private func postNotification() {
        NotificationCenter.default.post(name: .reachabilityChanged, object: self)
    }

    // MARK: - Deinit

    deinit {
        SCNetworkReachabilitySetCallback(ref, nil, nil)
        SCNetworkReachabilityUnscheduleFromRunLoop(ref, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        complete()
    }
}
