//
//  OverdoseAnnotation.swift
//  
//
//  Created by Yudhvir Raj on 2018-03-03.
//

import Foundation
import MapKit

class OverdoseAnnotation: MKPointAnnotation, PreventanylAnnotation {
    let identifier = "overdose-annotation"
    let color = UIColor.red
    let image = #imageLiteral(resourceName: "timer")
    let defaultTitle = "Overdose"
}

