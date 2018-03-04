//
//  Automated External Defibrillator.swift
//  Safety
//
//  Created by D'Arcy Smith on 2018-03-03.
//  Copyright © 2018 D'Arcy Smith. All rights reserved.
//

import Foundation
import EVReflection

public class AutomatedExternalDefibrillator : EVObject
{
    public var type : String?
    public var features : [Feature]?
    
    public class Feature : EVObject
    {
        public var type : String?
        public var geometry : Geometry?
        public var properties : Properties?
        
        public class Geometry : EVObject
        {
            public var type : String?
            public var coordinates: [Double]?
        }
        
        public class Properties : EVObject
        {
            public var name : String?
            public var address : String?
            public var location : String?
            public var phone : String?
        }
    }
    
    public static func getAutomatedExternalDefibrillators(from url: URL!) throws -> AutomatedExternalDefibrillator
    {
        let json = try String(contentsOf: url, encoding: .utf8)
        let data = AutomatedExternalDefibrillator(json: json)
        
        return data
    }
}
