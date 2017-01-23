//
//  SettingsViewController.swift
//  IceReport
//
//  Created by Andrew Thom on 1/23/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import UIKit
import MapKit

class SettingsViewController: UIViewController {
    
    var refreshMapDelegate : IceReportMapDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "logoutUnwindSegue", sender: sender)
    }

    @IBAction func doneTapped(_ sender: Any) {
        refreshMapDelegate!.refreshMap()
        let mapType = UserDefaults.standard.integer(forKey: "mapType")
        refreshMapDelegate!.set(mapType: MapTypeMapper.mapType(for: mapType))
        self.dismiss(animated: true, completion: nil)
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
