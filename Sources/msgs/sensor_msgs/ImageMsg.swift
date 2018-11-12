import Foundation
import StdMsgs
import RosTime


extension sensor_msgs {
public struct Image: Message {
public static var md5sum: String = "060021388200f6f0f447d0fcd9c64743"
public static var datatype = "sensor_msgs/Image"
public static var definition = """
# This message contains an uncompressed image
# (0, 0) is at top-left corner of image
#

Header header        # Header timestamp should be acquisition time of image
                     # Header frame_id should be optical frame of camera
                     # origin of frame should be optical center of cameara
                     # +x should point to the right in the image
                     # +y should point down in the image
                     # +z should point into to plane of the image
                     # If the frame_id here and the frame_id of the CameraInfo
                     # message associated with the image conflict
                     # the behavior is undefined

uint32 height         # image height, that is, number of rows
uint32 width          # image width, that is, number of columns

# The legal values for encoding are in file src/image_encodings.cpp
# If you want to standardize a new string format, join
# ros-users@lists.sourceforge.net and send an email proposing a new encoding.

string encoding       # Encoding of pixels -- channel meaning, ordering, size
                      # taken from the list of strings in include/sensor_msgs/image_encodings.h

uint8 is_bigendian    # is this data bigendian?
uint32 step           # Full row length in bytes
uint8[] data          # actual matrix data, size is (step * rows)
"""
public static var hasHeader = false

public var header: std_msgs.header
public var height: UInt32
public var width: UInt32
public var encoding: String
public var is_bigendian: UInt8
public var step: UInt32
public var data: [UInt8]

public init(header: std_msgs.header, height: UInt32, width: UInt32, encoding: String, is_bigendian: UInt8, step: UInt32, data: [UInt8]) {
self.header = header
self.height = height
self.width = width
self.encoding = encoding
self.is_bigendian = is_bigendian
self.step = step
self.data = data
}

public init() {
    header = std_msgs.header()
height = UInt32()
width = UInt32()
encoding = String()
is_bigendian = UInt8()
step = UInt32()
data = [UInt8]()
}

}
}