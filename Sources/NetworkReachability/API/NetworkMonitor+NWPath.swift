// NetworkReachabiliy
// NetworkMonitor+NWPath.swift
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

#if canImport(Network)
    import Foundation
    import Network

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public extension NetworkMonitor {

        /// Retrieve the available network path observed by the monitor in an asynchronous context
        ///
        /// ```swift
        /// func updatePath() async {
        ///     let path = await NetworkMonitor.networkPath
        ///     // Do something with `path`
        /// }
        /// ```
        static var networkPath: NWPath {
            get async {
                await withUnsafeContinuation { continuation in
                    let pathMonitor = NWPathMonitor()
                    pathMonitor.pathUpdateHandler = { path in
                        pathMonitor.cancel()
                        continuation.resume(with: .success(path))
                    }
                    pathMonitor.start(queue: .networkMonitorQueue)
                }
            }
        }
    }
#endif
