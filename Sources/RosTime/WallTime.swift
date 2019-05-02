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

    public static var now: WallTime {
        let time = rosWalltime()
        return WallTime(sec: time.sec, nsec: time.nsec)
    }
}
