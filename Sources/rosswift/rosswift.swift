import Foundation
import HeliumLogger
import LoggerAPI
import NIO

import NIOConcurrencyHelpers
import RosTime
import StdMsgs

public typealias StringStringMap = [String: String]

struct TransportTCP {
    static var useKeepalive = false
    static var useIPv6 = false
}


func amIBeingDebugged() -> Bool {
    #if os(OSX)
    var info = kinfo_proc()
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var size = MemoryLayout<kinfo_proc>.stride
    let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
    assert(junk == 0, "sysctl failed")
    return (info.kp_proc.p_flag & P_TRACED) != 0
    #else
    return false
    #endif
}

public final class Ros: Hashable {

    public static func == (lhs: Ros, rhs: Ros) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        let i = ObjectIdentifier(self)
        hasher.combine(i)
    }


    public enum InitOptions {
        case noSigintHandler
        case anonymousName
        case noRosout
    }

    fileprivate static var globalRos = Set<Ros>()
    fileprivate static var atexitRegistered = false

    public typealias InitOption = Set<InitOptions>

    let gGlobalQueue = CallbackQueue()
    let gInternalCallbackQueue = CallbackQueue()
    let initOptions: InitOption

    var rosoutAppender: ROSOutAppender?
    var fileLog: FileLog?
    var isShutdownRequested = false
    var isShuttingDown = Atomic<Bool>(value: false)
    var isRunning = false
    var isStarted = false
    var isInitialized = false
    let logg = HeliumLogger(.debug)

    public var ok: Bool { return isRunning }

    public init(name: String, remappings: StringStringMap = [:], options: InitOption = []) {
        initOptions = options
        isRunning = true

        check_ipv6_environment()
        Network.initialize(remappings: remappings)
        Master.shared.initialize(remappings: remappings)
        ThisNode.initialize(name: name, remappings: remappings, options: options)
        fileLog = FileLog(remappings: remappings)
        Param.initialize(remappings: remappings)

        isInitialized = true

        if !Ros.atexitRegistered {
            Ros.atexitRegistered = true
            atexit(atexitCallback)
        }

        Ros.globalRos.insert(self)
    }

    public convenience init(argv: inout [String], name: String, options: InitOption = []) {


        var remappings = StringStringMap()
        var unhandled = [String]()

        for arg in argv {
            if let pos = arg.range(of: ":=") {
                let local = String(arg.prefix(upTo: pos.lowerBound))
                let external = String(arg.suffix(from: pos.upperBound))
                ROS_DEBUG("remap \(local) => \(external)")
                remappings[local] = external
            } else {
                unhandled.append(arg)
            }
        }
        argv = unhandled
        self.init(name: name, remappings: remappings, options: options)


        Log.logger = logg
        #if os(Linux)
        logg.colored = true
        logg.details = true
        #else
        logg.colored = !amIBeingDebugged()
        logg.details = amIBeingDebugged()
        #endif
        logg.dateFormat = "HH:mm:ss.SSS"
        ROS_INFO("Ros is initializing")

    }



//    public init() {
//        if !Ros.atexitRegistered {
//            Ros.atexitRegistered = true
//            atexit(atexitCallback)
//        }
//    }

    deinit {
        shutdown()
        Ros.globalRos.remove(self)
    }

    public func createNode() -> NodeHandle {
        return NodeHandle(ros: self)
    }


    public func createNode(ns: String, remappings: StringStringMap? = nil) -> NodeHandle? {
        return NodeHandle(ros: self, ns: ns, remappings: remappings)
    }

    public func createNode(parent: Ros.NodeHandle, ns: String = "") -> NodeHandle {
        return NodeHandle(parent: parent, ns: ns)
    }

    func getGlobalCallbackQueue() -> CallbackQueue {
        return gGlobalQueue
    }

    func requestShutdown() {
        isShutdownRequested = true
        shutdown()
    }

    func shutdownCallback(params: XmlRpcValue) -> XmlRpcValue {
        var count = 0
        switch params.getType() {
        case  .array(let a):
            count = a.count
        default:
            break
        }
        if count > 1 {
            let reason = params[1]
            ROS_INFO("Shutdown request received.")
            ROS_INFO("Reason given for shutdown: \(reason)")
            // we have to avoid calling wait inside an EventLoop
            DispatchQueue(label: "shutdown").async {
                self.requestShutdown()
            }
        }

        return XmlRpc.responseInt(code: 1, msg: "", response: 0)
    }

    ///  ROS initialization function.
    ///
    /// This function will parse any ROS arguments (e.g., topic name
    /// remappings), and will consume them (i.e., argc and argv may be
    /// modified as a result of this call).
    ///
    /// Use this version if you are using the NodeHandle API
    ///
    /// - Parameter argv: Command line argumets
    /// - Parameter name: Name of this node.  The name must be a base name, ie.
    ///             it cannot contain namespaces.
    /// - Parameter options: [optional] Options to start the node with
    /// (a set of bit flags from `Ros.InitOption`)
    /// - Returns: a future that will succeed at shutdown

//    public func initialize(argv: inout [String],
//                                  name: String,
//                                  options: InitOption = .init()) -> EventLoopFuture<Void> {
//
//        Log.logger = logg
//        #if os(Linux)
//        logg.colored = true
//        logg.details = true
//        #else
//        logg.colored = !amIBeingDebugged()
//        logg.details = amIBeingDebugged()
//        #endif
//        logg.dateFormat = "HH:mm:ss.SSS"
//        ROS_INFO("Ros is initializing")
//
//        var remappings = StringStringMap()
//        var unhandled = [String]()
//
//        for arg in argv {
//            if let pos = arg.range(of: ":=") {
//                let local = String(arg.prefix(upTo: pos.lowerBound))
//                let external = String(arg.suffix(from: pos.upperBound))
//                ROS_DEBUG("remap \(local) => \(external)")
//                remappings[local] = external
//            } else {
//                unhandled.append(arg)
//            }
//        }
//        argv = unhandled
//        return initialize(remappings: remappings, name: name, options: options)
//    }
//
//    private let promise: EventLoopPromise<Void> = threadGroup.next().makePromise()

    /// Alternate ROS initialization function.
    ///
    /// - Parameter remappings: A map<string, string> where each one constitutes
    /// a name remapping, or one of the special remappings like __name, __master, __ns, etc.
    /// - Parameter name: Name of this node.  The name must be a base name, ie. it cannot contain namespaces.
    /// - Parameter options: [optional] Options to start the node with (a set of bit flags from \ref ros::init_options)
    /// - Returns: a future that will succeed at shutdown


//    public func initialize(remappings: StringStringMap,
//                                  name: String,
//                                  options: InitOption) -> EventLoopFuture<Void> {
//
//        if !Ros.atexitRegistered {
//            Ros.atexitRegistered = true
//            atexit(atexitCallback)
//        }
//
//        initOptions = options
//        isRunning = true
//
//        check_ipv6_environment()
//        Network.initialize(remappings: remappings)
//        Master.shared.initialize(remappings: remappings)
//        ThisNode.initialize(name: name, remappings: remappings, options: options)
//        fileLog = FileLog(remappings: remappings)
//        Param.initialize(remappings: remappings)
//
//        isInitialized = true
//
//        return promise.futureResult
//    }

    func check_ipv6_environment() {
//        if let envIPv6 = getenv("ROS_IPV6") {
//            let env = String(utf8String: envIPv6)
//            let useIPv6 = env == "on"
//        }
    }

    func removeROSArgs(argv: [String]) -> [String] {
        return argv.filter { $0.contains(":=") }
    }

    public func waitForShutdown() {
        while isRunning {
            _ = RosTime.WallDuration(seconds: 0.05).sleep()
        }
//        promise.succeed(())
    }

    private func kill() {
        ROS_ERROR("Caught kill, stopping...")
        DispatchQueue.main.async {
            self.isShutdownRequested = true
            self.requestShutdown()
        }
    }

    private func start() {
        ROS_INFO("starting Ros")
        if isStarted {
            return
        }

        isShutdownRequested = false
        isStarted = true
        isRunning = true

        _ = Param.param(name: "/tcp_keepalive", value: &TransportTCP.useKeepalive, defaultValue: TransportTCP.useKeepalive)

        guard XMLRPCManager.instance.bind(function: "shutdown", cb: shutdownCallback) else {
            fatalError("Could not bind function")
        }

        initInternalTimerManager()

        TopicManager.instance.start()
        ServiceManager.instance.start()
        Ros.ConnectionManager.instance.start()
        XMLRPCManager.instance.start()

        if !initOptions.contains(.noSigintHandler) {
            signal(SIGINT, basicSigintHandler)
            signal(SIGTERM, basicSigintHandler)
        }

        RosTime.Time.initialize()

        if !initOptions.contains(.noRosout) {
            let appender = ROSOutAppender()
            Console.registerAppender(appender: appender)
            rosoutAppender = appender
        }

        let logServiceName = Names.resolve(name: "~set_logger_level")!
        _ = ServiceManager.instance.advertiseService(.init(service: logServiceName,
                                                           callback: setLoggerLevel))

        if isShuttingDown.load() {
            return
        }

        if let enableDebug = ProcessInfo.processInfo.environment["ROSCPP_ENABLE_DEBUG"],
            enableDebug.lowercased() == "true" || enableDebug == "1" {

            let closeServiceName = Names.resolve(name: "~debug/close_all_connections")!
            let options = AdvertiseServiceOptions(service: closeServiceName, callback: closeAllConnections)
            _ = ServiceManager.instance.advertiseService(options)
        }

        let useSimTime = Param.param(name: "/use_sim_time", defaultValue: false)
        if useSimTime {
            RosTime.Time.setNow(RosTime.Time())
        }

        if useSimTime {
            let ops = SubscribeOptions(topic: "/clock", queueSize: 1, queue: getGlobalCallbackQueue(), callback: clockCallback)
            if !TopicManager.instance.subscribeWith(options: ops) {
                ROS_ERROR("could not subscribe to /clock")
            }
        }

        if isShuttingDown.load() {
            return
        }

        ROS_INFO("Started node [\(Ros.ThisNode.getName())], " +
            "pid [\(getpid())], bound on [\(Network.getHost())], " +
            "xmlrpc port [\(XMLRPCManager.instance.serverPort)], " +
            "tcpros port [\(Ros.ConnectionManager.instance.getTCPPort())], using [\(Time.isSimTime() ? "sim":"real")] time")

    }



    func closeAllConnections(x: EmptyRequest) -> EmptyResponse? {
        ROS_INFO("close_all_connections service called, closing connections")
        ConnectionManager.instance.clear(reason: .transportDisconnect)
        return EmptyResponse()
    }


    func clockCallback(msg: RosgraphMsgs.Clock) {
        Time.setNow(msg.time)
    }

    func shutdown() {


        if isShuttingDown.compareAndExchange(expected: false, desired: true) {
            ROS_DEBUG("ros shutdown")
            if isStarted {
                TopicManager.instance.shutdown()
                ServiceManager.instance.shutdown()
                ConnectionManager.instance.shutdown()
                XMLRPCManager.instance.shutdown()
            }

            isStarted = false
            isRunning = false
//            promise.succeed(())
            isShuttingDown.store(false)
        }
    }

    func spin() {
        let spinner = SingleThreadSpinner()
        spin(spinner)
    }

    func spin(_ spinner: Spinner) {
        spinner.spin(ros: self, queue: nil)
    }

    func spinOnce() {
        gGlobalQueue.callAvailable()
    }



}


func basicSigintHandler(signal: Int32) {
    ROS_INFO("SIGINT")
    Ros.globalRos.forEach{ $0.requestShutdown() }
}

func atexitCallback() {
    Ros.globalRos.forEach { ros in
        if ros.isRunning && !ros.isShuttingDown.load() {
            ROS_DEBUG("shutting down due to exit() or end of main() without cleanup of all NodeHandles")
            ros.isStarted = false
            ros.shutdown()
        }
    }
}
