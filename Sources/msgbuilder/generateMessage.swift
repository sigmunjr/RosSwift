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

    var constShortText: String? {
        if let val = value {
            return "\(simpleType) \(name)=\(val)\n"
        } else {
            return nil
        }
    }

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
            return "\tpublic static let \(name): \(fullType) = \(v)"
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

    var variables = [dataItem]()
    let messageType = msg.replacingOccurrences(of: "/", with: ".")

    let dataStr = shell.rosmsg(["info","-r",msg]).trimmingCharacters(in: .whitespacesAndNewlines)
    let data = dataStr.components(separatedBy: .newlines).filter{ $0 != "" }
    let tabbedData = data.joined(separator: "\n\t\t\t")

    for line in data {
        let parts = line.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces).filter { $0 != "" }
        if parts.count > 1 && !parts[0].hasPrefix("#") {
            let structName = parts[0]
            if let eqIndex = parts[1].firstIndex(of: "=") {
                let name = String(parts[1].prefix(upTo: eqIndex))
                let val = String(parts[1].suffix(from: eqIndex).dropFirst())
                variables.append(.init(name: name, type: structName, value: val))
            } else {
                let name = parts[1]
                if parts.count > 2 && parts[2] == "=" {
                    variables.append(.init(name: name, type: structName, value: parts[3]))
                } else {
                    variables.append(.init(name: name,type: structName))
                }
            }
        }
    }

    let decl = variables.map{$0.declaration}.joined(separator: "\n\t")

    let constText = variables.compactMap { $0.constShortText }


    let cleanDef = dataStr.components(separatedBy: .newlines).filter { !$0.hasPrefix("#") }.joined(separator: "/n")
    let md5sum = cleanDef.hashed()!
    let md5sum2 = String(shell.rosmsg(["md5",msg]).trimmingCharacters(in: .whitespacesAndNewlines))
    assert(md5sum == md5sum2)
    let arguments = variables.compactMap{$0.argument}.joined(separator: ", ")
    let initCode = variables.compactMap{$0.initCode}.joined(separator: "\n\t")
    let codeInit = variables.compactMap{$0.codeInit}.joined(separator: "\n\t")
    let path = messageType.components(separatedBy: ".")
    let modules = Set(variables.compactMap{$0.module})
    let importModules = modules.map{"import \($0)"}.joined(separator: "\n")
    let hasHeader = variables.contains { $0.simpleType == "std_msgs.header" }

    let comments = data.filter{ $0.starts(with: "#") }
        .joined(separator: "\n")
        .replacingOccurrences(of: "##", with: "\t///")
        .replacingOccurrences(of: "#", with: "\t///")
    var argInit = ""
    if !arguments.isEmpty {
        argInit = """
        \t\tpublic init(\(arguments)) {
        \t\(initCode)
        \t\t}
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
    \t\tpublic static var md5sum: String = "\(md5sum)"
    \t\tpublic static var datatype = "\(msg)"
    \t\tpublic static var definition = \"\"\"
    \t\t\t\(tabbedData)
    \t\t\t\"\"\"

    \t\tpublic static let hasHeader = \(hasHeader)

    \t\(decl)

    \(argInit)

    \t\tpublic init() {
    \t\(codeInit)
    \t\t}
    \t}
    }
    """
    let file = "Sources/msgs/\(messageType.replacingOccurrences(of: ".", with: "/"))Msg.swift"
    print("writing to \(file)" )
    try? code.write(toFile: file, atomically: false, encoding: .utf8)

}





/// Split a name into its package and resource name parts, e.g. 'std_msgs/String -> std_msgs, String'
///
/// - Parameters:
///     - name: package resource name, e.g. 'std_msgs/String'
/// - Returns: package name, resource name

func package_resource_name(name: String) -> (package: String, name: String)? {
    if name.contains("/") {
        let val = name.components(separatedBy: "/")
        if val.count != 2 {
            return nil
        } else {
            return (val[0], val[1])
        }
    }
    return ("", name)
}

extension MsgSpec {

    func generateMessage(context: MsgContext) {


        let messageType = full_name.replacingOccurrences(of: "/", with: ".")
        let data = text.components(separatedBy: .newlines).filter{ $0 != "" }
        let tabbedData = data.joined(separator: "\n\t\t\t")

        let decl = variables.map{ $0.declaration(in: package) }.joined(separator: "\n\t")

        guard let md5sum = compute_md5(msg_context: context) else {
            print("Could not compute md5 for \(full_name)")
            return
        }

        let arguments = variables.compactMap{$0.argument(in: package)}.joined(separator: ", ")
        let initCode = variables.compactMap{$0.initCode}.joined(separator: "\n\t")
        let codeInit = variables.compactMap{$0.codeInit(in: package)}.joined(separator: "\n\t")
        let path = messageType.components(separatedBy: ".")
        var modules = Set(variables.compactMap{$0.module})
        modules.remove(package)
        modules.remove("std_msgs")
        let importModules = modules.map{"import \($0)"}.joined(separator: "\n")
        let hasHeader = variables.contains { $0.simpleType == "std_msgs.header" }

        let comments = data.filter{ $0.starts(with: "#") }
            .joined(separator: "\n")
            .replacingOccurrences(of: "##", with: "\t///")
            .replacingOccurrences(of: "#", with: "\t///")
        var argInit = ""
        if !arguments.isEmpty {
            argInit = """
            \t\tpublic init(\(arguments)) {
            \t\(initCode)
            \t\t}
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
        \t\tpublic static var md5sum: String = "\(md5sum)"
        \t\tpublic static var datatype = "\(full_name)"
        \t\tpublic static var definition = \"\"\"
        \t\t\t\(tabbedData)
        \t\t\t\"\"\"

        \t\tpublic static let hasHeader = \(hasHeader)

        \t\(decl)

        \(argInit)

        \t\tpublic init() {
        \t\(codeInit)
        \t\t}
        \t}
        }
        """
        let file = "Sources/msgs/\(messageType.replacingOccurrences(of: ".", with: "/"))Msg.swift"
        print("writing to \(file)" )
        try? code.write(toFile: file, atomically: false, encoding: .utf8)

    }


}
