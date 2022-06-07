// NetworkReachabiliy
// ReachabilityMonitorTests.swift
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

import Combine
@testable import NetworkReachability
import XCTest

final class ReachabilityMonitorTests: XCTestCase {

    var cancellable: AnyCancellable?

    func test_get_concurrency() {
        do {
            let reachability = try ReachabilityMonitor.reachability
            XCTAssertTrue(reachability.status.isReachable)
        } catch {
            XCTFail()
        }
    }

    func test_observe_concurrency() {
        let expectation = expectation(description: "pass")

        Task {
            do {
                for try await isReachable in ReachabilityMonitor.reachabilityUpdates.map(\.status.isReachable) {
                    if isReachable {
                        expectation.fulfill()
                    } else {
                        XCTFail()
                    }
                }
            } catch {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_observe_closure() {
        let expectation = expectation(description: "pass")
        do {
            withExtendedLifetime(try ReachabilityMonitor(updateHandler: { _, reachability in
                do {
                    if try reachability.get().status.isReachable {
                        expectation.fulfill()
                    } else {
                        XCTFail()
                    }
                } catch {
                    XCTFail()
                }
            })) {
                waitForExpectations(timeout: 5, handler: nil)
            }
        } catch {
            XCTFail()
        }
    }

    func test_observe_combine() {
        let expectation = expectation(description: "pass")
        cancellable = ReachabilityMonitor
            .reachabilityPublisher
            .map(\.status.isReachable)
            .replaceError(with: false)
            .removeDuplicates()
            .sink { isReachable in
                XCTAssertTrue(isReachable)
                expectation.fulfill()
            }
        waitForExpectations(timeout: 5)
    }

    func test_observe_delegate() {
        let expectation = expectation(description: "pass")

        final class Delegate: ReachabilityMonitorDelegate {
            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            let expectation: XCTestExpectation

            func reachabilityMonitor(_ monitor: ReachabilityMonitor, didUpdateReachability reachability: Reachability) {
                XCTAssertTrue(reachability.status.isReachable)
                expectation.fulfill()
            }

            func reachabilityMonitor(_ monitor: ReachabilityMonitor, didFailWithError error: Error) {
                XCTFail()
            }
        }

        let delegate = Delegate(expectation)

        do {
            let monitor = try ReachabilityMonitor(delegate: delegate)
            withExtendedLifetime(monitor) {
                waitForExpectations(timeout: 5)
            }
        } catch {
            XCTFail()
        }
    }

    func test_observe_notification() {
        class Observer {

            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
                observe()
            }

            func observe() {
                NotificationCenter.default.addObserver(self, selector: #selector(fulfill(_:)), name: .reachabilityChanged, object: nil)
            }

            @objc
            func fulfill(_ notification: Notification) {
                guard let monitor = notification.object as? ReachabilityMonitor,
                      let isReachable = try? monitor.currentReachability.status.isReachable else {
                    XCTFail()
                    return
                }
                XCTAssertTrue(isReachable)
                expectation.fulfill()
            }

            let expectation: XCTestExpectation

            deinit {
                NotificationCenter.default.removeObserver(self)
            }
        }

        let expectation = expectation(description: "pass")
        withExtendedLifetime(Observer(expectation)) {
            do {
                withExtendedLifetime(try ReachabilityMonitor()) {
                    waitForExpectations(timeout: 5)
                }
            } catch {
                XCTFail()
            }
        }
    }
}
