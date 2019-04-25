//
//  TimerTest.swift
//  rosswiftTests
//
//  Created by Thomas Gustafsson on 2019-04-24.
//

import XCTest
@testable import RosSwift
@testable import RosTime

class SteadyTimerHelper {
    var expectedPeriod: WallDuration
    let oneshot: Bool
    var failed = false
    var totalCalls = 0
    var testingPeriod = false
    var callsBeforeTestingPeriod = 0
    var timer: SteadyTimer? = nil
    var lastCall = SteadyTime(nanosec: 0)

    init(_ period: Double, oneshot: Bool = false) {
        self.oneshot = oneshot
        let n = Ros.NodeHandle()
        let d = WallDuration(seconds: period)
        self.expectedPeriod = d
        let tim = n.createSteadyTimer(period: d, trackedObject: self, callback: callback)
        self.timer = tim
    }

    func callback(event: SteadyTimerEvent) {
        let first = lastCall.isZero()
        lastCall = event.currentExpired

        if !first {
            let time_error = event.currentExpired.toSec() - event.currentExpected.toSec()
            if time_error > 5.0 || time_error < -0.01 {
                ROS_ERROR("Call came at wrong time")
                failed = true
            }
        }

        if testingPeriod {
            if totalCalls == callsBeforeTestingPeriod {
                let p = WallDuration(milliseconds: 500)
                pretendWork(0.15)
                setPeriod(p)
            } else if totalCalls == callsBeforeTestingPeriod + 1 {
                let p = WallDuration(milliseconds: 250)
                pretendWork(0.15)
                setPeriod(p)
            } else if totalCalls == callsBeforeTestingPeriod + 2 {
                let p = WallDuration(milliseconds: 500)
                pretendWork(0.15)
                setPeriod(p, reset: true)
            } else if totalCalls == callsBeforeTestingPeriod + 2 {
                let p = WallDuration(milliseconds: 250)
                pretendWork(0.15)
                setPeriod(p, reset: true)
            }
        }

        totalCalls += 1
    }

    func setPeriod(_ p: WallDuration, reset: Bool = false) {
        timer?.setPeriod(period: p, reset: reset)
        expectedPeriod = p
    }

    func pretendWork(_ t: Double) {
        var r = Rate(duration: Duration(seconds: t))
        r.sleep()
    }
}

class TimerTest: XCTestCase {

    override func setUp() {
        _ = Ros.initialize(argv: &CommandLine.arguments, name: "TimerTest")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSingleSteadyTimeCallback() {
        let n = Ros.NodeHandle()

        let helper = SteadyTimerHelper(0.01)
        let d = WallDuration(milliseconds: 1)
        for i in 0..<1000 {
            Ros.spinOnce()
            d.sleep()
        }

        XCTAssertFalse(helper.failed)
        XCTAssertGreaterThan(helper.totalCalls, 99)
    }

    func testMultipleSteadyTimeCallbacks() {
        let n = Ros.NodeHandle()
        let count = 10
        var helpers = [SteadyTimerHelper]()
        helpers.reserveCapacity(count)
        for i in 0..<count {
            let period = Double(i+1)*0.1
            let helper = SteadyTimerHelper(period)
            helpers.append(helper)
        }

        let start = WallTime.now()
        let d = WallDuration(milliseconds: 10)
        let spinCount = 1000
        for i in 0..<spinCount {
            Ros.spinOnce()
            d.sleep()
        }
        let end = WallTime.now()
        let dur = (end - start).toSec()

        for i in 0..<count {
            XCTAssertFalse(helpers[i].failed)

            let expectedCount = Int(dur / helpers[i].expectedPeriod.toSec())
            XCTAssertEqual(helpers[i].totalCalls, expectedCount)
        }
    }


  
}
