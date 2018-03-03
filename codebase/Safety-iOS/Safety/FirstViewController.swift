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

    @IBAction func helpMe(_ sender: UIButton) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        // 2
        let overdoseAction = UIAlertAction(title: "Overdose", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Overdose")
        })
        
        let heartAttackAction = UIAlertAction(title: "Heart Attack", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Heart Attack")
        })
        
        // asthma
        // anaphylactic shock
        
        let asthmaAction = UIAlertAction(title: "Asthma Attack", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Asthma Attack")
        })
        
        let anaphylacticAction = UIAlertAction(title: "Anaphylactic Attack", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Anaphylactic Attack")
        })
        
        //
        let otherAction = UIAlertAction(title: "Other", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Other")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(overdoseAction)
        optionMenu.addAction(heartAttackAction)
        optionMenu.addAction(asthmaAction)
        optionMenu.addAction(anaphylacticAction)
        optionMenu.addAction(otherAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
}

