//
//  EventDetailViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 30.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import SDCAlertView
import Async
import FBSDKShareKit

private let reuseIdentifier = "participantsCell"

class EventDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var eventAddressLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var eventFullAddressLabel: UILabel!
    @IBOutlet var capacityLabel: UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet var requestsButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var yellowLineWidth: NSLayoutConstraint!
    @IBOutlet var descriptionHeight: NSLayoutConstraint!
    @IBOutlet var participantsCollectionView: UICollectionView!
    @IBOutlet var hexagon1: UIImageView!
    @IBOutlet var hexagon2: UIImageView!
    @IBOutlet var hexagon3: UIImageView!
    @IBOutlet var hexagon4: UIImageView!
    @IBOutlet var hexagon5: UIImageView!
    
    let grayLineWidth = screenSize.width - 90.0
    let fbButton : FBSDKShareButton = FBSDKShareButton()
    let pin = MKPointAnnotation()
    
    var mainMenuSender : EventViewController? = nil
    var joinAlert : AlertController!
    var event : Event!
    var creator : User! = nil {
        didSet {
            self.participantsCollectionView.reloadData()
        }
    }
    var participants = [User]() {
        didSet{
            yellowLineWidth.constant = ( CGFloat(participants.count) / CGFloat(Double(event.maxJoinNumber)!)) * grayLineWidth
            capacityLabel.text = String(participants.count) + "/" + String(event.maxJoinNumber)
        }
    }
    
    var eventRequsters = [User]() {
        didSet {
            self.requestsButton.setTitle("Requests (\(eventRequsters.count))", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        
        eventNameLabel.adjustsFontSizeToFitWidth = true
        eventAddressLabel.adjustsFontSizeToFitWidth = true
        eventFullAddressLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if event.creator != nil {
            self.creator = event.creator
        } else {
            REF_USERS.child(event.creatorID).observeSingleEvent(of: .value, with : { snapshot in
                if snapshot.exists() {
                    self.creator = User(snapshot: snapshot)
                }
            })
        }
        var eventAddress = ""
        if let address = event.address { eventAddress = " - " + address }
        
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: "http://www.beesportive.com/")
        content.contentTitle = "BeeEvent: " + "'" + event.name + "' - Let's BeeSportive!"
        content.contentDescription = "Nerede? : " + event.location + eventAddress + " - " +
            "Ne zaman? : " + event.day + "." + event.month + "." + event.year + ", " + event.time + " \u{1F41D} Download the app from the App Store and join this event of your friend! \u{1F41D}"
        content.imageURL = URL(string: "https://s15.postimg.org/ph36t3vt7/Logo2.png")
        fbButton.shareContent = content
        
        joinAlert = AlertController(title: ("Join '" + event.name + "' BeeEvent?"), message: (event.day + "." + event.month + "." + event.year + ", " + event!.time + "\n" +
            event.location + "\n" +
            "\n" +
            "You will be notified when event owner considers your application."), preferredStyle: AlertControllerStyle.alert)
        joinAlert.add(AlertAction(title: "Cancel", style: .destructive, handler: { _ in
            self.joinAlert.dismiss()
        })
        )
        joinAlert.add(AlertAction(title: "Join!", style: .preferred, handler: { _ in
            if self.event!.creatorID != FIRAuth.auth()?.currentUser?.uid {
                REF_EVENTS.child(self.event!.id).child("requested").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue((FIRAuth.auth()?.currentUser?.uid)!)
                REF_EVENTS.child(self.event!.id).child("requested").child((FIRAuth.auth()?.currentUser?.uid)!).child("result").setValue("requested")
                
                if self.mainMenuSender != nil {
                    self.mainMenuSender?.retrieveAllEvents()
                }
                
                self.joinButton.setTitle("Requested", for: .disabled)
                self.joinButton.layer.borderColor = UIColor.gray.cgColor
                self.joinButton.isEnabled = false
                
                let notifier = [
                    "notification": (currentUser.instance.user?.displayName)! + " wanted to join your event: '" + self.event.name + "'." ,
                    "notificationConnection": self.event.id,
                    "type": "incomingJoinRequest"
                ]
                
                REF_NOTIFICATIONS.child(self.event.creatorID).childByAutoId().setValue(notifier)
            }
        })
        )
        
        self.eventRequsters = [User]()
        if let reqIDs = event.requesters?.keys {
            let allReq = Array(reqIDs)
            
            if allReq.contains((FIRAuth.auth()?.currentUser?.uid)!){
                Async.main{
                    self.joinButton.setTitle("Requested", for: .disabled)
                    self.joinButton.layer.borderColor = UIColor.gray.cgColor
                    self.joinButton.isEnabled = false
                }
            }
            
            for reqID in allReq {
                REF_USERS.child(reqID).observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        let newReqUser = User(snapshot: snapshot)
                        
                        self.eventRequsters.append(newReqUser)
                    }
                })
            }
        }
        
        if event.participants.contains((FIRAuth.auth()?.currentUser?.uid)!){
            Async.main{
                self.joinButton.setTitle("Joined", for: .disabled)
                self.joinButton.layer.borderColor = UIColor.gray.cgColor
                self.joinButton.isEnabled = false
            }
        }
        
        if event.creatorID == FIRAuth.auth()?.currentUser?.uid {
            Async.main{
                self.joinButton.setTitle("Your Beevent", for: .disabled)
                self.joinButton.layer.borderColor = UIColor.gray.cgColor
                self.joinButton.isEnabled = false
            }
        }
        
        yellowLineWidth.constant = ( CGFloat(participants.count) / CGFloat(Double(event.maxJoinNumber)!)) * grayLineWidth
        
        setPageOutlets()
        retrieveParticipants()
        
        // If visitor is creator or not
        if event?.creatorID == FIRAuth.auth()?.currentUser?.uid {
            joinButton.layer.borderColor = UIColor.gray.cgColor
            joinButton.isEnabled = false
            requestsButton.isHidden = false
            
            REF_EVENTS.child(event.id).child("requested").observe(.value, with: { snapshot in
                var tempReqs = [User]()
                
                if snapshot.exists() {
                    for snap in snapshot.children.allObjects as! [FIRDataSnapshot] {
                        if let data = snap.value as? Dictionary<String, String> {
                            REF_USERS.child(data["id"]!).observeSingleEvent(of: .value, with: { snapshot2 in
                                tempReqs.append(User(snapshot: snapshot2))
                                
                                self.eventRequsters = tempReqs
                            })
                        }
                    }
                } else {
                    self.eventRequsters.removeAll()
                }
            })
            
        } else {
            joinButton.isEnabled = true
            requestsButton.isHidden = true
        }

    } // End of viewWillAppear
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        map.removeAnnotation(self.pin)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = participantsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParticipantsCollectionViewCell
        
        if indexPath.row == 0 {
            cell.configureCell(user: creator)
            
            cell.name.text = cell.name.text! + " (Creator)"
            
            return cell
        }
        
        cell.configureCell(user: participants[indexPath.row - 1])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if creator != nil {
            return participants.count + 1
        }
        
        return participants.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80 , height: participantsCollectionView.bounds.height-2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 && creator != nil {
            let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            viewController5.getUser(userID: event.creatorID)
            self.present(viewController5, animated: true, completion: nil)
        } else {
            let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            viewController5.getUser(userID: self.participants[indexPath.row-1].id)
            self.present(viewController5, animated: true, completion: nil)
        }
    }
    
    func setPageOutlets () {
        if self.isViewLoaded {
            eventNameLabel.text = event.name
            descriptionLabel.text = event.description
            
            if let font = UIFont(name: "Open Sans", size: 14) {
                descriptionHeight.constant = event.description.heightWithConstrainedWidth(screenSize.width - 18, font: font) + 10
            } else {
                descriptionHeight.constant = 180.0
            }
            
            event.address != nil ? (eventFullAddressLabel.text = event.address) : (eventFullAddressLabel.text = "")
            
            eventAddressLabel.text = event.location
            eventDateLabel.text = event.day + "." + event.month + "." + event.year + "  " + event!.time
            
            if levels[0] == event.level {
                hexagon1.image = UIImage(named: "YellowHexagon")
                hexagon2.image = UIImage(named: "Hexagon")
                hexagon3.image = UIImage(named: "Hexagon")
                hexagon4.image = UIImage(named: "Hexagon")
                hexagon5.image = UIImage(named: "Hexagon")
            } else if levels[1] == event.level {
                hexagon1.image = UIImage(named: "YellowHexagon")
                hexagon2.image = UIImage(named: "YellowHexagon")
                hexagon3.image = UIImage(named: "Hexagon")
                hexagon4.image = UIImage(named: "Hexagon")
                hexagon5.image = UIImage(named: "Hexagon")
            } else if levels[2] == event.level {
                hexagon1.image = UIImage(named: "YellowHexagon")
                hexagon2.image = UIImage(named: "YellowHexagon")
                hexagon3.image = UIImage(named: "YellowHexagon")
                hexagon4.image = UIImage(named: "Hexagon")
                hexagon5.image = UIImage(named: "Hexagon")
            } else if levels[3] == event.level {
                hexagon1.image = UIImage(named: "YellowHexagon")
                hexagon2.image = UIImage(named: "YellowHexagon")
                hexagon3.image = UIImage(named: "YellowHexagon")
                hexagon4.image = UIImage(named: "YellowHexagon")
                hexagon5.image = UIImage(named: "Hexagon")
            } else if levels[4] == event.level {
                hexagon1.image = UIImage(named: "YellowHexagon")
                hexagon2.image = UIImage(named: "YellowHexagon")
                hexagon3.image = UIImage(named: "YellowHexagon")
                hexagon4.image = UIImage(named: "YellowHexagon")
                hexagon5.image = UIImage(named: "YellowHexagon")
            }
            
            let centerLocation = CLLocationCoordinate2DMake(Double(event!.locationLat)!, Double(event!.locationLon)!)
            let mapSpan = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
            
            self.pin.coordinate = centerLocation
            map.addAnnotation(self.pin)
            
            map.region = MKCoordinateRegion(center: centerLocation, span: mapSpan)
            
            capacityLabel.text = String(event.participants.count) + "/" + event.maxJoinNumber
        }
    }
    
    @IBAction func joinEventButtonClicked(_ sender: AnyObject) {
        joinAlert.present()
    }
    
    @IBAction func requestsButtonClicked(_ sender: AnyObject) {
        let popoverContent = self.storyboard!.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverContent.preferredContentSize = CGSize(width: screenSize.width-16, height: 250)
        popoverContent.eventID = self.event.id
        popoverContent.users = self.eventRequsters
        popoverContent.senderVC = self
        let popoverController = popoverContent.popoverPresentationController
        popoverController?.permittedArrowDirections = .any
        popoverController?.delegate = self
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = (sender as! UIButton).frame

        self.present(popoverContent, animated: true, completion: nil)
    }
    

    @IBAction func backButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportButtonClicked(_ sender: AnyObject) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverContent.preferredContentSize = CGSize(width: screenSize.width-16, height: 250)
        popoverContent.reporting = .event
        popoverContent.reported = event
        let popoverController = popoverContent.popoverPresentationController
        popoverController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popoverController?.delegate = self
        popoverController?.sourceView = self.view
        popoverController?.sourceRect = CGRect(x: 80, y: 80, width: 50, height: 50)
        present(popoverContent, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @IBAction func shareButtonClicked(_ sender: AnyObject) {
        fbButton.sendActions(for: .touchUpInside)
    }
   
    
    func retrieveParticipants() {
        
        self.participants.removeAll()
        
        for element in event.participants {
            REF_USERS.child(element).observeSingleEvent(of: .value, with: { snapshot in
                
                
                if snapshot.exists() {
                    let user = User(snapshot: snapshot)
                    
                    self.participants.append(user)
                    self.participantsCollectionView.reloadData()
                }
            })
        }
    }
}
