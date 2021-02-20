//
//  Location.swift
//  Kaktus
//
//  Created by Karl Cridland on 12/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    
    public static let shared = Location()
    var locationManager: CLLocationManager?
    
    private init(){
        locationManager = CLLocationManager()
        if let home = Settings.shared.home{
            locationManager?.delegate = home
        }
        locationManager?.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
//                    print("weeee wooooo")
                }
            }
        }
    }
    
    func get() -> CLLocationCoordinate2D?{
        if let location = locationManager?.location{
            return location.coordinate
        }
        return nil
    }
}
