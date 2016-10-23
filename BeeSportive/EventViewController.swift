//
//  EventViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 16.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import Async
import FTIndicator

class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, ScrollPagerDelegate {
    
    @IBOutlet var firstCollectionView: UICollectionView!
    @IBOutlet var secondCollectionView: UICollectionView!
    @IBOutlet var thirdCollectionView: UICollectionView!
    @IBOutlet var fourthCollectionView: UICollectionView!
    @IBOutlet var followingCollectionView: UICollectionView!
    
    @IBOutlet var beeView: UIView!
    
    @IBOutlet var scrollPager: ScrollPager!
    
    @IBOutlet var beeViewLeading: NSLayoutConstraint!
    
    let refreshControl1 = UIRefreshControl()
    let refreshControl2 = UIRefreshControl()
    let refreshControl3 = UIRefreshControl()
    
    var eventDetailVC : EventDetailViewController!
    
    var allEvents = [Event]()
    var favoriteSports = [String]()
    var popularEvents = [Event]()
    var favoriteEvents = [Event]()
    var followingEvents = [Event]()
    var selectedEventNo : Int?
    
    var startAnimation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FTIndicator.showProgressWithmessage("Loading!")
        
        eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        eventDetailVC.mainMenuSender = self
        
        scrollPager.delegate = self
        scrollPager.addSegmentsWithTitlesAndViews(segments: [
            ("All", firstCollectionView),
            ("Popular", secondCollectionView),
            ("My Favorites", thirdCollectionView),
            ("Followed", followingCollectionView),
            ("Branchs", fourthCollectionView)
            ])
        
        // Navigation bar & controller settings
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Chat") , style: .plain, target: self, action: #selector(rightBarButtonItemTouchUpInside))
        rightBarButtonItem.tintColor = UIColor.gray
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        // Get data from database and update collection view
        retrieveAllEvents()
        retrievePopularEvents()
        
        // Pull to refresh
        refreshControl1.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl1.addTarget(self, action: #selector(retrieveAllEvents), for: UIControlEvents.valueChanged)
        firstCollectionView.addSubview(refreshControl1)
        
        refreshControl2.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl2.addTarget(self, action: #selector(retrievePopularEvents), for: UIControlEvents.valueChanged)
        secondCollectionView.addSubview(refreshControl2)
        
        refreshControl3.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl3.addTarget(self, action: #selector(retrieveAllEvents), for: UIControlEvents.valueChanged)
        thirdCollectionView.addSubview(refreshControl3)
        
        // Collection view cell nib register
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle:nil)
        let nibName2 = UINib(nibName: "FavoriteSportCollectionViewCell", bundle:nil)
        
        firstCollectionView.register(nibName, forCellWithReuseIdentifier: "eventCell")
        secondCollectionView.register(nibName, forCellWithReuseIdentifier: "eventCell")
        thirdCollectionView.register(nibName, forCellWithReuseIdentifier: "eventCell")
        followingCollectionView.register(nibName, forCellWithReuseIdentifier: "eventCell")
        fourthCollectionView.register(nibName2, forCellWithReuseIdentifier: "FavoriteSportCell")
        
        
        // If there are not enough events to scroll, you can still pull to refresh
        firstCollectionView.alwaysBounceVertical = true
        secondCollectionView.alwaysBounceVertical = true
        thirdCollectionView.alwaysBounceVertical = true
    }
    
    // MARK: - CollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == firstCollectionView {
            return allEvents.count
        } else if collectionView == secondCollectionView {
            return popularEvents.count
        } else if collectionView == thirdCollectionView {
            return favoriteEvents.count
        } else if collectionView == fourthCollectionView {
            return branchs.count
        } else if collectionView == followingCollectionView {
            return followingEvents.count
        }
        
        return 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FTIndicator.dismissProgress()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == firstCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
            
            if startAnimation {
                let frame = cell.frame
                
                if (indexPath.row % 2) == 0 {
                    cell.frame.origin = CGPoint(x: -screenSize.width, y: frame.origin.y)
                } else {
                    cell.frame.origin = CGPoint(x: screenSize.width, y: frame.origin.y)
                }
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { 
                        cell.frame = frame
                    }, completion: nil)
            }
            
            
            cell.configureCell(event: allEvents[indexPath.row])
            
            return cell
        } else if collectionView == secondCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
            
            cell.configureCell(event: popularEvents[indexPath.row])
            
            return cell
        } else if collectionView == thirdCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
            
            cell.configureCell(event: favoriteEvents[indexPath.row])
            
            return cell
        } else if collectionView == fourthCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteSportCell", for: indexPath) as! FavoriteSportCollectionViewCell
            
            cell.favSportImage.image = UIImage(named: branchs[(indexPath as NSIndexPath).row])
            cell.favSportName.text = branchs[(indexPath as NSIndexPath).row]
            
            return cell
        } else if collectionView == followingCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
            
            cell.configureCell(event: followingEvents[indexPath.row])
            
            return cell

        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        if collectionView == firstCollectionView {
            eventDetailVC.event = allEvents[indexPath.row]
            self.present(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == secondCollectionView {
            eventDetailVC.event = popularEvents[indexPath.row]
            self.present(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == thirdCollectionView {
            eventDetailVC.event = favoriteEvents[indexPath.row]
            self.present(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == fourthCollectionView {
            
            let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsCollectionViewController") as! EventsCollectionViewController
            eventsVC.navigationItem.title = branchs[indexPath.row]
            
            var events = [Event]()
            
            for i in 0..<allEvents.count {
                if allEvents[i].branch == branchs[indexPath.row] {events.insert(allEvents[i], at: 0)  }
            }
            
            eventsVC.branchName = branchs[indexPath.row]
            eventsVC.events = events
            eventsVC.collectionView?.reloadData()
            
            self.show(eventsVC, sender: self)
        } else if collectionView == followingCollectionView {
            eventDetailVC.event = followingEvents[indexPath.row]
            self.present(eventDetailVC, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if collectionView == firstCollectionView || collectionView == secondCollectionView || collectionView == thirdCollectionView || collectionView == followingCollectionView {
            return CGSize(width: screenSize.width - 8, height: 144)
        }
        
        var events = [Event]()
        
        for i in 0..<allEvents.count {
            if allEvents[i].branch == branchs[(indexPath as NSIndexPath).row] {events.insert(allEvents[i], at: 0)  }
        }
        if events.count == 0 { return CGSize(width: 4, height: 0) }
        
        return CGSize(width: screenSize.width - 8, height: 120)
    }
    
    //
    // MARK: -Self created methods
    
    func retrieveAllEvents() {
       
        var tempAllEvents = [Event]()
        var tempFavEvents = [Event]()
        var tempFolEvents = [Event]()
        
        
        REF_EVENTS.observe(.value , with: { (snapshot) in
            
            tempAllEvents.removeAll()
            tempFavEvents.removeAll()
            tempFolEvents.removeAll()
            
            if snapshot.exists() {
                
                let postDict = snapshot.children
                
                for element in postDict {
                    let eventElement = Event(snapshot: element as! FIRDataSnapshot)
                    
                    if !eventElement.isPast {
                        tempAllEvents.append(eventElement)
                    }
                }
                
                self.allEvents = tempAllEvents
                FTIndicator.dismissProgress()
                
                Async.main {
                    self.refreshControl1.endRefreshing()
                    self.firstCollectionView.reloadData()
                    self.fourthCollectionView.reloadData()
                    
                    if self.startAnimation {
                        Async.main(after: 0.5, { _ in
                            self.startAnimation = false
                        })
                    }
                }
                
                if (currentUser.instance.user != nil) && (currentUser.instance.user?.favoriteSports != nil){
                    self.favoriteSports = (currentUser.instance.user?.favoriteSports)!
                    
                    for k in 0 ..< self.allEvents.count {
                        for j in 0 ..< self.favoriteSports.count {
                            if self.allEvents[k].branch == self.favoriteSports[j] {
                                tempFavEvents.append(tempAllEvents[k])
                            }
                        }
                    }
                    
                    self.favoriteEvents = tempFavEvents
                    
                    Async.main {
                        self.refreshControl1.endRefreshing()
                        self.thirdCollectionView.reloadData()
                    }
                } else {
                    REF_USERS.child((FIRAuth.auth()?.currentUser!.uid)!).child("favoriteSports").observe(.value, with: { snapshot in
                        if snapshot.exists() {
                            if let postDict = (snapshot.value as? Dictionary<String, String>)?.values {
                                self.favoriteSports = Array(postDict)
                            }
                            
                            for k in 0 ..< self.allEvents.count {
                                for j in 0 ..< self.favoriteSports.count {
                                    if self.allEvents[k].branch == self.favoriteSports[j] {
                                        tempFavEvents.append(tempAllEvents[k])
                                    }
                                }
                            }
                            
                            self.favoriteEvents = tempFavEvents
                            
                            Async.main {
                                self.refreshControl1.endRefreshing()
                                self.thirdCollectionView.reloadData()
                            }
                        }
                    })
                }
                
                if (currentUser.instance.user != nil) && (currentUser.instance.user?.following != nil) {
                    for eventElement in self.allEvents {
                        if (currentUser.instance.user?.following.contains(eventElement.creatorID))! {
                            tempFolEvents.append(eventElement)
                        }
                    }
                    
                    self.followingEvents = tempFolEvents
                    
                    Async.main {
                        self.followingCollectionView.reloadData()
                    }
                } else {
                    REF_USERS.child((FIRAuth.auth()?.currentUser!.uid)!).child("following").observe(.value, with: { snapshot in
                        if snapshot.exists() {
                            if let followingUsersIDs = (snapshot.value as? Dictionary<String, AnyObject>)?.keys {
                                for eventElement in self.allEvents {
                                    if followingUsersIDs.contains(eventElement.creatorID) {
                                        tempFolEvents.append(eventElement)
                                    }
                                }
                                
                                self.followingEvents = tempFolEvents
                                
                                Async.main {
                                    self.followingCollectionView.reloadData()
                                }
                            }
                        }
                    })
                }
                
            }
        })
    }
    
    func retrievePopularEvents() {
        var tempPopularEvents = [Event]()
        
        REF_POPULAR_EVENTS.observe(.value , with: { (snapshot) in
            tempPopularEvents.removeAll()
            
            if snapshot.exists() {
                let postDict = snapshot.children
                
                for element in postDict {
                    let eventElement = Event(snapshot: element as! FIRDataSnapshot)
                    
                    tempPopularEvents.append(eventElement)
                }
                
                self.popularEvents = tempPopularEvents
                
                Async.main {
                    self.refreshControl2.endRefreshing()
                    self.secondCollectionView.reloadData()
                }
            }
        })
    }
    
    func rightBarButtonItemTouchUpInside() {
        self.performSegue(withIdentifier: "toChannelsSegue", sender: self)
    }

    
    func scrollPager(scrollPager: ScrollPager, changedIndex: Int) {
        switch changedIndex {
        case 0:
            UIView.animate(withDuration: 0.2, animations: { 
                self.beeViewLeading.constant = 0
            })
            break
        case 1:
            UIView.animate(withDuration: 0.2, animations: {
                self.beeViewLeading.constant = screenSize.width * (1/5.0)
            })
            break
        case 2:
            UIView.animate(withDuration: 0.2, animations: {
                self.beeViewLeading.constant = screenSize.width * (2/5.0)
            })
            break
        case 3:
            UIView.animate(withDuration: 0.2, animations: {
                self.beeViewLeading.constant = screenSize.width * (3/5.0)
            })
            break
        case 4:
            UIView.animate(withDuration: 0.2, animations: {
                self.beeViewLeading.constant = screenSize.width * (4/5.0)
            })
            break
        default:
            break
        }
    }
}
