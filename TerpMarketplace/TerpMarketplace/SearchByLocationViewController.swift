//
//  SearchByLocationViewController.swift
//  TerpMarketplace
//
//  Created by Kyle Lam on 4/21/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import CoreLocation

class SearchByLocationViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    
    @IBOutlet weak var userLocationLabel: UILabel!
    
    @IBAction func locationServicesOutlet(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    // get user's current location 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        userLocationLabel.text = "\(locValue.latitude), \(locValue.longitude)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
        }
    }

}
