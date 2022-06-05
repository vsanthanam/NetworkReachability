// NetworkReachabiliy
// ReachabilityMonitor+Combine.swift
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

#if canImport(Combine)
    import Combine
    import Foundation

    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public extension ReachabilityMonitor {

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
        static var reachabilityPublisher: Publishers.ReachabilityPublisher {
            .init()
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

            public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
                let subscription = ReachabilitySubscription(subscriber: subscriber)
                subscriber.receive(subscription: subscription)
            }

        }

        private final class ReachabilitySubscription<S: Subscriber>: Subscription where S.Input == Reachability, S.Failure == Swift.Error {

            // MARK: - Initializers

            init(subscriber: S?) {
                self.subscriber = subscriber
            }

            // MARK: - Subscription

            func request(_ demand: Subscribers.Demand) {
                requested += 1
                do {
                    networkMonitor = try ReachabilityMonitor { [weak self] result in
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
                } catch {
                    subscriber?.receive(completion: .failure(error))
                }
            }

            func cancel() {
                networkMonitor = nil
            }

            // MARK: - Private

            private var subscriber: S?
            private var networkMonitor: ReachabilityMonitor?
            private var requested: Subscribers.Demand = .none

        }

    }
#endif
