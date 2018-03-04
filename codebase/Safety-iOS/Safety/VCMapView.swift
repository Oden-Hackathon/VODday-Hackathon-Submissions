//
//  VCMapView.swift
//  Preventanyl
//
//  Created by Yudhvir Raj on 2017-09-29.
//  Copyright © 2017 Yudhvir Raj. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension FirstViewController: MKMapViewDelegate {
    
    func mapView (_ mapView: MKMapView!, viewFor annotation: MKAnnotation!) -> MKAnnotationView! {
        return nil
    }
    
    /*
     Function that gets called when a "callout accessory" gets tapped, (for us it the directions button)
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // Check the button that is tapped, in this case if it is the right callout button
        if control == view.rightCalloutAccessoryView {
            // Set appropriate variables, check if works, and then pass into function that opens maps
            if let coordinates = view.annotation?.coordinate, let title = view.annotation?.title {
                openAppleMapsForDirections(coordinates: coordinates, name: title!)
            } else {
                print ("null")
            }
        }
    }
    
    /*
     Function that opens apple maps and asks for directions
     Takes in coordinates and name of destination to input into apple maps
     */
    func openAppleMapsForDirections (coordinates: CLLocationCoordinate2D, name: String) {
        // Set region distance in metres
        let regionDistance:CLLocationDistance = 10000
        
        // Make region coordinate
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        // Create options array to open apple maps with
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        // Create a placemark object from the coordinates
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        
        // Create a map item using the placemark
        let mapItem = MKMapItem(placemark: placemark)
        
        // Set the name of the map item
        mapItem.name = name
        
        // Open apple maps with the configure options
        mapItem.openInMaps(launchOptions: options)
    }
    
    func addMapTrackingButton(){
        let button   = UIButton(type: UIButtonType.custom) as UIButton
        button.frame = CGRect(origin: CGPoint(x:5, y: 25), size: CGSize(width: 35, height: 35))
        button.setImage(#imageLiteral(resourceName: "location"), for: .normal)
        button.backgroundColor = .clear
        
        button.addTarget(self, action: #selector(FirstViewController.centerMapOnUserButtonClicked), for:.touchUpInside)
        MView.addSubview(button)
    }
    
    @objc func centerMapOnUserButtonClicked() {
        MView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
}

