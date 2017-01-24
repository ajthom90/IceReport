//
//  NumberOfDaysPickerViewController.swift
//  IceReport
//
//  Created by Andrew Thom on 1/24/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import UIKit

class NumberOfDaysPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var nums = [Int]()
    var numberOfDaysDelegate : NumberOfDaysToSearchDelegate?
    
    @IBOutlet var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        for i in 1...100 {
            nums.append(i)
        }
        
        let daysToSearch = UserDefaults.standard.integer(forKey: "daysToSearch")
        picker.selectRow(daysToSearch - 1, inComponent: 0, animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        numberOfDaysDelegate!.updateNumberOfDays(to: nums[picker.selectedRow(inComponent: 0)])
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(nums[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return nums.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
