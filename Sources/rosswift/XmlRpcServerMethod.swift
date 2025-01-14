//
//  XmlRpcServerMethod.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-03-06.
//

import Foundation

enum XmlRpcServerMethodError: Error {
    case notImplemented
}

protocol XmlRpcServerMethod {
    var name: String { get }
    var server: XMLRPCServer { get }

    func execute(params: XmlRpcValue) throws -> XmlRpcValue
    func help() -> String
}
