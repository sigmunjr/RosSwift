//
//  thisNode.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-03-03.
//

import Foundation
import RosTime

extension Ros {

    static let thisNode = ThisNode()

    final class ThisNode {

        var name = "empty"
        public var namespace = "/"

        fileprivate init() {
        }

        /// Get the list of topics advertised by this node
        ///
        public class func getAdvertisedTopics() -> [String] {
            return TopicManager.instance.getAdvertised()
        }

        /// Returns the name of the current node.

        public class func getName() -> String {
            return thisNode.name
        }

        /// Returns the namespace of the current node

        public class func getNamespace() -> String {
            return thisNode.namespace
        }

        /// Get the list of topics subscribed to by this node

        public class func getSubscribedTopics(topics: inout [String]) -> [String] {
            return TopicManager.instance.getSubscribed()
        }

        internal class func initialize(name: String, remappings: StringStringMap, options: InitOption) {
            thisNode.initialize(name: name, remappings: remappings, options: options)
        }

        private func initialize(name inName: String, remappings: StringStringMap, options: InitOption) {
            if let namespaceEnvironment = ProcessInfo.processInfo.environment["ROS_NAMESPACE"] {
                namespace = namespaceEnvironment
            }

            guard !name.isEmpty else {
                fatalError("The node name must not be empty")
            }

            name = inName

            var disableAnon = false
            if let it = remappings["__name"] {
                self.name = it
                disableAnon = true
            }

            if let it = remappings["__ns"] {
                self.namespace = it
            }

            namespace = Names.clean(namespace)
            if namespace.isEmpty || namespace.first != "/" {
                namespace = "/" + namespace
            }

            var error = ""
            if !Names.validate(name: namespace, error: &error) {
                fatalError("Namespace [\(namespace)] is invalid: \(error)")
            }

            // names must be initialized here, because it requires the namespace
            // to already be known so that it can properly resolve names.
            // It must be done before we resolve g_name, because otherwise the name will not get remapped.
            Names.initialize(remappings: remappings)

            if name.contains("/") {
                fatalError("\(name), node names cannot contain /")
            }

            if name.contains("~") {
                fatalError("\(name), node names cannot contain ~")
            }

            name = Names.resolve(ns: namespace, name: name)!

            if options.contains(.anonymousName) && !disableAnon {
                name.append("_\(RosTime.WallTime.now().toNSec())")
            }

            Ros.Console.setFixedFilterToken(key: "node", val: name)
        }

    }
}
