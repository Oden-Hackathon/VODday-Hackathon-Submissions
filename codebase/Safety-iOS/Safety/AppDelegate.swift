//
//  AppDelegate.swift
//  Safety
//
//  Created by D'Arcy Smith on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import TraceLog
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ManifestDownloaderDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    let locationManager = CLLocationManager ()
    let downloader = ManifestDownloader()
    var manifest : [ManifestEntry]?
    var requestDataReceiver: NSObjectProtocol?
    
    private var startTime: Date? //An instance variable, will be used as a previous location time.
    
    static var fcmtoken:String? = ""


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        downloader.delegate = self
        locationManager.delegate = self
        requestDataReceiver = AppNotifications.addRequestDataObserver(object: nil) {
            (fileName, overwrite) in
            
            logTrace { "enter RequestData receiver" }
            self.requestData(fileName, overwrite: overwrite)
            logTrace { "exit RequestData receiver" }
        }

        /*
        do {
            try downloader.download("oden-manifest", overwrite: true)
        }
        catch {
            print (error)
        }
        */
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        // Override point for customization after application launch.
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        let viewController = self.window?.rootViewController
        
        
        Location.locationAuthorizationStatus(viewController: viewController, status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let loc = locations.last else { return }
        
        let time = loc.timestamp
        
        guard let startTime2 = startTime else {
            self.startTime = time // Saving time of first location, so we could use it to compare later with second location time.
            return //Returning from this function, as at this moment we don't have second location.
        }
        
        let elapsed = time.timeIntervalSince(startTime2) // Calculating time interval between first and second (previously saved) locations timestamps.
        
        if elapsed > 1 { //If time interval is more than 1 second
            print("Received location from device")
            Location.updateUser(location: loc) //user function which uploads user location or coordinate to server.
            
            startTime = time //Changing our timestamp of previous location to timestamp of location we already uploaded.
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("error: \(error.localizedDescription)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("applicationDidEnterBackground")
        
        //        if UserDefaults.standard.bool(forKey: Location.TRACK_ME_AT_ALL_TIMES) {
        //            Location.startLocationUpdatesAlways(caller: nil)
        //        } else {
        //            Location.startLocationUpdatesWhenInUse()
        //        }
        
        UserDefaults.standard.synchronize();
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("applicationDidBecomeActive")
        
        self.locationManager.delegate = self
        if UserDefaults.standard.bool(forKey: Location.TRACK_ME_AT_ALL_TIMES) {
            Location.startLocationUpdatesAlways(caller: self.window?.rootViewController)
        } else {
            Location.startLocationUpdatesWhenInUse(caller: self.window?.rootViewController)
        }
        
        /* if AppDelegate.fcmtoken == "" {
            AppDelegate.fcmtoken = Messaging.messaging().fcmToken
        } */
        
        // print ("FCMTOKEN \(AppDelegate.fcmtoken)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String (format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print ("Registration succeeded! Token: ", token);
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        AppDelegate.fcmtoken = fcmToken
        print ("TOKEN : " + fcmToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print ("Registration failed!")
        print (error)
    }
    
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground\(notification.request.content.userInfo)")
        
        let infoDict = notification.request.content.userInfo as! NSDictionary
        
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        
        print(dict)
        
        let d : [String : Any] = dict["alert"] as! [String : Any]
        var body : String = d["body"] as! String
        let title : String = d["title"] as! String
        
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ignore", style: UIAlertActionStyle.cancel, handler: nil))
        
        let region = infoDict["gcm.notification.region"] as? String ?? "Unknown region"
        
        /*
        if let latitude = infoDict["gcm.notification.latitude"] as? String, let longitude = infoDict["gcm.notification.longitude"] as? String {
            body = "\(body) lat:\(latitude) long:\(longitude)"
            
            alert.addAction(UIAlertAction(title: "Show", style: UIAlertActionStyle.default, handler: { _ in
                print("should direct to location now")
                
                // TODO finish this
                
                Notifications.post(messageName: "show_last_overdose", object: nil, userInfo: nil)
                
                
            }))
            
            if let lat = Double(latitude), let long = Double(longitude) {
                /*
                self.overdoses.append(Overdose(region: region, reportedTime: Date(), coordinates: CLLocationCoordinate2D(latitude: lat, longitude:  long))) */
                Notifications.post(messageName: "new_overdose", object: nil, userInfo: nil)
            }
            
        } */
        
        print("Title:\(title) + body:\(body)")
        //self.showAlertAppDelegate(title: title,message:body,buttonTitle:"OK",window:self.window!)
        
        
        
        self.window!.rootViewController?.present(alert, animated: false, completion: nil)
        
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("Handle push from background or closed\(response.notification.request.content.userInfo)")
    }
    
    // For iOS 9+
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        // URL not auth related, developer should handle it
        return false
    }

    func converted(_ entry: ManifestEntry, to convertedDatasetURL: URL!)
    {
        sync(self)
        {
            print("converted \(entry.provider!) to: \(convertedDatasetURL.path)")
            AppNotifications.postDataReceived(convertedDatasetURL, type: entry.datasetName)

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
    }
    
    func conversionCompleted(_ entries : [ManifestEntry]!)
    {
        sync(self)
        {
            print("conversion completed")
        }
        
//        let convertedDatasetURLs = Manifest.getLocalDatasetFilesFor(entries)!
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
    
    func requestData(_ fileName : String!, overwrite : Bool!)
    {
        let downloader = ManifestDownloader()
        
        downloader.delegate = self
        
        do
        {
            try downloader.download(fileName, overwrite: overwrite)
        }
        catch
        {
            print("error: \(error.localizedDescription)")
        }
    }
}

