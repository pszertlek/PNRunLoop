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

struct PNRunLoopActivity: OptionSet {
    let rawValue: Int
    static let entry = PNRunLoopActivity(rawValue: 1 << 0)
    static let beforeTimers = PNRunLoopActivity(rawValue: 1 << 1)
    static let beforeSources = PNRunLoopActivity(rawValue: 1 << 2)
    static let beforeWaiting = PNRunLoopActivity(rawValue: 1 << 5)
    static let afterWaiting = PNRunLoopActivity(rawValue: 1 << 6)
    static let exit = PNRunLoopActivity(rawValue: 1 << 7)
    static let allActivities = PNRunLoopActivity(rawValue: 0x0fffffff)
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
    var lock: pthread_mutex_t!
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
    
    var isSleeping: Bool = false
    
    var isDeallocating: Bool = false
    
    
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
    
//    static func runLoopFindMode(modeName: String, create: Bool) -> PNRunLoop {
//        let runLoopMode = PNRunLoopMode()
//    }
    
}

let kPNRunLoopCommonModes = "kPNRunLoopCommonModes"
let kPNRunLoopDefaultMode = "kPNRunLoopDefaultMode"
let kPNRunLoopTrackingMode = "kPNRunLoopTrackingMode"

extension PNRunLoop {
    func observerSchedule(rlo: PNRunLoopObserver, mode: PNRunLoopModeRef) {
        rlo.oberverLock()
        if 0 == rlo.rlCount {
            rlo.runLoop = self
        }
        rlo.rlCount += 1
        rlo.observerUnlock()
    }
    
    func observerCancel(rlo: PNRunLoopObserver, mode: PNRunLoopModeRef) {
        rlo.oberverLock()
        rlo.rlCount -= 1
        if 0 == rlo.rlCount {
            rlo.runLoop = nil
        }
        rlo.observerUnlock()
    }
    
}

extension PNRunLoop {
    //__CFRunLoopFindMode 创建
    func findMode(modeName: String, create: Bool) -> PNRunLoopModeRef? {
        var runloopMode: PNRunLoopModeRef?
        var srlm = PNRunLoopModeRef(name: modeName) {
            
        }
        if self.modes.contains(modeName) {
            runloopMode = srlm
        }
        srlm.name = modeName
        if runloopMode != nil {
            runloopMode?.modeLock()
            return runloopMode
        }
        if !create {
            return nil
        }
        
        
    }
}

extension PNRunLoop {
    func runSpecific(runLoop: PNRunLoop, modeName: String, seconds: CFTimeInterval, returnAfterSouceHandled: Bool) -> PNRunLoopResult {
        if modeName == nil || modeName == kPNRunLoopCommonModes || modeName == kPNRunLoopCommonModes {
            return .finished
        }
        if runLoop.isDeallocating {
            return .finished
        }
        runLoop.runLoopLock()
        let currentMode = self.findMode(modeName: modeName, create: false)
        if currentMode == nil // || __CFRunLoopModeIsEmpty(rl, currentMode, rl->_currentMode)
        {
            var did = false
            if currentMode != nil {
                currentMode?.modeUnlock()
                return did ? .handleSource : .finished
            }

        }
    }
}

extension PNRunLoop {
    //MARK: public API
    func getTypeId() -> Int {
        return 0
    }
}
