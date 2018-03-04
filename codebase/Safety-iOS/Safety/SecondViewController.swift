//
//  SecondViewController.swift
//  Safety
//
//  Created by D'Arcy Smith on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    
    lazy var ref: DatabaseReference = Database.database().reference()
    var feedRef: DatabaseReference!
    
    var allFeedAlerts: [FeedAlert]!
    
    var feedAlerts: [FeedAlert] = {
    
        var _feed = [FeedAlert]()
        
// let newFeedAlert = FeedAlert(timestamp: 0)
        
        
        /* _feed.append(FeedAlert(timestamp: 1520115759, location: CLLocation(), type: FeedAlert.AlertType.accident, message: "Highway closed at Boundary Rd."))
        _feed.append(FeedAlert(timestamp: 1520115459, location: CLLocation(), type: FeedAlert.AlertType.fire,     message: "Fire at 304 Beta Ave.")) */

        
        return _feed
    }()
    
    func initStaticKits() {
        allFeedAlerts = [FeedAlert]()
        
        // Listen for new staticKits in the Firebase database
        // it is aysn.kits will be added one by one;
        //
        feedRef.observe(.childAdded, with: {[weak self] (snapshot) -> Void in
            
            print("childAdded")
            
            if let addedFeedAlert = FeedAlert(From: snapshot) {
                
                
                //                guard let id = Int32(addedskit.id) else {
                //                    print("kit id (\(addedskit.id)) is not an int! Skipping!")
                //                    return
                //                }
                
                
                
                self?.allFeedAlerts.append(addedFeedAlert)
                
                
                //debug info
                print("start printing\n")
                print(addedFeedAlert)
                print("\(self?.allFeedAlerts.count ?? -1)")
            }
            
        })
        
        // Listen for deleted staticKits in the Firebase database
        feedRef.observe(.childRemoved, with: { [weak self] (snapshot) -> Void in
            
            print("childRemoved")
            
            // get value as dictionary
            guard let dict = snapshot.value as? [String:Any] else {
                print("childRemoved: Unable to parse snapshot.value from firebase!")
                return
            }
            
            // get the userid
            guard let rmid = dict["id"] as? String else {
                print("childRemoved: id not found!")
                return
            }
            // remove
            guard let kit = FeedAlert(From: snapshot) else {
                print("childRemoved: Unable to parse Kit from firebase!")
                return
            }
            
            if let index = self?.allFeedAlerts.index(where: {$0.id == rmid}) {
                self?.allFeedAlerts.remove(at: index)
            }
        })
        
        // Listen for deleted staticKits in the Firebase database
        feedRef.observe(.childChanged, with: { [weak self] (snapshot) -> Void in
            
            print("childChanged")
            
            // remove
            guard let dict = snapshot.value as? [String:Any] else { return }
            guard let changeid = dict["id"] as? String else {return }
            if let index = self?.allFeedAlerts.index(where: {$0.id == changeid}) {
                self?.allFeedAlerts.remove(at: index)
            }
            // add back
            if let addedFeedAlert = FeedAlert(From: snapshot) {
                self?.allFeedAlerts.append(addedFeedAlert)
                //                print("start printing\n")
                //                print(addedskit)
                //                print("\(self?.allStaticKits.count ?? -1)")
            }
            
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

//      self.tableView.rowHeight = 140


    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedAlerts.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedAlertCell", for: indexPath) as! FeedAlertViewCell
//
//
//        let row = indexPath.row
//
//
//        orderItems[row].data?.printRow()
//
//        let desc = orderItems[row].data?[OrderItem.description]
//        let qty  = Int(orderItems[row].data?[OrderItem.quantity] ?? 0)
//
//        let mix = desc?.uppercased().contains("MIX") ?? false && !(desc?.uppercased().contains("MIXED") ?? false)
//
//
//        cell.productThumbnail.image = #imageLiteral(resourceName: "PetalsGray")
//        if let partNo = orderItems[row].data?[OrderItem.partNo] {
//            cell.productThumbnail.downloadedFrom(link: "https://\(IntranetTools.DOMAINNAME)/images/product_photos/\(partNo)-thumb.png", cache: true, fallbackImage: #imageLiteral(resourceName: "PetalsGray"))
//        }
//
//
//        //cell.textLabel?.text = orderItems[row].data?[OrderItem.description]
//        cell.descriptionLabel.text = desc
//        cell.quantityLabel.text = mix && qty == 0 ? "" : "\(qty)"
//
//        cell.descriptionLabel.font = mix ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
//
//        cell.descriptionLabel.textAlignment = mix && qty == 0 ? .center : .left
//
//        let shade: CGFloat = 0xEE/0xFF
//
//        cell.backgroundColor = mix ? UIColor.init(red: 0xFF, green: shade, blue: 0xFF, alpha: 0xFF) : .white
//

        cell.alertTitleLabel.text = feedAlerts[indexPath.row].type

        let calendar = Calendar.autoupdatingCurrent


        let date = Date(timeIntervalSince1970: Double(feedAlerts[indexPath.row].timestamp))




        let dateFormatter = DateFormatter()
// let df = dateFormatter.timeSince(from: date, numericDates: true)



// dateFormatter.timeSince(from: Date.init(timeInterval: 600, since: date), numericDates: true)  // 9 minutes ago


        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)


        let components = gregorian?.components([.day, .month, .year, .hour, .minute], from: date, to: Date(), options: .matchFirst)




// let components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: date, to: Date())

//        let components = calendar.components([ .Minute, .Hour, .Day ],
//                fromDate: , toDate: Date(), options: [])

        let minute = components!.minute ?? 0
        let hour = components!.hour ?? 0
        let day = components!.day ?? 0

        var text = ""
        if(hour > 0) {
            text += "\(hour)h, "
        }

        cell.timeLabel.text = "\(text) \(minute ?? 0) min ago"

        cell.messageLabel.text = feedAlerts[indexPath.row].message



// cell.timeLabel.text = String(feedAlerts[indexPath.row].timestamp)
        
        
        return cell
        
        
    }

    
//    override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
//    {
//        return 85 //Your custom row height
//    }

    
    
    
}
