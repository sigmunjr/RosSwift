import Foundation
import RosTime

let gTimerManager = InternalTimerManager()

func getInternalTimerManager() -> InternalTimerManager {
    return gTimerManager
}

typealias InternalTimerManager = TimerManager<RosTime.SteadyTime, RosTime.WallDuration, RosTime.SteadyTimerEvent>

func initInternalTimerManager() {
    ROS_ERROR("initInternalTimerManager not implemented")
}

final class TimerManager<T: TimeBase, D: RosTime.DurationBase, E> {
    let timers: [TimerInfo] = []
    let timersMutex = DispatchQueue(label: "TimerManager")
    let timersCond = NSCondition()
    let newTimer: Bool = false
    let waitingMutex = DispatchQueue(label: "waitingMutex")
    let waiting = Set<Int32>()
    let idCounter: UInt32 = 0
    let idMutex = DispatchQueue(label: "idMutex")

    let threadStarted = false
    let thread: Thread? = nil
    let threadGroup = DispatchGroup()

    var quit = false

    init() {
    }

    deinit {
        quit = true
        timersMutex.sync {
            timersCond.broadcast()
        }
        if threadStarted {
            threadGroup.wait()
        }
    }

    func waitingCompare(lhs: Int32, rhs: Int32) -> Bool {
        let infol = findTimer(lhs)
        let infor = findTimer(rhs)

        if let infol = infol, let infor = infor {
            return infol.nextExpected < infor.nextExpected
        }

        return infor != nil
    }

    func findTimer(_ handle: Int32) -> TimerInfo? {
        return timers.first(where: { $0.handle == handle })
    }

    func hasPending(handle: Int32) -> Bool {
        return timersMutex.sync {
            guard let info = findTimer(handle) else {
                return false
            }

            if info.hasTrackedObject && info.trackedObject == nil {
                return false
            }

            return waitingMutex.sync {
                return info.nextExpected <= T.now() || info.waitingCallbacks != 0
            }
        }
    }

    func remove(timerHandle: Int32) {
        ROS_ERROR("\(#function) not implemented")
    }


}

extension TimerManager {
    struct TimerInfo {
        let handle: Int32
        let period: D

        let callback: (E) -> Void
        let callbackQueue: CallbackQueueInterface

        let lastCBDuration: RosTime.WallDuration

        let lastExpected: T
        let nextExpected: T

        let lastReal: T
        let lastExpired: T

        let removed: Bool
        let trackedObject: AnyClass?
        let hasTrackedObject: Bool
        let waitingMutex: DispatchQueue
        let waitingCallbacks: UInt32

        let oneshot: Bool

        let totalCalls: UInt32
    }
}
