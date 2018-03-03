//
//  AppNotifications.swift
//  Safety
//
//  Created by D'Arcy Smith on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import TraceLog

typealias RequestDataReceiver = (_ path : String) -> Void
typealias DataReceivedReceiver = (_ localURLs : [URL]) -> Void

class AppNotifications: Notifications
{
    private static let RequestData = "RequestData"
    private static let DataReceived = "DataReceived"
    
    // MARK: -RequestData
    
    static func postRequestData(_ fileName : String, object: AnyObject? = nil)
    {
        logTrace { "enter \(#function)" }
        
        let userInfo : [AnyHashable: Any] =
        [
            "FileName" : fileName,
        ]
        
        post(messageName: AppNotifications.RequestData,
             object: object,
             userInfo: userInfo as [NSObject : AnyObject])
        
        logTrace { "exit \(#function)" }
    }
    
    static func addRequestDataObserver(object: AnyObject?,
                                       using receiver: @escaping RequestDataReceiver) -> NSObjectProtocol
    {
        logTrace { "enter \(#function)" }
        
        let id = addObserver(messageName: AppNotifications.RequestData,
                             object: object)
        {
            (notification) in
            
            logTrace { "enter \(#function) receiver" }
            
            let fileName = notification.userInfo!["FileName"] as? String
            receiver(fileName!)
            
            logTrace { "enter \(#function) receiver" }
        }
        
        logTrace { "exit \(#function)" }
        
        return id
    }
    
    // MARK: -RequestData
    
    static func postDataReceived(_ urls : [URL]!, object: AnyObject? = nil)
    {
        logTrace { "enter \(#function)" }
        
        let userInfo : [AnyHashable: Any] =
        [
            "URLs" : urls,
        ]
        
        post(messageName: AppNotifications.DataReceived,
             object: object,
             userInfo: userInfo as [NSObject : AnyObject])
        
        logTrace { "exit \(#function)" }
    }
    
    static func addDataReceivedObserver(object: AnyObject?,
                                        using receiver: @escaping DataReceivedReceiver) -> NSObjectProtocol
    {
        logTrace { "enter \(#function)" }
        
        let id = addObserver(messageName: AppNotifications.DataReceived,
                             object: object)
        {
            (notification) in
            
            logTrace { "enter \(#function) receiver" }
            
            let urls = notification.userInfo!["URLs"] as? [URL]
            receiver(urls!)
            
            logTrace { "enter \(#function) receiver" }
        }
        
        logTrace { "exit \(#function)" }
        
        return id
    }
}
