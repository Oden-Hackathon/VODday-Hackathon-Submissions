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
    }
    
}

