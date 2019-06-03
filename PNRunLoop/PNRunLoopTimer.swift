//
//  PNRunLoopTimer.swift
//  PNRunLoop
//
//  Created by apple on 2019/5/30.
//  Copyright © 2019 Pszertlek. All rights reserved.
//

import Foundation

typealias PNRunLoopTimerCallBack = (_ observer:PNRunLoopTimer, _ info: UnsafeMutableRawPointer) -> Void

class PNRunLoopTimerContext {
    var version: Int = 0
    var info: UnsafeMutableRawPointer?
    var retain: ((UnsafeMutableRawPointer) -> Void)?
    var release: ((UnsafeMutableRawPointer) -> Void)?
    var copyDescription: ((UnsafeMutableRawPointer) -> String)?
}

class PNRunLoopTimer {
    var bits: Int16 = 0
    var lock = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    var runLoop: PNRunLoop?
    lazy var rlModes: [String] = [String]()
    var nextFireDate: CFAbsoluteTime = 0
    let interval: CFTimeInterval
    var tolerance: CFTimeInterval = 0
    var fireTSR: Int64 = 0
    var order: Int
    let callout: PNRunLoopTimerCallBack?
    let context: PNRunLoopTimerContext?
    init(interval: CFTimeInterval, order: Int, callout: @escaping PNRunLoopTimerCallBack, context: PNRunLoopTimerContext) {
        self.interval = interval
        self.order = order
        self.callout = callout
        self.context = context
    }
    
    func isFiring() -> Bool {
        return self.bits & 0x1 == 1
    }
    
    func setFiring() {
        self.bits = self.bits | 0x1
    }
    
    func unsetFiring() {
        self.bits = self.bits & 0x0
    }
    
    func setDeallocating() {
        self.bits = self.bits | 0x100
    }
    
    func isDealocating() -> Bool {
        return self.bits & 0x001 != 0
    }
    
    
    func timerLock() {
        pthread_mutex_lock(self.lock)
    }
    
    func timerUnlock() {
        pthread_mutex_unlock(self.lock)
    }
}
