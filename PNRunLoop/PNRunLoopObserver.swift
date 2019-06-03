//
//  PNRunLoopObserver.swift
//  PNRunLoop
//
//  Created by apple on 2019/5/30.
//  Copyright © 2019 Pszertlek. All rights reserved.
//

import Foundation


typealias PNRunLoopObserverCallBack = (_ observer:PNRunLoopObserver, _ activity: PNRunLoopActivity, _ info: UnsafeMutableRawPointer) -> Void

class PNRunLoopObserverContext {
    var version: Int = 0
    var info: UnsafeMutableRawPointer?
    var retain: ((UnsafeMutableRawPointer) -> Void)?
    var release: ((UnsafeMutableRawPointer) -> Void)?
    var copyDescription: ((UnsafeMutableRawPointer) -> String)?
}


class PNRunLoopObserver {
    let lock = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    var runLoop: PNRunLoop?
    var rlCount: Int = 0
    let activities: PNRunLoopActivity?
    let order: Int = 0
    let callout: PNRunLoopObserverCallBack?
    let context: PNRunLoopObserverContext?
    
    init(_ activities: PNRunLoopActivity, _ callout: PNRunLoopObserverCallBack?, _ context: PNRunLoopObserverContext) {
        self.activities = activities
        self.callout = callout
        self.context = context
    }
    
    var isFiring: Bool {//get bit 0 from observer
        set {
            print("set firing")
        }
        get {
            return false
        }
    }
    
    var repeats: Bool {
        //get bit 1 from observer
        set {
            print("set firing")
        }
        get {
            return false
        }
    }
    
    func oberverLock() {
        pthread_mutex_lock(self.lock)
    }
    
    func observerUnlock() {
        pthread_mutex_unlock(self.lock)
    }
}
