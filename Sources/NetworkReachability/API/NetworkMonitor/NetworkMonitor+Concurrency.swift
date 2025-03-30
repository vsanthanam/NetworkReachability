// NetworkReachability
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

import Network

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension NetworkMonitor {

    /// Retrieve the latest known network path using [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
    ///
    /// ```swift
    /// func updateReachability() async throws {
    ///     let path = try await NetworkMonitor.networkPath
    ///     // Do something with `path`
    /// }
    /// ```
    static var networkPath: NWPath {
        get async throws {
            try await withUnsafeThrowingContinuation { continuation in
                NetworkMonitor.networkPath { path in
                    if Task.isCancelled {
                        continuation.resume(throwing: CancellationError())
                    } else {
                        continuation.resume(returning: path)
                    }
                }
            }
        }
    }

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of network path updates.
    ///
    /// Use this property observe network path updates using [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
    ///
    /// ```swift
    /// for await path in NetworkMontitor.networkPathUpdates {
    ///     // Do something with `path`
    /// }
    /// ```
    static var networkPathUpdates: AsyncThrowingStream<NWPath, any Error> {
        stream(.init())
    }

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of network path updates for a specific interface.
    ///
    /// Use this function to observe network path updates using [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
    ///
    /// ```swift
    /// for await path in NetworkMontitor.networkPathUpdates(requiringInterfaceType: .wifi) {
    ///     // Do something with `path`
    /// }
    /// ```
    static func networkPathUpdates(requiringInterfaceType interfaceType: NWInterface.InterfaceType) -> AsyncThrowingStream<NWPath, any Error> {
        stream(.init(requiredInterfaceType: interfaceType))
    }

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of network path updates for interface types that are not explicitly prohibited.
    ///
    /// Use this function to observe network path updates using [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
    ///
    /// ```swift
    /// for await path in NetworkMontitor.networkPathUpdates(prohibitingInterfaceTypes: [.wifi, .wiredEthernet]) {
    ///     // Do something with `path`
    /// }
    /// ```
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    static func networkPathUpdates(prohibitingInterfaceTypes interfaceTypes: [NWInterface.InterfaceType]) -> AsyncThrowingStream<NWPath, any Error> {
        stream(.init(prohibitedInterfaceTypes: interfaceTypes))
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private func stream(_ monitor: NWPathMonitor) -> AsyncThrowingStream<NWPath, any Error> {
    .init { continuation in
        monitor.pathUpdateHandler = { path in
            if Task.isCancelled {
                monitor.cancel()
                continuation.finish(throwing: CancellationError())
            } else {
                continuation.yield(path)
            }
        }
        monitor.start(queue: .networkMonitorQueue)
    }
}
