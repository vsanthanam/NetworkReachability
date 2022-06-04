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

    func test_standardSynchronous() {
        do {
            let monitor = try NetworkMonitor()
            let reachability = try monitor.reachability
            XCTAssertTrue(reachability.isReachable)
        } catch {
            XCTFail()
        }
    }

    func test_hostSynchronous() {
        do {
            let monitor = try NetworkMonitor(host: "apple.com")
            let reachability = try monitor.reachability
            XCTAssertTrue(reachability.isReachable)
        } catch {
            XCTFail()
        }
    }

    func test_hostSynchronous_fails() {
        do {
            _ = try NetworkMonitor(host: "")
            XCTFail()
        } catch {
            guard let error = error as? NetworkMonitor.Error else {
                XCTFail()
                return
            }
            guard case .failedToCreate = error else {
                XCTFail()
                return
            }
        }
    }

    func test_standardConcurrency() {
        let expectation = expectation(description: "pass")

        Task {
            do {
                for try await reachability in NetworkMonitor.reachability {
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
                for try await reachability in NetworkMonitor.reachability(forHost: "apple.com") {
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

    func test_hostConcurrency_fail() async {
        do {
            for try await _ in NetworkMonitor.reachability(forHost: "") {
                XCTFail()
            }

        } catch {
            guard let error = error as? NetworkMonitor.Error else {
                XCTFail()
                return
            }
            guard case .failedToCreate = error else {
                XCTFail()
                return
            }
        }
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
        let expectation = expectation(description: "pass")
        do {
            _ = try NetworkMonitor(host: "apple.com") { _, result in
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

    func test_hostClosure_fail() {
        do {
            _ = try NetworkMonitor(host: "") { _, result in
                XCTFail()
            }
            XCTFail()
        } catch {
            guard let error = error as? NetworkMonitor.Error else {
                XCTFail()
                return
            }
            guard case .failedToCreate = error else {
                XCTFail()
                return
            }
        }
    }

    func test_standardPublisher() {
        let expectation = expectation(description: "pass")
        cancellable = NetworkMonitor
            .reachabilityPublisher
            .map(\.isReachable)
            .replaceError(with: false)
            .removeDuplicates()
            .sink { isReachable in
                XCTAssertTrue(isReachable)
                expectation.fulfill()
            }
        waitForExpectations(timeout: 5)
    }

    func test_hostPublisher() {
        let expectation = expectation(description: "pass")
        cancellable = NetworkMonitor
            .reachabilityPublisher(forHost: "apple.com")
            .map(\.isReachable)
            .replaceError(with: false)
            .removeDuplicates()
            .sink { isReachable in
                XCTAssertTrue(isReachable)
                expectation.fulfill()
            }
        waitForExpectations(timeout: 5)
    }

    func test_hostPublisher_fail() {
        let expectation = expectation(description: "pass")
        cancellable = NetworkMonitor
            .reachabilityPublisher(forHost: "")
            .map(\.isReachable)
            .removeDuplicates()
            .sink { result in
                expectation.fulfill()
                switch result {
                case let .failure(error):
                    guard let error = error as? NetworkMonitor.Error else {
                        XCTFail()
                        return
                    }
                    guard case .failedToCreate = error else {
                        XCTFail()
                        return
                    }
                case .finished:
                    XCTFail()
                }
            } receiveValue: { _ in
                XCTFail()
            }
        waitForExpectations(timeout: 5)
    }

    func test_standardDelegate() {
        let expectation = expectation(description: "pass")

        final class Delegate: NetworkMonitorDelegate {
            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            let expectation: XCTestExpectation
            func networkMonitor(_ monitor: NetworkMonitor, didUpdateReachability reachability: Reachability) {
                expectation.fulfill()
            }

            func networkMonitor(_ monitor: NetworkMonitor, didFailWithError error: Error) {
                XCTFail()
            }
        }

        let delegate = Delegate(expectation)

        do {
            _ = try NetworkMonitor(delegate: delegate)
            waitForExpectations(timeout: 5)
        } catch {
            XCTFail()
        }
    }

    func test_hostDelegate() {

        final class Delegate: NetworkMonitorDelegate {
            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            let expectation: XCTestExpectation
            func networkMonitor(_ monitor: NetworkMonitor, didUpdateReachability reachability: Reachability) {
                expectation.fulfill()
            }

            func networkMonitor(_ monitor: NetworkMonitor, didFailWithError error: Error) {
                XCTFail()
            }
        }

        let expectation = expectation(description: "pass")
        let delegate = Delegate(expectation)

        do {
            _ = try NetworkMonitor(host: "apple.com",
                                   delegate: delegate)
            waitForExpectations(timeout: 5)
        } catch {
            XCTFail()
        }
    }

    func test_hostDelegate_fail() {

        final class Delegate: NetworkMonitorDelegate {
            init() {}
            func networkMonitor(_ monitor: NetworkMonitor, didUpdateReachability reachability: Reachability) {
                XCTFail()
            }

            func networkMonitor(_ monitor: NetworkMonitor, didFailWithError error: Error) {
                XCTFail()
            }
        }

        let delegate = Delegate()

        do {
            _ = try NetworkMonitor(host: "",
                                   delegate: delegate)
            XCTFail()
        } catch {
            guard let error = error as? NetworkMonitor.Error else {
                XCTFail()
                return
            }
            guard case .failedToCreate = error else {
                XCTFail()
                return
            }
        }
    }

    func test_standardNotification() {
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
                guard let monitor = notification.object as? NetworkMonitor,
                      let reachable = try? monitor.reachability.isReachable,
                      reachable else {
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
        let observer = Observer(expectation)

        do {
            _ = try NetworkMonitor()
            waitForExpectations(timeout: 5)
            print(observer)
        } catch {
            XCTFail()
        }
    }

    func test_hostNotification() {
        final class Observer {

            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
                observe()
            }

            func observe() {
                NotificationCenter.default.addObserver(self, selector: #selector(fulfill(_:)), name: .reachabilityChanged, object: nil)
            }

            @objc
            func fulfill(_ notification: Notification) {
                guard let monitor = notification.object as? NetworkMonitor,
                      let reachable = try? monitor.reachability.isReachable,
                      reachable else {
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
        let observer = Observer(expectation)

        do {
            _ = try NetworkMonitor(host: "apple.com")
            waitForExpectations(timeout: 5)
            print(observer)
        } catch {
            XCTFail()
        }
    }

    func test_hostNotification_fail() {
        final class Observer {

            init() {
                observe()
            }

            func observe() {
                NotificationCenter.default.addObserver(self, selector: #selector(fulfill(_:)), name: .reachabilityChanged, object: nil)
            }

            @objc
            func fulfill(_ notification: Notification) {
                XCTFail()
            }

            deinit {
                NotificationCenter.default.removeObserver(self)
            }
        }

        _ = Observer()

        do {
            _ = try NetworkMonitor(host: "")
            XCTFail()
        } catch {
            guard let error = error as? NetworkMonitor.Error else {
                XCTFail()
                return
            }
            guard case .failedToCreate = error else {
                XCTFail()
                return
            }
        }
    }

    func test_path_async() async {
        let path = await NetworkMonitor.networkPath
        XCTAssertEqual(path.status, .satisfied)
    }

    func test_path_asynchronous_stream() {
        let expectation = expectation(description: "pass")

        Task {
            for await path in NetworkMonitor.networkPathUpdates {
                if path.status == .satisfied {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_path_combine() {
        let expectation = expectation(description: "pass")
        cancellable = NetworkMonitor
            .networkPathPublisher
            .map { path in
                path.status == .satisfied
            }
            .removeDuplicates()
            .sink { isReachable in
                XCTAssertTrue(isReachable)
                expectation.fulfill()
            }
        waitForExpectations(timeout: 5)
    }

    deinit {
        cancellable?.cancel()
    }
}
