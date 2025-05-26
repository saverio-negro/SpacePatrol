//
//  Text.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 26/05/25.
//

import SwiftUI

enum Utility {
    static func animateText(text: String, inputText: Binding<String>) async {
        
        inputText.wrappedValue = ""

        let letters = text.split(separator: "")
        for letter in letters {
            let lowerTimeBound = Time.getNanosecondsFromSeconds(seconds: 0.02)
            let upperTimeBound = Time.getNanosecondsFromSeconds(seconds: 0.07)
            try! await Task.sleep(nanoseconds: UInt64.random(in: lowerTimeBound...upperTimeBound))
            
            inputText.wrappedValue += letter
        }
    }
}
