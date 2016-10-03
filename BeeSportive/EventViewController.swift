//
//  EventViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 16.08.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import Async

class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, ScrollPagerDelegate {
    
    @IBOutlet var firstView: UIView!
    @IBOutlet var secondView: UIView!
    @IBOutlet var thirdView: UIView!
    @IBOutlet var fourthView: UIView!
    
    @IBOutlet var firstCollectionView: UICollectionView!
    @IBOutlet var secondCollectionView: UICollectionView!
    @IBOutlet var thirdCollectionView: UICollectionView!
    @IBOutlet var fourthCollectionView: UICollectionView!
    
    @IBOutlet var scrollPager: ScrollPager!
    
    @IBOutlet var beeViewLeading: NSLayoutConstraint!
    
    let refreshControl1 = UIRefreshControl()
    let refreshControl2 = UIRefreshControl()
    let refreshControl3 = UIRefreshControl()
    
    var allEvents = [Event]()
    var favoriteSports = [String]()
    var popularEvents = [Event]()
    var favoriteEvents = [Event]()
    var selectedEventNo : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollPager.delegate = self
        scrollPager.addSegmentsWithTitlesAndViews(segments: [
            ("All", firstCollectionView),
            ("Popular", secondCollectionView),
            ("My Favorites", thirdCollectionView),
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
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == firstCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCollectionViewCell
            
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
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == firstCollectionView {
            let eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = allEvents[(indexPath as NSIndexPath).row]
            self.present(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == secondCollectionView {
            let eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = popularEvents[(indexPath as NSIndexPath).row]
            self.present(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == thirdCollectionView {
            let eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            eventDetailVC.event = favoriteEvents[(indexPath as NSIndexPath).row]
            self.present(eventDetailVC, animated: true, completion: nil)
        } else if collectionView == fourthCollectionView {
            
            let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsCollectionViewController") as! EventsCollectionViewController
            
            var events = [Event]()
            
            for i in 0..<allEvents.count {
                if allEvents[i].branch == branchs[(indexPath as NSIndexPath).row] {events.insert(allEvents[i], at: 0)  }
            }
            
            eventsVC.branchName = branchs[(indexPath as NSIndexPath).row]
            eventsVC.events = events
            eventsVC.collectionView?.reloadData()
            
            self.show(eventsVC, sender: self)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if collectionView == firstCollectionView || collectionView == secondCollectionView || collectionView == thirdCollectionView {
            return CGSize(width: screenSize.width - 8, height: 180)
        }
        
        return CGSize(width: screenSize.width - 8, height: 120)
    }
    
    //
    // MARK: -Self created methods
    
    func retrieveAllEvents() {
       
        var tempAllEvents = [Event]()
        var tempFavEvents = [Event]()
        
        
        REF_EVENTS.observeSingleEvent(of: .value , with: { (snapshot) in
            if snapshot.exists() {
                let postDict = snapshot.children
                
                for element in postDict {
                    let eventElement = Event(snapshot: element as! FIRDataSnapshot)
                    
                    tempAllEvents.append(eventElement)
                }
                
                self.allEvents = tempAllEvents
                
                Async.main {
                    self.refreshControl1.endRefreshing()
                    self.firstCollectionView.reloadData()
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
                    REF_USERS.child((FIRAuth.auth()?.currentUser!.uid)!).child("favoriteSports").observeSingleEvent(of: .value, with: { snapshot in
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
            }
        })
    }
    
    func retrievePopularEvents() {
        var tempPopularEvents = [Event]()
        
        REF_POPULAR_EVENTS.observeSingleEvent(of: .value , with: { (snapshot) in
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
    
    func leftBarButtonItemTouchUpInside() {
        self.performSegue(withIdentifier: "EventsToLoginSegue", sender: self)
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
                self.beeViewLeading.constant = screenSize.width * (1/4.0)
            })
            break
        case 2:
            UIView.animate(withDuration: 0.2, animations: {
                self.beeViewLeading.constant = screenSize.width * (2/4.0)
            })
            break
        case 3:
            UIView.animate(withDuration: 0.2, animations: {
                self.beeViewLeading.constant = screenSize.width * (3/4.0)
            })
            break
        default:
            break
        }
    }
}
