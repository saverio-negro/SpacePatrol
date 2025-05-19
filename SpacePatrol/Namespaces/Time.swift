//
//  Time.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 19/05/25.
//

import SwiftUI

// Define Time Namespace
enum Time {
    static func getNanosecondsFromSeconds(seconds: Double) -> UInt64 {
        return UInt64(seconds * pow(10, 9))
    }
    
    static func scheduleTimer(timeInterval: TimeInterval, action: () -> Void) async {
        
        let timeInterval = getNanosecondsFromSeconds(seconds: timeInterval)
        
        while true {
            try! await Task.sleep(nanoseconds: timeInterval)
            action()
        }
    }
}
