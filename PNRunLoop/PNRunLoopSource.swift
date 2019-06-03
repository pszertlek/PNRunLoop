//
//  PNRunLoopSource.swift
//  PNRunLoop
//
//  Created by apple on 2019/5/30.
//  Copyright © 2019 Pszertlek. All rights reserved.
//

import Foundation

class PNRunLoopSourceContext {
    var version: Int?
    var info: UnsafeMutableRawPointer?
    var retain: ((_ info: UnsafeMutableRawPointer) -> Void)?
    var release: ((_ info: UnsafeMutableRawPointer) -> Void)?
    var copyDescription: ((_ info: UnsafeMutableRawPointer) -> Void)?
    var hash: ((_ info: UnsafeMutableRawPointer) -> Int)?
    var schedule: ((_ info: UnsafeMutableRawPointer, _ runLoop: PNRunLoop, _ mode: PNRunLoopModeRef) -> Void)?
    var cancel: ((_ info: UnsafeMutableRawPointer, _ runLoop: PNRunLoop, _ mode: PNRunLoopModeRef) -> Void)?
    var perform: ((_ info: UnsafeMutableRawPointer) -> Void)?
    
}

class PNRunLoopSourceContext1 {
    /*
     CFIndex    version;
     void *    info;
     const void *(*retain)(const void *info);
     void    (*release)(const void *info);
     CFStringRef    (*copyDescription)(const void *info);
     Boolean    (*equal)(const void *info1, const void *info2);
     CFHashCode    (*hash)(const void *info);
     #if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)) || (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
     mach_port_t    (*getPort)(void *info);
     void *    (*perform)(void *msg, CFIndex size, CFAllocatorRef allocator, void *info);
     #else
     void *    (*getPort)(void *info);
     void    (*perform)(void *info);
     #endif
     */
}



class PNRunLoopSource {
    let lock = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
    let order: Int = 0
    var runloops: [PNRunLoop]?
    var version0: PNRunLoopSourceContext?
    var version1: PNRunLoopSourceContext1?
    var signaled: Bool = false //atomic
    
    func setSignaled() {
        self.signaled = true
    }
    
    func unsetSignaled() {
        self.signaled = false
    }
    
    func sourceLock() {
        pthread_mutex_lock(self.lock)
    }
    
    func sourceUnlock() {
        pthread_mutex_unlock(self.lock)
    }
    
    
}
