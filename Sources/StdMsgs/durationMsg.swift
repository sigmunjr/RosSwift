// Generated by msgbuilder 2019-05-02 08:13:26 +0000

import RosTime

extension std_msgs {
	public struct duration: Message {
		public static let md5sum: String = "3e286caf4241d664e55f3ad380e2ae46"
		public static let datatype = "std_msgs/Duration"
		public static let definition = "duration data"
		public static let hasHeader = false

		public var data: Duration

		public init(_ value: Duration) {
			self.data = value
		}
	}
}