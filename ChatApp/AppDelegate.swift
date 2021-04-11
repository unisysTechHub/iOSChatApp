//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 27/08/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import UIKit
import AWSAppSync
import Amplify
import AmplifyPlugins
import AWSMobileClient
//guard let idToken = self.cachedLoginsMap.first?.value
extension AWSMobileClient: AWSCognitoUserPoolsAuthProvider {
    public func getLatestAuthToken() -> String {
        return ""
    }
    
    public func getLatestAuthToken(_ callback: @escaping (String?, Error?) -> Void) {
        getTokens { (tokens, error) in
            if error != nil {
                callback(nil, error)
            } else {
                 print("token \(tokens?.idToken?.tokenString)")
                callback(tokens?.idToken?.tokenString, nil)
            }
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var appSyncClient: AWSAppSyncClient?
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
        // You can choose the directory in which AppSync stores its persistent cache databases
            let cacheConfiguration = try AWSAppSyncCacheConfiguration()
            let appSyncServiceConfig = try AWSAppSyncServiceConfig()
            
            do {
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
               try Amplify.configure()
               print("Initialized Amplify");
            } catch {
               print("Could not initialize Amplify: \(error)")
            }
          
            class userPoolAuthProvider : AWSCognitoUserPoolsAuthProvider
            {
                func getLatestAuthToken() -> String {
                    return "test"
                }
                
            }
        // AppSync configuration & client initialization
            
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: appSyncServiceConfig,userPoolsAuthProvider: AWSMobileClient.default(),cacheConfiguration: cacheConfiguration)
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            
            // Set id as the cache key for objects. See architecture section for details
            appSyncClient?.apolloClient?.cacheKeyForObject = { $0["id"] }
        } catch {
            print("Error initializing appsync client. \(error)")
        }
        // Override point for customization after application launch
        Amplify.Logging.logLevel = .debug
        

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

