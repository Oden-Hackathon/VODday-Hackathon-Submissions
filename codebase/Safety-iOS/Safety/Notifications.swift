//
//  Notifications.swift
//  ios-swift-demo
//
//  Created by D'Arcy Smith on 2017-07-23.
//  Copyright © 2017 TerraTap Technologies Inc. All rights reserved.
//

import TraceLog

class Notifications
{
    private static let notificationCentre = NotificationCenter.default
    
    static func post(messageName: String!,
                     object: AnyObject?,
                     userInfo: [AnyHashable: Any]? = nil)
    {
        logTrace { "enter post \(messageName!)" }
        
        if userInfo == nil
        {
            logInfo { "posting \(messageName!)" }
        }
        else
        {
            logInfo { "posting \(messageName!) \(String(describing: userInfo))" }
        }
        
        notificationCentre.post(name: NSNotification.Name(messageName),
                                object: object,
                                userInfo: userInfo)
        logTrace { "exit post \(messageName!)" }
    }
    
    static func addObserver(forName messageName: String!,
                            object: Any?,
                            using receiver: @escaping (Notification) -> Void) -> NSObjectProtocol
    {
        logTrace { "enter addObserver \(messageName!)" }
        
        let id = notificationCentre.addObserver(forName: NSNotification.Name(messageName),
                                                object: object,
                                                queue: nil,
                                                using: receiver)
        logTrace { "exit addObserver \(messageName!)" }
        
        return id
    }
    
    static func removeObserver(observer: AnyObject?)
    {
        logTrace { "enter removeObserver" }
        
        if observer != nil
        {
            notificationCentre.removeObserver(observer!)
        }
        
        logTrace { "exit removeObserver" }
    }
}
