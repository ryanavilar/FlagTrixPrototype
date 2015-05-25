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
import Darwin

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate,PNDelegate{
    
    private var channel = PNChannel()
    private let config = PNConfiguration(publishKey: "pub-c-abb44363-d8fd-4e4e-a3b7-4ee2f2181ac4", subscribeKey: "sub-c-4d55b60a-cc5d-11e4-8fa6-0619f8945a4f", secretKey: "sec-c-MzY3ODQ1YWUtYjU0Mi00MWRlLWEyM2EtZTNiOWM3YTIxYzY4")
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation : CLLocationCoordinate2D!
    var currentLoc : CLLocation!
    
    var loginUser : Int!
    
    var centerToUserLocation: Bool = true
    //var rotateEnabled: Bool
    

    var locationManager: CLLocationManager!
    
    func PubNubStart(){
        PubNub.setDelegate(self)
        PubNub.setConfiguration(self.config)
        PubNub.connect()
        self.channel = PNChannel.channelWithName("flagtrix", shouldObservePresence: false) as PNChannel
        PubNub.subscribeOn([self.channel])
        addData()
        
    }
    
    func addData(){
        let message = "{\"lat\":35.70879,\"lng\":139.775327, \"alt\":0.0,\"id\":3}"
        let message2 = "{\"lat\":35.70579,\"lng\":139.777327, \"alt\":0.0,\"id\":4}"
        let message3 = "{\"lat\":35.70679,\"lng\":139.778327, \"alt\":0.0,\"id\":5}"
        let message4 = "{\"lat\":35.70579,\"lng\":139.776327, \"alt\":0.0,\"id\":6}"
        let message5 = "{\"lat\":35.70479,\"lng\":139.772327, \"alt\":0.0,\"id\":7}"
        PubNub.sendMessage(message, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message2, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message3, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message4, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message5, toChannel: self.channel, compressed: true)
    }
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
 
        // Extract content from received message
        handleOtherLocation(message)
        
    }
    
    func handleOtherLocation(message: PNMessage!){
        let receivedMessage = message.message as [NSString : Double]
        let lng : CLLocationDegrees! = receivedMessage["lng"]
        let lat : CLLocationDegrees! = receivedMessage["lat"]
        let alt : CLLocationDegrees! = receivedMessage["alt"]
        let login : Double! = receivedMessage["id"]
        if(loginUser != Int(login)){
            println("This \(login) is located \(lng),\(lat),\(alt)")
            let newLocation2D = CLLocationCoordinate2DMake(lat, lng)
            var dropPin2 = MKPointAnnotation()
            dropPin2.coordinate = newLocation2D
            dropPin2.title = "Enemy ID : \(login)"
            mapView.addAnnotation(dropPin2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginUser = 1
        PubNubStart()
        
        //predefined location
        locationManager = CLLocationManager()
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        
        self.locationManager.requestWhenInUseAuthorization()
        self.mapView.rotateEnabled=true
        self.mapView.zoomEnabled=true
        self.mapView.pitchEnabled=true
        self.mapView.userInteractionEnabled=true;
        self.mapView.scrollEnabled=true;
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        
        let location = locations.last as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        if(centerToUserLocation){
            println("location")
            currentLocation = center
            currentLoc = location
            self.mapView.setRegion(region, animated: true)
            centerToUserLocation=false;
            
        }
        //println("current position: \(location.coordinate.longitude) , \(location.coordinate.latitude)")
        
        let message = "{\"lat\":\(location.coordinate.latitude),\"lng\":\(location.coordinate.longitude), \"alt\": \(location.altitude),\"id\":\(loginUser)}"
        PubNub.sendMessage(message, toChannel: self.channel, compressed: true)
    }
    
    func addRadiusCircle(location:CLLocation){
    
        self.mapView.delegate = self
        var overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        var circle = MKCircle(centerCoordinate: location.coordinate, radius: 700 as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.02)
            
            circle.lineWidth = 0.5
            return circle
        } else {
            return nil
        }
    }

    @IBAction func startButton(sender: AnyObject) {
        // Add an annotation
        var newYorkLocation = CLLocationCoordinate2DMake(-27.486622, 153.001531)
        

        addRadiusCircle(currentLoc)
        var radius : Double = 0.7
        
        var randomDegree : Double = Double(arc4random_uniform(360))
        
        var degree : Double = randomDegree
        println("randomDegree = \(randomDegree)")
        var newLocations = coordinatefromCoord(currentLocation, distanceKm: radius , BearingDegrees: degree)
        var newLocations2 = coordinatefromCoord(currentLocation, distanceKm: radius , BearingDegrees: degree+180)

        
        var getLat = newLocations.latitude
        var getLon = newLocations.longitude
        
        var newLoc = CLLocation(latitude: getLat, longitude: getLon)
        
        println("Old longitude = \(currentLocation.longitude)")
        println("Old latitude = \(currentLocation.latitude)")
        
        println("enemy longitude = \(newLocations2.longitude)")
        println("enemy latitude = \(newLocations2.latitude)")
        println("distance= \(currentLoc.distanceFromLocation(newLoc))")
        
        // Drop a pin
        var dropPin = MKPointAnnotation()
        dropPin.coordinate = newLocations
        dropPin.title = "Player Base"
        mapView.addAnnotation(dropPin)
        
        var dropPin2 = MKPointAnnotation()
        dropPin2.coordinate = newLocations2
        dropPin2.title = "Enemy Base"
        mapView.addAnnotation(dropPin2)
    }
    
    func radiansFromDegree(degrees: Double)->Double{
        let π : Double = M_PI
        var results:Double = degrees*(π/180)
        return results
    }
    
    func degreesFromRadians(radians: Double)->Double{
        return radians*(180/M_PI)
    }
    
    func coordinatefromCoord(fromCoord: CLLocationCoordinate2D, distanceKm:Double, BearingDegrees:Double)->CLLocationCoordinate2D{
        var distanceRadians : Double = distanceKm / 6371.0
        
        var bearingRadians : Double = radiansFromDegree(BearingDegrees)

        var fromLatRadians : Double = radiansFromDegree(fromCoord.latitude)
        
        var fromLonRadians : Double = radiansFromDegree(fromCoord.longitude)
        
        var toLatRadians = asin(sin(fromLatRadians)*cos(distanceRadians) + cos(fromLatRadians)*sin(distanceRadians)*cos(bearingRadians))
        var toLonRadians = fromLonRadians + atan2(sin(bearingRadians)*sin(distanceRadians)*cos(fromLatRadians),cos(distanceRadians)-sin(fromLatRadians)*sin(toLatRadians))

        toLonRadians = fmod(toLonRadians + 3*M_PI, (2*M_PI)) - M_PI
        var result : CLLocationCoordinate2D = CLLocationCoordinate2DMake(degreesFromRadians(toLatRadians), degreesFromRadians(toLonRadians))
        return result
        
    }
    @IBAction func centerUserLocation(sender: AnyObject) {
        
        println("Clicked")
        centerToUserLocation=true
        println("true")

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // this is called before the segue happens
    }

}

