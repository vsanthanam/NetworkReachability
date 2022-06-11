// NetworkReachabiliy
// NetworkMonitorRxSwiftTests.swift
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
import Network
import NetworkReachability
@testable import NetworkReachabilityRxSwift
import RxSwift
import XCTest

final class NetworkMonitorRxSwiftTests: XCTestCase {

    var disposable: Disposable?

    func test_observable_path() {
        let expectation = expectation(description: "pass")
        disposable = NetworkMonitor
            .observableNetworkPath
            .map(\.status)
            .subscribe(onNext: { status in
                XCTAssertTrue(status == status)
                expectation.fulfill()
            })
        waitForExpectations(timeout: 5)
    }

    func test_single_path() {
        let expectation = expectation(description: "pass")
        disposable = NetworkMonitor
            .singleNetworkPath
            .map(\.status)
            .subscribe(onSuccess: { status in
                XCTAssertTrue(status == status)
                expectation.fulfill()
            })
        waitForExpectations(timeout: 5)
    }

    deinit {
        disposable?.dispose()
    }

}
