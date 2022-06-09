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

import Dispatch
import Foundation
import Network

/// A class used to observe network path changes
///
/// Create an instance of this object and retain it in memory.
///
/// You can observe reachability changes in several ways:
/// - Synchronously, using the ``currentPath`` property
/// - Using delegation via ``NetworkMonitorDelegate``.
/// - Using [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) via the ``networkPath`` and ``networkPathUpdates`` properties
/// - Using [Combine](https://developer.apple.com/documentation/combine), via the ``networkPathPublisher`` property.
/// - Using a provided closure via the ``updateHandler-swift.property`` property.
/// - Using notification observers on [`NotificationCenter.default`](https://developer.apple.com/documentation/foundation/notificationcenter).
@available(iOS 12.0, macOS 10.14, watchOS 5.0, tvOS 12.0, *)
public final class NetworkMonitor {

    // MARK: - Initializers

    /// Create a network monitor
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    public convenience init() {
        self.init(pathMonitor: .init(),
                  updateHandler: nil,
                  delegate: nil,
                  continuation: nil)
    }

    /// Create a network monitor to observe a specific interface type
    ///
    /// - Parameter requiredInterfaceType: The required interface type
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    public convenience init(requiredInterfaceType: NWInterface.InterfaceType) {
        self.init(pathMonitor: .init(requiredInterfaceType: requiredInterfaceType),
                  updateHandler: nil,
                  delegate: nil,
                  continuation: nil)
    }

    /// Create a network monitor to observe interface types that are not explicitly prohibited
    ///
    /// - Parameter prohibitedInterfaceTypes: The explicitly prohibited interface types
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public convenience init(prohibitedInterfaceTypes: [NWInterface.InterfaceType]) {
        self.init(pathMonitor: .init(prohibitedInterfaceTypes: prohibitedInterfaceTypes),
                  updateHandler: nil,
                  delegate: nil,
                  continuation: nil)
    }

    /// Create a network monitor that publishes updates to a delegate object
    ///
    /// - Parameter delegate: The delegate object used to recieve updates
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    public convenience init(delegate: any NetworkMonitorDelegate) {
        self.init(pathMonitor: .init(),
                  updateHandler: nil,
                  delegate: delegate,
                  continuation: nil)
    }

    /// Create a network monitor to observe a specific interface type that publishes updates to a delegate object
    ///
    /// - Parameters:
    ///   - requiredInterfaceType: The explicitly prohibited interface types
    ///   - delegate: The delegate object used to recieve updates
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    public convenience init(requiredInterfaceType: NWInterface.InterfaceType,
                            delegate: any NetworkMonitorDelegate) {
        self.init(pathMonitor: .init(requiredInterfaceType: requiredInterfaceType),
                  updateHandler: nil,
                  delegate: delegate,
                  continuation: nil)
    }

    /// Create a network monitor to observe interface types that are not explicitly prohibited that publishes updates to a delegate object
    ///
    /// - Parameters:
    ///   - prohibitedInterfaceTypes: The explicitly prohibited interface types
    ///   - delegate: The delegate object used to recieve updates
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public convenience init(prohibitedInterfaceTypes: [NWInterface.InterfaceType],
                            delegate: any NetworkMonitorDelegate) {
        self.init(pathMonitor: .init(prohibitedInterfaceTypes: prohibitedInterfaceTypes),
                  updateHandler: nil,
                  delegate: delegate,
                  continuation: nil)
    }

    /// Create a network monitor that publishes updates to a provided closure
    ///
    /// - Parameter updateHandler: Closure used to handle network path updates
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    public convenience init(updateHandler: @escaping UpdateHandler) {
        self.init(pathMonitor: .init(),
                  updateHandler: updateHandler,
                  delegate: nil,
                  continuation: nil)
    }

    /// Create a network monitor to observe a specific interface type that publishes to a provided closure
    ///
    /// - Parameters:
    ///   - requiredInterfaceType: The explicitly prohibited interface types
    ///   - updateHandler: Closure used to handle network path updates
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    public convenience init(requiredInterfaceType: NWInterface.InterfaceType,
                            updateHandler: @escaping UpdateHandler) {
        self.init(pathMonitor: .init(requiredInterfaceType: requiredInterfaceType),
                  updateHandler: updateHandler,
                  delegate: nil,
                  continuation: nil)
    }

    /// Create a network monitor to observe interface types that are not explicitly prohibited that publishes updates to a provided closure
    ///
    /// - Parameters:
    ///   - prohibitedInterfaceTypes: The explicitly prohibited interface types
    ///   - updateHandler: Closure used to handle network path updates
    ///
    /// - Note: The monitor begins observing and publishing updates immediately
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    public convenience init(prohibitedInterfaceTypes: [NWInterface.InterfaceType],
                            updateHandler: @escaping UpdateHandler) {
        self.init(pathMonitor: .init(prohibitedInterfaceTypes: prohibitedInterfaceTypes),
                  updateHandler: updateHandler,
                  delegate: nil,
                  continuation: nil)
    }

    // MARK: - API

    /// A closure used to recieve network path updates from a network monitor
    public typealias UpdateHandler = (NetworkMonitor, NWPath) -> Void

    /// The delegate object used to observe reachability updates
    ///
    /// See ``NetworkMonitorDelegate`` for more information
    ///
    /// - Tip: The delegate only recieves status changes that occured after it was assigned. To ensure that the delegate recieves every network path change, pass in the delegate on initialization of the monitor.
    public weak var delegate: (any NetworkMonitorDelegate)?

    /// The closure used to observe reachability updates
    ///
    /// - Tip: The update handler only recieves status changes that occured after it was assigned. To enture that the delegate recieves every network path changes, pass in the delegate on initalization of the monitor.
    ///
    /// - Note: Instances of ``NetworkMonitor`` will always invoke this closure the main thread.
    public private(set) var updateHandler: UpdateHandler?

    /// The currently available network path observed by the network monitor.
    public var currentPath: NWPath {
        pathMonitor.currentPath
    }

    // MARK: - Private

    convenience init(pathMonitor: NWPathMonitor,
                     continuation: @escaping ((NWPath) -> Void)) {
        self.init(pathMonitor: pathMonitor,
                  updateHandler: nil,
                  delegate: nil,
                  continuation: continuation)
    }

    private init(pathMonitor: NWPathMonitor,
                 updateHandler: UpdateHandler?,
                 delegate: (any NetworkMonitorDelegate)?,
                 continuation: ((NWPath) -> Void)?) {
        self.pathMonitor = pathMonitor
        self.updateHandler = updateHandler
        self.delegate = delegate
        self.continuation = continuation
        setUp()
    }

    private let pathMonitor: NWPathMonitor
    private let continuation: ((NWPath) -> Void)?

    private func setUp() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.forward(path: path)
        }
        pathMonitor.start(queue: .networkMonitorQueue)
    }

    private func forward(path: NWPath) {
        continuation?(path)
        if #available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *) {
            Task {
                await MainActor.run {
                    postNotification()
                    updateDelegate(path: path)
                    updateHandler?(self, path)
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.postNotification()
                self.updateDelegate(path: path)
                self.updateHandler?(self, path)
            }
        }
    }

    private func postNotification() {
        NotificationCenter.default.post(name: .networkPathChanged, object: self)
    }

    private func updateDelegate(path: NWPath) {
        delegate?.networkMonitor(self, didUpdateNetworkPath: path)
    }
    
    // MARK: - Deinit

    deinit {
        pathMonitor.cancel()
        pathMonitor.pathUpdateHandler = nil
    }

}
