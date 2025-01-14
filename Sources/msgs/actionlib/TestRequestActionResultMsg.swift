import Foundation
import StdMsgs
import RosTime
import actionlib_msgs

extension actionlib {
/// ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======
public struct TestRequestActionResult: Message {
public static var md5sum: String = "0476d1fdf437a3a6e7d6d0e9f5561298"
public static var datatype = "actionlib/TestRequestActionResult"
public static var definition = """
# ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======

Header header
actionlib_msgs/GoalStatus status
TestRequestResult result
"""
public static var hasHeader = false

public var header: std_msgs.header
public var status: actionlib_msgs.GoalStatus
public var result: TestRequestResult

public init(header: std_msgs.header, status: actionlib_msgs.GoalStatus, result: TestRequestResult) {
self.header = header
self.status = status
self.result = result
}

public init() {
    header = std_msgs.header()
status = actionlib_msgs.GoalStatus()
result = TestRequestResult()
}

}
}
