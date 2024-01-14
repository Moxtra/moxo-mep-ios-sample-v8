//
//  BroadcastManager.swift
//  MoxoDemo
//
//  Created by John on 2024/1/11.
//

import Foundation

let GROUP_NAME = "group.com.demo.MoxoDemo"
let EXTENSION_NAME = "com.demo.MoxoDemo.DSBroadcast"
let BROADCAST_MSG_KEY = "message"
let BROADCAST_DESCRIPTION_KEY = "description"
let BROADCAST_FRAME_KEY = "frame"

let MSG_START = "started"
let MSG_FINISH = "finished"

class BroadcastManager: NSObject, MEPBroadcastingDelegate  {
    
    static let shared = BroadcastManager()
    let sharedDefaults = UserDefaults(suiteName: GROUP_NAME)
    let frameProcessQ = OperationQueue.init()
    
    private let moxoBroadcast = MEPBroadcasting.sharedInstance() as! MEPBroadcasting

    private override init() {
        super.init()
        moxoBroadcast.broadcastExtensionBundleIdentifier = EXTENSION_NAME
        moxoBroadcast.delegate = self
        sharedDefaults?.addObserver(self, forKeyPath: BROADCAST_MSG_KEY, options: .new, context: nil)
        sharedDefaults?.addObserver(self, forKeyPath: BROADCAST_FRAME_KEY, options: .new, context: nil)
        frameProcessQ.maxConcurrentOperationCount = 1
    }
    
    private func sendMessage(_ message:String) {
        sharedDefaults?.setValue(message, forKey: BROADCAST_MSG_KEY)
    }
    
    private func sendDescription(_ description:String) {
        sharedDefaults?.setValue(description, forKey: BROADCAST_DESCRIPTION_KEY)
    }
    
    private func handleMessage(_ message: String) {
        if (message == MSG_FINISH) {
            moxoBroadcast.stopSharing()
        } else if (message == MSG_START) {
            moxoBroadcast.startSharing()
        }
    }
    
    private func handleFrame(_ frame: Data) {
        frameProcessQ.cancelAllOperations()
        frameProcessQ.addOperation {
            if let image = UIImage(data: frame) {
                self.moxoBroadcast.share(image)
            }
        }
    }
    
    //MARK: Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == BROADCAST_MSG_KEY) {
            if let newValue = change?[.newKey] as? String {
                handleMessage(newValue)
            }
        } else if (keyPath == BROADCAST_FRAME_KEY) {
            if let newValue = change?[.newKey] as? Data {
                handleFrame(newValue)
            }
        }
    }

    //MARK: MEPBroadcastingDelegate
    func broadcastingScreenShareDidStarted(_ boradcasting: MEPBroadcasting) {
        //Send start command to extension
        sendMessage(MSG_START)
    }
    
    func broadcastingScreenShareDidStopped(_ boradcasting: MEPBroadcasting) {
        sendDescription("Application stopped broadcast")
        sendMessage(MSG_FINISH)
    }
    
}
