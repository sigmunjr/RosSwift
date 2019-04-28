//
//  hashing.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-10-12.
//

import Foundation

struct Shell {
    let rosmsgPath: URL
    let env: [String: String]

    init?() {
        env = ProcessInfo.processInfo.environment

        guard env["PYTHONPATH"] != nil else {
            print("PYTHONPATH is not set")
            return nil
        }
        guard let rosPath = env["ROS_PACKAGE_PATH"] else {
            print("ROS_PACKAGE_PATH is not set")
            return nil
        }
        rosmsgPath = Shell.getRosPath(rosPath: rosPath)

    }

    static func getRosPath(rosPath: String) -> URL {
        let parts = rosPath.split(separator: "/").dropLast()
        let rosbin = parts.joined(separator: "/")
        let rosmsgPath = "/" + rosbin + "/bin/rosmsg"
        return URL(fileURLWithPath: rosmsgPath)
    }


    func rosmsg(_ cmd: [String]) -> String {
        return shell(url: rosmsgPath, args: cmd, environment: env)
    }

    func shell(url: URL, args: [String], environment: [String:String] = [:]) -> String {
        let task = Process()
        task.executableURL = url
        task.arguments = args
        task.environment = environment
        let pipe = Pipe()
        task.standardOutput = pipe
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            guard let stringRead = String(data: data, encoding: .utf8 ) else {
                return ""
            }
            return stringRead

        } catch let error {
            print(error.localizedDescription)
            return ""
        }

    }


}


struct StdMessage<T> {
    var value : T
}


var generatedMessages = [String:String]()

if let shell = Shell() {
    let allMsgsString = shell.rosmsg(["list"])
    let allMsgs = allMsgsString.components(separatedBy: .newlines)

    let msgs = allMsgs.filter { !$0.hasPrefix("std_msgs") }
    for msg in msgs {
        generateMessage(shell: shell, msg: msg)
    }


    let stdMsgs = allMsgs.filter { $0.hasPrefix("std_msgs") && !$0.contains("Array") }
    for msg in stdMsgs {
        generateStdMsg(shell: shell, msg: msg)
    }
}









