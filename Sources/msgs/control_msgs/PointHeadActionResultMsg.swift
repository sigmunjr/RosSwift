import Foundation
import StdMsgs
import RosTime
import actionlib_msgs

extension control_msgs {
/// ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======
public struct PointHeadActionResult: Message {
public static var md5sum: String = "1eb06eeff08fa7ea874431638cb52332"
public static var datatype = "control_msgs/PointHeadActionResult"
public static var definition = """
# ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======

Header header
actionlib_msgs/GoalStatus status
PointHeadResult result
"""
public static var hasHeader = false

public var header: std_msgs.header
public var status: actionlib_msgs.GoalStatus
public var result: PointHeadResult

public init(header: std_msgs.header, status: actionlib_msgs.GoalStatus, result: PointHeadResult) {
self.header = header
self.status = status
self.result = result
}

public init() {
    header = std_msgs.header()
status = actionlib_msgs.GoalStatus()
result = PointHeadResult()
}

}
}
