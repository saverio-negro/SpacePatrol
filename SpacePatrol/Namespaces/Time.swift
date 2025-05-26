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
    
    static func scheduledTimer(timeInterval: TimeInterval, condition: Bool, action: () -> Void) async {
        
        let timeInterval = getNanosecondsFromSeconds(seconds: timeInterval)
        
        while condition {
            try! await Task.sleep(nanoseconds: timeInterval)
            action()
        }
    }
}
