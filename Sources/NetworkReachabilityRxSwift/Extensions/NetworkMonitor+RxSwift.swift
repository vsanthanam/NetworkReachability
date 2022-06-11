// NetworkReachabiliy
// NetworkMonitor+RxSwift.swift
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
import RxSwift

@available(macOS 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
public extension NetworkMonitor {

    static var observableNetworkPath: Observable<NWPath> {
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            return Observable
                .create { observer in
                    let task = Task {
                        for await path in NetworkMonitor.networkPathUpdates {
                            observer.on(.next(path))
                        }
                        observer.on(.completed)
                    }
                    return Disposables.create {
                        task.cancel()
                    }
                }
        } else {
            return Observable
                .create { subscriber in
                    let queue = DispatchQueue.networkMonitorQueue
                    _ = NetworkMonitor { _, path in
                        queue.async {
                            subscriber.on(.next(path))
                        }
                    }
                    return Disposables.create()
                }
        }
    }

    static func observableNetworkPath(requiringInterfaceType interfaceType: NWInterface.InterfaceType) -> Observable<NWPath> {
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            return Observable
                .create { observer in
                    let task = Task {
                        for await path in NetworkMonitor.networkPathUpdates(requiringInterfaceType: interfaceType) {
                            observer.on(.next(path))
                        }
                    }
                    return Disposables.create {
                        task.cancel()
                    }
                }
        } else {
            return Observable
                .create { subscriber in
                    let queue = DispatchQueue.networkMonitorQueue
                    _ = NetworkMonitor(requiredInterfaceType: interfaceType) { _, path in
                        queue.async {
                            subscriber.on(.next(path))
                        }
                    }
                    return Disposables.create()
                }
        }
    }

    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    static func observableNetworkPath(prohibitingInterfaceTypes interfaceTypes: [NWInterface.InterfaceType]) -> Observable<NWPath> {
        Observable
            .create { observer in
                let task = Task {
                    for await path in NetworkMonitor.networkPathUpdates(prohibitingInterfaceTypes: interfaceTypes) {
                        observer.on(.next(path))
                    }
                }
                return Disposables.create {
                    task.cancel()
                }
            }
    }

    static var singleNetworkPath: Single<NWPath> {
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            return Single
                .create { observer in
                    let task = Task {
                        let path = await NetworkMonitor.networkPath
                        observer(.success(path))
                    }
                    return Disposables.create {
                        task.cancel()
                    }
                }
        } else {
            return Single
                .create { observer in
                    NetworkMonitor.networkPath { path in
                        observer(.success(path))
                    }
                    return Disposables.create()
                }
        }
    }

}
