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

class EventDetailViewController: UIViewController {
    
    @IBOutlet var creatorProfileView: UIView!
    @IBOutlet var creatorName: UILabel!
    @IBOutlet var creatorImage: UIImageView!
    @IBOutlet var descriptionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var eventDescriptionLabel: UILabel!
    @IBOutlet var eventBrancImage: UIImageView!
    @IBOutlet var eventAddressLabel: UILabel!
    @IBOutlet var eventDateLabel: UILabel!
    
    internal var event : Event?
    let font = UIFont(name: "Helvetica", size: 15.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        setPageOutlets()
        
        // If visitor is creator or not
        if event?.creatorID == FIRAuth.auth()?.currentUser?.uid {
            
        } else {
            
        }
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
        
        Alamofire.request(.GET, (self.event!.creatorImageURL)).responseData{ response in
            if let image = response.result.value {
                self.creatorImage.layer.masksToBounds = true
                self.creatorImage.layer.cornerRadius = self.creatorImage.frame.width / 2.0
                self.creatorImage.image = UIImage(data: image)
                self.creatorName.text = self.event!.creatorName
            }
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    @IBAction func creatorProfileClicked(sender: AnyObject) {
        let function = Functions()
        function.getProfilePage(event!.creatorID , vc: self)
    }
    
    @IBAction func joinEventButtonClicked(sender: AnyObject) {
        if event!.creatorID != FIRAuth.auth()?.currentUser?.uid {
            REF_EVENTS.child(event!.id).child("requested").child((FIRAuth.auth()?.currentUser?.uid)!).child("id").setValue((FIRAuth.auth()?.currentUser?.uid)!)
            REF_EVENTS.child(event!.id).child("requested").child((FIRAuth.auth()?.currentUser?.uid)!).child("result").setValue("requested")
        }
    }
    
    @IBAction func requestsButtonClicked(sender: AnyObject) {
        let requestPage = self.storyboard!.instantiateViewControllerWithIdentifier("RequestsViewController") as! RequestsViewController
        requestPage.eventID = event?.id
        self.presentViewController(requestPage, animated: true, completion: nil)
    }
}
