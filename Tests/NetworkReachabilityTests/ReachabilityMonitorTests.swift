//
//  File.swift
//  
//
//  Created by Varun Santhanam on 6/5/22.
//

import Foundation

import Combine
@testable import NetworkReachability
import XCTest

final class ReachabilityMonitorTests: XCTestCase {

    var cancellable: AnyCancellable?

    func test_get_concurrency() async {
        do {
            let reachability = try await ReachabilityMonitor.reachability
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
