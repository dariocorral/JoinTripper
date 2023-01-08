//
//  AppDelegate.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import CoreData
import AviasalesSDK
import CoreLocation
import Firebase
import FirebaseCore
import FirebaseMessaging
import FirebaseUI
import UserNotifications
import FirebaseInstanceID
import FirebaseDatabase
import TJBioAuthentication
import Alamofire
import SwiftyJSON
import SwiftyXMLParser
import Branch


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    let gcmMessageIDKey = "gcm.message_id"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Load Location Manager
        setupLocationManager()
        
        //Google Firebase init singleton
        FirebaseApp.configure()
        
        //Set login or main storyboard like initial storyboard according extension bellow
        do { try configureInitialRootViewController(for: window)}
        catch let error as NSError {
            print("Error ConfigureRootViewController: \(error.debugDescription)")
            }
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        //AppConfigurator.swift Aviasales
        AppConfigurator.configure()
        let airportsData : [JRSDKAirport]? =  AviasalesSDK.sharedInstance().airportsStorage.airports()
        AviasalesSDK.sharedInstance().airportsStorage.store(airportsData)
        
        //Navigation Controller Color
        UINavigationBar.appearance().barTintColor = ColorHex.hexStringToUIColor(hex: "#F2B2AF")
        UINavigationBar.appearance().tintColor = ColorHex.hexStringToUIColor(hex: "#526CA0")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:ColorHex.hexStringToUIColor(hex: "#526CA0"), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22) as Any]
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UINavigationBar.appearance().isTranslucent = false

        
        //Tab bar font
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13) as Any], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13) as Any], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
        
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = false
        
        //Core Data
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            preloadCoreData()
            defaults.set(true, forKey: "isPreloaded")
        }
        
        //Load airports data
        self.loadAirportsData()
        
        
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil {
                // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
                // params will be empty if no data found
                // ... insert custom logic here ...
                print("params: %@", params as? [String: AnyObject] ?? {})
            }
        })
                
        return true
    }
    
    //MARK: - Branch links
    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // pass the url to the handle deep link call
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }
        
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    
    //MARK: - Setup Location manager
    func setupLocationManager(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
        
        guard let location = self.locationManager.location else {return}
        
        print("User location")
        print(location.coordinate.latitude, location.coordinate.longitude)
        
    }
    
    //MARK: - Load airports data
    func loadAirportsData() {
        
        let dataAirports = DataAPI()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //Delete previous data
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Airports")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            
        } catch let error as NSError {
            print ("There was an error deleting airports data: \(error.debugDescription)")
        }
        
        //Load data airports
        dataAirports.loadJSONAirportsData()
        
        //Save closest airports code
        guard let firUser = Auth.auth().currentUser else {
            print("No firuser")
            return}
        
        var airports: [NSManagedObject] = []
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Airports")
        
        //Ordenamos los aeropuertos por distancia
        let sortByDistance = NSSortDescriptor(key: #keyPath(Airports.distance),
                                              ascending: true)
        fetchRequest.sortDescriptors = [sortByDistance]
        
        do {
            airports = try managedContext.fetch(fetchRequest)
            
            //Get Closest Airport & save at firebase
            guard let closestAirport = airports.first?.value(forKey: "code") else {print ("Error fetching closest airport code")
                return}
            
            print("Closest airport: \(closestAirport)")
            let ref = Database.database().reference().child("users").child(firUser.uid)
            let childUpdates = ["closestAirport": closestAirport]
            ref.updateChildValues(childUpdates)
            
            
        } catch let error as NSError {
            print("Could not fetch Airports Data: \(error), \(error.userInfo)")
        }
        
    }
    
    func preloadCoreData () {
        
        //Core Data variables
        let dataCurrencies = DataAPI()
        let dataLanguages = DataAPI()
        let dataCountries = DataAPI()
        
        var languages: [NSManagedObject] = []
        var countries: [NSManagedObject] = []
        var currencies: [NSManagedObject] = []
        
        
        //Load Currencies Core Data if not loaded before
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //Currencies fetch
        let fetchRequestCurrencies =
            NSFetchRequest<NSManagedObject>(entityName: "Currencies")
        
        //Ordenamos el símbolo de las divisas alfabéticamente
        let sortBySymbol = NSSortDescriptor(key: #keyPath(Currencies.symbol),
                                            ascending: true)
        fetchRequestCurrencies.sortDescriptors = [sortBySymbol]
        
        do {
            currencies = try managedContext.fetch(fetchRequestCurrencies)
            
            //Si no hay información cargamos la info en Core Data desde el file JSON
            if 0 ..< 7 ~= currencies.count {
                
                dataCurrencies.loadJSONCurrenciesData()
                
                //Ordenamos el símbolo de las divisas alfabéticamente
                let sortBySymbol = NSSortDescriptor(key: #keyPath(Currencies.symbol),
                                                    ascending: true)
                fetchRequestCurrencies.sortDescriptors = [sortBySymbol]
                currencies = try managedContext.fetch(fetchRequestCurrencies)
            }
            
        } catch let error as NSError {
            print("Could not fetch Currencies Data: \(error), \(error.userInfo)")
        }
        
        //Load Languages Core Data if not loaaded before
        let fetchRequestLanguages =
            NSFetchRequest<NSManagedObject>(entityName: "Languages")
        
        //Ordenamos el símbolo de las divisas alfabéticamente
        let sortByCodeL = NSSortDescriptor(key: #keyPath(Languages.code),
                                           ascending: true)
        fetchRequestLanguages.sortDescriptors = [sortByCodeL]
        
        do {
            languages = try managedContext.fetch(fetchRequestLanguages)
            
            //Si no hay información cargamos la info en Core Data desde el file JSON
            if 0 ..< 19 ~= languages.count {
                
                dataLanguages.loadJSONLanguagesData()
                
                //Ordenamos el símbolo de los idiomas alfabéticamente
                let sortByCodeL = NSSortDescriptor(key: #keyPath(Languages.code),
                                                   ascending: true)
                fetchRequestLanguages.sortDescriptors = [sortByCodeL]
                languages = try managedContext.fetch(fetchRequestLanguages)
            }
            
        } catch let error as NSError {
            print("Could not fetch Languages Data: \(error), \(error.userInfo)")
        }
        
        //Load Countries Core Data if not loaaded before
        let fetchRequestCountries =
            NSFetchRequest<NSManagedObject>(entityName: "Countries")
        
        //Ordenamos el nombre de las divisas alfabéticamente
        let sortByName = NSSortDescriptor(key: #keyPath(Countries.name),
                                          ascending: true)
        fetchRequestCountries.sortDescriptors = [sortByName]
        
        do {
            countries = try managedContext.fetch(fetchRequestCountries)
            
            //Si no hay información cargamos la info en Core Data desde el file JSON
            if 0 ..< 24 ~= countries.count {
                
                dataCountries.loadJSONCountriesData()
                
                //Ordenamos el símbolo de las divisas alfabéticamente
                let sortByName = NSSortDescriptor(key: #keyPath(Countries.name),
                                                  ascending: true)
                fetchRequestCountries.sortDescriptors = [sortByName]
                countries = try managedContext.fetch(fetchRequestCountries)
            }
            
        } catch let error as NSError {
            print("Could not fetch Countries Data: \(error), \(error.userInfo)")
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // handle your message
        
    }
    
    private func application(application: UIApplication,
                             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        //Get a reference to current user logged to FB Database (Mandatory UID)
        guard let firUser = Auth.auth().currentUser else {return}
        
        //Write online status firebase
        let ref = Database.database().reference().child("users").child(firUser.uid).child("isOnline")
        ref.setValue(false)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Get a reference to current user logged to FB Database (Mandatory UID)
        guard let firUser = Auth.auth().currentUser else {return}
        
        //Write online status firebase
        let ref = Database.database().reference().child("users").child(firUser.uid).child("isOnline")
        ref.setValue(true)
        
        //Update last user session
        let refUserSession =
            Database.database().reference().child("users").child(firUser.uid).child("lastSession")
        
        let dateFommatter = DateFormatter()
        dateFommatter.dateFormat = "ddMMyyyy"
        let lastSessionDate = dateFommatter.string(from: Date())
        
        refUserSession.setValue(lastSessionDate)
        
        //Restart badget count
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Social Logign config
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        
        // other URL handling goes here
        
        return false
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "JoinTripper")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    //MARK: - Local Authentication methods
    //MARK: - Authenticate FaceId / Biometrics / Password
    func securityCheckPoint() {
        print("Loading security check point")
        
        if Auth.auth().currentUser != nil{
        
            TJBioAuthenticator.shared.authenticateUserWithBioMetrics(success: {
                // Biometric Authentication success
                print("Local Authentication Passed")
                let initialViewController = UIStoryboard.initialViewController(for: .main)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
                
                
            }) { (error) in
                // Biometric Authentication unsuccessful
                
                print("Error Authentication: \(error)")
                switch error{
                    
                case .userCancel:
                    
                    guard Auth.auth().currentUser != nil else {
                        return
                    }
                    do {
                        try Auth.auth().signOut()
                        
                        let initialViewController = UIStoryboard.initialViewController(for: .login)
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = initialViewController
                        self.window?.makeKeyAndVisible()
                        
//                        let loginStoryboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
//                        let initialViewController: UIViewController = loginStoryboard.instantiateViewController(withIdentifier: "Login") as UIViewController
//                        self.window = UIWindow(frame: UIScreen.main.bounds)
//                        self.window?.rootViewController = initialViewController
//                        self.window?.makeKeyAndVisible()
                        
                        
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                    
                default:
                    self.executePasscodeAuthentication()
                }
            }
        }
    }
    func executePasscodeAuthentication(){
        TJBioAuthenticator.shared.authenticateUserWithPasscode(success: {
            
            let initialViewController = UIStoryboard.initialViewController(for: .main)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            //Segue
        }) { (error) in
            
            guard Auth.auth().currentUser != nil else {
                return
            }
            do {
                try Auth.auth().signOut()
                
                let initialViewController = UIStoryboard.initialViewController(for: .login)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }

}

//MARK: - Extension to select according logged user or not
extension AppDelegate {
    func configureInitialRootViewController(for window: UIWindow?) throws {
        let defaults = UserDefaults.standard
        let initialViewController: UIViewController
        
        if Auth.auth().currentUser != nil,
            let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data,
            //let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
            let user = try NSKeyedUnarchiver.unarchivedObject(ofClass: User.self, from: userData){
            
                try User.setCurrent(user)
            
            initialViewController = UIStoryboard.initialViewController(for: .main)
        } else {
            initialViewController = UIStoryboard.initialViewController(for: .login)
        }
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
    }
}

