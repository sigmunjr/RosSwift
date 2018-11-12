import Foundation
import StdMsgs
import RosTime


extension sensor_msgs {
public struct BatteryState: Message {
public static var md5sum: String = "476f837fa6771f6e16e3bf4ef96f8770"
public static var datatype = "sensor_msgs/BatteryState"
public static var definition = """
# Constants are chosen to match the enums in the linux kernel
# defined in include/linux/power_supply.h as of version 3.7
# The one difference is for style reasons the constants are
# all uppercase not mixed case.

# Power supply status constants
uint8 POWER_SUPPLY_STATUS_UNKNOWN = 0
uint8 POWER_SUPPLY_STATUS_CHARGING = 1
uint8 POWER_SUPPLY_STATUS_DISCHARGING = 2
uint8 POWER_SUPPLY_STATUS_NOT_CHARGING = 3
uint8 POWER_SUPPLY_STATUS_FULL = 4

# Power supply health constants
uint8 POWER_SUPPLY_HEALTH_UNKNOWN = 0
uint8 POWER_SUPPLY_HEALTH_GOOD = 1
uint8 POWER_SUPPLY_HEALTH_OVERHEAT = 2
uint8 POWER_SUPPLY_HEALTH_DEAD = 3
uint8 POWER_SUPPLY_HEALTH_OVERVOLTAGE = 4
uint8 POWER_SUPPLY_HEALTH_UNSPEC_FAILURE = 5
uint8 POWER_SUPPLY_HEALTH_COLD = 6
uint8 POWER_SUPPLY_HEALTH_WATCHDOG_TIMER_EXPIRE = 7
uint8 POWER_SUPPLY_HEALTH_SAFETY_TIMER_EXPIRE = 8

# Power supply technology (chemistry) constants
uint8 POWER_SUPPLY_TECHNOLOGY_UNKNOWN = 0
uint8 POWER_SUPPLY_TECHNOLOGY_NIMH = 1
uint8 POWER_SUPPLY_TECHNOLOGY_LION = 2
uint8 POWER_SUPPLY_TECHNOLOGY_LIPO = 3
uint8 POWER_SUPPLY_TECHNOLOGY_LIFE = 4
uint8 POWER_SUPPLY_TECHNOLOGY_NICD = 5
uint8 POWER_SUPPLY_TECHNOLOGY_LIMN = 6

Header  header
float32 voltage          # Voltage in Volts (Mandatory)
float32 current          # Negative when discharging (A)  (If unmeasured NaN)
float32 charge           # Current charge in Ah  (If unmeasured NaN)
float32 capacity         # Capacity in Ah (last full capacity)  (If unmeasured NaN)
float32 design_capacity  # Capacity in Ah (design capacity)  (If unmeasured NaN)
float32 percentage       # Charge percentage on 0 to 1 range  (If unmeasured NaN)
uint8   power_supply_status     # The charging status as reported. Values defined above
uint8   power_supply_health     # The battery health metric. Values defined above
uint8   power_supply_technology # The battery chemistry. Values defined above
bool    present          # True if the battery is present

float32[] cell_voltage   # An array of individual cell voltages for each cell in the pack
                         # If individual voltages unknown but number of cells known set each to NaN
string location          # The location into which the battery is inserted. (slot number or plug)
string serial_number     # The best approximation of the battery serial number
"""
public static var hasHeader = false

public let POWER_SUPPLY_STATUS_UNKNOWN : UInt8 = 0
public let POWER_SUPPLY_STATUS_CHARGING : UInt8 = 1
public let POWER_SUPPLY_STATUS_DISCHARGING : UInt8 = 2
public let POWER_SUPPLY_STATUS_NOT_CHARGING : UInt8 = 3
public let POWER_SUPPLY_STATUS_FULL : UInt8 = 4
public let POWER_SUPPLY_HEALTH_UNKNOWN : UInt8 = 0
public let POWER_SUPPLY_HEALTH_GOOD : UInt8 = 1
public let POWER_SUPPLY_HEALTH_OVERHEAT : UInt8 = 2
public let POWER_SUPPLY_HEALTH_DEAD : UInt8 = 3
public let POWER_SUPPLY_HEALTH_OVERVOLTAGE : UInt8 = 4
public let POWER_SUPPLY_HEALTH_UNSPEC_FAILURE : UInt8 = 5
public let POWER_SUPPLY_HEALTH_COLD : UInt8 = 6
public let POWER_SUPPLY_HEALTH_WATCHDOG_TIMER_EXPIRE : UInt8 = 7
public let POWER_SUPPLY_HEALTH_SAFETY_TIMER_EXPIRE : UInt8 = 8
public let POWER_SUPPLY_TECHNOLOGY_UNKNOWN : UInt8 = 0
public let POWER_SUPPLY_TECHNOLOGY_NIMH : UInt8 = 1
public let POWER_SUPPLY_TECHNOLOGY_LION : UInt8 = 2
public let POWER_SUPPLY_TECHNOLOGY_LIPO : UInt8 = 3
public let POWER_SUPPLY_TECHNOLOGY_LIFE : UInt8 = 4
public let POWER_SUPPLY_TECHNOLOGY_NICD : UInt8 = 5
public let POWER_SUPPLY_TECHNOLOGY_LIMN : UInt8 = 6
public var header: std_msgs.header
public var voltage: Float32
public var current: Float32
public var charge: Float32
public var capacity: Float32
public var design_capacity: Float32
public var percentage: Float32
public var power_supply_status: UInt8
public var power_supply_health: UInt8
public var power_supply_technology: UInt8
public var present: Bool
public var cell_voltage: [Float32]
public var location: String
public var serial_number: String

public init(header: std_msgs.header, voltage: Float32, current: Float32, charge: Float32, capacity: Float32, design_capacity: Float32, percentage: Float32, power_supply_status: UInt8, power_supply_health: UInt8, power_supply_technology: UInt8, present: Bool, cell_voltage: [Float32], location: String, serial_number: String) {
self.header = header
self.voltage = voltage
self.current = current
self.charge = charge
self.capacity = capacity
self.design_capacity = design_capacity
self.percentage = percentage
self.power_supply_status = power_supply_status
self.power_supply_health = power_supply_health
self.power_supply_technology = power_supply_technology
self.present = present
self.cell_voltage = cell_voltage
self.location = location
self.serial_number = serial_number
}

public init() {
    header = std_msgs.header()
voltage = Float32()
current = Float32()
charge = Float32()
capacity = Float32()
design_capacity = Float32()
percentage = Float32()
power_supply_status = UInt8()
power_supply_health = UInt8()
power_supply_technology = UInt8()
present = Bool()
cell_voltage = [Float32]()
location = String()
serial_number = String()
}

}
}