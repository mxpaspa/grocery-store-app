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


class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    
        var locationManager: CLLocationManager!
        var placesClient: GMSPlacesClient!
        
        // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
        @IBOutlet var nameLabel: UILabel!
    

        override func viewDidLoad() {
            super.viewDidLoad()
            
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            placesClient = GMSPlacesClient.shared()
            checkCoreLocationPermission()
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
                    if let place = place {
                        self.nameLabel.text = place.name
                        
                    }
                }
                
            })
        }
    
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
    
    @IBOutlet var input: UITextField!
    @IBAction func addItem(_ sender: Any) {
        list.append(input.text!)
        input.text = ""
        MyTableView.reloadData()
    }
    
}

func sendNotification () {
let content = UNMutableNotificationContent()
content.title = NSString.localizedUserNotificationString(forKey:
    "Your notification title", arguments: nil)
content.body = NSString.localizedUserNotificationString(forKey: "Your notification body", arguments: nil)
content.categoryIdentifier = "Your notification category"
content.sound = UNNotificationSound.default()
content.badge = 1
    
}


