//
//  Bundle-Extension.swift
//  SpacePatrol
//
//  Created by Saverio Negro on 28/05/25.
//

import AVKit
import Foundation
import RealityKit

extension Bundle {
    
    // 1. Create the `AVPlayer` object as well as the `VideoMaterial` object
    // 2. Call a closure passing over the created objects for the user to perform an action with
    func videoMaterial(for file: String, action: (_ player: AVPlayer, _ material: VideoMaterial) -> Void) {
        guard
            let fileURL = self.url(forResource: file, withExtension: nil)
        else {
            fatalError("Failed finding the file from the bundle.")
        }
        
        // Create player to play audiovisual resource referenced by the url
        let player = AVPlayer(url: fileURL)
        
        // Create video material
        let videoMaterial = VideoMaterial(avPlayer: player)
        
        // Pass over the instances for the user to use them withon the `action` closure's body.
        action(player, videoMaterial)
    }
}
