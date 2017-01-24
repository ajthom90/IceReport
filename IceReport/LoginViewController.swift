//
//  ViewController.swift
//  IceReport
//
//  Created by Andrew Thom on 1/21/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    var loggedIn = false
    var loggedInSessionId : String?
    var loggedInUserId : Int?
    
    var iceReportMapDelegate : IceReportMapDelegate?
    
    @IBOutlet var emailAddressField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func registerTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "registerUserSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddressField.delegate = self
        passwordField.delegate = self
        
        let emailAddress = UserDefaults.standard.string(forKey: "emailAddress")
        let password = UserDefaults.standard.string(forKey: "password")
        
        if (emailAddress != nil && password != nil) {
            emailAddressField.text = emailAddress
            passwordField.text = password
            logInUser()
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        self.logInUser()
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        self.logoutUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == emailAddressField) {
            emailAddressField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        }
        else if (textField == passwordField) {
            passwordField.resignFirstResponder()
            logInUser()
        }
        return true
    }
    
    func logoutUser() {
        let url = URL(string: "https://ft-andrewjthom.vz2.dreamfactory.com/api/v2/user/session")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("fc1ac7729bd1622bfa2d555a4d1d78e59c03da4eba86769c811ff7f00ad05295", forHTTPHeaderField: "X-DreamFactory-Api-Key")
        request.addValue(self.loggedInSessionId!, forHTTPHeaderField: "X-DreamFactory-Session-Token")
        
        self.loggedInSessionId = nil
        self.loggedInUserId = nil
        self.loggedIn = false
        UserDefaults.standard.removeObject(forKey: "emailAddress")
        UserDefaults.standard.removeObject(forKey: "password")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
        }
        
        task.resume()
        
        emailAddressField.text = ""
        passwordField.text = ""
    }
    
    func logInUser() {
        let alert = UIAlertController(title: nil, message: "Logging in...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        let url = URL(string: "https://ft-andrewjthom.vz2.dreamfactory.com/api/v2/user/session")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("fc1ac7729bd1622bfa2d555a4d1d78e59c03da4eba86769c811ff7f00ad05295", forHTTPHeaderField: "X-DreamFactory-Api-Key")
        
        let postData = [
            "email" : emailAddressField.text!,
            "password" : passwordField.text!,
            "duration" : 0
            ] as [String : Any]
        
        let json = try? JSONSerialization.data(withJSONObject: postData, options: [])
        
        request.httpBody = json
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: "There was an error logging in. Please try again", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: {
                    //
                })
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            let alertController = UIAlertController(title: "Error", message: "There was an error logging in. Please try again", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: {
                                //
                            })
                        })
                    }

                }
                else {
                    let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    
                    let sessionId = jsonData["session_id"] as? String
                    let userId = jsonData["id"] as! Int
                    self.loggedIn = true
                    self.loggedInSessionId = sessionId
                    self.loggedInUserId = userId
                    
                    let email = self.emailAddressField.text!
                    let password = self.passwordField.text!
                    
                    UserDefaults.standard.setValue(email, forKey: "emailAddress")
                    UserDefaults.standard.setValue(password, forKey: "password")
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "loginAndShowMapSegue", sender: self)
                            }
                        })
                    }
                }
            }
        }
        
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loginAndShowMapSegue") {
            let dest = segue.destination as! MapViewController
            iceReportMapDelegate = dest
            dest.userId = loggedInUserId
            dest.sessionId = loggedInSessionId
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

