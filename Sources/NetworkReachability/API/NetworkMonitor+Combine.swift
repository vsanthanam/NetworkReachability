// NetworkReachabiliy
// NetworkMonitor+Combine.swift
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

public extension NetworkMonitor {

    /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of reachability updates
    ///
    /// Use this property to observe reachability updates with [Combine](https://developer.apple.com/documentation/combine).
    ///
    /// ```swift
    /// let cancellable = NetworkMonitor.reachabilityPublisher
    ///     .map(\.isReachable)
    ///     .removeDuplicates()
    ///     .replaceError(with: false)
    ///     .sink { isReachable in
    ///         // Do something with `isReachable`
    ///     }
    /// ```
    static var reachabilityPublisher: NetworkMonitor.Publisher {
        .init()
    }

    /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of reachability updates for a specific host
    ///
    /// Use this property to observe reachability updates with [Combine](https://developer.apple.com/documentation/combine).
    ///
    /// ```swift
    /// let cancellable = NetworkMonitor.reachabilityPublisher(forHost: "apple.com")
    ///     .map(\.isReachable)
    ///     .removeDuplicates()
    ///     .replaceError(with: false)
    ///     .sink { isReachable in
    ///         // Do something with `isReachable`
    ///     }
    /// ```
    static func reachabilityPublisher(forHost host: String) -> NetworkMonitor.Publisher {
        .init(host: host)
    }

    /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) used to observe reachability updates for use with [Combine](https://developer.apple.com/documentation/combine).
    ///
    /// See ``reachabilityPublisher`` for usage.
    struct Publisher: Combine.Publisher {

        // MARK: - Publisher

        /// The kind of values published by this publisher.
        public typealias Output = Reachability

        /// The kind of errors this publisher might publish.
        public typealias Failure = Swift.Error

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Reachability == S.Input {
            let subscription = ReachabilitySubscription(subscriber: subscriber, host: host)
            subscriber.receive(subscription: subscription)
        }

        // MARK: - Private

        init(host: String? = nil) {
            self.host = host
        }

        private var host: String?

    }

    private final class ReachabilitySubscription<S: Subscriber>: Subscription where S.Input == Reachability, S.Failure == Swift.Error {

        // MARK: - Initializers

        init(subscriber: S?, host: String?) {
            self.subscriber = subscriber
            self.host = host
        }

        // MARK: - Subscription

        func request(_ demand: Subscribers.Demand) {
            requested += 1
            do {
                let continuation: (NetworkMonitor.Result) -> Void = { [weak self] result in
                    guard let self = self,
                          let subscriber = self.subscriber,
                          self.requested > .none else { return }
                    self.requested -= .max(1)
                    do {
                        let reachability = try result.get()
                        let newDemand = subscriber.receive(reachability)
                        self.requested += newDemand
                    } catch {
                        subscriber.receive(completion: .failure(error))
                    }
                }
                if let host = host {
                    networkMonitor = try NetworkMonitor(host: host, continuation: continuation)
                } else {
                    networkMonitor = try NetworkMonitor(continuation: continuation)
                }
            } catch {
                subscriber?.receive(completion: .failure(error))
            }
        }

        func cancel() {
            networkMonitor = nil
        }

        // MARK: - Private

        private var subscriber: S?
        private var networkMonitor: NetworkMonitor?
        private var requested: Subscribers.Demand = .none
        private var host: String?

    }

}
