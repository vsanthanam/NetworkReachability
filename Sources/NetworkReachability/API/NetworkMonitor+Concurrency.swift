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

public extension NetworkMonitor {

    /// An [`AsyncSequence`](https://developer.apple.com/documentation/swift/asyncsequence) of reachability updates
    ///
    /// Use [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates
    ///
    /// ```swift
    /// do {
    ///     for try await reachability in NetworkMonitor.reachability {
    ///         // Do something with `reachability`
    ///     }
    /// } catch {
    ///     // Handle error
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
    /// Use [structured concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) to iterate over reachability updates
    ///
    /// ```swift
    /// do {
    ///     for try await reachability in NetworkMonitor.reachability(forHost: "apple.com") {
    ///         // Do something with `reachability`
    ///     }
    /// } catch {
    ///     // Handle error
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
