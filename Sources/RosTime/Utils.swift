//
//  TimeUtils.swift
//  RosTime
//
//  Created by Thomas Gustafsson on 2019-04-24.
//

import Foundation

func rosWalltime() -> (sec: UInt32, nsec: UInt32) {
    var start = timespec()
    clock_gettime(CLOCK_REALTIME, &start)
    return (UInt32(start.tv_sec), UInt32(start.tv_nsec))
}

func rosWallsleep(sec: UInt32, nsec: UInt32) -> Bool {
    var req = timespec(tv_sec: Int(sec), tv_nsec: Int(nsec))
    var rem = timespec(tv_sec: 0, tv_nsec: 0)
    while nanosleep(&req, &rem) != 0 && !Time.gStopped {
        req = rem

    }
    return !Time.gStopped
}

func normalizeSecNSec(_ sec: inout UInt64, _ nsec: inout UInt64) {
    let nsecPart = nsec % 1_000_000_000
    let secPart = nsec / 1_000_000_000

    if sec + secPart > UInt32.max {
        sec = UInt64(UInt32.max)
        nsec = 0
    } else {
        sec += secPart
        nsec = nsecPart
    }
}

func normalizeSecNSec(_ sec: inout UInt32, _ nsec: inout UInt32) {
    var sec64 = UInt64(sec)
    var nsec64 = UInt64(nsec)

    normalizeSecNSec(&sec64, &nsec64)

    sec = UInt32(sec64)
    nsec = UInt32(nsec64)
}

func normalizeSecNSecSigned(_ sec: inout Int64, _ nsec: inout Int64) {
    var nsecPart = nsec % 1000000000
    var secPart = sec + nsec / 1000000000
    if nsecPart < 0 {
        nsecPart += 1000000000
        secPart -= 1
    }

    if secPart < Int32.min || secPart > Int32.max {
        fatalError("normalizeSecNSecSigned of \(sec):\(nsec) failed")
    }

    sec = secPart
    nsec = nsecPart
}

func normalizeSecNSecSigned(_ sec: inout Int32, _ nsec: inout Int32) {
    var sec64 = Int64(sec)
    var nsec64 = Int64(nsec)

    normalizeSecNSecSigned(&sec64, &nsec64)

    sec = Int32(sec64)
    nsec = Int32(nsec64)
}
