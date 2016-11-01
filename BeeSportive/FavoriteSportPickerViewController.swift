//
//  FavoriteSportPickerViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 4.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import FTIndicator
import Firebase

class FavoriteSportPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    
    var selectedBranchs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteSportPickerCell", for: indexPath) as! FavoriteSportPickerCollectionViewCell
        
        cell.branchImage.image = UIImage(named: (branchs[indexPath.row] + "Mini"))
        cell.branchName.text = branchs[indexPath.row]
        
        if selectedBranchs.contains(branchs[indexPath.row]) {
            UIView.animate(withDuration: 0.5, animations: {
                cell.yellowCurtainView.alpha = 0.3
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                cell.yellowCurtainView.alpha = 0.0
            })
        }

        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return branchs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedBranchs.contains(branchs[indexPath.row]) {
            selectedBranchs.remove(at: selectedBranchs.index(of: branchs[indexPath.row])!)
        } else {
            if selectedBranchs.count < 4 {
                selectedBranchs.append(branchs[indexPath.row])
            } else {
                FTIndicator.showInfo(withMessage: "You can only have 4 favorite sport branchs!")
            }
            
        }
        
        collectionView.reloadItems(at: [indexPath])
        
        print(selectedBranchs)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenSize.width/5 - 10, height: (screenSize.width/5 - 10) + 40)
    }
    
    @IBAction func doneButtonClicked(_ sender: AnyObject) {
        
        REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("favoriteSports").removeValue()
        
        for fav in selectedBranchs {
            REF_USERS.child((FIRAuth.auth()?.currentUser?.uid)!).child("favoriteSports").childByAutoId().setValue(fav)
        }
        
        if let usr = currentUser.instance.user {
            usr.favoriteSports = selectedBranchs
            currentUser.instance.user? = usr
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
