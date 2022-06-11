// NetworkReachabiliy
// ReachabilityMonitor+RxSwift.swift
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
import NetworkReachability
import RxSwift

public extension ReachabilityMonitor {

    static var observableReachability: Observable<Reachability> {
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            return Observable
                .create { observer in
                    let task = Task {
                        do {
                            for try await reachability in ReachabilityMonitor.reachabilityUpdates {
                                observer.on(.next(reachability))
                            }
                            observer.on(.completed)
                        } catch {
                            observer.on(.error(error))
                        }
                    }
                    return Disposables.create {
                        task.cancel()
                    }
                }
        } else {
            return Observable
                .create { observer in
                    do {
                        _ = try ReachabilityMonitor { _, result in
                            do {
                                let reachability = try result.get()
                                observer.on(.next(reachability))
                            } catch {
                                observer.on(.error(error))
                            }
                        }
                    } catch {
                        observer.on(.error(error))
                    }
                    return Disposables.create()
                }
        }
    }

    static var singleReachability: Single<Reachability> {
        Single.create { observer in
            do {
                let reachability = try ReachabilityMonitor.reachability
                observer(.success(reachability))
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }

}
