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
    
    @IBOutlet var creatorProfileView: UIView!
    @IBOutlet var creatorName: UILabel!
    @IBOutlet var creatorImage: UIImageView!
    @IBOutlet var descriptionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var eventDescriptionLabel: UILabel!
    @IBOutlet var eventBrancImage: UIImageView!
    @IBOutlet var eventAddressLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    @IBOutlet var map: MKMapView!
    
    @IBOutlet var participantsCollectionView: UICollectionView!
    
    
    internal var event : Event?
    var participants = [User]()
    let font = UIFont(name: "Helvetica", size: 15.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPageOutlets()
        
        retrieveParticipants()
        
        // If visitor is creator or not
        if event?.creatorID == FIRAuth.auth()?.currentUser?.uid {
            
        } else {
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = participantsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParticipantsCollectionViewCell
        
        cell.name.text = participants[(indexPath as NSIndexPath).row].displayName
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: screenSize.width/4.0, height: participantsCollectionView.bounds.height)
    }

    func setPageOutlets () {
        eventNameLabel.text = event!.name
        descriptionLabelHeightConstraint.constant = heightForView(event!.description, font: font!, width: screenSize.width-40)
        eventDescriptionLabel.text = event!.description
        eventBrancImage.image = UIImage(named: event!.branch)
        eventAddressLabel.text = event!.location
        eventDateLabel.text = event!.day + "/" + event!.month + "/" + event!.year + "  " + event!.time
        creatorProfileView.layer.borderWidth = 1.0
        creatorProfileView.layer.cornerRadius = 10.0
        
        let centerLocation = CLLocationCoordinate2DMake(Double(event!.locationLat)!, Double(event!.locationLon)!)
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        
        let pin = MKPointAnnotation()
        pin.coordinate = centerLocation
        map.addAnnotation(pin)
        
        map.region = MKCoordinateRegion(center: centerLocation, span: mapSpan)
        
        Alamofire.request(self.event!.creatorImageURL).responseImage(completionHandler: { response in
            if let image = response.result.value {
                self.creatorImage.layer.masksToBounds = true
                self.creatorImage.layer.cornerRadius = self.creatorImage.frame.width / 2.0
                self.creatorImage.image = image
                self.creatorName.text = self.event!.creatorName
            }
        })
    }
    
    func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    @IBAction func creatorProfileClicked(_ sender: AnyObject) {
        let viewController5 = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.present(viewController5, animated: true, completion: { _ in
            viewController5.getUser(userID: (self.event?.creatorID)!)
        })
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
    
    func retrieveParticipants() {
        REF_EVENTS.child(event!.id).child("participants").observeSingleEvent(of: .value , with: { (snapshot) in
            if snapshot.exists() {
                let postDict = Array((snapshot.value as! [String : AnyObject]).values)
                
                for element in postDict {
                    let id = element.value(forKey: "id") as! String
                    
                    REF_USERS.child(id).observeSingleEvent(of: .value, with: { snapshot in
                        if snapshot.exists() {
                            let user = User(snapshot: snapshot)
                            
                            self.participants.insert(user, at: 0)
                            self.participantsCollectionView.reloadData()
                        }
                    })
                }
            }
        })
    }
}
