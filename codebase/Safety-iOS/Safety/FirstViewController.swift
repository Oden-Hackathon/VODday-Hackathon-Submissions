//
//  FirstViewController.swift
//  Safety
//
//  Created by D'Arcy Smith on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import UIKit
import MapKit
import TraceLog

class FirstViewController: UIViewController {
    var receivedDataReceiver: NSObjectProtocol?

    @IBOutlet weak var MView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var observer:  NSObjectProtocol?
    var centered: Bool = false
    var selfAnnotation: MKPointAnnotation?

    var onColor = UIColor.yellow
    var offColor = UIColor.darkGray

    var heartOn = false
    var needleOn = false
    var medicalOn = false

    @IBOutlet var heartButton: UIButton!
    @IBOutlet var needleButton: UIButton!
    @IBOutlet var medical: UIButton!
    
    @IBAction func heartClick(_ sender: Any) {
        
        heartOn = !heartOn
        print("heart click \(heartOn)")
        
        (sender as! UIButton).tintColor = heartOn ? onColor : offColor

        reloadPins()
        
    }
    
    @IBAction func needleClick(_ sender: Any) {
        
        needleOn = !needleOn
        print("needle click \(needleOn)")
        
        (sender as! UIButton).tintColor = needleOn ? onColor : offColor
        reloadPins()
        
    }
    
    @IBAction func medicalClick(_ sender: Any) {
        
        medicalOn = !medicalOn
        print("medical click: \(medicalOn)")

        (sender as! UIButton).tintColor = medicalOn ? onColor : offColor
        reloadPins()
        
    }

    func reloadPins() {
        // Todo this
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receivedDataReceiver = AppNotifications.addDataReceivedObserver(object: nil)
        {
            (urls) in
            
            logTrace { "enter DataReceived receiver" }
            self.receivedData(urls)
            logTrace { "exit DataReceived receiver" }
        }
        
        AppNotifications.postRequestData("oden-manifest", overwrite: true)
        observer = Notifications.addObserver(messageName: Location.LOCATION_CHANGED, object: nil) { _ in
            self.updateUserLocation(location: Location.currentLocation)
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        Location.startLocationUpdatesWhenInUse(caller: self)
        var coord: CLLocationCoordinate2D!
        coord = appDelegate.locationManager.location?.coordinate
        if (coord != nil) {
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            
            //            marker = Marker (title: "Marker",
            //                                 locationName:"User Position",
            //                                 discipline: "You",
            //                                 coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:  location.coordinate.longitude))
            
            selfAnnotation = MKPointAnnotation()
            selfAnnotation?.coordinate = coord
            
            centerMapOnLocation (location: location)
            MView.addAnnotation (selfAnnotation!)
        }
        
        addMapTrackingButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUserLocation(location: CLLocation) {
        
        if !centered {
            centerMapOnLocation(location: location)
        }
        centered = true
        
        //        let marker = Marker (title: "Marker",
        //                             locationName:"User Position",
        //                             discipline: "You",
        //                             let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        //        centerMapOnLocation (location: location)
        //        MapView.addAnnotation (marker)
        
        if self.selfAnnotation != nil {
            self.selfAnnotation!.coordinate = location.coordinate
            
        }
        
        
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation (location: CLLocation) {
        let doubleRegionRadius = regionRadius * 2.0;
        let coordinateRadius = MKCoordinateRegionMakeWithDistance (
            location.coordinate, doubleRegionRadius, doubleRegionRadius)
        MView.setRegion (coordinateRadius, animated:true)
    }

    private func receivedData(_ urls : [URL]!)
    {
        urls.forEach
        {
            (url) in

            do
            {
                let locations = try AutomatedExternalDefibrillator.getAutomatedExternalDefibrillators(from: url)

                plotPoints(locations)
            }
            catch
            {
                print("\(url.path) \(error.localizedDescription)")
            }
        }
    }
    
    private func plotPoints(_ objects : AutomatedExternalDefibrillator)
    {
        objects.features!.forEach
        {
            (feature) in


            let coordinate = CLLocationCoordinate2D(latitude: feature.geometry!.coordinates![1],
                                                    longitude: feature.geometry!.coordinates![0])
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotation.title      = feature.properties!.name!
            self.MView.addAnnotation(annotation)
            
            print(annotation.title!)
        }

    }
    
    func helpAlert (title: String) {
        let message = "Please call 911 if you haven't already, someone will be be helping you shortly"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Okay")
        }
        
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func helpMe(_ sender: UIButton) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let overdoseAction = UIAlertAction(title: "Overdose", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Overdose")
            self.helpAlert (title : "Overdose")
        })
        
        let heartAttackAction = UIAlertAction(title: "Heart Attack", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Heart Attack")
            self.helpAlert (title : "Heart Attack")
        })
        
        let asthmaAction = UIAlertAction(title: "Asthma Attack", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Asthma Attack")
            self.helpAlert (title : "Asthma Attack")
        })
        
        let anaphylacticAction = UIAlertAction(title: "Anaphylactic Attack", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Anaphylactic Attack")
            self.helpAlert (title : "Anaphylactic Attack")
        })
        
        let otherAction = UIAlertAction(title: "Other", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Other")
            self.helpAlert (title : "Other")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        // Option Menus
        optionMenu.addAction(overdoseAction)
        optionMenu.addAction(heartAttackAction)
        optionMenu.addAction(asthmaAction)
        optionMenu.addAction(anaphylacticAction)
        optionMenu.addAction(otherAction)
        optionMenu.addAction(cancelAction)
        
        // Present
        self.present(optionMenu, animated: true, completion: nil)
    }
    
}

