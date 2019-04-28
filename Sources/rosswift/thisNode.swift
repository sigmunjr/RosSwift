//
//  thisNode.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-03-03.
//

import Foundation
import RosTime

extension Ros {

    /// Get the list of topics advertised by this node
    ///
    public func getAdvertisedTopics() -> [String] {
        return topicManager.getAdvertised()
    }

    /// Get the list of topics subscribed to by this node

    public func getSubscribedTopics(topics: inout [String]) -> [String] {
        return topicManager.getSubscribed()
    }

    /// Returns the name of the current node.

    public func getName() -> String {
        return name
    }

//    /// Returns the namespace of the current node
//
//    public func getNamespace() -> String {
//        return namespace
//    }


//    static let thisNode = ThisNode()

//    final class ThisNode {
//
////        let name: String
////        let namespace: String
//
////        fileprivate init() {
////        }
////
//
//
////        internal func initialize(name: String, remappings: StringStringMap, options: InitOption) {
////            thisNode.initialize(name: name, remappings: remappings, options: options)
////        }
//
//        init(name inName: String, remappings: StringStringMap, options: InitOption) {
//
//            var ns = ""
//
//            if let namespaceEnvironment = ProcessInfo.processInfo.environment["ROS_NAMESPACE"] {
//                ns = namespaceEnvironment
//            }
//
//            guard !inName.isEmpty else {
//                fatalError("The node name must not be empty")
//            }
//
//            var node_name = inName
//
//            var disableAnon = false
//            if let it = remappings["__name"] {
//                node_name = it
//                disableAnon = true
//            }
//
//            if let it = remappings["__ns"] {
//                ns = it
//            }
//
//            ns = Names.clean(ns)
//            if ns.isEmpty || ns.first != "/" {
//                ns = "/" + ns
//            }
//
//            var error = ""
//            if !Names.validate(name: ns, error: &error) {
//                fatalError("Namespace [\(ns)] is invalid: \(error)")
//            }
//
//
//            // names must be initialized here, because it requires the namespace
//            // to already be known so that it can properly resolve names.
//            // It must be done before we resolve g_name, because otherwise the name will not get remapped.
//            initialize(remappings: remappings)
//
//            if node_name.contains("/") {
//                fatalError("\(node_name), node names cannot contain /")
//            }
//
//            if node_name.contains("~") {
//                fatalError("\(node_name), node names cannot contain ~")
//            }
//
//            node_name = Names.resolve(ns: ns, name: node_name)!
//
//            if options.contains(.anonymousName) && !disableAnon {
//                node_name.append("_\(WallTime.now().toNSec())")
//            }
//
//            Ros.Console.setFixedFilterToken(key: "node", val: node_name)
//
//            self.namespace = ns
//            self.name = node_name
//        }
//
//    }
}
