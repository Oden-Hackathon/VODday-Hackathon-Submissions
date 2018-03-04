//
//  Location.swift
//  Safety
//
//  Created by Yudhvir Raj on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import UserNotifications
import Firebase

class Location {
    
    static let LOCATION_CHANGED = "LOCATION_CHANGED"
    static let LOCATION_AUTHORIZATION_CHANGED = "LOCATION_AUTHORIZATION_CHANGED"
    static let LOCATION_PERMISSION_FALIED     = "LOCAITON_PERMISSION_FAILED"
    static let REQUESTED_ALWAYS_AUTHORIZATION = "REQUESTED_ALWAYS_AUTHORIZATION"
    static let REQUESTED_INUSE_AUTHORIZATION = "REQUESTED_INUSE_AUTHORIZATION"
    static let TRACK_ME_AT_ALL_TIMES = "trackMeAtAllTimes"
    static var currentLocation = CLLocation()
    
    // firebase database refs
    lazy var ref: DatabaseReference = Database.database().reference()
    static var userLocationsRef: DatabaseReference!
    
    static var requestedAuthorizationStatus: CLAuthorizationStatus = CLAuthorizationStatus.notDetermined
    
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static func startLocationUpdatesAlways(caller: UIViewController?) {
        
        print("starting location updates always")
        
        requestedAuthorizationStatus = .authorizedAlways
        
        // if we don't have always access
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            
            // if the user has previously denied it.
            if UserDefaults.standard.bool(forKey: Location.REQUESTED_ALWAYS_AUTHORIZATION) {
                locationAuthorizationStatus(viewController: caller, status: CLLocationManager.authorizationStatus())
                return
            } else { // we can request it
                print("don't have always access, requesting now")
                appDelegate.locationManager.requestAlwaysAuthorization()
                UserDefaults.standard.set(true, forKey: Location.REQUESTED_ALWAYS_AUTHORIZATION)
                //UserDefaults.standard.set(true, forKey: Location.REQUESTED_ALWAYS_AUTHORIZATION)
            }
            return // delegate will handle turning on location updates if approved.
        } else {
            locationAuthorizationStatus(viewController: caller, status: CLLocationManager.authorizationStatus())
        }
        
    }
    
    static func stopBackgroundUpdates() {
        print("stopBackgroundUpdates()")
        
        requestedAuthorizationStatus = .notDetermined
        appDelegate.locationManager.stopUpdatingLocation()
        appDelegate.locationManager.stopMonitoringSignificantLocationChanges()
        appDelegate.locationManager.allowsBackgroundLocationUpdates = false;
    }
    
    static func startLocationUpdatesWhenInUse(caller: UIViewController?) {
        
        print("starting location updates when in use")
        
        requestedAuthorizationStatus = .authorizedWhenInUse
        
        let status = CLLocationManager.authorizationStatus()
        
        // if we don't have the required permission already
        if status != .authorizedAlways && status != .authorizedWhenInUse {
            
            // if the user has previously denied it.
            if UserDefaults.standard.bool(forKey: Location.REQUESTED_INUSE_AUTHORIZATION) {
                locationAuthorizationStatus(viewController: caller, status: status)
                return
            } else { // we can request it
                appDelegate.locationManager.requestWhenInUseAuthorization()
            }
            return // delegate will handle turning on location updates if approved.
            
        } else { // already have permission
            locationAuthorizationStatus(viewController: caller, status: status)
        }
        
        //        appDelegate.locationManager.requestWhenInUseAuthorization()
        //        appDelegate.locationManager.requestLocation()
        //        //appDelegate.locationManager.startMonitoringSignificantLocationChanges()
        //        appDelegate.locationManager.startUpdatingLocation()
    }
    
    
    static func locationAuthorizationStatus(viewController: UIViewController?, status: CLAuthorizationStatus) {
        print("Location.swift: locationAuthorizationChanged!")
        
        if requestedAuthorizationStatus == .authorizedWhenInUse {
            UserDefaults.standard.set(true, forKey: Location.REQUESTED_INUSE_AUTHORIZATION)
        }
        
        if requestedAuthorizationStatus == .authorizedAlways {
            UserDefaults.standard.set(true, forKey: Location.REQUESTED_ALWAYS_AUTHORIZATION)
        }
        
        
        Notifications.post(messageName: LOCATION_AUTHORIZATION_CHANGED, object: nil)
        
        if requestedAuthorizationStatus == .authorizedWhenInUse || requestedAuthorizationStatus == .authorizedAlways {
            appDelegate.locationManager.requestLocation()
            appDelegate.locationManager.startUpdatingLocation()
            appDelegate.locationManager.startMonitoringSignificantLocationChanges()
        }
        
        // default
        appDelegate.locationManager.allowsBackgroundLocationUpdates = false
        
        switch status
        {
        case .authorizedAlways:
            print("always is authorized")
            if(requestedAuthorizationStatus == .authorizedAlways) {
                appDelegate.locationManager.allowsBackgroundLocationUpdates = true
            }
            return
            
            
        case .authorizedWhenInUse:
            print("when in use")
            
            if(requestedAuthorizationStatus == .authorizedAlways) {
                locationPermissionFailed(viewController: viewController, message: "Please enable background location in the Settings app")
            }
            
            
        case .denied:
            print("denied")
            if(requestedAuthorizationStatus == .authorizedAlways || requestedAuthorizationStatus == .authorizedWhenInUse) {
                locationPermissionFailed(viewController: viewController, message: "Please enable location services in the Settings app")
            }
            
        case .notDetermined:
            print("not determined")
            
            //            if(requestedAuthorizationStatus == .authorizedAlways || requestedAuthorizationStatus == .authorizedWhenInUse) {
            //                locationPermissionFailed(viewController: viewController, message: "Please enable location services in the Settings app")
            //            }
            
            return
            
        case .restricted:
            print("restricted")
            
            if(requestedAuthorizationStatus == .authorizedAlways || requestedAuthorizationStatus == .authorizedWhenInUse) {
                locationPermissionFailed(viewController: viewController, message: "Location services disabled by your administrator")
            }
            
        }
        
        
        
    }
    
    static func locationPermissionFailed(viewController: UIViewController?, message: String) {
        
        Notifications.post(messageName: Location.LOCATION_PERMISSION_FALIED, object: nil)
        
        let alertController = UIAlertController(title: "Location Denied", message: message, preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        if let controller = viewController {
            controller.present(alertController, animated: true, completion: nil)
        } else {
            print("no controller to present results to")
        }
        
    }
    
    
    
    // decide what to do with the new location. Depends if this user has a moving Naloxone kit
    static func updateUser(location: CLLocation) {

        if AppDelegate.fcmtoken == "" {
            AppDelegate.fcmtoken = Messaging.messaging().fcmToken
        }
        
        print ("token : \(AppDelegate.fcmtoken ?? "")")
        
        let date = Date()// Aug 25, 2017, 11:55 AM
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date) //11
        let minute = calendar.component(.minute, from: date) //55
        let sec = calendar.component(.second, from: date) //33
        let weekDay = calendar.component(.weekday, from: date) //6 (Friday)
        
        print("Time = \(weekDay) \(hour):\(minute):\(sec), Location = Lat:\(location.coordinate.latitude), Long:\(location.coordinate.longitude)")
        
        currentLocation = location
        Notifications.post(messageName: LOCATION_CHANGED, object: location, userInfo: nil)
        
        let loc = ["lat" : location.coordinate.latitude,
                   "lng" : location.coordinate.longitude] as [String : Any]
        
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let value = ["id" : AppDelegate.fcmtoken,
                     "loc" : loc] as [String : Any]
        
        // firebase database reference of statickits
        userLocationsRef = Database.database().reference().child("userLocations")
        
        // locationAngelsRef.setValue(uid)
        userLocationsRef.child(uid).updateChildValues(value)
        
        // locationAngelsRef.child(uid)
        
    }
}

