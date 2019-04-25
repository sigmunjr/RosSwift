//
//  TimeBase.swift
//  RosTime
//
//  Created by Thomas Gustafsson on 2019-04-24.
//

import BinaryCoder
import Foundation

/// Protocol for Time implementations. Provides common functions and
/// operator overloads.


public protocol TimeBase: Comparable, BinaryCodable {

    var nanoseconds: UInt64 {get}
    var sec: UInt32 { get }
    var nsec: UInt32 { get }
    init()
    init(sec: UInt32, nsec: UInt32)
    init(seconds: TimeInterval)
    init(nanosec: UInt64)
    func isZero() -> Bool
    func toNSec() -> UInt64
    func toSec() -> TimeInterval
    static func isSystemTime() -> Bool
    static func now() -> Self
    static func distantFuture() -> Self
}

public extension TimeBase {

    var sec: UInt32 {
        return UInt32(nanoseconds / 1_000_000_000)
    }

    var nsec: UInt32 {
        return UInt32(nanoseconds % 1_000_000_000)
    }

    init() {
        self.init(nanosec: 0)
    }

    init(sec: UInt32, nsec: UInt32) {
        let nano = UInt64(sec) * 1_000_000_000 + UInt64(nsec)
        self.init(nanosec: nano)
    }

    init(seconds: TimeInterval) {
        let nano = UInt64( floor(seconds * 1_000_000_000) )
        self.init(nanosec: nano)
    }

    func isZero() -> Bool {
        return nanoseconds == 0
    }

    func toNSec() -> UInt64 {
        return nanoseconds
    }

    func toSec() -> TimeInterval {
        return TimeInterval(nanoseconds) * 1e-9
    }

    static func isSystemTime() -> Bool {
        return true
    }


    static func += (lhs: inout Self, rhs: BasicDurationBase) {
        lhs = lhs + rhs
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.nanoseconds < rhs.nanoseconds
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.nanoseconds == rhs.nanoseconds
    }

    static func distantFuture() -> Self {
        return Self(nanosec: UInt64.max)
    }

    static func + (lhs: Self, rhs: BasicDurationBase) -> Self {
        return Self(nanosec: UInt64(Int64(lhs.toNSec()) + rhs.toNSec()))
    }

    static func - (lhs: Self, rhs: Self) -> WallDuration {
        return WallDuration(nanosec: Int64(lhs.toNSec()) - Int64(rhs.toNSec()))
    }
}
