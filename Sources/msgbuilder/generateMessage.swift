//
//  generateMessage.swift
//  msgbuilder
//
//  Created by Thomas Gustafsson on 2019-04-27.
//

import Foundation

struct dataItem {
    let name : String
    let simpleType : String
    let builtin : Bool
    let array : Bool
    let fixedArraySize : Int?
    let module : String?
    let value : String?
    var type : String {
        if array {
            return "[" + simpleType + "]"
        }
        return simpleType
    }

    var fullType: String {
        if let m = module {
            return m + "." + type
        }
        return type
    }

    var initCode: String? {
        return value == nil ? "\t\tself.\(name) = \(name)" : nil
    }

    var argument: String? {
        return value == nil ?  "\(name): \(fullType)" : nil
    }

    var codeInit: String? {
        return value == nil ?  "\t\t\(name) = \(fullType)()" : nil
    }

    var declaration: String {
        if let v = value {
            return "\tpublic let \(name): \(fullType) = \(v)"
        }
        return "\tpublic var \(name): \(fullType)"
    }

    init(name: String, type: String, value: String? = nil) {
        var isArray = false
        var isBuiltin = false
        var fixedArraySize : Int?
        let parts = type.components(separatedBy: "/")
        var t = parts.last!
        module = parts.count > 1 ? parts.first : nil
        if t.hasSuffix("[]") {
            t = String(t.dropLast(2))
            isArray = true
        } else if t.hasSuffix("]") {
            if let index = t.firstIndex(of: "[") {
                let arraySizeStr = t.suffix(from: index).dropLast().dropFirst()
                if let arraySize = Int(arraySizeStr) {
                    fixedArraySize = arraySize
                    isArray = true
                }
                t = String(t.prefix(upTo: index))
            }
        }
        if let typ = types[t] {
            t = typ
            isBuiltin = true
        }
        self.array = isArray
        self.name = name
        self.simpleType = t
        self.builtin = isBuiltin
        self.value = value
        self.fixedArraySize = fixedArraySize
    }
}

func generateMessage(shell: Shell, msg: String) {
    var items = [dataItem]()
    let messageType = msg.replacingOccurrences(of: "/", with: ".")

    let dataStr = shell.rosmsg(["info","-r",msg]).trimmingCharacters(in: .whitespacesAndNewlines)
    let data = dataStr.components(separatedBy: .newlines).filter{ $0 != "" }
    let tabbedData = data.joined(separator: "\n\t\t")

    for line in data {
        let parts = line.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).filter { $0 != "" }
        if parts.count > 1 && !parts[0].hasPrefix("#") {
            let structName = parts[0]
            if let eqIndex = parts[1].firstIndex(of: "=") {
                let name = String(parts[1].prefix(upTo: eqIndex))
                let val = String(parts[1].suffix(from: eqIndex).dropFirst())
                items.append(.init(name: name, type: structName, value: val))
            } else {
                let name = parts[1]
                if parts.count > 2 && parts[2] == "=" {
                    items.append(.init(name: name, type: structName, value: parts[3]))
                } else {
                    items.append(.init(name: name,type: structName))
                }
            }
        }
    }

    let decl = items.map{$0.declaration}.joined(separator: "\n")
    let md5sum = String(shell.rosmsg(["md5",msg]).trimmingCharacters(in: .whitespacesAndNewlines))
    let arguments = items.compactMap{$0.argument}.joined(separator: ", ")
    let initCode = items.compactMap{$0.initCode}.joined(separator: "\n")
    let codeInit = items.compactMap{$0.codeInit}.joined(separator: "\n")
    let path = messageType.components(separatedBy: ".")
    let modules = Set(items.compactMap{$0.module})
    let importModules = modules.map{"import \($0)"}.joined(separator: "\n")
    let hasHeader = "false"  // Some logic here...

    let comments = data.filter{ $0.starts(with: "#") }
        .joined(separator: "\n")
        .replacingOccurrences(of: "#", with: "\t///")
    var argInit = ""
    if !arguments.isEmpty {
        argInit = """
        \tpublic init(\(arguments)) {
        \(initCode)
        \t}
        """
    }

    let code = """
    import Foundation
    import StdMsgs
    import RosTime
    \(importModules)

    extension \(path.dropLast().joined(separator: ".")) {
    \(comments)
    \tpublic struct \(path.last!): Message {
    \tpublic static var md5sum: String = "\(md5sum)"
    \tpublic static var datatype = "\(msg)"
    \tpublic static var definition = \"\"\"
    \t\t\(tabbedData)
    \t\t\"\"\"
    \tpublic static var hasHeader = \(hasHeader)

    \(decl)

    \(argInit)

    \tpublic init() {
    \(codeInit)
    \t}

    }
    }
    """
    let file = "Sources/msgs/\(messageType.replacingOccurrences(of: ".", with: "/"))Msg.swift"
    print("writing to \(file)" )
    try? code.write(toFile: file, atomically: false, encoding: .utf8)

}
