//
//  Duration.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-03-15.
//

import BinaryCoder
import Foundation


public struct Duration: DurationBase {
    public let nanoseconds: Int64

    public init(nanosec: Int64) {
        nanoseconds = nanosec
    }

    @discardableResult
    public func sleep() -> Bool {
        if !Time.useSimTime {
            return rosWallsleep(sec: UInt32(sec), nsec: UInt32(nsec))
        }

        var start = Time.now()
        var end = start + self
        if start.isZero() {
            end = Time(nanosec: UInt64.max)
        }

        var didSleep = false
        while !Time.gStopped && Time.now() < end {
            _ = rosWallsleep(sec: 0, nsec: 1_000_000)
            didSleep = true
            if start.isZero() {
                start = Time.now()
                end = start + self
            }
            if Time.now() < start {
                return false
            }
        }
        return didSleep && !Time.gStopped
    }

}

public struct WallDuration: DurationBase {
    public var nanoseconds: Int64

    public init(nanosec: Int64) {
        nanoseconds = nanosec
    }

    @discardableResult
    public func sleep() -> Bool {
        return rosWallsleep(sec: UInt32(sec), nsec: UInt32(nsec))
    }

    public static func + (lhs: WallDuration, rhs: WallDuration) -> WallDuration {
        return WallDuration(nanosec: lhs.nanoseconds + rhs.nanoseconds)
    }
}
