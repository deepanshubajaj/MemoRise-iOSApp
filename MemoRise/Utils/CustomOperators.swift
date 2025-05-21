//
//  CustomOperators.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import Foundation
import SwiftUI

public func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
