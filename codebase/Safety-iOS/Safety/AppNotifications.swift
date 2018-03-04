//
//  AppNotifications.swift
//  Safety
//
//  Created by D'Arcy Smith on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import TraceLog

typealias RequestDataReceiver = (_ path : String, _ overwrite : Bool) -> Void
typealias DataReceivedReceiver = (_ localURL : URL, _ type : String) -> Void

class AppNotifications: Notifications
{
    private static let RequestData = "RequestData"
    private static let DataReceived = "DataReceived"
    
    // MARK: -RequestData
    
    static func postRequestData(_ fileName : String!, overwrite : Bool!, object: AnyObject? = nil)
    {
        logTrace { "enter \(#function)" }
        
        let userInfo : [AnyHashable: Any] =
        [
            "FileName" : fileName,
            "Overwrite" : overwrite
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
            
            let fileName = notification.userInfo!["FileName"] as! String
            let overwrite = notification.userInfo!["Overwrite"] as! Bool
            receiver(fileName, overwrite)
            
            logTrace { "enter \(#function) receiver" }
        }
        
        logTrace { "exit \(#function)" }
        
        return id
    }
    
    // MARK: -RequestData
    
    static func postDataReceived(_ url : URL!, type : String!, object: AnyObject? = nil)
    {
        logTrace { "enter \(#function)" }
        
        let userInfo : [AnyHashable: Any] =
        [
            "URL" : url,
            "Type" : type,
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
            
            let url = notification.userInfo!["URL"] as! URL
            let type = notification.userInfo!["Type"] as! String
            receiver(url, type)
            
            logTrace { "enter \(#function) receiver" }
        }
        
        logTrace { "exit \(#function)" }
        
        return id
    }
}
