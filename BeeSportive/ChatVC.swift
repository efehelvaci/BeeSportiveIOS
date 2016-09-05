//
//  ChatVC.swift
//  BeeSportive
//
//  Created by Doruk Gezici on 30/08/2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatVC: JSQMessagesViewController {

    var channelID: String!
    var messages = [JSQMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = true
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        self.senderDisplayName = FIRAuth.auth()?.currentUser?.displayName
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(ChatVC.segueToParticipants))
        REF_CHANNELS.child(channelID).child("messages").observeEventType(.ChildAdded, withBlock: { snapshot in
            guard let data = snapshot.value as? Dictionary<String, String> else { return }
            let senderId = data["senderId"]!
            REF_USERS.child(senderId).child("displayName").observeEventType(.Value, withBlock: { (snapshot) in
                let displayName = snapshot.value as! String
                self.addMessage(data["message"]!, senderId: data["senderId"]!, senderDisplayName: displayName, date: NSDate())
            })
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId { cell.textView!.textColor = UIColor.whiteColor() }
        else { cell.textView!.textColor = UIColor.blackColor() }
        return cell
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let factory = JSQMessagesBubbleImageFactory()
        let outgoingBubbleImage = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        let incomingBubbleImage = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
        let message = messages[indexPath.item]
        if message.senderId == senderId { return outgoingBubbleImage }
        else { return incomingBubbleImage }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let name = messages[indexPath.row].senderDisplayName
        let components = name.componentsSeparatedByString(" ")
        var initials = ""
        for component in components {
            initials += String(component.characters.first!).capitalizedString
        }
        let factory = JSQMessagesAvatarImageFactory.self
        return factory.avatarImageWithUserInitials(initials, backgroundColor: UIColor.grayColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12), diameter: 30)
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let dict: Dictionary<String, String> = ["message":text, "senderId":senderId, "date":NSDate().description]
        REF_CHANNELS.child(channelID).child("messages").childByAutoId().setValue(dict)
        REF_CHANNELS.child(channelID).child("lastMessage").setValue(dict)
        finishSendingMessageAnimated(true)
    }

    override func didPressAccessoryButton(sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .ActionSheet)
        let photoAction = UIAlertAction(title: "Send photo", style: .Default) { (action) in
            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "pp"))
            self.addMedia(photoItem)
        }
        let locationAction = UIAlertAction(title: "Send location", style: .Default) { (action) in
            let locationItem = self.buildLocationItem()
            self.addMedia(locationItem)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(cancelAction)
        self.presentViewController(sheet, animated: true, completion: nil)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {

    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: messages[indexPath.row].senderDisplayName)
    }

    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        return locationItem
    }

    func addMedia(media:JSQMediaItem) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, media: media)
        self.messages.append(message)
        self.finishSendingMessageAnimated(true)
    }

    func addMessage(text: String, senderId: String, senderDisplayName: String, date: NSDate) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        messages.append(message)
        self.collectionView.reloadData()
        finishReceivingMessageAnimated(true)
    }

    func segueToParticipants() {
        self.performSegueWithIdentifier("toParticipantsSegue", sender: self.navigationItem.rightBarButtonItem)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destVC = segue.destinationViewController as? ParticipantsVC {
            destVC.eventID = self.channelID
        }
    }
    
}
