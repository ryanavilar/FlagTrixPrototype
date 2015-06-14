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
    
    @IBOutlet weak var sbutton: UIButton!
    @IBOutlet weak var stoleButton: UIButton!
    
    private var players = [Int:Player]()
    private var channel = PNChannel()
    private let config = PNConfiguration(publishKey: "pub-c-abb44363-d8fd-4e4e-a3b7-4ee2f2181ac4", subscribeKey: "sub-c-4d55b60a-cc5d-11e4-8fa6-0619f8945a4f", secretKey: "sec-c-MzY3ODQ1YWUtYjU0Mi00MWRlLWEyM2EtZTNiOWM3YTIxYzY4")
    private var bases = [Base]()
    private var you = Player()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation : CLLocationCoordinate2D!
    var currentLoc : CLLocation!
    
    var loginUser : Double!
    
    var centerToUserLocation: Bool = true
    //var rotateEnabled: Bool
    
    var locationManager: CLLocationManager!
  
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is ImagedBasedMKPointAnnotation) {
            let reuseId = "pointIdentifier"
            
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            else {
                anView.annotation = annotation
            }
            
            let ann = annotation as! ImagedBasedMKPointAnnotation
            anView.image = UIImage(named:ann.imageName!)
            anView.canShowCallout = true
            anView.centerOffset = CGPointMake(0, -anView.frame.size.height / 2);
            return anView
        }
        return nil
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
    
    func PubNubStart(){
        PubNub.setDelegate(self)
        PubNub.setConfiguration(self.config)
        PubNub.connect()
        self.channel = PNChannel.channelWithName("flagtrix", shouldObservePresence: false) as! PNChannel
        PubNub.subscribeOn([self.channel])
        addData()
    }
    
    func addData(){
        let message = "{\"lat\":35.70879,\"lng\":139.775327, \"alt\":0.0,\"id\":2}"
        let message6 = "{\"lat\":35.70979,\"lng\":139.776327, \"alt\":0.0,\"id\":3}"
        let message2 = "{\"lat\":35.70579,\"lng\":139.777327, \"alt\":0.0,\"id\":4}"
        let message3 = "{\"lat\":35.70679,\"lng\":139.778327, \"alt\":0.0,\"id\":5}"
        let message4 = "{\"lat\":35.70579,\"lng\":139.776327, \"alt\":0.0,\"id\":0}"
        let message5 = "{\"lat\":35.70479,\"lng\":139.772327, \"alt\":0.0,\"id\":2}"
        PubNub.sendMessage(message, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message6, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message3, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message4, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message5, toChannel: self.channel, compressed: true)
        PubNub.sendMessage(message2, toChannel: self.channel, compressed: true)
        
        PubNub.disconnect()
        
    }
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
 
        // Extract content from received message
        handleOtherLocation(message)
        
    }
    
    func handleOtherLocation(message: PNMessage!){
        let receivedMessage = message.message as! [NSString : Double]
        let lng : CLLocationDegrees! = receivedMessage["lng"]
        let lat : CLLocationDegrees! = receivedMessage["lat"]
        let alt : CLLocationDegrees! = receivedMessage["alt"]
        let login : Double! = receivedMessage["id"]
        let newLocation2D = CLLocationCoordinate2DMake(lat, lng)
        if(loginUser != login){
            if(players.count < 5 && players[Int(login)] == nil){
                var player = Player(coordinate: newLocation2D, altitude: alt, ID : login, has:0, stat:login)
                var namesOfIntegers = [Int: String]()
                players.updateValue(player, forKey: Int(login))
                //println(players.count)
                updateMarker()
            } else{
                var userID : Int = Int(login)
                players[userID]?.changeCoordinate(lat, newLng: lng)
                //println("User ID : \(userID) has been Updated to \(lng),\(lat),\(alt)")
                updateMarker()
            }
        }
    }
    
    func updateMarker(){
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        if(bases.count != 0){
            
            var info1 = ImagedBasedMKPointAnnotation()
            info1.coordinate = bases[0].baseLocation
            info1.title = "Player Base"
            info1.imageName = "blueteam.png"
            mapView.addAnnotation(info1)
            
            var info2 = ImagedBasedMKPointAnnotation()
            info2.coordinate = bases[1].baseLocation
            info2.title = "Enemy Base"
            info2.imageName = "greenteam.png"
            mapView.addAnnotation(info2)
        }
        
        if(you.hasFlag == 1){
            var dropPin3 = ImagedBasedMKPointAnnotation()
            dropPin3.coordinate = you.coordinate
            dropPin3.title = "Enemy ID : \(you.userID)"
            dropPin3.imageName = "blueflag.png"
            mapView.addAnnotation(dropPin3)
        }
        else if(you.hasFlag==2){
            var dropPin3 = ImagedBasedMKPointAnnotation()
            dropPin3.coordinate = you.coordinate
            dropPin3.title = "Enemy ID : \(you.userID)"
            dropPin3.imageName = "greenflag.png"
            mapView.addAnnotation(dropPin3)
        }
        for (num,pl) in players{
            //println("This \(pl.userID) is located \(pl.coordinate.longitude),\(pl.coordinate.latitude),\(pl.altitude)")
            let newLocation2D = CLLocationCoordinate2DMake(pl.coordinate.latitude, pl.coordinate.latitude)
            
            if(pl.status < 3){
                var dropPin3 = ImagedBasedMKPointAnnotation()
                dropPin3.coordinate = pl.coordinate
                dropPin3.title = "Team ID : \(pl.userID)"
                dropPin3.imageName = "team.png"
                mapView.addAnnotation(dropPin3)
            }
            else{
                var dropPin3 = ImagedBasedMKPointAnnotation()
                dropPin3.coordinate = pl.coordinate
                dropPin3.title = "Enemy ID : \(pl.userID)"
                dropPin3.imageName = "enemy.png"
                mapView.addAnnotation(dropPin3)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self;
        
        
        stoleButton.hidden = true
        loginUser = 1
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
        let location = locations.last as! CLLocation

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        currentLocation = center
        currentLoc = location
        if(centerToUserLocation){
            //println("location")
            self.mapView.setRegion(region, animated: true)
            centerToUserLocation=false;
        }
        //println("current position: \(location.coordinate.longitude) , \(location.coordinate.latitude)")
        you.coordinate = center
        if(bases.count != 0){
            var myBaseLoc = CLLocation(latitude: bases[0].baseLocation.latitude, longitude: bases[0].baseLocation.longitude)
            var enemyBaseLoc = CLLocation(latitude: bases[1].baseLocation.latitude, longitude: bases[1].baseLocation.longitude)
            //println(currentLoc.distanceFromLocation(enemyBaseLoc))
            if(currentLoc.distanceFromLocation(enemyBaseLoc) < 20){
                stoleButton.hidden = false
            }else{
                stoleButton.hidden = true
            }
            
        }
        let myPlayer = Player(coordinate: center, altitude: 0.0, ID: loginUser, has: 0, stat: 0)
        let message = "{\"lat\":\(location.coordinate.latitude),\"lng\":\(location.coordinate.longitude), \"alt\": \(location.altitude),\"id\":\(loginUser)}"
        PubNub.sendMessage(myPlayer.message, toChannel: self.channel, compressed: true)
        updateMarker()
    }
    
    func addRadiusCircle(location:CLLocation){
    
        self.mapView.delegate = self
        var overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        var circle = MKCircle(centerCoordinate: location.coordinate, radius: 700 as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    @IBAction func StoleThis(sender: AnyObject) {
        var alert = UIAlertController(title: "Green Flag Stolen", message: "message here", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        you.hasFlag = 2
    }
    
    
    @IBAction func startButton(sender: AnyObject) {
        // Add an annotation
        PubNubStart()
        var newYorkLocation = CLLocationCoordinate2DMake(-27.486622, 153.001531)
        sbutton.hidden = true
        
        var alert = UIAlertController(title: "Game Is Started", message: "Stole the enemy Flag", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

        addRadiusCircle(currentLoc)
        var radius : Double = 0.7
        
        var randomDegree : Double = Double(arc4random_uniform(360))
        
        var degree : Double = randomDegree
        //println("randomDegree = \(randomDegree)")
        var newLocations = coordinatefromCoord(currentLocation, distanceKm: radius , BearingDegrees: degree)
        var newLocations2 = coordinatefromCoord(currentLocation, distanceKm: radius , BearingDegrees: degree+180)

        var getLat = newLocations.latitude
        var getLon = newLocations.longitude
        
        var newLoc = CLLocation(latitude: getLat, longitude: getLon)
        
        println("Old longitude = \(currentLocation.longitude)")
        println("Old latitude = \(currentLocation.latitude)")
        
        
        println("our longitude = \(newLocations.longitude)")
        println("our latitude = \(newLocations.latitude)")
        println("enemy longitude = \(newLocations2.longitude)")
        println("enemy latitude = \(newLocations2.latitude)")
        println("distance= \(currentLoc.distanceFromLocation(newLoc))")
        
        // Drop a pin
        
        var base1 = Base(coordinate: newLocations, statusFlag: false, ID: 0)
        bases.append(base1)
        
        var base2 = Base(coordinate: newLocations2, statusFlag: false, ID: 1)
        bases.append(base2)
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
        //println("Clicked")
        centerToUserLocation=true
        //println("true")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // this is called before the segue happens
    }
    
 

}

