//
//  PNRunLoop.swift
//  PNRunLoop
//
//  Created by apple on 2018/4/2.
//  Copyright © 2018年 Pszertlek. All rights reserved.
//

import Foundation

//public typealias PNRunLoopMode = String
public typealias PNIndex = Int

typealias retainBlock = (UnsafePointer<Any>) -> UnsafePointer<Any>
typealias releaseBlock = (UnsafePointer<Any>) -> UnsafePointer<Any>
typealias copyDescriptionBlock = (UnsafePointer<Any>) -> String
typealias equalBlock = (AnyObject,AnyObject) -> Bool
typealias hashBlock = (AnyObject) -> Hashable
//typealias schedule = (AnyObject,)
/* Reasons for RunLoopInMode to return */
enum PNRunLoopResult {
    case finished,stopped,timedOut,handleSource
}

struct PNOptionFlags: OptionSet {
    let rawValue: Int
    static let entry = PNOptionFlags(rawValue: 1 << 0)
    static let beforeTimers = PNOptionFlags(rawValue: 1 << 1)
    static let beforeSources = PNOptionFlags(rawValue: 1 << 2)
    static let beforeWaiting = PNOptionFlags(rawValue: 1 << 5)
    static let afterWaiting = PNOptionFlags(rawValue: 1 << 6)
    static let exit = PNOptionFlags(rawValue: 1 << 7)
    static let allActivities = PNOptionFlags(rawValue: 0x0fffffff)
}

let kRunLoopDefaultMode = "kRunLoopDefaultMode"
let kRunLoopCommonModes = "kRunLoopCommonModes"

//struct PNRunLoopTimerContext {
//    var version: PNIndex?
//    var info: UnsafePointer<Any>?
//    var
//}
class _block_item {
    var next: _block_item?
    var mode: String?
    var block: (() -> Void)?
}

class _per_run_data {
    var a: Int = 0x4346524c
    var b: Int = 0x4346524c // 'CFRL'
    var stopped: Int = 0
    var ignoreWakeUps: Int = 0
}

class PNRunLoop {
    var lock: pthread_mutex_t
    var wakeUpPort: PNPort!
    var unused: Bool = false
    var perRunData: _per_run_data = _per_run_data()
    var pthread: pthread_t!
    var commonModes: Set<String>!
    var commonModeItems: Set<String>!
    var currentMode: PNRunLoopMode!
    var modes: Set<String>!
    var block_head: _block_item?
    var block_tail: _block_item?
    var runTime: CFAbsoluteTime!
    var sleepTime: CFAbsoluteTime!
    var timerTSRLock: pthread_mutex_t!
    
    var isStopped: Bool {
        set {
            if newValue {
                perRunData.stopped = 0x53544f50
            } else {
                perRunData.stopped = 0x0
            }
        }
        get {
            return perRunData.stopped != 0
        }
    }
    
    var ignoringWakeUps: Bool {
        set {
            if newValue {
                perRunData.ignoreWakeUps = 0x57414B45
            } else {
                perRunData.ignoreWakeUps = 0
            }
        }
        get {
            return perRunData.ignoreWakeUps != 0
        }
    }
    
//    var isSleeping: Bool {
//        set {
//            if newValue {
//                perRunData.ignoreWakeUps =
//            }
//        }
//    }
    
    
    init() {

    }
    
    func runLoopPushPerData() -> _per_run_data {
        let previous = perRunData
        perRunData = _per_run_data()
        return previous
    }
    
    func runLoopPopPerRunData(previous: _per_run_data) {
        if self.perRunData != nil {
            //释放之前操作 & dealloc
        }
        self.perRunData = previous
    }
    
    @inline(__always) func runLoopLock() {
        pthread_mutex_lock(&lock)
    }
    
    @inline(__always) func runLoopUnloop() {
        pthread_mutex_unlock(&lock)
    }
    
    @inline(__always) func runLoopLockInit(lock: UnsafeMutablePointer<pthread_mutex_t>) {
        var mattr = pthread_mutexattr_t()
        pthread_mutexattr_init(&mattr)
        pthread_mutexattr_settype(&mattr, PTHREAD_MUTEX_RECURSIVE)
        let mret = pthread_mutex_init(lock, &mattr)
        if mret == 0 {
            
        }
    }
    
    static func runLoopFindMode(modeName: String, create: Bool) -> PNRunLoop {
        let runLoopMode = PNRunLoopMode()
    }
}
