//
//  msg_loader.swift
//  msgbuilder
//
//  Created by Thomas Gustafsson on 2019-04-29.
//

import Foundation


struct Package {
    let name: String
    let path: String
    let messages: [Message]
}

struct MessageType {
    let package: Package
}


struct Message {
    let type: MessageType
    let name: String
    let file: String
    let isArray: Bool
    let arraySize: Int
}


class MsgContext {
    var registered: [String: [String: MsgSpec] ]
    var files: [String: String]
    var dependencies: [String: [MsgSpec]]

    init() {
        registered = [:]
        files = [:]
        dependencies = [:]
    }

    func register(full_msg_type: String, msgspec: MsgSpec) {
        if let (package, base_type) = package_resource_name(name: bare_msg_type(full_msg_type)) {
            if var pack = registered[package] {
                pack.updateValue(msgspec, forKey: base_type)
                registered[package] = pack
            } else {
                registered.updateValue([base_type: msgspec], forKey: package)
            }
        }
    }

    func get_registered(msg_type: String) -> MsgSpec? {
        let full_msg_type = bare_msg_type(msg_type)
        guard let (package, base_type) = package_resource_name(name: full_msg_type) else {
            return nil
        }
        return registered[package]?[base_type]
    }

    func is_registered(_ msg_type: String) -> Bool {
        let full_type = bare_msg_type(msg_type)
        if let (package, base_type) = package_resource_name(name: full_type) {
            return registered[package]?.keys.contains(base_type) ?? false
        }
        return false
    }

    func set_depends(full_msg_type: String, dependencies: [MsgSpec]) {
        self.dependencies[full_msg_type] = dependencies
    }

    func get_depends(full_msg_type: String) -> [MsgSpec]? {
        return dependencies[full_msg_type]
    }

    func set_file(full_msg_type: String, file_path: String) {
        files[full_msg_type] = file_path
    }

    func get_file(full_msg_type: String) -> String? {
        return files[full_msg_type]
    }
}

func strip_comments(_ orig: String) -> String {
    return orig.components(separatedBy: "#").first ?? ""
}

func load_msg_from_file(msg_context: MsgContext, file_path: String, full_name: String) -> MsgSpec? {
    guard let content = try? String(contentsOfFile: file_path) else {
        return nil
    }

    return MsgSpec(msg_context: msg_context, text: content, full_name: full_name)

}


func load_field_line(orig_line: String, package_context: String) -> (field_type: String, name: String)? {
    let clean_line = strip_comments(orig_line).trimmingCharacters(in: .whitespaces)
    let line_splits = clean_line.components(separatedBy: " ").filter { !$0.isEmpty }
    guard line_splits.count == 2 else {
        print("Invalid declaration: \(orig_line)")
        return nil
    }
    var field_type = line_splits[0]
    let name = line_splits[1]
    guard is_valid_msg_field_name(name) else {
        print("\(name) is not a legal message field name")
        return nil
    }
    guard is_valid_msg_type(field_type) else {
        print("\(field_type) is not a legal message field type")
        return nil
    }
    if !package_context.isEmpty && !field_type.contains("/") {
        if field_type == HEADER {
            field_type = HEADER_FULL_NAME
        } else if !is_builtin(bare_msg_type(field_type)) {
            field_type = "\(package_context)/\(field_type)"
        }
    } else if field_type == HEADER {
        field_type = HEADER_FULL_NAME
    }
    return (field_type, name)

}

func load_constant_line(line: String) -> Constant? {
    let clean_line = strip_comments(line)
    let line_splits = clean_line.components(separatedBy: " ").filter { !$0.isEmpty }
    let field_type = line_splits[0]
    var name = ""
    var val = ""
    guard is_valid_constant_type(field_type) else {
        print("\(field_type) is not a legal constant type")
        return nil
    }
    if field_type == "string" {
        let idx = line.firstIndex(of: "=")!
        name = String(line.prefix(upTo: idx))
        val = String(line.suffix(from: idx).dropFirst())
    } else {
        let splits = line_splits
                .dropFirst()
                .map{ $0.trimmingCharacters(in: .whitespaces)}
                .joined(separator: " ")
                .components(separatedBy: "=")
        guard splits.count == 2 else {
            print("Invalid constant declaration: \(line)")
            return nil
        }
        name = splits[0]
        val = splits[1].trimmingCharacters(in: .whitespaces)
    }
    guard let val_converted = convert_constant_value(field_type: field_type, val: val) else {
        print("Invalid constant value: \(val)")
        return nil
    }
    return Constant(field_type: field_type, name: name, val_converted: val_converted, val: val.trimmingCharacters(in: .whitespaces))

}

func convert_constant_value(field_type: String, val: String) -> Any? {
    switch field_type {
    case "float32", "float64":
        return Float(val)
    case "string":
        return val.trimmingCharacters(in: .whitespaces)
    case "bool":
        return val == "true"
    default:
        return Int(val)
    }
}

func load_msg_depends(msg_context: MsgContext, spec: MsgSpec, search_path: [String: [String]]) -> [MsgSpec] {
    let package_context = spec.package
    var depends = [MsgSpec]()
    for unresolved_type in spec.variables.map({$0.field_type}) {
        let bare_type = bare_msg_type(unresolved_type)
        let resolved_type = resolve_type(bare_type, package_context: package_context)
        if is_builtin(resolved_type) {
            continue
        }
        var depspec: MsgSpec?
        if msg_context.is_registered(resolved_type) {
            depspec = msg_context.get_registered(msg_type: resolved_type)!
        } else {
            depspec = load_msg_by_type(msg_context: msg_context, msg_type: resolved_type, search_path: search_path)!
            msg_context.register(full_msg_type: resolved_type, msgspec: depspec!)
        }

        depends.append(depspec!)
        if let dep_dependencies = msg_context.get_depends(full_msg_type: resolved_type) {
            load_msg_depends(msg_context: msg_context, spec: depspec!, search_path: search_path)
        }

    }
    msg_context.set_depends(full_msg_type: spec.full_name, dependencies: depends)
    return depends
}

func load_msg_by_type(msg_context: MsgContext, msg_type: String, search_path: [String: [String]]) -> MsgSpec? {
    var type = msg_type
    if msg_type == HEADER {
        type = HEADER_FULL_NAME
    }
    if let (package, base_type) = package_resource_name(name: msg_type) {
        let file_path = get_msg_file(package: package, base_type: base_type, search_path: search_path)
        let spec = load_msg_from_file(msg_context: msg_context, file_path: file_path!, full_name: msg_type)
        msg_context.set_file(full_msg_type: msg_type, file_path: file_path!)
        return spec
    }
    return nil
}

func get_msg_file(package: String, base_type: String, search_path: [String: [String]]) -> String? {
    guard search_path.keys.contains(package) else {
        print("Cannot locate message [\(base_type)]: unknown package [\(package)] on search path [\(search_path)]")
        return nil
    }

    for path_tmp in search_path[package]! {
        let path = path_tmp + "/" + base_type + ".msg"
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
    }

    print("Cannot locate message [\(base_type)] in package [\(package)] with paths [\(search_path)]")
    return nil

}
