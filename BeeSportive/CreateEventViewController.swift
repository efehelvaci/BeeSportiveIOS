//
//  CreateEventViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 16.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Async
import Firebase
import FTIndicator
import WWCalendarTimeSelector
import CoreLocation

class CreateEventViewController: UIViewController, WWCalendarTimeSelectorProtocol, UIPickerViewDelegate {
    
    @IBOutlet var addEventButton: UIButton!
    @IBOutlet var branchPicker: UIPickerView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var locationField: UITextField!
    @IBOutlet var maxJoinNumberField: UITextField!
    @IBOutlet var levelField: UITextField!
    @IBOutlet var descriptionField: UITextView!
    
    let databaseRef = FIRDatabase.database().reference()
    let calendar = WWCalendarTimeSelector.instantiate()
    let branchs = ["Badminton", "Baseball", "Basketball", "Billard", "Bowling", "Crossfit", "Curling", "Cycling", "Dancing", "Diving", "Fencing", "Fitness", "Football", "Golf", "Gymnastic", "Handball", "Ice Hockey", "Ice Skating", "Martial Arts", "Motor Sports", "Mountain Climbing", "Orienting", "Paintball", "Parkour", "Pilates", "Pokemon Go", "Quidditch", "Rafting", "Rowing", "Rugby", "Running", "Sailing", "Skateboarding", "Skating", "Snowboarding", "Surfing", "Swimming", "Table Tennis", "Tennis", "Triathlon", "Volleyball", "Water Polo", "Wind Surfing", "Wrestling", "Yoga", "Zumba"]
    var currentBranch = "Basketball"
    var currentDay = "01"
    var currentMonth = "01"
    var currentHour = "12:00"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = "01/01/2017 Monday 12:00"
        
        calendar.delegate = self
        
        descriptionField.layer.borderWidth = 1.0
        descriptionField.layer.cornerRadius = 1.0
        descriptionField.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    //
    // PickerView delegate methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return branchs.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return branchs[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentBranch = branchs[row]
    }
    
    //
    // Button actions
    @IBAction func addEventButtonTouch(sender: AnyObject) {
        addEventButton.enabled = false
        
        if nameField.text != "" && locationField.text != "" && maxJoinNumberField.text != "" {
            if let name = nameField.text, location = locationField.text, maxJoinNumber = maxJoinNumberField.text , level = levelField.text, description = descriptionField.text{
                let uuid = NSUUID().UUIDString
                
                let newEvent = [
                    "creatorID" : (FIRAuth.auth()?.currentUser?.uid)!,
                    "creatorImageURL" : (FIRAuth.auth()?.currentUser?.photoURL?.absoluteString)!,
                    "creatorName" : (FIRAuth.auth()?.currentUser?.displayName)!,
                    "name" : name,
                    "branch" : self.currentBranch,
                    "location" : location,
                    "time" : self.currentHour,
                    "month" : self.currentMonth,
                    "day" : self.currentDay,
                    "maxJoinNumber" : maxJoinNumber,
                    "level" : level,
                    "description" : description
                ]
                
                databaseRef.child("events").child(uuid).setValue(newEvent)
                databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("eventsCreated").childByAutoId().setValue(uuid)
                FTIndicator.showNotificationWithImage(UIImage(named: "Success"), title: "Yay!", message: "Event successfully created!")
    
                Async.main(after: 1, block: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            } else {
                addEventButton.enabled = true
                FTIndicator.showToastMessage("Server error... Try again later!")
            }
        } else {
            addEventButton.enabled = true
            FTIndicator.showToastMessage("Fill the empty areas!")
        }
    }
    
    @IBAction func datePickButtonClicked(sender: AnyObject) {
        presentViewController(self.calendar, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }    
    
    //
    // Calender delegate method
    func WWCalendarTimeSelectorDone(selector: WWCalendarTimeSelector, date: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy EEEE HH:mm"
        dateFormatter.stringFromDate(date)

        self.dateLabel.text = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "dd"
        self.currentDay = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "M"
        self.currentMonth = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "HH:mm"
        self.currentHour = dateFormatter.stringFromDate(date)
    }
}
