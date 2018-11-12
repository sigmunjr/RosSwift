import Foundation
import StdMsgs
import RosTime
import actionlib_msgs

extension actionlib {
public struct TwoIntsActionFeedback: Message {
public static var md5sum: String = "aae20e09065c3809e8a8e87c4c8953fd"
public static var datatype = "actionlib/TwoIntsActionFeedback"
public static var definition = """
# ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======

Header header
actionlib_msgs/GoalStatus status
TwoIntsFeedback feedback
"""
public static var hasHeader = false

public var header: std_msgs.header
public var status: actionlib_msgs.GoalStatus
public var feedback: TwoIntsFeedback

public init(header: std_msgs.header, status: actionlib_msgs.GoalStatus, feedback: TwoIntsFeedback) {
self.header = header
self.status = status
self.feedback = feedback
}

public init() {
    header = std_msgs.header()
status = actionlib_msgs.GoalStatus()
feedback = TwoIntsFeedback()
}

}
}