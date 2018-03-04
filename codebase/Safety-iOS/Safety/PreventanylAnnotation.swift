//
//  PreventanylAnnotation.swift
//  Safety
//
//  Created by Yudhvir Raj on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import MapKit

protocol PreventanylAnnotation: MKAnnotation {
    var identifier: String { get }
    var color: UIColor { get }
    var image: UIImage { get }
    
    var defaultTitle: String { get }
    
    //var view: MKAnnotationView { get }
}

