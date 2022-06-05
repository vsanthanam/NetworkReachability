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

import Combine
import Network
@testable import NetworkReachability
import XCTest

final class NetworkMonitorTests: XCTestCase {

    var cancellable: AnyCancellable?

    func test_get_concurrency() async {
        let path = await NetworkMonitor.networkPath
        XCTAssertEqual(path.status, .satisfied)
    }

    func test_observe_concurrency() {
        let expectation = expectation(description: "pass")

        Task {
            for await status in NetworkMonitor.networkPathUpdates.map(\.status) {
                if status == .satisfied {
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_observe_closure() {
        let expectation = expectation(description: "pass")
        withExtendedLifetime(NetworkMonitor(updateHandler: { _, path in
            if path.status == .satisfied {
                expectation.fulfill()
            }
        })) {
            waitForExpectations(timeout: 5, handler: nil)
        }
    }

    func test_observe_combine() {
        let expectation = expectation(description: "pass")
        cancellable = NetworkMonitor
            .networkPathPublisher
            .map { $0.status == .satisfied }
            .removeDuplicates()
            .sink { isReachable in
                XCTAssertTrue(isReachable)
                expectation.fulfill()
            }
        waitForExpectations(timeout: 5)
    }

    func test_observe_delegate() {
        let expectation = expectation(description: "pass")

        final class Delegate: NetworkMonitorDelegate {
            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            let expectation: XCTestExpectation

            func networkMonitor(_ monitor: NetworkMonitor, didUpdateNetworkPath networkPath: NWPath) {
                if networkPath.status == .satisfied {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }

        let delegate = Delegate(expectation)

        let monitor = NetworkMonitor(delegate: delegate)
        withExtendedLifetime(monitor) {
            waitForExpectations(timeout: 5)
        }
    }

    func test_observe_notification() {
        class Observer {

            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
                observe()
            }

            func observe() {
                NotificationCenter.default.addObserver(self, selector: #selector(fulfill(_:)), name: .networkPathChanged, object: nil)
            }

            @objc
            func fulfill(_ notification: Notification) {
                guard let monitor = notification.object as? NetworkMonitor,
                      monitor.currentPath.status == .satisfied else {
                    XCTFail()
                    return
                }
                expectation.fulfill()
            }

            let expectation: XCTestExpectation

            deinit {
                NotificationCenter.default.removeObserver(self)
            }
        }

        let expectation = expectation(description: "pass")
        withExtendedLifetime(Observer(expectation)) {
            withExtendedLifetime(NetworkMonitor()) {
                waitForExpectations(timeout: 5)
            }
        }
    }
}
