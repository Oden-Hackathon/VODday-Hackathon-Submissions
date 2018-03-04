//
//  FeedAlert.swift
//  Safety
//
//  Created by Brayden Traas on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseDatabase

class FeedAlert: NSObject {
    
    /* enum AlertType: String {
//        case overdose = "Overdose"
//        case heart = "Heart Attack"
//        case annaphalactic = "Annaphalactic Shock"
//        case athsma = "Athsma Attack"
//        case other = "Other Emergency"

        case fire = "Fire"
        case accident = "Accident"
        case missing = "Missing person"

        case custom = "Custom Alert"

    } */
    
    var id:        String
    var timestamp: Int
    var location:  CLLocation
    var type:      String
    var message:   String
    
    //used when getting data from firebase
    init?(From snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any] else { print("dict is nil")
            return nil
        }
        
//        guard let location = dict["location"] as? [String : String] else {
//            print("location is nil")
//            return nil
//        }
        
        guard let message = dict["message"]  as? String else {
            print ("message is nil")
            return nil
        }
        
        guard let timestamp = dict["timestamp"] as? Int else {
            print("timestamp is nil")
            return nil
        }
        
        guard let type = dict["type"]  as? String else {
            print("type is nil")
            return nil
        }
        
        guard let id = dict["id"]  as? String else {
            print("id is nil")
            return nil
        }
        
        //print ("LOCATION \(location)")
        
        // _feed.append(FeedAlert(timestamp: 1520115759, location: CLLocation(), type: FeedAlert.AlertType.accident, message: "Highway closed at Boundary Rd."))
        
        self.id        = id
        self.timestamp = timestamp
        self.location  = CLLocation()
        self.type      = type
        self.message   = message
    }
    
    init(id: String, timestamp: Int, location:CLLocation, type:String, message:String) {
        self.id        = id
        self.timestamp = timestamp
        self.location  = CLLocation()
        self.type      = type
        self.message   = message
    }
}
