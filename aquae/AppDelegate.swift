//
//  AppDelegate.swift
//  aquae
//
//  Created by Pietro Santececca on 17/11/15.
//  Copyright © 2015 Pietro Santececca. All rights reserved.
//

import UIKit
import SKMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SKMapVersioningDelegate {

    var window: UIWindow?
    let API_KEY: String = "be142663d8acbd7e33a0babb3288ff5f7749e576e4d31a8f19b8e47556d3e58f"
    let dbName: String = "aquae.db"
    let criptedDbName: String = "aquaeCripted.db"
    let criptoPassword = "jnkdsafoknamsclviknfsa"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        Util.copyFile(dbName)
//
//        // Encryption
//        let data = NSData(contentsOfFile: Util.getPath(dbName))!
//        let ciphertext = RNCryptor.encryptData(data, password: criptoPassword)
//        ciphertext.writeToFile("/Users/Pietro/Desktop/aquaeCripted.db", atomically: false)
        
        let criptedDbPath: String? = ((Bundle.main.resourcePath)! as NSString).appendingPathComponent(criptedDbName)
        let fileManager = FileManager.default
        if criptedDbPath != nil && fileManager.fileExists(atPath: criptedDbPath!) {
            let criptedDb = try? Data(contentsOf: URL(fileURLWithPath: criptedDbPath!))
            if criptedDb != nil {
                
                // Decryption
                do {
                    let encriptedDb = try RNCryptor.decrypt(data: criptedDb!, withPassword: criptoPassword)
                    if !((try? encriptedDb.write(to: URL(fileURLWithPath: Util.getPath(dbName)), options: [])) != nil) {
                        print("Error during db file writing")
                    }
                }
                catch {
                    print("Error during db encripting")
                }
            }
        }
        
        let initSettings: SKMapsInitSettings = SKMapsInitSettings()
        initSettings.connectivityMode = SKConnectivityMode.offline
        initSettings.mapDetailLevel = SKMapDetailLevel.light
        SKMapsService.sharedInstance().initializeSKMaps(withAPIKey: API_KEY, settings: initSettings)
        SKPositionerService.sharedInstance().startLocationUpdate()
        SKMapsService.sharedInstance().mapsVersioningManager.delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

