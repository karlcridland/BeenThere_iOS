//
//  PageAddress.swift
//  Been There
//
//  Created by Karl Cridland on 20/08/2020.
//  Copyright © 2020 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PageAddress: Page {
    
    let uid: String
    var address: String?
    var map = MKMapView()
    
    init(uid: String) {
        self.uid = uid
        super .init(title: "location")
        Firebase.shared.getAddress(self)
        map.mapType = .hybrid
        map.showsCompass = true
        map.showsScale = true
        map.showsUserLocation = true
        map.tintColor = .white
    }
    
    func update(){
        map.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(map)
        let geoCoder = CLGeocoder()
        if let add = address{
            geoCoder.geocodeAddressString(add.replacingOccurrences(of: "\n", with: ", ")) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    return
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                if let profile = Settings.shared.getProfile(self.uid){
                    annotation.title = profile.name
                    annotation.subtitle = add
                    
                    
                }
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: span)
                self.map.setRegion(region, animated: true)
                self.map.addAnnotation(annotation)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
