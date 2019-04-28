import Foundation


let types = ["int8": "Int8",
             "int16": "Int16",
             "int32": "Int32",
             "int64": "Int64",
             "uint8": "UInt8",
             "uint16": "UInt16",
             "uint32": "UInt32",
             "uint64": "UInt64",
             "string": "String",
             "byte": "Int8",
             "char": "UInt8",
             "duration": "Duration",
             "time": "Time",
             "bool": "Bool",
             "float32": "Float32",
             "float64": "Float64",
             "empty": "Empty",
             "Header": "std_msgs.header"]


func generateStdMsg(shell: Shell, msg: String) {

    let data = shell.rosmsg(["info",msg]).trimmingCharacters(in: .whitespacesAndNewlines)

    let parts = data.components(separatedBy: .whitespaces)
    let structName = parts[0] == "" ? "empty" : parts[0]
    let type = types[structName]!
    let name = parts.count > 1 ? String(parts[1]) : "data"
    let decl = "public var \(name): \(type)"
    let md5sum = String(data).hashed() ?? "*"

    let code = """
    import Foundation
    import RosTime

    extension std_msgs {
    \tpublic struct \(structName): Message {
    \t\t\(decl)
    \t\tpublic static var md5sum: String = "\(md5sum)"
    \t\tpublic static var datatype = "\(msg)"
    \t\tpublic static var definition = "\(data)"
    \t\tpublic static var hasHeader = false

    \t\tpublic init(_ value: \(type)) {
    \t\t\tself.\(name) = value
    \t\t}

    \t}
    }
    """

    let file = "Sources/StdMsgs/\(structName)Msg.swift"
    print("writing to \(file)" )
    try? code.write(toFile: file, atomically: false, encoding: .utf8)
}

