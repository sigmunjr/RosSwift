//
//  WallTime.swift
//  RosTime
//
//  Created by Thomas Gustafsson on 2019-04-24.
//

import Foundation


public struct WallTime: TimeBase {
    public var nanoseconds: UInt64

    public init(nanosec: UInt64) {
        nanoseconds = nanosec
    }


    public static func now() -> WallTime {
        let time = rosWalltime()
        return WallTime(sec: time.sec, nsec: time.nsec)
    }

//    public static func + (lhs: WallTime, rhs: WallDuration) -> WallTime {
//        return WallTime(nanosec: lhs.toNSec() + UInt64(rhs.toNSec()))
//    }
//
//    public static func - (lhs: WallTime, rhs: WallTime) -> WallDuration {
//        return WallDuration(nanosec: Int64(lhs.toNSec()) - Int64(rhs.toNSec()))
//    }

}
