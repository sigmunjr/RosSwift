import Foundation
import StdMsgs
import RosTime
import actionlib_msgs

extension actionlib_tutorials {
/// ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======
public struct AveragingActionGoal: Message {
public static var md5sum: String = "1561825b734ebd6039851c501e3fb570"
public static var datatype = "actionlib_tutorials/AveragingActionGoal"
public static var definition = """
# ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======

Header header
actionlib_msgs/GoalID goal_id
AveragingGoal goal
"""
public static var hasHeader = false

public var header: std_msgs.header
public var goal_id: actionlib_msgs.GoalID
public var goal: AveragingGoal

public init(header: std_msgs.header, goal_id: actionlib_msgs.GoalID, goal: AveragingGoal) {
self.header = header
self.goal_id = goal_id
self.goal = goal
}

public init() {
    header = std_msgs.header()
goal_id = actionlib_msgs.GoalID()
goal = AveragingGoal()
}

}
}
