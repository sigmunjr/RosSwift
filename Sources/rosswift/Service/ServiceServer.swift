//
//  ServiceServer.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-10-24.
//

import Foundation

public final class ServiceServer {
    let service: String
    unowned var node: Ros.NodeHandle
    var isUnadvertised = false

    init(service: String, node: Ros.NodeHandle) {
        self.service = service
        self.node = node
    }

    deinit {
        unadvertise()
    }

    func unadvertise() {
        if !isUnadvertised {
            isUnadvertised = true
            _ = node.ros.serviceManager.unadvertiseService(name: service)
        }
    }

    func isValid() -> Bool {
        return !isUnadvertised
    }


    func shutdown() {
        unadvertise()
    }

    func getService() -> String {
        return service
    }

}
