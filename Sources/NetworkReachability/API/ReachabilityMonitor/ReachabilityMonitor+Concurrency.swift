// NetworkReachability
// ReachabilityMonitor+Concurrency.swift
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

import Darwin
import SystemConfiguration

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension ReachabilityMonitor {

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of reachability updates
    ///
    /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates in an asynchronous context.
    ///
    /// ```swift
    /// func observe() async throws {
    ///     do {
    ///         for try await reachability in NetworkMonitor.reachabilityUpdates {
    ///             // Do something with `reachability`
    ///         }
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    static var reachabilityUpdates: AsyncThrowingStream<Reachability, Swift.Error> {
        stream { try .general }
    }

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of reachability updates for a specific host
    ///
    /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates in an asynchronous context.
    ///
    /// ```swift
    /// func observe() async throws {
    ///     do {
    ///         for try await reachability in NetworkMonitor.reachabilityUpdates(forHost: www.apple.com) {
    ///             // Do something with `reachability`
    ///         }
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter host: The host you want to monitor
    /// - Returns: An `AsyncSequence` of reachability updates for a given host
    static func reachabilityUpdates(forHost host: String) -> AsyncThrowingStream<Reachability, Swift.Error> {
        stream { try .forHost(host) }
    }

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of reachability updates for a specific socket address
    ///
    /// Use [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates in an asynchronous context.
    ///
    /// ```swift
    /// func observe() async throws {
    ///     do {
    ///         for try await reachability in NetworkMonitor.reachabilityUpdates(forAddress: myAddress) {
    ///             // Do something with `reachability`
    ///         }
    ///     } catch {
    ///         // Handle error
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter address: The socket address you want to monitor
    /// - Returns: An `AsyncSequence` of reachability updates for a given host
    static func reachabilityUpdates(forAddress address: sockaddr) -> AsyncThrowingStream<Reachability, Swift.Error> {
        stream { try .forAddress(address) }
    }

}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private func stream(_ refBuilder: () throws -> SCNetworkReachability) -> AsyncThrowingStream<Reachability, Swift.Error> {
    .init(bufferingPolicy: .bufferingNewest(1)) { continuation in
        do {
            _ = ReachabilityMonitor(try refBuilder()) { result in
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
