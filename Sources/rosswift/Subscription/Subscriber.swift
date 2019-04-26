//
//  Subscriber.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-03-06.
//

import Foundation
import StdMsgs
import RosTime

extension Ros {
public final class Subscriber {
    let topic: String
    let node: Ros.NodeHandle
    let helper: SubscriptionCallbackHelper

    struct LatchInfo {
        let message: SerializedMessage
        let link: PublisherLink
        let connectionHeader: StringStringMap
        let receiptTime: RosTime.Time
    }

    public init(topic: String, node: Ros.NodeHandle, helper: SubscriptionCallbackHelper) {
        self.topic = topic
        self.node = node
        self.helper = helper
    }

    deinit {
        ROS_DEBUG("Subscriber on '\(self.topic)' deregistering callbacks.")
        _ = node.ros.topicManager.unsubscribe(topic: topic, helper: helper)
    }

    func getTopic() -> String {
        return topic
    }

    func getNumPublishers() -> Int {
            return node.ros.topicManager.getNumPublishers(topic: topic)
    }

}

}
