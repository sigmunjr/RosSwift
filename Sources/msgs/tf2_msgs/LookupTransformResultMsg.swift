import Foundation
import StdMsgs
import RosTime
import tf2_msgs
import geometry_msgs

extension tf2_msgs {
public struct LookupTransformResult: Message {
public static var md5sum: String = "3fe5db6a19ca9cfb675418c5ad875c36"
public static var datatype = "tf2_msgs/LookupTransformResult"
public static var definition = """
# ====== DO NOT MODIFY! AUTOGENERATED FROM AN ACTION DEFINITION ======
geometry_msgs/TransformStamped transform
tf2_msgs/TF2Error error
"""
public static var hasHeader = false

public var transform: geometry_msgs.TransformStamped
public var error: tf2_msgs.TF2Error

public init(transform: geometry_msgs.TransformStamped, error: tf2_msgs.TF2Error) {
self.transform = transform
self.error = error
}

public init() {
    transform = geometry_msgs.TransformStamped()
error = tf2_msgs.TF2Error()
}

}
}