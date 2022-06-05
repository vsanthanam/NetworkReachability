// NetworkReachabiliy
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

@available(macOS 10.13, iOS 11, watchOS 4, tvOS 11, *)
public final class ReachabilityMonitor {

    // MARK: - Initializers

    /// Create a reachability monitor
    ///
    /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
    ///
    /// - Throws: An error of type ``Error``
    public convenience init() throws {
        self.init(ref: try .general,
                  updateHandler: nil,
                  delegate: nil)
    }

    /// Create a reachability monitor with a closure used to respond to reachability changes
    ///
    /// Use this initializer to respond to reachability updates with a closure
    ///
    /// - Parameter updateHandler: The closure used to observe reachability updates
    ///
    /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
    ///
    /// - Throws: An error of type ``Error``
    public convenience init(updateHandler: @escaping UpdateHandler) throws {
        self.init(ref: try .general,
                  updateHandler: updateHandler,
                  delegate: nil)
    }

    /// Create a reachability monitor with a delegate object used to respond to reachability changes
    ///
    /// Use this initializer to respond to reachability updates with an instance of an object that conforms to ``ReachabilityMonitorDelegate``
    ///
    /// - Parameter delegate: The delegate object used to observe reachability updates
    ///
    /// - Note: A reachability monitor begins observing and publishing reachability updates immediately after initialization.
    ///
    /// - Throws: An error of type ``Error``
    public convenience init(delegate: ReachabilityMonitorDelegate) throws {
        self.init(ref: try .general,
                  updateHandler: nil,
                  delegate: delegate)
    }

    // MARK: - API

    /// Specialized [`Result`](https://developer.apple.com/documentation/swift/result) delivered by a ``ReachabilityMonitor`` to it's ``updateHandler-swift.property``
    public typealias Result = Swift.Result<Reachability, Error>

    /// The closure type used to observe reachability updates
    public typealias UpdateHandler = (ReachabilityMonitor, ReachabilityMonitor.Result) -> Void

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
    /// - Note: Instances of ``ReachabilityMonitor`` will always invoke this closure the main thread.
    public var updateHandler: UpdateHandler?

    /// The delegate object used to observe reachability updates
    ///
    /// See ``ReachabilityMonitorDelegate`` for more information.
    ///
    /// - Tip: The delegate only recieves status changes that occured after it was assigned. To recieve every status update, including the reachability status at the time the monitor was initialized, pass in the delegate on initialization of the monitor.
    public weak var delegate: ReachabilityMonitorDelegate?

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
    public var reachability: Reachability {
        get throws {
            refreshFlags()
            return Reachability(flags: try flags.get())
        }
    }

    // MARK: - Private

    private init(ref: SCNetworkReachability,
                 updateHandler: UpdateHandler?,
                 delegate: ReachabilityMonitorDelegate?,
                 continuation: ((Result) -> Void)? = nil) {
        self.ref = ref
        self.updateHandler = updateHandler
        self.delegate = delegate
        self.continuation = continuation
        setUp()
    }

    convenience init(continuation: @escaping (Result) -> Void) throws {
        self.init(ref: try .general,
                  updateHandler: nil,
                  delegate: nil,
                  continuation: continuation)
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
                    fail(with: error as! Error)
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
            copyDescription: { (info: UnsafeRawPointer) -> Unmanaged<CFString> in
                let unmanagedMonitor = Unmanaged<WeakReference<ReachabilityMonitor>>.fromOpaque(info)
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
        let reachability = Reachability(flags: flags)
        continuation?(.success(reachability))
        if #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) {
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
        continuation?(.failure(error))
        if #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) {
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
        SCNetworkReachabilityUnscheduleFromRunLoop(ref, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
    }
}
