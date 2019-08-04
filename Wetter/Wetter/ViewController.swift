//
//  ViewController.swift
//  Wetter
//
//  Created by Kilian Kellermann on 28.02.17.
//  Copyright © 2017 Kilian Kellermann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // View-Elemente
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let resource = OpenweatherResource()
        resource.fetchReport {
            (response) in
            
            self.weatherLabel.text = response.description
            self.weatherLabel.isHidden = false
            
            self.tempLabel.text = "\(response.temperatur)°"
            self.tempLabel.isHidden = false
            
            resource.fetchImage(forIcon: response.icon, completion: {
                (img) in
                
                self.weatherImage.image = img
                self.weatherImage.isHidden = false
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

