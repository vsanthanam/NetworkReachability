// NetworkReachability
// NetworkMonitorConcurrencyTests.swift
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
    import Network
#endif

@testable import NetworkReachability
import XCTest

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class NetworkMonitorConcurrencyTests: XCTestCase {

    func test_get_concurrency() async throws {
        let path = try await NetworkMonitor.networkPath
        XCTAssertEqual(path.status, .satisfied)
    }

    func test_observe_concurrency() {
        let expectation = expectation(description: "pass")

        Task {
            for try await status in NetworkMonitor.networkPathUpdates.map(\.status) {
                if status == .satisfied {
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
