//
//  hashing.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-10-12.
//

import Foundation

let std_msg_path = "/Users/tgu/ros-install-osx/melodic_desktop_full_ws/src/std_msgs/msg"
let path = "/Users/tgu/ros-install-osx/melodic_desktop_full_ws/src/common_msgs/geometry_msgs"

extension MsgContext {

    func load_dir(path: String, package_name: String) {
        guard let content = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            print("no files in directory \(path)")
            exit(1)
        }

        let packages = content.filter { $0.hasSuffix("_msgs")}
        let files = content.filter { $0.hasSuffix(".msg") }
        print("found \(packages.count) packages: \(packages.joined(separator: "\n"))")
        print("found \(files.count) files in package \(package_name): \(files.joined(separator: "\n"))")

        for file in files {
            let name = String(URL(fileURLWithPath: file).lastPathComponent.dropLast(4))
            let full_name = package_name + "/" + name
            let full_path = path + "/" + file
            if let spec = load_msg_from_file(msg_context: self, file_path: full_path, full_name: full_name) {
                set_file(full_msg_type: full_name, file_path: full_path)
            } else {
                print("\(full_name) = no spec")
            }
        }

        for package in packages {
            let sub_path = path + "/" + package
            load_dir(path: sub_path, package_name: package)
        }

        if content.contains("msg") {
            let sub_path = path + "/msg"
            load_dir(path: sub_path, package_name: package_name)
        }
    }

}

let context = MsgContext()

context.load_dir(path: std_msg_path, package_name: "std_msgs")
context.load_dir(path: path, package_name: "geometry_msgs")

let spec = context.get_registered(msg_type: "geometry_msgs/Inertia")
let md5 = spec?.compute_md5(msg_context: context)
spec?.generateMessage(context: context)

if let messages = context.registered["geometry_msgs"] {
    for (msg,spec) in messages {
        spec.generateMessage(context: context)
        print("genrated \(msg)")
    }
}

exit(0)



if let shell = Shell() {
    let allMsgsString = shell.rosmsg(["list"])
    let allMsgs = allMsgsString.components(separatedBy: .newlines)

    // generate standard messages

    let stdMsgs = allMsgs.filter { $0.hasPrefix("std_msgs") && !$0.contains("Array") }
    for msg in stdMsgs {
        generateStdMsg(shell: shell, msg: msg)
    }

    // generate all other messages

    let msgs = allMsgs.filter { !$0.hasPrefix("std_msgs") }
    for msg in msgs {
        generateMessage(shell: shell, msg: msg)
    }


}









