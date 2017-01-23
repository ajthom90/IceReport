//
//  AddIceReportViewController.swift
//  IceReport
//
//  Created by Andrew Thom on 1/21/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import UIKit

class AddIceReportViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var pickerOptions : [String] = []
    var addIceReportDelegate : AddIceReportDelegate?
    @IBOutlet var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = self
        picker.delegate = self
        
        var options = [String]()
        
        let useMetric = UserDefaults.standard.bool(forKey: "useMetric")
        
        if (useMetric) {
            for i in 0...200 {
                options.append("\(i)cm")
            }
        }
        else {
            for i in 0...100 {
                options.append("\(i).0in")
                options.append("\(i).5in")
            }
        }
        
        pickerOptions = options
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        addIceReportDelegate!.addIceReport(pickerOptions[picker.selectedRow(inComponent: 0)])
        self.dismiss(animated: true) {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
