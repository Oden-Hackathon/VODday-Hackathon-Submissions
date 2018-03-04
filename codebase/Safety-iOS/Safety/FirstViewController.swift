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
import Firebase
import FirebaseDatabase

class FirstViewController: UIViewController, MKMapViewDelegate {
    var receivedDataReceiver: NSObjectProtocol?

    @IBOutlet weak var MView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var observer:  NSObjectProtocol?
    var centered: Bool = false
    var selfAnnotation: MKPointAnnotation?
    
    var overdoseMarkerMap : Dictionary<String, OverdoseAnnotation> = Dictionary<String, OverdoseAnnotation>()

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
    
    
    lazy var ref: DatabaseReference = Database.database().reference()
    var helpObjectRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        helpObjectRef = ref.child("helpObjects")
        
        MView.delegate = self
        
        receivedDataReceiver = AppNotifications.addDataReceivedObserver(object: nil)
        {
            (url, type) in
            
            logTrace { "enter DataReceived receiver" }
            self.receivedData(url, type: type)
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

    private func receivedData(_ url : URL!, type: String!)
    {
        do
        {
            let locations = try AutomatedExternalDefibrillator.getAutomatedExternalDefibrillators(from: url)
            plotPoints(locations, type: type)
        }
        catch
        {
            print("\(url.path) \(error.localizedDescription)")
        }
    }
    
    private func plotPoints(_ objects : AutomatedExternalDefibrillator, type: String!)
    {
        objects.features!.forEach
        {
            (feature) in


            let coordinate = CLLocationCoordinate2D(latitude: feature.geometry!.coordinates![1],
                                                    longitude: feature.geometry!.coordinates![0])
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotation.title      = feature.properties!.name!
            annotation.subtitle   = "Hospital" // TODO
            self.MView.addAnnotation(annotation)
            
            // print(annotation.title!)
        }

    }
    
    func initHelpObjects () {
        //overdoses = [Overdose]()
        
        // Listen for new staticKits in the Firebase database
        // it is aysn.kits will be added one by one;
        //
        helpObjectRef.observe(.childAdded, with: {[weak self] (snapshot) -> Void in
            
            print("overDoses: childAdded")
            
            if let addedOverdose = HelpObject(From: snapshot) {
                self?.addOverdose(addedOverdose)
            } else {
                
                print("error! overdose from snapshot not parseable!")
                print(snapshot)
            }
            
            
            // prolly wanna remove this after we refer to firebase db
            
            //            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            //
            //            for overdose in appDelegate.overdoses {
            //                self?.addOverdose(overdose)
            //            }
            //
            
            
        })
        
        // Listen for deleted staticKits in the Firebase database
        helpObjectRef.observe(.childRemoved, with: { [weak self] (snapshot) -> Void in
            
            print("overdoses childRemoved")
            
            guard let overdose = HelpObject(From: snapshot) else {
                return
            }
            
            let id: String = overdose.id
            
            if let marker = self?.overdoseMarkerMap[id] {
                self?.overdoseMarkerMap.removeValue(forKey: id)
                self?.MView.removeAnnotation(marker)
            }
            //            }
            //
            //    
            //
            //
            //
            //
            //            self?.overdoseMarkerMap.removeValue(forKey: id)
            //            if let index = self?.allStaticKits.index(where: {$0.userId == rmuid}) {
            //                self?.allStaticKits.remove(at: index)
            //            }
        })
        
        
        // Listen for deleted staticKits in the Firebase database
        helpObjectRef.observe(.childChanged, with: { [weak self] (snapshot) -> Void in
            
            print("overdoses: childChanged")
            
            guard let overdose = HelpObject(From: snapshot) else {
                return
            }
            
            let id = overdose.id
            
            // remove
            if let marker = self?.overdoseMarkerMap[id] {
                self?.overdoseMarkerMap.removeValue(forKey: id)
                self?.MView.removeAnnotation(marker)
            }
            
            // add back
            //self?.allStaticKits.append(addedskit)
            
            self?.addOverdose(overdose)
            
            //                print("start printing\n")
            //                print(addedskit)
            //                print("\(self?.allStaticKits.count ?? -1)")
            
            
            
            
        })
    }
    
    func addOverdose(_ addedOverdose: HelpObject) {
        
        let location = addedOverdose.coordinates
        
        DispatchQueue.main.async {
            print("adding overdose from \(addedOverdose.region ?? "Unknown") to map")
            
            
            //            let userCoordinate = self.selfAnnotation?.coordinate ?? CLLocationCoordinate2D(latitude: 49.205323, longitude: -122.930271)
            //
            //            let fakeOverdose1 = OverdoseAnnotation()
            //            fakeOverdose1.coordinate = CLLocationCoordinate2D(latitude: userCoordinate.latitude + 0.07, longitude: userCoordinate.longitude + 0.04)
            
            let id = addedOverdose.id
            
            let overdose = OverdoseAnnotation()
            overdose.coordinate = location
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            
            let hhmm = dateFormatter.string(from: addedOverdose.reportedTime)
            overdose.title = "Reported Overdose at (\(hhmm))"
            
            
            self.overdoseMarkerMap[id] = overdose
            self.MView.addAnnotation(overdose)
        }
        
        //self.overdoses.append(addedOverdose)
        //self?.addOverdose(addedOverdose)
        
        //                let time = addedOverdose.reportedTime
        //
        //                let title = "Reported Overdose at  "
        //
        //                let newMarker = Marker (title: addedOverdose.displayName,
        //                                        locationName: "\(addedOverdose.address.streetAddress) \(addedOverdose.address.city)",
        //                    discipline: "Overdose",
        //                    coordinate: CLLocationCoordinate2D(latitude: addedOverdose.coordinates.lat, longitude: addedOverdose.coordinates.long))
        //                self?.MapView.addAnnotation(newMarker)
        //                self?.staticKitMarkerMap[id] = newMarker
        //
        //debug info
        print("start printing\n")
        print(addedOverdose)
        //print("\(self.overdoses.count ?? -1)")
        
        
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
        
        let coordinates = Location.currentLocation.coordinate
        
        let helpObject = HelpObject(region: nil, reportedTime: Date(), coordinates:
            CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude))
        
        print ("https://preventanyl.com/regionfinder.php?id=\(helpObject.id)&lat=\(Location.currentLocation.coordinate.latitude)&long=\(Location.currentLocation.coordinate.longitude)")
        if let url = URL(string: "https://preventanyl.com/regionfinder.php?id=\(helpObject.id)&lat=\(Location.currentLocation.coordinate.latitude)&long=\(Location.currentLocation.coordinate.longitude)") {
            var request = URLRequest(url: url)
            request.setValue("Safety App", forHTTPHeaderField: "User-Agent")
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                
                print (error as Any?)
                
                if let data = data {
                    print (data)
                    // data is a response string
                }
            }
            
            
            
            var d = DateFormatter()
            d.dateFormat = "yyyy-MM-dd"
            
            
            let value = ["id" : helpObject.id,
                         "date" : d.string(from: helpObject.reportedTime),
                         "timestamp" : helpObject.reportedTime.timeIntervalSince1970,
                         "latitude" : coordinates.latitude,
                         "longitude" : coordinates.longitude
                ] as [String : Any]
            
            
            print("\nAdding overdose child:\(helpObject.id)\n")
            print (helpObjectRef.child(helpObject.id))
            helpObjectRef.child(helpObject.id).updateChildValues(value)
            
            task.resume()
        }
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
    
    // https://www.hackingwithswift.com/read/19/3/annotations-and-accessory-views-mkpinannotationview
    private func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.subtitle! == "Hospital"
        {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.description)
            
            if annotationView == nil
            {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.description)
                annotationView!.canShowCallout = false
                annotationView!.tintColor = .green
            }
            else
            {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
}

