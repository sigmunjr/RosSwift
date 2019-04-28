//
//  hashing.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-10-12.
//

import Foundation



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









