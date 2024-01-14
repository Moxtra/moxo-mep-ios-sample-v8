//
//  SampleHandler.swift
//  Broadcast
//
//  Created by John on 2024/1/11.
//

import ReplayKit
import VideoToolbox

let GROUP_NAME = "group.com.demo.MoxoDemo"
let ERROR_DOMAIN = "com.demo.MoxoDemo"

let BROADCAST_MSG_KEY = "message"
let BROADCAST_DESCRIPTION_KEY = "description"
let BROADCAST_FRAME_KEY = "frame"

let MSG_START = "started"
let MSG_FINISH = "finished"
let FPS = 24.0
let compress = 0.01
var lastCall = Date.now.timeIntervalSince1970 * 1000 //milliseconds
let delay = 1/FPS * 1000 //milliseconds

class SampleHandler: RPBroadcastSampleHandler {
    let sharedDefaults = UserDefaults(suiteName: GROUP_NAME)
    var stateTimer : Timer?
    var frameTimer : Timer?
    var currentFrame : Data?
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendMessage(MSG_START)
            self.startTimers()
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        clearAndfinish()
    }
    
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            currentFrame = handleVideoBuffer(sampleBuffer)
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
    
    //MARK: Broadcast state manage
    private func startTimers() {
        // Check status from host app per seconds
        self.stateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.syncStatus()
        }
        RunLoop.current.add(self.stateTimer!, forMode: .default)
        RunLoop.current.add(self.stateTimer!, forMode: .common)
        self.stateTimer?.fire()
        
        // Send frame in configured FPS
        frameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / FPS, repeats: true) { _ in
            self.sendFrame()
        }
        RunLoop.current.add(self.frameTimer!, forMode: .default)
        RunLoop.current.add(self.frameTimer!, forMode: .common)
        self.frameTimer?.fire()
    }
    
    private func sendMessage(_ message:String) {
        sharedDefaults?.setValue(message, forKey: BROADCAST_MSG_KEY)
    }
    
    private func syncStatus() {
        print("syncing...")
        if let message = sharedDefaults?.object(forKey: BROADCAST_MSG_KEY) as? String {
            if (message == MSG_FINISH) {
                var error:Error?
                if let description = sharedDefaults?.object(forKey: BROADCAST_DESCRIPTION_KEY) as? String {
                    error = NSError(domain: ERROR_DOMAIN, code: 1, userInfo: [NSLocalizedDescriptionKey: description])
                } else {
                    error = NSError(domain: ERROR_DOMAIN, code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
                }
                finishBroadcastWithError(error!)
                clearAndfinish()
            }
        }
    }
    
    private func clearAndfinish() {
        stateTimer?.invalidate()
        frameTimer?.invalidate()
        sendMessage(MSG_FINISH)
    }
    
    //MARK: Broadcast sample buffer manage
    private func handleVideoBuffer(_ buffer: CMSampleBuffer) -> Data? {
        let now = Date.now.timeIntervalSince1970 * 1000
        let elapsed = now - lastCall
        let remaining = delay - elapsed
        if (remaining < 0) {
            lastCall = Date.now.timeIntervalSince1970 * 1000
            guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else { return nil }
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
            defer { CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly) }
            var imgOut: CGImage?
            VTCreateCGImageFromCVPixelBuffer(imageBuffer, options: nil, imageOut: &imgOut)
            guard let cgImage = imgOut else { return nil }
            guard let imageData = UIImage(cgImage: cgImage).jpegData(compressionQuality: compress) else { return nil }
            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
            return imageData
        }
        return nil
    }
    
    private func sendFrame() {
        if let frame = currentFrame {
            DispatchQueue.main.async {
                self.sharedDefaults?.setValue(frame, forKey: BROADCAST_FRAME_KEY)
            }
        }
    }
}
