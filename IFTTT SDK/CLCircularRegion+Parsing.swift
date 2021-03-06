//
//  CLCircularRegion+Parsing.swift
//  IFTTT SDK
//
//  Copyright © 2020 IFTTT. All rights reserved.
//

import Foundation
import CoreLocation

struct Constants {
    static let IFTTTRegionPrefix = "ifttt"
}

extension CLRegion {
    /// Determines whether or not the region is an region associated with an IFTTT connection.
    var isIFTTTRegion: Bool {
        return identifier.lowercased().starts(with: Constants.IFTTTRegionPrefix)
    }
}

extension CLCircularRegion {
    private static let locationManager = CLLocationManager()
    
    func toUserDefaultsJSON() -> JSON {
        return [
            "latitude": center.latitude,
            "longitude": center.longitude,
            "radius": radius,
            "identifier": identifier
        ]
    }
    
    convenience init?(parser: Parser) {
        guard let latitude = parser["latitude"].double,
            let longitude = parser["longitude"].double,
            let radius = parser["radius"].double,
            let identifier = parser["identifier"].string else {
                return nil
        }
        
        let center = CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees,
                                            longitude: longitude as CLLocationDegrees)
        
        self.init(center: center,
                  radius: radius as CLLocationDistance,
                  identifier: identifier)
    }
    
    convenience init?(defaultFieldParser: Parser, triggerId: String) {
        let locationParser = defaultFieldParser["default_value"]
        self.init(parser: locationParser, triggerId: triggerId)
    }
    
    convenience init?(parser: Parser, triggerId: String) {
        guard let latitude = parser["lat"].double,
            let longitude = parser["lng"].double,
            var radius = parser["radius"].double else {
                return nil
        }
        
        radius = min(radius, CLCircularRegion.locationManager.maximumRegionMonitoringDistance)
        
        let center = CLLocationCoordinate2D(latitude: latitude as CLLocationDegrees, longitude: longitude as CLLocationDegrees)
        let identifier = triggerId.addIFTTTPrefix()
        
        self.init(center: center,
                  radius: radius as CLLocationDistance,
                  identifier: identifier)
    }
    
    convenience init?(json: JSON, triggerId: String) {
        let parser = Parser(content: json)
        let locationParser = parser["value"]
        self.init(parser: locationParser, triggerId: triggerId)
    }
}

extension String {
    func addIFTTTPrefix() -> String {
        return "\(Constants.IFTTTRegionPrefix)_\(self)"
    }
    
    func stripIFTTTPrefix() -> String {
        let splitString = split(separator: "_")
        if splitString.count == 2 && splitString.first?.lowercased() == "ifttt" {
            return String(splitString[1])
        } else {
            return self
        }
    }
}

