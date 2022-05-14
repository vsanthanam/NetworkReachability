//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/14/22.
//

import Foundation

/// A weak reference to an object or actor
final class WeakReference<T: AnyObject> {

    /// Create a weak reference to the provided object instance
    /// - Parameter obj: An instance to weakify
    init(_ obj: T) {
        self.obj = obj
    }

    /// A weak reference to the object
    weak var obj: T?
}

func weak<T: AnyObject>(_ obj: T) -> WeakReference<T> {
    .init(obj)
}
