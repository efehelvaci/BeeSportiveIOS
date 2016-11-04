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
import CoreLocation

class EventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, ScrollPagerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var firstCollectionView: UICollectionView! // All Events
    @IBOutlet var thirdCollectionView: UICollectionView! // Favorite Events
    @IBOutlet var fourthCollectionView: UICollectionView! // Branchs
    @IBOutlet var followingCollectionView: UICollectionView! // Followed Events
    
    @IBOutlet var setDistanceButton: UIButton!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var distanceSlider: UISlider!
    @IBOutlet var SetDistanceView: UIView!
    @IBOutlet var needYourLocationView: UIView!
    
    @IBOutlet var beeView: UIView!
    
    @IBOutlet var scrollPager: ScrollPager!
    
    @IBOutlet var beeViewLeading: NSLayoutConstraint!

    let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    let allEventsRefreshControl = UIRefreshControl()
    let favoritesRefreshControl = UIRefreshControl()
    let followingRefreshControl = UIRefreshControl()
    let backButton = UIBarButtonItem()
    
    var isFirstLocationExists = false
    var distanceMax : Float = 25
    var timesToLocateAccurate = 5
    var eventDetailVC : EventDetailViewController!
    var allEvents = [Event]()
    var favoriteSports = [String]()
    var favoriteEvents = [Event]()
    var followingEvents = [Event]()
    var selectedEventNo : Int?
    var startAnimation = true
    var location = CLLocation(latitude: 41.01513, longitude: 28.97953) { // Kennedy Street, Istanbul
        didSet {
            if timesToLocateAccurate <= 0 {
                let locationData = NSKeyedArchiver.archivedData(withRootObject: location)
                userDefaults.set(locationData, forKey: "lastLocation")
                retrieveAllEvents()
                locationManager.stopUpdatingLocation()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if let distanceDefault = userDefaults.value(forKey: "maxDistance") as? Float {
            distanceMax = distanceDefault
            distanceSlider.value = distanceMax
            distanceLabel.text = String(format: "%.1f km", distanceMax)
        }
        
        if let lastLocationData = userDefaults.value(forKey: "lastLocation") as? Data {
            if let storedLocation = NSKeyedUnarchiver.unarchiveObject(with: lastLocationData) as? CLLocation {
                location = storedLocation
                isFirstLocationExists = true
                retrieveAllEvents()
            }
        }
        
        checkLocationPermission()
        
        allEventsRefreshControl.addTarget(self, action: #selector(fakeAllEventsRefresh), for: UIControlEvents.valueChanged)
        favoritesRefreshControl.addTarget(self, action: #selector(retrieveFavoriteEvents), for: UIControlEvents.valueChanged)
        followingRefreshControl.addTarget(self, action: #selector(retrieveFollowingEvents), for: UIControlEvents.valueChanged)
        firstCollectionView.addSubview(allEventsRefreshControl)
        thirdCollectionView.addSubview(favoritesRefreshControl)
        followingCollectionView.addSubview(followingRefreshControl)
        
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        eventDetailVC.mainMenuSender = self
        
        scrollPager.delegate = self
        scrollPager.addSegmentsWithTitlesAndViews(segments: [
            ("All", firstCollectionView),
            ("Favorites", thirdCollectionView),
            ("Following", followingCollectionView),
            ("Branches", fourthCollectionView)
            ])
        
        // Navigation bar & controller settings
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Chat") , style: .plain, target: self, action: #selector(rightBarButtonItemTouchUpInside))
        rightBarButtonItem.tintColor = UIColor.gray
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        // Collection view cell nib register
        let nibName = UINib(nibName: "EventCollectionViewCell", bundle:nil)
        let nibName2 = UINib(nibName: "FavoriteSportCollectionViewCell", bundle:nil)
        
        firstCollectionView.register(nibName, forCellWithReuseIdentifier: "eventCell")
        thirdCollectionView.register(nibName, forCellWithReuseIdentifier: "eventCell")
        followingCollectionView.register(nibName, forCellWithReuseIdentifier: "eventCell")
        fourthCollectionView.register(nibName2, forCellWithReuseIdentifier: "FavoriteSportCell")
        
        
        // If there are not enough events to scroll, you can still scroll
        firstCollectionView.alwaysBounceVertical = true
        thirdCollectionView.alwaysBounceVertical = true
        followingCollectionView.alwaysBounceVertical = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FTIndicator.dismissProgress()
    }
    
    // MARK: - CollectionView Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == firstCollectionView {
            return allEvents.count
        } else if collectionView == thirdCollectionView {
            return favoriteEvents.count
        } else if collectionView == fourthCollectionView {
            return branchs.count
        } else if collectionView == followingCollectionView {
            return followingEvents.count
        }
        
        return 0
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
            show(eventDetailVC, sender: self)
        } else if collectionView == thirdCollectionView {
            eventDetailVC.event = favoriteEvents[indexPath.row]
            show(eventDetailVC, sender: self)
        } else if collectionView == followingCollectionView {
            eventDetailVC.event = followingEvents[indexPath.row]
            show(eventDetailVC, sender: self)
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
            
            show(eventsVC, sender: self)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        if collectionView == firstCollectionView || collectionView == thirdCollectionView || collectionView == followingCollectionView {
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
        FTIndicator.showProgressWithmessage("Loading...", userInteractionEnable: false)
        
        var tempAllEvents = [Event]()
        var tempPopularEvents = [Event]()
        
        REF_EVENTS.observe(.value , with: { (snapshot) in
            
            tempAllEvents.removeAll()
            tempPopularEvents.removeAll()
            
            if snapshot.exists() {
                
                for element in snapshot.children.allObjects {
                    let eventElement = Event(snapshot: element as! FIRDataSnapshot)
                    
                    let eventLocation = CLLocation(latitude: Double(eventElement.locationLat)!, longitude: Double(eventElement.locationLon)!)
                    
                    let distance = Float(Double(self.location.distance(from: eventLocation)) / 1000.0)
                    
                    if !eventElement.isPast && distance < self.distanceMax {
                        if eventElement.isSponsored {
                            tempPopularEvents.append(eventElement)
                        } else {
                            tempAllEvents.append(eventElement)
                        }
                    }
                }
                
                self.allEvents = tempAllEvents.sorted(by: { ($0.fullDate?.isLessThanDate(dateToCompare: $1.fullDate!))!})
                
                for popularEvent in tempPopularEvents {
                    self.allEvents.insert(popularEvent, at: 0)
                }
                
                FTIndicator.dismissProgress()
                
                Async.main {
                    self.firstCollectionView.reloadData()
                    self.fourthCollectionView.reloadData()
                    
                    if self.startAnimation {
                        Async.main(after: 0.5, { _ in
                            self.startAnimation = false
                        })
                    }
                }
                
                self.retrieveFavoriteEvents()
                self.retrieveFollowingEvents()
            }
        })
    }
    
    func retrieveFollowingEvents () {
        var tempFolEvents = [Event]()
        
        if (currentUser.instance.user != nil) && (currentUser.instance.user?.following != nil) {
            for eventElement in self.allEvents {
                if (currentUser.instance.user?.following.contains(eventElement.creatorID))! {
                    tempFolEvents.append(eventElement)
                }
            }
            
            self.followingEvents = tempFolEvents.sorted(by: { ($0.fullDate?.isLessThanDate(dateToCompare: $1.fullDate!))!})
            
            Async.main {
                self.followingCollectionView.reloadData()
                self.followingRefreshControl.endRefreshing()
            }
        } else {
            REF_USERS.child((FIRAuth.auth()?.currentUser!.uid)!).child("following").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    tempFolEvents.removeAll()
                    
                    if let followingUsersIDs = (snapshot.value as? Dictionary<String, AnyObject>)?.keys {
                        for eventElement in self.allEvents {
                            if followingUsersIDs.contains(eventElement.creatorID) {
                                tempFolEvents.append(eventElement)
                            }
                        }
                        
                        self.followingEvents = tempFolEvents.sorted(by: { ($0.fullDate?.isLessThanDate(dateToCompare: $1.fullDate!))!})
                        
                        Async.main {
                            self.followingCollectionView.reloadData()
                            self.followingRefreshControl.endRefreshing()
                        }
                    }
                }
            })
        }
    }
    
    func retrieveFavoriteEvents () {
        var tempFavEvents = [Event]()
        
        if (currentUser.instance.user != nil) && (currentUser.instance.user?.favoriteSports != nil){
            self.favoriteSports = (currentUser.instance.user?.favoriteSports)!
            tempFavEvents.removeAll()
            
            for k in 0 ..< self.allEvents.count {
                for j in 0 ..< self.favoriteSports.count {
                    if self.allEvents[k].branch == self.favoriteSports[j] {
                        tempFavEvents.append(self.allEvents[k])
                    }
                }
            }
            
            self.favoriteEvents = tempFavEvents.sorted(by: { ($0.fullDate?.isLessThanDate(dateToCompare: $1.fullDate!))!})
            
            Async.main {
                self.thirdCollectionView.reloadData()
                self.favoritesRefreshControl.endRefreshing()
            }
        } else {
            REF_USERS.child((FIRAuth.auth()?.currentUser!.uid)!).child("favoriteSports").observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    tempFavEvents.removeAll()
                    
                    if let postDict = (snapshot.value as? Dictionary<String, String>)?.values {
                        self.favoriteSports = Array(postDict)
                    }
                    
                    for k in 0 ..< self.allEvents.count {
                        for j in 0 ..< self.favoriteSports.count {
                            if self.allEvents[k].branch == self.favoriteSports[j] {
                                tempFavEvents.append(self.allEvents[k])
                            }
                        }
                    }
                    
                    self.favoriteEvents = tempFavEvents.sorted(by: { ($0.fullDate?.isLessThanDate(dateToCompare: $1.fullDate!))!})
                }
                
                Async.main {
                    self.thirdCollectionView.reloadData()
                    self.favoritesRefreshControl.endRefreshing()
                }
            })
        }
    }
    
    func fakeAllEventsRefresh() {
        Async.main(after: 0.5, { _ in
            self.allEventsRefreshControl.endRefreshing()
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
    
    // MARK: -Location Services
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        timesToLocateAccurate -= 1
        location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error while updating location " + error.localizedDescription)
    }
    
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                if !isFirstLocationExists {
                    FTIndicator.showNotification(with: UIImage(named: "LocationPin"), title: "Can't update location!", message: "Give us location permission to list the events based on your current location!")
                    Async.main(after: 1, { self.checkLocationPermission() })
                }
            case .authorizedAlways, .authorizedWhenInUse:
                self.needYourLocationView.isHidden = true
                locationManager.startUpdatingLocation()
            }
        } else {
            if !isFirstLocationExists {
                FTIndicator.showNotification(with: UIImage(named: "LocationPin"), title: "Can't update location!", message: "You should enable your location services to list the events based on your current location!")
            }
            Async.main(after: 1, { self.checkLocationPermission() })
        }
    }
    
    @IBAction func distanceSliderChanged(_ sender: AnyObject) {
        distanceLabel.text = String(format: "%.1f km", distanceSlider.value)
    }
    
    @IBAction func setDistance(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.5, animations: {
            self.SetDistanceView.alpha = 0
            self.setDistanceButton.alpha = 1
            }, completion: { _ in
                self.setDistanceButton.isHidden = false
                self.SetDistanceView.isHidden = true
        })
        distanceMax = distanceSlider.value
        retrieveAllEvents()
        userDefaults.set(distanceMax, forKey: "maxDistance")
    }
    
    @IBAction func showDistanaceSettingButtonClicked(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.5, animations: {
            self.SetDistanceView.isHidden = false
            self.SetDistanceView.alpha = 1
            self.setDistanceButton.alpha = 0
        })
        
    }
}
