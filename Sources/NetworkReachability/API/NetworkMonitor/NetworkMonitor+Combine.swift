// NetworkReachability
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

#if canImport(Combine)
    import Combine
    import Network

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public extension NetworkMonitor {

        /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of network path updates
        ///
        /// Use this property to observe network path updates using [Combine](https://developer.apple.com/documentation/combine)
        ///
        /// ```swift
        /// let cancellable = NetworkMonitor.networkPathPublisher
        ///     .map { path in
        ///         path.status == .satisfied
        ///     }
        ///     .removeDuplicates()
        ///     .sink { isSatisfied in
        ///         // Do something with `isSatisfied`
        ///     }
        /// ```
        static var networkPathPublisher: Publishers.NetworkPathPublisher {
            .init(pathMonitor: .init())
        }

        /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of network path updates for a specific interface
        ///
        /// Use this function to observe network path updates using [Combine](https://developer.apple.com/documentation/combine)
        ///
        /// ```swift
        /// let cancellable = NetworkMonitor.networkPathPublisher(requiringInterfaceType: .wifi)
        ///     .map { path in
        ///         path.status == .satisfied
        ///     }
        ///     .removeDuplicates()
        ///     .sink { isSatisfied in
        ///         // Do something with `isSatisfied`
        ///     }
        /// ```
        static func networkPathPublisher(requiringInterfaceType interfaceType: NWInterface.InterfaceType) -> Publishers.NetworkPathPublisher {
            .init(pathMonitor: .init(requiredInterfaceType: interfaceType))
        }

        /// A [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of network path updates for interface types that are not explicitly prohibited.
        ///
        /// Use this function to observe network path updates using [Combine](https://developer.apple.com/documentation/combine)
        ///
        /// ```swift
        /// let cancellable = NetworkMonitor.networkPathPublisher(prohibitingInterfaceTypes: [.wifi, .wiredEthernet])
        ///     .map { path in
        ///         path.status == .satisfied
        ///     }
        ///     .removeDuplicates()
        ///     .sink { isSatisfied in
        ///         // Do something with `isSatisfied`
        ///     }
        /// ```
        @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
        static func networkPathPublisher(prohibitingInterfaceTypes interfaceTypes: [NWInterface.InterfaceType]) -> Publishers.NetworkPathPublisher {
            .init(pathMonitor: .init(prohibitedInterfaceTypes: interfaceTypes))
        }

        /// A  [`Publisher`](https://developer.apple.com/documentation/combine/publisher) of [`NWPath`](https://developer.apple.com/documentation/network/nwpath) updates for use with [Combine](https://developer.apple.com/documentation/combine)
        struct Publisher: Combine.Publisher {

            // MARK: - Initializers

            init(pathMonitor: NWPathMonitor) {
                self.pathMonitor = pathMonitor
            }

            // MARK: - Publisher

            /// The kind of values published by this publisher.
            public typealias Output = NWPath

            /// The kind of errors this publisher might publish.
            public typealias Failure = Never

            /// Attaches the specified subscriber to this publisher.
            /// - Parameter subscriber: The subscriber to attach to this [`Publisher`](https://developer.apple.com/documentation/combine/publisher), after which it can receive values.
            public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
                let subscription = Subscription(subscriber: subscriber, pathMonitor: pathMonitor)
                subscriber.receive(subscription: subscription)
            }

            // MARK: - Private

            private let pathMonitor: NWPathMonitor
        }

        private final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == NWPath, S.Failure == Never {

            // MARK: - Initializers

            init(subscriber: S?, pathMonitor: NWPathMonitor) {
                self.subscriber = subscriber
                self.pathMonitor = pathMonitor
            }

            // MARK: - Subscription

            func request(_ demand: Subscribers.Demand) {
                requested += 1
                monitor = .withContinuation(pathMonitor: pathMonitor) { [weak self] path in
                    guard let self,
                          let subscriber,
                          requested > .none else { return }
                    requested -= .max(1)
                    let newDemand = subscriber.receive(path)
                    requested += newDemand
                }
            }

            func cancel() {
                monitor = nil
            }

            // MARK: - Private

            private let pathMonitor: NWPathMonitor
            private var monitor: NetworkMonitor?
            private var subscriber: S?
            private var requested: Subscribers.Demand = .none

        }

    }
#endif
