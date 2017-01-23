//
//  SettingsTableViewController.swift
//  IceReport
//
//  Created by Andrew Thom on 1/23/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import UIKit
import MapKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet var useMetricSwitch: UISwitch!
    @IBOutlet var mapTypeControl: UISegmentedControl!
    @IBOutlet var showDateTimeSwitch: UISwitch!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}