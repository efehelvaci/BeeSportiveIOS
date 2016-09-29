//
//  EventFormViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 3.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation
import Async
import Firebase
import FTIndicator
import MapKit

class EventFormViewController: FormViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var location : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        form +++ Section()
            <<< TextRow(){ row in
                row.placeholder = "Event name"
                row.tag = "Name"
            }
            <<< TextAreaRow() {
                $0.placeholder = "Description"
                $0.textAreaHeight = .Dynamic(initialTextViewHeight: 110)
                $0.tag = "Description"
            }
            +++ Section("When & Where & What")
            <<< DateRow(){
                $0.title = "Date"
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0)
                $0.tag = "Date"
            }
            <<< TimeInlineRow(){
                $0.title = "Time"
                $0.value = NSDate()
                $0.tag = "Time"
            }
            <<< LocationRow(){
                $0.value = CLLocation()
                $0.title = "Location Pin"
                
                $0.tag = "LocationPin"
            }
            <<< TextRow(){ row in
                row.title = "Location name"
                row.placeholder = "Ex. Caddebostan Sahil"
                row.tag = "LocationName"
            }
            <<< AlertRow<String>() {
                $0.title = "Level"
                $0.selectorTitle = "Levels"
                $0.options = levels
                $0.value = "Not chosen"
                $0.tag = "Level"
                }.onChange { row in
                    print(row.value)
                }
                .onPresent{ _, to in
                    to.view.tintColor = .grayColor()
            }
            <<< AlertRow<String>() {
                $0.title = "Branch"
                $0.selectorTitle = "Branchs"
                $0.options = branchs
                $0.value = "Not chosen"
                $0.tag = "Branch"
                }.onChange { row in
                    print(row.value)
                }
                .onPresent{ _, to in
                    to.view.tintColor = .grayColor()
            }
            <<< IntRow() {
                $0.title = "Join Number"
                $0.value = 10
                $0.tag = "MaxJoin"
            }
            +++ Section()
            <<< ButtonRow("Add Event") { (row: ButtonRow) -> () in
                row.title = row.tag
                row.tag = "AddButton"
                row.onCellSelection({ (cell, row) in
                    
                    if let name = self.form.rowByTag("Name")?.baseValue as? String,
                        let description = self.form.rowByTag("Description")?.baseValue as? String,
                        let date = self.form.rowByTag("Date")?.baseValue as? NSDate,
                        let time = self.form.rowByTag("Time")?.baseValue as? NSDate,
                        let locationPin = self.form.rowByTag("LocationPin")?.baseValue as? CLLocation,
                        let locationName = self.form.rowByTag("LocationName")?.baseValue as? String,
                        let level = self.form.rowByTag("Level")?.baseValue as? String,
                        let branch = self.form.rowByTag("Branch")?.baseValue as? String,
                        let maxJoin = self.form.rowByTag("MaxJoin")?.baseValue as? Int
                    {
                        self.view.userInteractionEnabled = false
                        
                        let dateFormatter = NSDateFormatter()
                    
                        dateFormatter.dateFormat = "dd"
                        let day = dateFormatter.stringFromDate(date)
                    
                        dateFormatter.dateFormat = "M"
                        let month = dateFormatter.stringFromDate(date)
                    
                        dateFormatter.dateFormat = "yyyy"
                        let year = dateFormatter.stringFromDate(date)
                    
                        dateFormatter.dateFormat = "HH:mm"
                        let hour = dateFormatter.stringFromDate(time)
                        
                        let uuid = NSUUID().UUIDString
                    
                        let newEvent = [
                            "id" : uuid,
                            "creatorID" : (FIRAuth.auth()?.currentUser?.uid)!,
                            "creatorImageURL" : (FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!,
                            "creatorName" : (FIRAuth.auth()?.currentUser?.displayName)!,
                            "name" : name,
                            "branch" : branch,
                            "location" : locationName,
                            "locationLat" : String(locationPin.coordinate.latitude),
                            "locationLon" : String(locationPin.coordinate.longitude),
                            "time" : hour,
                            "year" : year,
                            "month" : month,
                            "day" : day,
                            "maxJoinNumber" : String(maxJoin),
                            "level" : level,
                            "description" : description
                        ]
                    
                        REF_EVENTS.child(uuid).setValue(newEvent)
                        REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("eventsCreated").childByAutoId().setValue(uuid)
                        FTIndicator.showNotificationWithImage(UIImage(named: "Success"), title: "Yay!", message: "Event successfully created!")
                    
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
            <<< ButtonRow("Cancel") { (row: ButtonRow) -> () in
                row.title = row.tag
                row.onCellSelection({ (cell, row) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        self.form.rowByTag("LocationPin")?.baseValue = self.location
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
}
