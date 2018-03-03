//
//  FeedAlert.swift
//  Safety
//
//  Created by Brayden Traas on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import CoreLocation

struct FeedAlert {
    
    enum AlertType: String {
//        case overdose = "Overdose"
//        case heart = "Heart Attack"
//        case annaphalactic = "Annaphalactic Shock"
//        case athsma = "Athsma Attack"
//        case other = "Other Emergency"

        case fire = "Fire"
        case accident = "Accident"
        case missing = "Missing person"

        case custom = "Custom Alert"

    }
    
    var timestamp: Int
    var location: CLLocation
    var type: AlertType
}
