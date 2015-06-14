//
//  GameData.swift
//  FlagTrixPrototype
//
//  Created by Rifqi Ryan on 27/05/2015.
//  Copyright (c) 2015 Rifqi Ryan. All rights reserved.
//

import Foundation
import MapKit

class Player{
    var coordinate : CLLocationCoordinate2D
    var altitude : Double
    var userID : Double
    var hasFlag : Int
    var status : Double
    var message : String
    
    init(coordinate : CLLocationCoordinate2D, altitude: Double, ID : Double, has:Int, stat:Double){
        self.coordinate = coordinate
        self.altitude = altitude
        self.hasFlag = has
        self.userID = ID
        self.status = stat
        self.message = "{\"lat\":\(self.coordinate.latitude),\"lng\":\(self.coordinate.longitude), \"alt\":\(self.altitude),\"id\":\(self.userID),\"hasFlag\":\(self.hasFlag),\"status\":\(self.status) }"
    }
    
    init(){
        self.coordinate = CLLocationCoordinate2DMake(0,0)
        self.altitude = 0.0
        self.hasFlag = 0
        self.status = 0
        self.userID = 0
        self.message = "{\"lat\":\(self.coordinate.latitude),\"lng\":\(self.coordinate.longitude), \"alt\":\(self.altitude),\"id\":\(self.userID),\"hasFlag\":\(self.hasFlag),\"status\":\(self.status) }"

    }
    
    func changeCoordinate(newLat : CLLocationDegrees, newLng : CLLocationDegrees){
        self.coordinate = CLLocationCoordinate2DMake(newLat,newLng)
    }
    
    func PlayerflagGrabbed(){
        self.hasFlag = 1
    }
    
    func EnemyFlagGrabbed(){
        self.hasFlag = 2
    }
    
    func flagStolen(){
        self.hasFlag = 0
    }
}

class Base{
    var baseLocation : CLLocationCoordinate2D
    var baseFlagStolen : Bool
    var baseId : Int
    
    init(coordinate: CLLocationCoordinate2D, statusFlag : Bool, ID: Int){
        self.baseFlagStolen = statusFlag
        self.baseLocation = coordinate
        self.baseId = ID
    }
    
    func flagStolen(){
        self.baseFlagStolen = true
    }
}

class ImagedBasedMKPointAnnotation: MKPointAnnotation {
    var imageName:String?
}