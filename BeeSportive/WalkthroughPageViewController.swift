//
//  WalkthroughPageViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 2.11.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var pageDescription = ["Recieve updates on the sports gatherings and events happening nearby.",
                           "Meet people with the same athletic interests woth you and exercise with them!",
                           "Create sporting events for your favourite sports and enjoy training with your new sports buddies!",
                           "Follow your friends and BeeSportive Athletes! Get inspired and socialize with BeeSportive!"]
    var pageImages = ["Slide1", "Slide2", "Slide3", "Slide4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        if let startVC = self.viewControllerAtIndex(index: 0) {
            setViewControllers([startVC], direction: .forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func nextPageWithIndex(index: Int) {
        
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        if index == NSNotFound || index < 0 || index >= pageDescription.count {
            return nil
        }
        
        let walkthroughVC = WalkthroughContentViewController(nibName: "WalkthroughContentViewController", bundle: nil)
        walkthroughVC.index = index
        walkthroughVC.imageName = pageImages[index]
        walkthroughVC.text = pageDescription[index]
        
        return walkthroughVC
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
