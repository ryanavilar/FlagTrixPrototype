//
//  ViewController.swift
//  FlagTrixPrototype
//
//  Created by Rifqi Ryan on 21/04/2015.
//  Copyright (c) 2015 Rifqi Ryan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation : CLLocationCoordinate2D!
    
    @IBAction func startButton(sender: AnyObject) {
        // Add an annotation
        var newYorkLocation = CLLocationCoordinate2DMake(-27.4860878, 152.9926336)
        // Drop a pin
        var dropPin = MKPointAnnotation()
        dropPin.coordinate = newYorkLocation
        dropPin.title = "New York City"
        mapView.addAnnotation(dropPin)
        
    }
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

