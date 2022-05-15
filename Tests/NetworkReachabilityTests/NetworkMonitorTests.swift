// NetworkReachabiliy
// NetworkMonitorTests.swift
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

@testable import NetworkReachability
import XCTest

final class NetworkMonitorTests: XCTestCase {

    func test_standardSynchronous() {
        do {
            let monitor = try NetworkMonitor()
            let reachability = try monitor.currentReachability
            XCTAssertTrue(reachability.isReachable)
        } catch {
            XCTFail()
        }
    }

    func test_hostSynchronous() {
        do {
            let monitor = try NetworkMonitor(host: "apple.com")
            let reachability = try monitor.currentReachability
            XCTAssertTrue(reachability.isReachable)
        } catch {
            XCTFail()
        }
    }

    func test_standardConcurrency() {
        let expectation = expectation(description: "pass")
        Task {
            do {
                let monitor = try NetworkMonitor()
                for try await reachability in monitor.reachability {
                    if reachability.isReachable {
                        expectation.fulfill()
                    }
                }
            } catch {
                XCTFail()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_hostConcurrency() {
        let expectation = expectation(description: "pass")
        Task {
            do {
                let monitor = try NetworkMonitor(host: "apple.com")
                for try await reachability in monitor.reachability {
                    if reachability.isReachable {
                        expectation.fulfill()
                    }
                }
            } catch {
                XCTFail()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_standardClosure() {
        let expectation = expectation(description: "pass")
        do {
            _ = try NetworkMonitor() { _, result in
                do {
                    let reachability = try result.get()
                    if reachability.isReachable {
                        expectation.fulfill()
                    }
                } catch {
                    XCTFail()
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        } catch {
            XCTFail()
        }
    }

    func test_hostClosure() {
        let expectation = expectation(description: "apple.com")
        do {
            _ = try NetworkMonitor() { _, result in
                do {
                    let reachability = try result.get()
                    if reachability.isReachable {
                        expectation.fulfill()
                    }
                } catch {
                    XCTFail()
                }
            }
            waitForExpectations(timeout: 5, handler: nil)
        } catch {
            XCTFail()
        }
    }

}
