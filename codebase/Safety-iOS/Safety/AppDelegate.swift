//
//  AppDelegate.swift
//  Safety
//
//  Created by D'Arcy Smith on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import UIKit
import TraceLog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ManifestDownloaderDelegate
{
    var window: UIWindow?

    var requestDataReceiver: NSObjectProtocol?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        requestDataReceiver = AppNotifications.addRequestDataObserver(object: nil)
        {
            (fileName) in
            
            logTrace { "enter RequestData receiver" }
            self.requestData(fileName)
            logTrace { "exit RequestData receiver" }
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func converted(_ entry: ManifestEntry, to convertedDatasetURL: URL!)
    {
        print("converted \(entry.provider!) to: \(convertedDatasetURL.path)")
        
        /*
         do
         {
         print(try String(contentsOf: convertedDatasetURL));
         }
         catch
         {
         print(error)
         }
         */
        
        print("----")
    }
    
    func conversionCompleted(_ entries : [ManifestEntry]!)
    {
        let convertedDatasetURLs = Manifest.getLocalDatasetFilesFor(entries)!

        AppNotifications.postDataReceived(convertedDatasetURLs)
    }
    
    func downloadError(_ entry : ManifestEntry!, error: Error!)
    {
        sync(self)
        {
            print("error downloading \(entry.provider!): \(error.localizedDescription)")
            print("----")
        }
    }
    
    func downloadError(_ entry : ManifestEntry!, url : URL!, error : Error!)
    {
        sync(self)
        {
            print("error downloading \(url.path): \(error.localizedDescription)")
            print("----")
        }
    }
    
    func unarchiveError(_ entry : ManifestEntry!, url : URL!, error : Error!)
    {
        sync(self)
        {
            print("error unarchiving \(url.path): \(error.localizedDescription)")
            print("----")
        }
    }
    
    func conversionError(_ entry : ManifestEntry!, url : URL!, error : Error!)
    {
        sync(self)
        {
            print("error converting \(url.path): \(error.localizedDescription)")
            print("----")
        }
    }
    
    func requestData(_ fileName : String!)
    {
        let downloader = ManifestDownloader()
        
        downloader.delegate = self
        
        do
        {
            try downloader.download(fileName, overwrite: true)
        }
        catch
        {
            print("error: \(error.localizedDescription)")
        }
    }
}

