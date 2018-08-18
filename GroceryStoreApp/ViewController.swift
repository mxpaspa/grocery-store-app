//
//  ViewController.swift
//  GroceryStoreApp
//
//  Created by Max Paspa on 9/25/17.
//  Copyright © 2017 Max Paspa. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import UserNotifications
import CoreBluetooth


class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    
        var locationManager: CLLocationManager!
        var placesClient: GMSPlacesClient!
        var location : String = String()
        private var notification: NSObjectProtocol?
    private var backgroundNotification: NSObjectProtocol?
    
    
        @IBOutlet var locationSetting: UILabel!
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
        @IBOutlet var nameLabel: UILabel!
        @IBOutlet var currentLocation: UILabel!
        @IBOutlet var input: UITextField!
    
        let userDefaults = UserDefaults.standard
    
//    //test function
//    @IBAction func localNotification(_ sender: Any) {
//        let content = UNMutableNotificationContent()
//        content.title = NSString.localizedUserNotificationString(forKey:"Your notification title", arguments: nil)
//        content.body = NSString.localizedUserNotificationString(forKey: "Your notification body", arguments: nil)
//        content.categoryIdentifier = "Your notification category"
//        content.sound = UNNotificationSound.default()
//        content.badge = 1
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        let request = UNNotificationRequest(identifier: "any", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//        }
    
    
//        let locationManager = CLLocationManager()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            
            self.input.delegate = self
            input.returnKeyType = UIReturnKeyType.done

            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            placesClient = GMSPlacesClient.shared()
//            checkCoreLocationPermission()
//            locationManager.startUpdatingLocation()
//            updateLocation()
            
            
            
            if CLLocationManager.locationServicesEnabled(){
//                locationManager.delegate = self
//                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.allowsBackgroundLocationUpdates = true
                locationManager.startUpdatingLocation()
            }
            
            
            
            
            UserDefaults.standard.register(defaults: [String : Any]())
        
//            notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
//                [unowned self] notification in
//            }
            
            //saves settings information
            notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
                [unowned self] notification in
                let location_test = self.userDefaults.string(forKey: "location_preference")
                let final_location_test = location_test?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                print(final_location_test as Any)
                self.locationSetting.text = final_location_test
                
                // do whatever you want when the app is brought back to the foreground
            }
            
            
//            backgroundNotification = NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: .main) {
//                [unowned self] backgroundNotification in
//                func updateLocation(){
//                    self.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
//                        if let error = error {
//                            print("Pick Place error: \(error.localizedDescription)")
//                            return
//                        }
//
//
//
//                        if let placeLikelihoodList = placeLikelihoodList {
//                            let place = placeLikelihoodList.likelihoods.first?.place
//                            let location_test = self.userDefaults.string(forKey: "location_preference")
//                            let final_location_test = location_test?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//                            print(final_location_test as Any)
//                            self.locationSetting.text = final_location_test
//                            let location = place!.name
//                            if let place = place {
//                                self.currentLocation.text = place.name
//
//                                if location == final_location_test{
//                                    self.sendNotification()
//                                }
//                            }
//                        }
//                    })
//                }
//
//            }

            //http post to server
//            let myUrl = URL(string: "");
//            var request = URLRequest(url:myUrl!)
//            request.httpMethod = "POST"// Compose a query string
//            let postString = "firstName=James&lastName=Bond";
//            request.httpBody = postString.data(using: String.Encoding.utf8);
//
//            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
//                if error != nil
//                {
//                    print("error=\(error!)")
//                    return
//                }
//
//                // You can print out response object
//                let response = NSString(data: data!, encoding: String.Encoding.utf8.rawValue )
//                print("response = \(response!)")
//
//                //convert response sent from a server side script to a NSDictionary object:
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
//
//                    if let parseJSON = json {
//                        // Now we can access value of First Name by its key
//                        let firstNameValue = parseJSON["firstName"] as? String
//                        print("firstNameValue: \(firstNameValue!)")
//                    }
//                } catch {
//                    print(error)
//                }
//            }
//            task.resume()
            
            var centralManager: CBCentralManager?
            var peripherals = Array<CBPeripheral>()
            
             //Initialise CoreBluetooth Central Manager
            centralManager = CBCentralManager(delegate: nil, queue: nil)
            
            // Required. Invoked when the central manager’s state is updated.
            func centralManagerDidUpdateState(_ manager: CBCentralManager) {
                switch manager.state {
                case .poweredOff:
                    print("BLE has powered off")
                    centralManager?.stopScan()
                case .poweredOn:
                    print("BLE is now powered on")
                    centralManager?.scanForPeripherals(withServices: nil, options: nil)
                case .resetting: print("BLE is resetting")
                case .unauthorized: print("Unauthorized BLE state")
                case .unknown: print("Unknown BLE state")
                case .unsupported: print("This platform does not support BLE")
                }
            }
            
            // Invoked when the central manager discovers a peripheral while scanning.
            func centralManager(_ manager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData advertisement: [String : Any], rssi: NSNumber) {
                if let name = peripheral.name {
                    // RSSI is Received Signal Strength Indicator
                    print("Found \"\(name)\" peripheral (RSSI: \(rssi))")
                } else {
                    print("Found unnamed peripheral (RSSI: \(rssi))")
                }
                print("Advertisement data:", advertisement)
                print("")
            }
            
        }
    
    //sending device token to server
//    func testFunction (for token: String){
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            print("device token from delegate: \(appDelegate.token)")
//        }
//
//    }
    
//    @objc func appWillEnterForeground () {
//
//    }

    func updateLocation(){
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            self.nameLabel.text = "No current place"

            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                let location_test = self.userDefaults.string(forKey: "location_preference")
                let final_location_test = location_test?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                print(final_location_test as Any)
                self.locationSetting.text = final_location_test
                let location = place!.name
                if let place = place {
                    self.currentLocation.text = place.name

                    if location == final_location_test{
                        self.sendNotification()
                    }
                }
            }
        })
    }
    
    
    // Add a UIButton in Interface Builder, and connect the action to this function.
    @IBAction func getCurrentPlace(_ sender: Any) {
        
        
            placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                self.nameLabel.text = "No current place"
                
                if let placeLikelihoodList = placeLikelihoodList {
                    let place = placeLikelihoodList.likelihoods.first?.place
                    let location = place!.name
                    if let place = place {
                        self.nameLabel.text = place.name
//                        self.sendLocation(location: location)
                        if location.contains("Inf") {
                            self.sendNotification()
                        }
                    }
                }
            })
        }
    
//sends location information to server
//    func sendLocation(location: String){
//        print(location)
//        let myUrl = URL(string: "http://10.0.1.44/push_notifications/location.php");
//        var request = URLRequest(url:myUrl!)
//        request.httpMethod = "POST"// Compose a query string
//        let postString = "location=\(location)";
//        request.httpBody = postString.data(using: String.Encoding.utf8);
//
//        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
//            if error != nil
//            {
//                print("error=\(error!)")
//                return
//            }
//
//            // You can print out response object
//            let response = NSString(data: data!, encoding: String.Encoding.utf8.rawValue )
//            print("response = \(response!)")
//        }
//
//        task.resume()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkCoreLocationPermission(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    var list = ["test 1", "test 2", "test 3"]
    @IBOutlet var MyTableView: UITableView!
    

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return(list.count)
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "prototype cell")
        cell.textLabel?.text = list[indexPath.row]
        return(cell)
        
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            self.list.remove(at: indexPath.row)
            MyTableView.reloadData()
        }
    }
    
    //input field stuff
    
    func addItem(_ sender: Any) {
        list.append(input.text!)
        input.text = ""
        MyTableView.reloadData()
    }
    
    //changed return to done, done will now add items to 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addItem(input)
        return(true)
    }
    
//    //hide keyboard when user touches outisde the keyboard
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        inputField.resignFirstResponder()
//        self.view.endEditing(true)
//    }

    func sendNotification () {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey:
            "Your notification title", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Your notification body", arguments: nil)
        content.categoryIdentifier = "Your notification category"
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "any", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
//    func renew(){
//        //reload application data (renew root view )
//        UIApplication.shared.keyWindow?.rootViewController = storyboard!.instantiateViewController(withIdentifier: "list_view")
//    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        locationManager = CLLocationManager()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//
//        locationManager.requestAlwaysAuthorization()
//        placesClient = GMSPlacesClient.shared()
//
//        locationManager.startUpdatingLocation()
//        print("updated location")
//        sendNotification()
//
//
//
//        if UIApplication.shared.applicationState == .active {
//            print("wunderlich code")
//        } else {
//            print("App is backgrounded. New location is most recent code")
//        }
        if let location = locations.first {
            print(location.coordinate)
        }
        updateLocation()
        
        
    }
    
    
}
