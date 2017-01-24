//
//  SettingsTableViewController.swift
//  IceReport
//
//  Created by Andrew Thom on 1/23/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import UIKit
import MapKit

class SettingsTableViewController: UITableViewController, NumberOfDaysToSearchDelegate {

    @IBOutlet var useMetricSwitch: UISwitch!
    @IBOutlet var mapTypeControl: UISegmentedControl!
    @IBOutlet var showDateTimeSwitch: UISwitch!
    @IBOutlet var numberOfDaysLabel: UILabel!
    
    @IBAction func mapTypeChanged(_ sender: Any) {
        let index = mapTypeControl.selectedSegmentIndex
        UserDefaults.standard.set(index, forKey: "mapType")
    }
    
    @IBAction func showDateTimeChanged(_ sender: Any) {
        UserDefaults.standard.set(showDateTimeSwitch.isOn, forKey: "showDateTime")
    }

    @IBAction func useMetricChanged(_ sender: Any) {
        UserDefaults.standard.setValue(useMetricSwitch.isOn, forKey: "useMetric")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let useMetric = UserDefaults.standard.bool(forKey: "useMetric")
        useMetricSwitch.isOn = useMetric
        
        let mapType = UserDefaults.standard.integer(forKey: "mapType")
        mapTypeControl.selectedSegmentIndex = mapType
        
        let showDateTime = UserDefaults.standard.bool(forKey: "showDateTime")
        showDateTimeSwitch.isOn = showDateTime
        
        let daysToSearch = UserDefaults.standard.integer(forKey: "daysToSearch")
        numberOfDaysLabel.text = String(daysToSearch)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 3 && indexPath.row == 0) {
            self.performSegue(withIdentifier: "numberOfDaysSegue", sender: nil)
        }
        else if (indexPath.section == 4) {
            if (indexPath.row == 0) {
                self.performSegue(withIdentifier: "showLicenseSegue", sender: nil)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "numberOfDaysSegue") {
            let destination = segue.destination as! NumberOfDaysPickerViewController
            destination.numberOfDaysDelegate = self
        }
    }
    
    func updateNumberOfDays(to: Int) {
        UserDefaults.standard.set(to, forKey: "daysToSearch")
        numberOfDaysLabel.text = String(to)
    }
}
