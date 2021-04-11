//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Ramesh kumar penta on 27/08/20.
//  Copyright © 2020 Ramesh kumar penta. All rights reserved.
//

import UIKit
import SwiftUI
import AWSAppSync
import Combine
import Amplify
import AWSMobileClient

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appSyncClient: AWSAppSyncClient?
    var chatMessageData = ChatMessagesData.shared
    var msgList = Array<Message>()
    var subscriberWatcher : AWSAppSyncSubscriptionWatcher<OnCreateMessageSubscription>?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
//        let contentView = ContentView()
        Amplify.Auth.signOut()

        

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            ( UIApplication.shared.delegate as! AppDelegate).window = window
            window.rootViewController = UIHostingController(rootView: SignIn().environmentObject(chatMessageData))
            self.window = window
            window.makeKeyAndVisible()
            getAppsyncClent()
            AWSMobileClient.default().addUserStateListener(self) { (userState, additionInfo) in
                print("user state changed\(additionInfo["token"])")
               switch userState
               {
               case .signedIn :
                print("Signe in ")
                self.fetchEventFromServer()
               // self.subsribeToMutationEvent()
                self.window?.rootViewController = UIHostingController(rootView: ContentView().environmentObject(self.chatMessageData))
                self.window?.makeKeyAndVisible()

               case .signedOut:
                print("signout")
               case .signedOutFederatedTokensInvalid:
                                print("signedOutFederatedTokensInvalid")
               case .signedOutUserPoolsTokenInvalid:
                print("signedOutFederatedTokensInvalid")

               case .guest:
                print("guest")
               case .unknown:
                print("unknow")
               }
                
            }
           // signInWithWebUI()

        }
       
      //  getAppsyncClent()
        //fetchEventFromServer()
       // subsribeToMutationEvent()
      // mutation()
    }
    func signInWithWebUI() -> AnyCancellable {
        Amplify.Auth.signInWithWebUI(presentationAnchor: ( UIApplication.shared.delegate as! AppDelegate).window!)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("Sign in failed \(authError)")
                }
            }
            receiveValue: { signResult in
                                print("Sign in succeeded \(Amplify.Auth.getCurrentUser()?.username)")
                
                getAppsyncClent()
                self.fetchEventFromServer()

                
            }
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    func fetchEventFromServer() {
        doFetchWithCachePolicy(.fetchIgnoringCacheData)
    }
    
    func doFetchWithCachePolicy(_ cachePolicy: CachePolicy)
    {

        //Run a query
        getAppsyncClent()?.fetch(query: ListMessagesQuery(), cachePolicy: cachePolicy)  { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            result?.data?.listMessages?.items!.forEach { print(($0?.name)! + " " + ($0?.message)!)
                if let name = $0?.name,
                    let id   = $0?.id ,
                    let message  = $0?.message
                {
                    self.msgList.append( Message(id: id, name: name, message: message))
                }
                else
                {
                   
                }
                
              }
            self.chatMessageData.listMessage? = self.msgList
            print("no of message \(self.chatMessageData.listMessage?.count)" )
                 
        }
    }
    
    func mutation()
    {
       

        getAppsyncClent()?.perform(mutation: CreateMessageMutation(input: CreateMessageInput(name: Amplify.Auth.getCurrentUser()?.username, message: "messag from ios app 12345"))) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            else
            {
                print(result?.data?.snapshot["createMessage"])
            }
            
        }
    }
    
    func  subsribeToMutationEvent()
    {
        
        let resultHandler = {   (_ result: GraphQLResult<OnCreateMessageSubscription.Data>?, _ transaction: ApolloStore.ReadWriteTransaction?, _ error: Error?) -> Void
            in
            print("deliveed to subscriber")
                            guard let result = result else
                            {
                             print("result nil")
                                return
                            }
                            guard let resultData = result.data else
                            {
                                print("data nil")
                                return
                            }
                        if let onCreateMessage = resultData.onCreateMessage  {
                                print("@Subscription " + onCreateMessage.name! + " " + onCreateMessage.message!)
                                if let name = onCreateMessage.name,
                                    let message  = onCreateMessage.message
                                {
                                    self.chatMessageData.listMessage?.append(Message(id: String(onCreateMessage.id), name: name, message: message))
                                }

                         }
                            else if let error = error {
                                print(error.localizedDescription)
                            }
                }




        do
        {
            self.subscriberWatcher = try getAppsyncClent()?.subscribe(subscription: OnCreateMessageSubscription( name: "Ramesh", message: "subscriber messae"), resultHandler: resultHandler)
            print( self.subscriberWatcher.debugDescription)

        }
        catch {
                       print("Error starting subscription: \(error.localizedDescription)")

        }
        print("@Subscription ")

        // In your app code
//        do {
//            self.subscriberWatcher = try appSyncClient?.subscribe(subscription: OnCreateMessageSubscription()) { [weak self] result, transaction, error in
//
//                guard let result = result else
//                {
//                 print("result nilt")
//                    return
//                }
//                guard let resultData = result.data else
//                {
//                    print("data nil")
//                    return
//                }
//            if let onCreateMessage = resultData.onCreateMessage  {
//                    print("@Subscription " + onCreateMessage.name! + " " + onCreateMessage.message!)
//                    if let name = onCreateMessage.name,
//                        let message  = onCreateMessage.message
//                    {
//                        self!.chatMessageData.listMessage?.append(Message(id: String(onCreateMessage.id), name: name, message: message))
//                    }
//
//             }
//                else if let error = error {
//                    print(error.localizedDescription)
//                }
//            }
//
//        } catch {
//            print("Error starting subscription: \(error.localizedDescription)")
//        }

        print(self.subscriberWatcher.debugDescription)
    }
}

