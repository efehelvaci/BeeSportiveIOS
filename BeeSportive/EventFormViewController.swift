//
//  EventFormViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 3.09.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FTIndicator
import MapKit
import Eureka

class EventFormViewController: FormViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var location : CLLocation? {
        didSet{
            self.form.rowBy(tag: "LocationPin")?.baseValue = location
            self.form.rowBy(tag: "LocationPin")?.reload()
            locationManager.stopUpdatingLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layoutIfNeeded()
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        LabelRow.defaultCellUpdate = { cell, row in cell.detailTextLabel?.textColor = .orange  }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createEvent))
        
        form =

        form +++ Section("Main Details")
                <<< TextRow(){ row in
                    row.placeholder = "Event name"
                    row.tag = "Name"
                }
                <<< TextAreaRow() {
                    $0.placeholder = "Description"
                    $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                    $0.tag = "Description"
                }

            +++ Section("When & Where & What")
                <<< DateRow(){
                    $0.title = "Date"
                    $0.value = Date()
                    $0.tag = "Date"
                }
                <<< TimeInlineRow(){
                        $0.title = "Time"
                        $0.value = Date()
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
                        $0.options = levels
                        $0.value = "Not chosen"
                        $0.tag = "Level"
                        }
                <<< AlertRow<String>() {
                        $0.title = "Branch"
                        $0.selectorTitle = "Branchs"
                        $0.options = branchs
                        $0.value = "Not chosen"
                        $0.tag = "Branch"
                        }
                <<< IntRow() {
                        $0.title = "Join Number"
                        $0.value = 10
                        $0.tag = "MaxJoin"
                    }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
//        self.form.rowByTag("LocationPin")?.baseValue = self.location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func createEvent() {
        
        let time = self.form.rowBy(tag: "Time")?.baseValue as? Date
        let date = self.form.rowBy(tag: "Date")?.baseValue as? Date
        
        print(time!)
        print(date!)
        
        print(time?.isGreaterThanDate(dateToCompare: Date() as NSDate))
        print(time?.isLessThanDate(dateToCompare: Date() as NSDate))
        
        print(date!.equalToDate(dateToCompare: Date() as NSDate))
        
        if let name = self.form.rowBy(tag: "Name")?.baseValue as? String,
            let description = self.form.rowBy(tag: "Description")?.baseValue as? String,
            let date = self.form.rowBy(tag: "Date")?.baseValue as? Date,
            let time = self.form.rowBy(tag: "Time")?.baseValue as? Date,
            let locationPin = self.form.rowBy(tag: "LocationPin")?.baseValue as? CLLocation,
            let locationName = self.form.rowBy(tag: "LocationName")?.baseValue as? String,
            let level = self.form.rowBy(tag: "Level")?.baseValue as? String,
            let branch = self.form.rowBy(tag: "Branch")?.baseValue as? String,
            let maxJoin = self.form.rowBy(tag: "MaxJoin")?.baseValue as? Int
        {
            if date.isLessThanDate(dateToCompare: Date() as Date as NSDate) {
                FTIndicator.showInfo(withMessage: "You can't create event to past time")
                return
            }
            
            if date.equalToDate(dateToCompare: Date() as NSDate) {
                
            }
            
            
            self.view.isUserInteractionEnabled = false
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "M"
            let month = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "HH:mm"
            let hour = dateFormatter.string(from: time)
            
            let uuid = UUID().uuidString
            
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
            FTIndicator.showNotification(with: UIImage(named: "Success"), title: "Yay!", message: "Event successfully created!")
            
            self.dismiss(animated: true, completion: nil)
        } else {
            FTIndicator.showInfo(withMessage: "You must fill all the areas!")
        }

    }
}
