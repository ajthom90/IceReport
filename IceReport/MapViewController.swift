//
//  MapViewController.swift
//  IceReport
//
//  Created by Andrew Thom on 1/21/17.
//  Copyright © 2017 Andrew J. Thom. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, AddIceReportDelegate, IceReportMapDelegate {
    var userId : Int?
    var sessionId : String?
    
    @IBOutlet var navBar: UINavigationBar!
    
    var reports : [Report] = []
    var usernameMap : [Int : String] = [:]
    
    let locationManager = CLLocationManager()
    
    let distanceSpan: Double = 500
    
    var enable = false
    
    var initialCenter = false;
    
    @IBOutlet var mapView: MKMapView!

    var myLocation:CLLocationCoordinate2D?
    
    @IBAction func refreshTapped(_ sender: Any) {
        self.refreshMap()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.mapType = MapTypeMapper.mapType(for: UserDefaults.standard.integer(forKey: "mapType"))
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        //addLongPressGesture()
        
        self.startLoadingData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapView.showsUserLocation = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.showsUserLocation = false
    }
    
    func centerMap(_ center:CLLocationCoordinate2D){
        self.saveCurrentLocation(center)
        
        let spanX = 0.05
        let spanY = 0.05
        
        let newRegion = MKCoordinateRegion(center:center , span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
    }
    
    func saveCurrentLocation(_ center:CLLocationCoordinate2D){
        let message = "\(center.latitude) , \(center.longitude)"
        print(message)
        //self.lable.text = message
        myLocation = center
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        if (!initialCenter) {
            centerMap(locValue)
            initialCenter = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if (annotation is MKUserLocation) {
            return nil
        }
        if (annotation is IceReportAnnotation) {
            let ann = annotation as! IceReportAnnotation
            let identifier = ann.reuseIdentifier
            var view : MKPinAnnotationView
            if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView{
                dequeueView.annotation = ann
                view = dequeueView
            }else{
                view = MKPinAnnotationView(annotation: ann, reuseIdentifier: identifier)
                view.canShowCallout = true
            }
            view.pinTintColor = ann.annotationColor
            return view
        }
        return nil
    }
    
    func refreshMap() {
        let allAnnotations = self.mapView.annotations
        var iceReportAnnotations = [MKAnnotation]()
        for annotation in allAnnotations {
            if (annotation is IceReportAnnotation) {
                iceReportAnnotations.append(annotation)
            }
        }
        self.mapView.removeAnnotations(iceReportAnnotations)
        
        self.reports = []
        self.usernameMap = [:]
        
        self.startLoadingData()
    }
    
    
    fileprivate func startLoadingData() {
        var comps = DateComponents()
        comps.day = -3
        
        let calendar = Calendar.current
        
        let twoWeeksAgo = calendar.date(byAdding: comps, to: Date())
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let dbDate = format.string(from: twoWeeksAgo!)
        let filter = "timestamp > \(dbDate)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: "https://ft-andrewjthom.vz2.dreamfactory.com/api/v2/db/_table/ice_report?filter=\(filter!)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("fc1ac7729bd1622bfa2d555a4d1d78e59c03da4eba86769c811ff7f00ad05295", forHTTPHeaderField: "X-DreamFactory-Api-Key")
        request.addValue(self.sessionId!, forHTTPHeaderField: "X-DreamFactory-Session-Token")
        
        let format2 = DateFormatter()
        format2.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let resource = jsonData["resource"] as! [Any]
            for item in resource {
                let rep = item as! [String: Any]
                let latitude = rep["latitude"] as! Double
                let longitude = rep["longitude"] as! Double
                let userId = rep["user_id"] as! Int
                let inches = rep["inches"] as! String
                let dateString = rep["timestamp"] as! String
                let year = Int(self.substring(of: dateString, from: 0, to: 3))
                let month = Int(self.substring(of: dateString, from: 5, to: 6))
                let day = Int(self.substring(of: dateString, from: 8, to: 9))
                let hour = Int(self.substring(of: dateString, from: 11, to: 12))
                let minute = Int(self.substring(of: dateString, from: 14, to: 15))
                let seconds = Int(self.substring(of: dateString, from: 17, to: 18))
                
                let dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone(abbreviation: "UTC"), era: nil, year: year, month: month, day: day, hour: hour, minute: minute, second: seconds, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                
                let timestamp = calendar.date(from: dateComponents)
                
                self.reports.append(Report(latitude, longitude, timestamp, userId, inches))
            }
            
            DispatchQueue.main.async {
                self.getUsernames()
            }
        }
        
        task.resume()
    }
    
    fileprivate func getUsernames() {
        let url = URL(string: "https://ft-andrewjthom.vz2.dreamfactory.com/api/v2/system/user?fields=id%2Cname")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("fc1ac7729bd1622bfa2d555a4d1d78e59c03da4eba86769c811ff7f00ad05295", forHTTPHeaderField: "X-DreamFactory-Api-Key")
        request.addValue(sessionId!, forHTTPHeaderField: "X-DreamFactory-Session-Token")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let resource = jsonData["resource"] as! [Any]
            for item in resource {
                let user = item as! [String: Any]
                let id = user["id"] as! Int
                let name = user["name"] as! String
                self.usernameMap[id] = name
            }
            
            DispatchQueue.main.async {
                self.getAdmins()
            }
        }
        task.resume()
    }
    
    fileprivate func getAdmins() {
        let url = URL(string: "https://ft-andrewjthom.vz2.dreamfactory.com/api/v2/system/admin?fields=id%2Cname")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("fc1ac7729bd1622bfa2d555a4d1d78e59c03da4eba86769c811ff7f00ad05295", forHTTPHeaderField: "X-DreamFactory-Api-Key")
        request.addValue(sessionId!, forHTTPHeaderField: "X-DreamFactory-Session-Token")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let resource = jsonData["resource"] as! [Any]
            for item in resource {
                let user = item as! [String: Any]
                let id = user["id"] as! Int
                let name = user["name"] as! String
                self.usernameMap[id] = name
            }
            
            DispatchQueue.main.async {
                self.placePinsOnMap()
            }
        }
        task.resume()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if let mapView = self.mapView {
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, self.distanceSpan, self.distanceSpan)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    fileprivate func placePinsOnMap() {
        let calendar = Calendar.current
        let now = Date()
        
        let useMetric = UserDefaults.standard.bool(forKey: "useMetric")
        
        for (index, report) in reports.enumerated() {
            let annotation = IceReportAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(report.latitude, report.longitude)
            var dateString = ""
            annotation.reuseIdentifier = "greenPin"
            annotation.annotationColor = UIColor.green
            if (Double(report.inches)! < 4.0) {
                annotation.reuseIdentifier = "redPin"
                annotation.annotationColor = UIColor.red
            }
            else if (Double(report.inches)! < 8.0) {
                annotation.reuseIdentifier = "yellowPin"
                annotation.annotationColor = UIColor.yellow
            }
            if let date = report.date {
                let showDateTime = UserDefaults.standard.bool(forKey: "showDateTime")
                if (!showDateTime) {
                    let components = calendar.dateComponents([.day], from: date, to: now)
                    if let days = components.day {
                        var daysStr = ""
                        if (days == 0) {
                            daysStr = "Today"
                        }
                        else if (days == 1) {
                            daysStr = "Yesterday"
                        }
                        else {
                            daysStr = "\(days) Days Ago"
                        }
                        
                        dateString = " \(daysStr)"
                    }
                }
                else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = NSTimeZone.local
                    let useMetric = UserDefaults.standard.bool(forKey: "useMetric")
                    if (useMetric) {
                        dateFormatter.dateFormat = "d/M H:mm"
                    }
                    else {
                        dateFormatter.dateFormat = "M/d h:mm a"
                    }
                    dateString = " - \(dateFormatter.string(from: date))"
                }
            }
            annotation.title = "\(getAmount(report.inches, useMetric: useMetric))\(getUnits(useMetric))\(dateString)"
            annotation.subtitle = "Reported by \(usernameMap[report.userId]!)"
            annotation.reportIndex = index
            mapView.addAnnotation(annotation)
        }
    }
    
    fileprivate func getAmount(_ amount : String, useMetric metric : Bool) -> String {
        if (!metric) {
            return amount
        }

        return String(Int(Double(amount)! * 2.54));
    }
    
    fileprivate func getUnits(_ metric : Bool) -> String {
        if (metric) {
            return "cm"
        }
        return " Inches"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addIceReportSegue" {
            let destination = segue.destination as! AddIceReportViewController
            destination.addIceReportDelegate = self
        }
        else if segue.identifier == "toSettingsSegue" {
            let destination = segue.destination as! SettingsViewController;
            destination.refreshMapDelegate = self
        }
    }
    
    @IBAction func addTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "addIceReportSegue", sender: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toSettingsSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func convertToInches(centimeters amount : String) -> String {
        let cm = Double(amount)!;
        let inches = cm / 2.54
        let denominator = 2.0
        return String(round(inches * denominator) / denominator)
    }
    
    func set(mapType: MKMapType) {
        mapView.mapType = mapType
    }
    
    func addIceReport(_ amount: String) {
        var inches = amount.replacingOccurrences(of: "in", with: "").replacingOccurrences(of: "cm", with: "")
        let useMetric = UserDefaults.standard.bool(forKey: "useMetric")
        if (useMetric) {
            inches = convertToInches(centimeters: inches)
        }
        let coordinates = self.locationManager.location?.coordinate
        if (coordinates == nil) {
            return
        }
        var postBody = [String: Any]()
        var resourceArray = [[String: Any]]()
        var object = [String: Any]()
        object["inches"] = inches
        object["latitude"] = coordinates!.latitude
        object["longitude"] = coordinates!.longitude
        resourceArray.append(object)
        postBody["resource"] = resourceArray
        
        let url = URL(string: "https://ft-andrewjthom.vz2.dreamfactory.com/api/v2/db/_table/ice_report")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("fc1ac7729bd1622bfa2d555a4d1d78e59c03da4eba86769c811ff7f00ad05295", forHTTPHeaderField: "X-DreamFactory-Api-Key")
        request.addValue(self.sessionId!, forHTTPHeaderField: "X-DreamFactory-Session-Token")
        
        let json = try? JSONSerialization.data(withJSONObject: postBody, options: [])
        
        request.httpBody = json
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (error != nil) {
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            
            if (httpResponse.statusCode != 200) {
                return
            }
            
            DispatchQueue.main.async {
                self.refreshMap()
            }
        }
        
        task.resume()
    }
    
    fileprivate func substring(of str : String, from startIndex : Int, to endIndex : Int) -> String {
        let start = str.index(str.startIndex, offsetBy: startIndex)
        let end = str.index(str.startIndex, offsetBy: endIndex)
        
        return str[start...end]
    }
}
