//
//  HelpObject.swift
//  Safety
//
//  Created by Yudhvir Raj on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import MapKit

import Firebase
import FirebaseDatabase


class HelpObject: NSObject {
    
    var id: String
    var region : String?
    var reportedTime : Date
    var coordinates : CLLocationCoordinate2D
    
    // data set...
    //     $data = ["region" => $region, "date"=>$date,"timestamp"=>$time,"latitude"=>$lat,"longitude"=>$long];
    
    
    //used when getting data from firebase
    init?(From snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any] else {
            print("dict is nil")
            return nil
        }
        
        let region = dict["region"]  as? String ?? ""
        
        
        guard let date = dict["date"] as? String else {
            print("date is nil")
            return nil }
        
        /*
         
         timestamp is nil
         error! overdose from snapshot not parseable!
         Snap (1511929609,8266_49,2503090091265_-123,001969296547) {
         date = "2017-11-28";
         id = "1511929609,8266_49,2503090091265_-123,001969296547";
         latitude = "49.25030900912655";
         longitude = "-123.0019692965467";
         timestamp = "1511929609.826604";
         }
         
         */
        
        guard let __timestamp = dict["timestamp"] else {
            print("timestamp is nil")
            return nil
        }
        
        let _timestamp = "\(__timestamp)"
        
        guard let _latitude = dict["latitude"] else {
            print("latitude is nil")
            return nil }
        guard let _longitude = dict["longitude"] else {
            
            
            print("longitude is nil")
            
            
            return nil }
        
        
        guard let timestamp = Double(_timestamp) else {
            print("timstamp unparseable!")
            return nil
        }
        
        guard let latitude = Double("\(_latitude)"), let longitude = Double("\(_longitude)")  else {
            print("lat/long unparseable!")
            return nil
        }
        
        
        
        
        //        guard let timestamp = Double(_timestamp) else {
        //            print("timestamp invalid")
        //            return nil
        //        }
        
        self.region  = region
        self.reportedTime = Date(timeIntervalSince1970: timestamp)
        self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
        self.id = dict["id"] as? String ?? HelpObject.getId(timestamp: timestamp, latitude: latitude, longitude: longitude)
        
        
        //        self.coordinates.latitude = latitude
        //        self.coordinates.longitude = longitude
        
    }
    
    
    init(region: String?, reportedTime: Date, coordinates: CLLocationCoordinate2D) {
        self.region = region
        self.reportedTime = reportedTime
        self.coordinates = coordinates
        
        self.id = HelpObject.getId(timestamp: reportedTime.timeIntervalSince1970, latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        //self.id = "\(reportedTime.timeIntervalSince1970)_\(coordinates.latitude)_\(coordinates.longitude)".replacingOccurrences(of: ".", with: ",")
    }
    
    private static func getId(timestamp: Double, latitude: Double, longitude: Double) -> String {
        return "\(timestamp)_\(latitude)_\(longitude)".replacingOccurrences(of: ".", with: ",")
    }
    
    
    
    //
    //    //function to get the Address of the dictinary type to insert into the firebase database as json
    //    func get_StaticKit_Dict_upload()-> Dictionary<String,Any> {
    ////        let addressDict = self.address.get_Address_Dict_upload()
    ////        let coorDict = coordinates.get_Coordinates_Dict_upload()
    ////
    //
    //
    //        let staticKit: [String:Any]  =
    //            [   "address" : addressDict["address"]!,
    //                "coordinates" : coorDict["coordinates"]!,
    //                "comments" : comments,
    //                "displayName": displayName,
    //                "id" : id,
    //                "phone" : phone,
    //                "userId" : userId
    //        ]
    //        return staticKit
    //
    //    }
    
    //    override var description: String {
    //        get {
    //            let str = " Address :\n \(address)\n  coordinates:\n \(coordinates)\n comments: \(comments)\n displayName : \(displayName)\n id: \(id)\n phone: \(phone)\n userId: \(userId)"
    //            return str
    //        }
    //    }
}


