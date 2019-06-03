//
//  PNRunLoopMode.swift
//  PNRunLoop
//
//  Created by apple on 2018/4/2.
//  Copyright © 2018年 Pszertlek. All rights reserved.
//

import Foundation

typealias PNPort = mach_port_t
typealias PNRunLoopMode = String


//@inline(__always) func pnPortSetAllocate() ->PNPort {
//    var result = mach_port_name_t()
//    var ret = mach_port_allocate(mach_task_self_, MACH_PORT_RIGHT_PORT_SET, &result)
//    if KERN_SUCCESS != ret {
//        //the system has no port sets available
//    }
//    return mach_port_t( KERN_SUCCESS == ret ? result : MACH_PORT_NULL)
//}


class PNRunLoopModeRef: Equatable {
    var lock: UnsafeMutablePointer<pthread_mutex_t>
    var name: String
    var stopped: Bool = false
    var padding: [Character] = [Character].init(repeating: Character(" "), count: 3)
//    var sources0: Set?
//    var sources1: Set?
    var observers: [AnyObject]?
    var timers: [AnyObject]?
    var portToV1SourceMap: [String:AnyObject]?
//    var portSet: PNPort
    var observerMask: PNIndex = 0
//    #if USE_DISPATCH_SOURCE_FOR_TIMERS
    var timerSource: DispatchSourceTimer
    var queue: DispatchQueue
    var timerFired: Bool = false
    var dispathTimerArmed: Bool = false
//    var timerPort: PNPort = 0
//    var mkTimerArmed: Bool
    var timerSoftDeadline: Int = Int.max
    var timerHardDeadline: Int = Int.max
    
    init(name: String, handler: @escaping () -> Void) {
        //        portSet = pnPortSetAllocate()
        self.name = name
        queue = DispatchQueue.init(label: "Run loop mode queue")
        timerSource = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.strict, queue: queue)
        timerSource.setEventHandler {
            handler()
        }
        self.lock = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        timerSource.resume()

    }
    deinit {
        if timerSource != nil {
            timerSource.cancel()
        }
    }
    
    @inline(__always) func modeLock() {
        pthread_mutex_lock(self.lock)
    }
    
    @inline(__always) func modeUnlock() {
        pthread_mutex_unlock(self.lock)
    }
    
    @inline(__always) func runLoopModeHash() -> Int {
        return name.hashValue
    }
    
    public static func ==(rhs: PNRunLoopModeRef, lhs: PNRunLoopModeRef) -> Bool {
        return rhs.name == lhs.name
    }

    

}
