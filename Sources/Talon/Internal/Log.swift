//
//  Log.swift
//  Talon
//
//  Created by Mike on 1/31/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation
import os.log

class Log {
    
    @available(OSX 10.12, *)
    fileprivate static var FrameworkLog = OSLog(subsystem: "com.talon.framework", category: "Framework")
        
    static func debug(_ file: String=#file, _ line: Int=#line, message: String) {
        #if DEBUG
        let filename = (file as NSString).lastPathComponent
        let combined = "\(filename):\(line) \(message)"
        if #available(OSX 10.12, *) {
            os_log("%@", log: FrameworkLog, type: .debug, combined)
        } else {
            NSLog("%@", combined)
        }
        #endif
    }
}
