// NetworkReachabiliy
// NetworkMonitor+Concurrency.swift
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

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension NetworkMonitor {

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of reachability updates
    ///
    /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates in an asynchronous context.
    ///
    /// ```swift
    /// func observe() async throws {
    ///     do {
    ///         for try await reachability in NetworkMonitor.reachability {
    ///             // Do something with `reachability`
    ///         }
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    static var reachability: AsyncThrowingStream<Reachability, Swift.Error> {
        .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
            do {
                _ = try NetworkMonitor() { result in
                    do {
                        let reachability = try result.get()
                        continuation.yield(reachability)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of reachability updates for a specific host
    ///
    /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates in an asynchronous context.
    ///
    /// ```swift
    /// func observe() async throws {
    ///     do {
    ///         for try await reachability in NetworkMonitor.reachability(forHost: "apple.com") {
    ///             // Do something with `reachability`
    ///         }
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    static func reachability(forHost host: String) -> AsyncThrowingStream<Reachability, Swift.Error> {
        .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
            do {
                _ = try NetworkMonitor(host: host) { result in
                    do {
                        let reachability = try result.get()
                        continuation.yield(reachability)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}

#if canImport(Network)

    import Network

    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    public extension NetworkMonitor {

        /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of network path updates
        ///
        /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over network path updates in an asynchronous context.
        ///
        /// ```swift
        /// func observe() async throws {
        ///     for await path in NetworkMonitor.networkPathUpdates {
        ///         // Do something with `reachability`
        ///     }
        /// }
        /// ```
        static var networkPathUpdates: AsyncStream<NWPath> {
            .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
                let monitor = NWPathMonitor()
                monitor.pathUpdateHandler = { path in
                    continuation.yield(path)
                }
                monitor.start(queue: .networkMonitorQueue)
            }
        }

        /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of network path updates for specific interfaces that are not explicitly prohibited.
        ///
        /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over network path updates in an asynchronous context.
        ///
        /// ```swift
        /// func observe() async throws {
        ///     for await path in NetworkMonitor.networkPathUpdates {
        ///         // Do something with `reachability`
        ///     }
        /// }
        /// ```
        static func networkPathUpdates(requiringInterfaceType interfaceType: NWInterface.InterfaceType) -> AsyncStream<NWPath> {
            .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
                let monitor = NWPathMonitor(requiredInterfaceType: interfaceType)
                monitor.pathUpdateHandler = { path in
                    continuation.yield(path)
                }
                monitor.start(queue: .networkMonitorQueue)
            }
        }

        /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of network path updates
        ///
        /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over network path updates in an asynchronous context.
        ///
        /// ```swift
        /// func observe() async throws {
        ///     for await path in NetworkMonitor.networkPathUpdates {
        ///         // Do something with `reachability`
        ///     }
        /// }
        /// ```
        @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
        static func networkPathUpdates(prohibitingInterfaceTypes interfaceTypes: [NWInterface.InterfaceType]) -> AsyncStream<NWPath> {
            .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
                let monitor = NWPathMonitor(prohibitedInterfaceTypes: interfaceTypes)
                monitor.pathUpdateHandler = { path in
                    continuation.yield(path)
                }
                monitor.start(queue: .networkMonitorQueue)
            }
        }

    }

#endif
