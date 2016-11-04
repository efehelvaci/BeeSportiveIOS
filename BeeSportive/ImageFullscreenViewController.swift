//
//  ImageFullscreenViewController.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 3.11.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import UIKit

class ImageFullscreenViewController: UIViewController {
    
    @IBOutlet var image: UIImageView!
    
    var imagePhotoURLString : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Profile Photo"
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        image.kf.setImage(with: URL(string: imagePhotoURLString))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
