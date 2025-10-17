//
//  AVAudioSession+Extension.swift
//  AlfaApp
//
//  Created by Onur Yilmaz on 17.10.2025.
//

import AVFoundation

extension AVAudioSession {
    
    func activatePlaybackSession() {
        do {
            try setCategory(.playback, mode: .default, policy: .longFormVideo, options: [])
            try setActive(true)
        } catch {
            print("Audio session ACTIVATE error: \(error.localizedDescription)")
        }
    }
    
    func deactivatePlaybackSession() {
        do {
            try setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session DEACTIVATE error: \(error.localizedDescription)")
        }
    }
}
