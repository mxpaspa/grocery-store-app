//
//  AppDelegate.swift
//  GroceryStoreApp
//
//  Created by Max Paspa on 9/25/17.
//  Copyright © 2017 Max Paspa. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation


import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var token: String?
    var locationManager: CLLocationManager!
    var placesClient: GMSPlacesClient!
    var backgroundLocation: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSPlacesClient.provideAPIKey("AIzaSyCPCxul04Cq5bGkHw693AblPDAMb3UEfQM")
//        registerForPushNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound, .badge]) { (allowed, error) in
            //
        }
        
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.setMinimumBackgroundFetchInterval( 5 )
//        application.beginBackgroundTask(withName: "showNotification", expirationHandler: nil)
        
        return true
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        placesClient = GMSPlacesClient.shared()
        
        locationManager.startUpdatingLocation()
        print("updating background after app minimized")
        sendNotification()
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        <#code#>
//    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        placesClient = GMSPlacesClient.shared()
        
        locationManager.startUpdatingLocation()
        sendBackgroundLocation()
        
    }
    
    
    func sendBackgroundLocation(){
    self.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
        if let error = error {
            print("Pick Place error: \(error.localizedDescription)")
            return
        }
        
        
        
        if let placeLikelihoodList = placeLikelihoodList {
            let place = placeLikelihoodList.likelihoods.first?.place
            
            let backgroundLocation = place!.name
            let testLocation = "Harris Teeter"
            if let place = place {
                self.backgroundLocation = place.name
                print (backgroundLocation)
                if backgroundLocation == testLocation{
                    self.sendNotification()
                    }
                
                }
            }
        })
    }
    

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
       



    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        let myUrl = URL(string: "http://10.0.1.44/push_notifications/token.php");
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"// Compose a query string
        let postString = "deviceToken=\(token)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            // You can print out response object
            let response = NSString(data: data!, encoding: String.Encoding.utf8.rawValue )
            print("response = \(response!)")
        
        }
        task.resume()
    }
    
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

}

