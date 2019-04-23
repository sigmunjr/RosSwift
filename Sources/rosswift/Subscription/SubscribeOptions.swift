//
//  SubscribeOptions.swift
//  RosSwift
//
//  Created by Thomas Gustafsson on 2018-03-06.
//

import Foundation
import StdMsgs

public struct SubscribeOptions<M: Message> {
    var topic: String
    let transportHints = TransportHints()
    let helper: SubscriptionCallbackHelper 
    var trackedObject: AnyObject?
    var allowConcurrentCallbacks = false
    private var callbackQueueInternal: CallbackQueueInterface?
    let queueSize: UInt32

    init(topic: String, queueSize: UInt32, callback: @escaping ((M) -> Void)) {
        self.topic = topic
        self.helper = SubscriptionCallbackHelperT(callback: callback)
        self.queueSize = queueSize
    }

    init(topic: String, queueSize: UInt32, callback: @escaping ((MessageEvent<M>) -> Void)) {
        self.topic = topic
        self.helper = SubscriptionEventCallbackHelperT(callback: callback)
        self.queueSize = queueSize
    }

    var callbackQueue: CallbackQueueInterface {
        get {
            return callbackQueueInternal != nil ? callbackQueueInternal! : Ros.getGlobalCallbackQueue()
        }
        set {
            callbackQueueInternal = newValue
        }
    }

}
