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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        receivedDataReceiver = AppNotifications.addDataReceivedObserver(object: nil)
        {
            (urls) in
            
            logTrace { "enter DataReceived receiver" }
            self.receivedData(urls)
            logTrace { "exit DataReceived receiver" }
        }
        
        AppNotifications.postRequestData("oden-manifest")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func receivedData(_ urls : [URL]!)
    {
        urls.forEach
        {
            (url) in
            
            print(url.path)
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

