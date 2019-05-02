// Generated by msgbuilder 2019-05-02 07:55:41 +0000

import StdMsgs

extension geometry_msgs {
	/// This represents an orientation with reference coordinate frame and timestamp.
	public struct QuaternionStamped: Message {
		public static let md5sum: String = "e57f1e547e0e1fd13504588ffc8334e2"
		public static let datatype = "geometry_msgs/QuaternionStamped"
		public static let definition = """
			# This represents an orientation with reference coordinate frame and timestamp.
			Header header
			Quaternion quaternion
			"""

		public static let hasHeader = true

	
		public var header: std_msgs.Header
		public var quaternion: Quaternion

		public init(header: std_msgs.Header, quaternion: Quaternion) {
			self.header = header
			self.quaternion = quaternion
		}

		public init() {
			header = std_msgs.Header()
			quaternion = Quaternion()
		}
	}
}