//
//  EventDetailViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 30.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import MapKit

private let reuseIdentifier = "participantsCell"

class EventDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var eventAddressLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet var requestsButton: UIButton!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var yellowLineWidth: NSLayoutConstraint!
    
    @IBOutlet var participantsCollectionView: UICollectionView!
    
    @IBOutlet var hexagon1: UIImageView!
    @IBOutlet var hexagon2: UIImageView!
    @IBOutlet var hexagon3: UIImageView!
    @IBOutlet var hexagon4: UIImageView!
    @IBOutlet var hexagon5: UIImageView!
    
    var event : Event!
    var creator : User! = nil
    var participants = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if event.creator != nil {
            self.creator = event.creator
        } else {
            REF_USERS.child(event.creatorID).observeSingleEvent(of: .value, with : { snapshot in
                if snapshot.exists() {
                    self.creator = User(snapshot: snapshot)
                }
            })
        }
        
        setPageOutlets()
        retrieveParticipants()
        
        // If visitor is creator or not
        if event?.creatorID == FIRAuth.auth()?.currentUser?.uid {
            joinButton.isEnabled = false
            requestsButton.isHidden = false
        } else {
            joinButton.isEnabled = true
            requestsButton.isHidden = true
        }
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
            self.present(viewController5, animated: true, completion: { _ in
                viewController5.user = self.creator
            })
        } else {
            let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.present(viewController5, animated: true, completion: { _ in
                viewController5.getUser(userID: self.participants[indexPath.row].id)
            })
        }
    }
    
    func setPageOutlets () {
        eventNameLabel.text = event.name
        descriptionTextView.text = event.description
        eventAddressLabel.text = event.location
        eventDateLabel.text = event.day + "." + event.month + "." + event.year + ", " + event!.time
        
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
        
        let pin = MKPointAnnotation()
        pin.coordinate = centerLocation
        map.addAnnotation(pin)
        
        map.region = MKCoordinateRegion(center: centerLocation, span: mapSpan)
    }
    
    @IBAction func joinEventButtonClicked(_ sender: AnyObject) {
        if event!.creatorID != FIRAuth.auth()?.currentUser?.uid {
        
            REF_EVENTS.child(event!.id).child("requested").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue((FIRAuth.auth()?.currentUser?.uid)!)
            REF_EVENTS.child(event!.id).child("requested").child((FIRAuth.auth()?.currentUser?.uid)!).child("result").setValue("requested")
        }
    }
    
    @IBAction func requestsButtonClicked(_ sender: AnyObject) {
        let requestPage = self.storyboard!.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
        requestPage.eventID = event?.id
        self.present(requestPage, animated: true, completion: nil)
    }
    

    @IBAction func backButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportButtonClicked(_ sender: AnyObject) {
        
    }
    
    
    func retrieveParticipants() {
        
        if let data = event.participants?.keys {
            let postDict = Array(data)
            
            for element in postDict {
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
}
